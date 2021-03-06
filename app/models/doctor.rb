class Doctor < ApplicationRecord
  has_many :carings, dependent: :destroy
  has_many :patients, through: :carings
  has_secure_password

  EMAIL_REGEX = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

  validates :email, presence: true, uniqueness: { case_sensitive: false }#, format: { with: EMAIL_REGEX }
  validates :first_name, presence: true
  validates :last_name, presence: true

  def self.authenticate(email_or_name, password)
    doctor = Doctor.find_by(email: email_or_name)
    doctor && doctor.authenticate(password)
  end

  def generate_auth_token(uid)
    begin
      now_seconds = Time.now.to_i
      credentials = JSON.parse(File.read("config/secrets/firebase-adminsdk-care-project.json"))
      private_key = OpenSSL::PKey::RSA.new credentials["private_key"]
      payload = {
          :iss => credentials["client_email"],
          :sub => credentials["client_email"],
          :aud => 'https://identitytoolkit.googleapis.com/google.identity.identitytoolkit.v1.IdentityToolkit',
          :iat => now_seconds,
          :exp => now_seconds+(60*60),
          :uid => uid.to_s,
          :claims => {:premium_account => true}
        }
      JWT.encode(payload, private_key, 'RS256')
    rescue
      nil
    end
  end
end
