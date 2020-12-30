require 'jwt'
require 'net/http'

class ApplicationController < ActionController::API

  include ActionController::HttpAuthentication::Token::ControllerMethods
  attr_reader :current_patient

  def authenticate_user!
    credentials = JSON.parse(File.read("config/secrets/firebase-adminsdk-care-project.json"))
    project_id = credentials["project_id"]
    decode(http_token, project_id) || render_unauthorized
  end

  VALID_JWT_PUBLIC_KEYS_RESPONSE_CACHE_KEY = "firebase_phone_jwt_public_keys_cache_key"
  JWT_ALGORITHM = 'RS256'

  def decode(id_token, project_id)
    decoded_token, error = decode_jwt_token(id_token, project_id, nil)
    unless error.nil?
      raise error
    end

    # Decoded data example:
    # [
    #   {"data"=>"test"}, # payload
    #   {"typ"=>"JWT", "alg"=>"none"} # header
    # ]
    payload = decoded_token[0]
    headers = decoded_token[1]

    # validate headers

    alg = headers['alg']
    if alg != JWT_ALGORITHM
      raise "Invalid access token 'alg' header (#{alg}). Must be '#{JWT_ALGORITHM}'."
    end

    valid_public_keys = retrieve_and_cache_jwt_valid_public_keys

    kid = headers['kid']

    unless valid_public_keys.keys.include?(kid)
      raise "Invalid access token 'kid' header, do not correspond to valid public keys."
    end

    rsa_public = OpenSSL::X509::Certificate.new(valid_public_keys.values[0])
    # validate payload

    # We are going to validate Subject ('sub') data only
    # because others params are validated above via 'resque' statement,
    # but we can't do the same with 'sub' there.
    # Must be a non-empty string and must be the uid of the user or device.
    sub = payload['sub']
    user_id = payload['user_id']
    if sub.nil? || sub.empty?
      raise "Invalid access token. 'Subject' (sub) must be a non-empty string."
    end
    if !user_id.nil?
      @current_patient ||= Patient.find_by(id: user_id)
    end

    # validate signature
    #
    # for this we need to decode one more time, but now with cert public key
    # More info: https://github.com/jwt/ruby-jwt/issues/216
    #
    decoded_token, error = decode_jwt_token(id_token, project_id, rsa_public)
    if decoded_token.nil?
      raise error
    end

    decoded_token
  end

  def decode_jwt_token(firebase_jwt_token, firebase_project_id, public_key)
    # Now we decode JWT token and validate
    # Validation rules:
    # https://firebase.google.com/docs/auth/admin/verify-id-tokens#verify_id_tokens_using_a_third-party_jwt_library

    custom_options = {
      :verify_iat => true,
      :verify_aud => true,
      :aud => firebase_project_id,
      :verify_iss => true,
      :iss => "https://securetoken.google.com/"+firebase_project_id,
      :verify_expiration => false
    }

    unless public_key.nil?
      custom_options[:algorithm] = JWT_ALGORITHM
    end

    begin
      decoded_token = JWT.decode(firebase_jwt_token, public_key, false, custom_options)
    rescue JWT::ExpiredSignature
      # Handle Expiration Time Claim: bad 'exp'
      return nil, "Invalid access token. 'Expiration time' (exp) must be in the future."
    rescue JWT::InvalidIatError
      # Handle Issued At Claim: bad 'iat'
      return nil, "Invalid access token. 'Issued-at time' (iat) must be in the past."
    rescue JWT::InvalidAudError
      # Handle Audience Claim: bad 'aud'
      return nil, "Invalid access token. 'Audience' (aud) must be your Firebase project ID, the unique identifier for your Firebase project."
    rescue JWT::InvalidIssuerError
      # Handle Issuer Claim: bad 'iss'
      return nil, "Invalid access token. 'Issuer' (iss) Must be 'https://securetoken.google.com/<projectId>', where <projectId> is your Firebase project ID."
    rescue JWT::VerificationError
      # Handle Signature verification fail
      return nil, "Invalid access token. Signature verification failed."
    end
    return decoded_token, nil
  end

  def render_unauthorized
      self.headers['WWW-Authenticate'] = 'Token realm="Application"'
      render json: { errors:  ['Bad credentials'] }, status: 401
    end

  def http_token
    authenticate_with_http_token do |token|
      @http_token = token
    end
  end

  def retrieve_and_cache_jwt_valid_public_keys
    # Get valid JWT public keys and save to cache
    #
    # Must correspond to one of the public keys listed at
    # https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com
    valid_public_keys = Rails.cache.read(VALID_JWT_PUBLIC_KEYS_RESPONSE_CACHE_KEY)
    if valid_public_keys.nil?
      uri = URI("https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com")
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
      req = Net::HTTP::Get.new(uri.path)
      response = https.request(req)
      if response.code != '200'
        raise "Something went wrong: can't obtain valid JWT public keys from Google."
      end
      valid_public_keys = JSON.parse(response.body)

      cc = response["cache-control"] # format example: Cache-Control: public, max-age=24442, must-revalidate, no-transform
      max_age = cc[/max-age=(\d+?),/m, 1] # get something between 'max-age=' and ','

      Rails.cache.write(VALID_JWT_PUBLIC_KEYS_RESPONSE_CACHE_KEY, valid_public_keys, :expires_in => max_age.to_i)
    end
    valid_public_keys
  end

end
