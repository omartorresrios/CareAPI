class ApplicationController < ActionController::API

  include ActionController::HttpAuthentication::Token::ControllerMethods
  attr_reader :current_patient

  def authenticate_patient!
    authenticate_patient_from_token || render_unauthorized
  end

  protected

    def authenticate_patient_from_token
      if patient_id_in_token?
        @current_patient ||= Patient.find_by(id: auth_token[:patient_id])
      else
        nil
      end
    end

    def render_unauthorized
      self.headers['WWW-Authenticate'] = 'Token realm="Application"'
      render json: { errors:  ['Bad credentials'] }, status: 401
    end

    def patient_id_in_token?
      http_token && auth_token && auth_token[:patient_id]
    end

    def http_token
      authenticate_with_http_token do |token|
        @http_token = token
      end
    end

    def auth_token
      begin
        @auth_token ||=  JsonWebToken.decode(http_token)
      rescue JWT::VerificationError, JWT::DecodeError
        return nil
      end
    end

end
