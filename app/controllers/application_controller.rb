require 'jwt'
require 'net/http'

class ApplicationController < ActionController::API

  include ActionController::HttpAuthentication::Token::ControllerMethods
  attr_reader :current_patient

  def authenticate_user!
    credentials = JSON.parse(File.read("config/secrets/firebase-adminsdk-care-project.json"))
    project_id = credentials["project_id"]

    certificate = "-----BEGIN CERTIFICATE-----\nMIIDHDCCAgSgAwIBAgIIcYOBxdgv20wwDQYJKoZIhvcNAQEFBQAwMTEvMC0GA1UE\nAxMmc2VjdXJldG9rZW4uc3lzdGVtLmdzZXJ2aWNlYWNjb3VudC5jb20wHhcNMjAx\nMjE1MDkyMDExWhcNMjAxMjMxMjEzNTExWjAxMS8wLQYDVQQDEyZzZWN1cmV0b2tl\nbi5zeXN0ZW0uZ3NlcnZpY2VhY2NvdW50LmNvbTCCASIwDQYJKoZIhvcNAQEBBQAD\nggEPADCCAQoCggEBALCJi7xqry88tJOn0sluSRAXjERc8uWZnbdp3BhvvNVGh1jp\nLQ83njFs/v8G7NwupgihNkCV9B5IyzJAUnCNPFC085sQUsNbUhestj18NGIvIrOm\nmU2U8/Oe9tzMCCdTtKcFhVkcaoT5usBpakOT/pi6UxwzN1T/TH+9RTJcvc9g0M1m\noUT6pPBMtl6cph4Gba7mJw2n6uZpgG5c4v0y42KcgwwIHn+U6jbTFnUXxwOSX6Sm\n7N+JThkt4YIvCrbMf2o0PoRM0II//5c4aWrsWI5hrgIRTns4wq7K3VssHQyjigl+\nm181J4fcw9XM4XrDU92ICd+VPduRXp2JO4as6vcCAwEAAaM4MDYwDAYDVR0TAQH/\nBAIwADAOBgNVHQ8BAf8EBAMCB4AwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwIwDQYJ\nKoZIhvcNAQEFBQADggEBAFTU2phg+MEJrWi1SVUR1eqP6qmvGavBVXl8kAPY9B0d\n1bNwbovj8WM6MFQQm6K/mCys5LA7iTMPu0B9duFhmpX9M8g/1TJ6hUmstw6scr38\nYBrhJulQ7HCbUTaI7+yPcSdT7WHXSnYvF/1fOFWaE8vVL9ZtM0DE/ldqx/MetvdQ\nWZWEkm6SEpLf3bKweza2PK/3RHtER8l/iV0KCdkh8Dugnf58QYVcsmy5wZkvXKII\n2qMl0e9y7wGTW9OvxQFpr4HB1T982r9M56a4TTMTCC8+KWJ/i34DmVro1Ngb+jOp\nu7cfh/Z2ahSym5asBz66UOk29W0nk3y4HeNCVwD+CZg=\n-----END CERTIFICATE-----\n"
    cert = OpenSSL::X509::Certificate.new(certificate)

    decode(http_token, cert.public_key, project_id) || render_unauthorized
  end

  VALID_JWT_PUBLIC_KEYS_RESPONSE_CACHE_KEY = "firebase_phone_jwt_public_keys_cache_key"
  JWT_ALGORITHM = 'RS256'

  # def initialize(firebase_project_id)
  #   @firebase_project_id = firebase_project_id
  # end

  def decode(id_token, public_key, project_id)
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
    logger.debug "kid: #{kid}"
    unless valid_public_keys.keys.include?(kid)
      raise "Invalid access token 'kid' header, do not correspond to valid public keys."
    end

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
    decoded_token, error = decode_jwt_token(id_token, project_id, public_key)
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
      decoded_token = JWT.decode(firebase_jwt_token, public_key, !public_key.nil?, custom_options)
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
    logger.debug "decoded_token: #{decoded_token}"
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
