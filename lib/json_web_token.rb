class JsonWebToken
  def self.encode(payload)
    JWT.encode(payload, Rails.application.secrets.secret_key_base)
  end
   def self.decode(token)
     credentials = JSON.parse(File.read("config/secrets/firebase-adminsdk-care-project.json"))
     public_key = OpenSSL::PKey::RSA.new credentials["private_key"]
    begin
      HashWithIndifferentAccess.new(JWT.decode(token, nil).first)
    rescue
      nil
    end
  end
end
