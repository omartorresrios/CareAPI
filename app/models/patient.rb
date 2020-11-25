class Patient < ApplicationRecord
  has_many :diseasings, dependent: :destroy
  has_many :carings, dependent: :destroy
  has_many :diseases, through: :diseasings
  has_many :doctors, through: :carings
  has_many :vital_signals, dependent: :destroy
  has_secure_password

  EMAIL_REGEX = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

  validates :email, presence: true, uniqueness: { case_sensitive: false }#, format: { with: EMAIL_REGEX }
  validates :first_name, presence: true
  validates :last_name, presence: true

  mount_uploader :avatar, AvatarUploader

  # has_attached_file :avatar, styles: { medium: "300x300>", thumb: "100x100>" }
  # validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\z/

  # before_save :decode_avatar_data

  def self.authenticate(email_or_name, password)
    patient = Patient.find_by(email: email_or_name)
    patient && patient.authenticate(password)
  end

  def signals_by_month
    by_month = vital_signals.group_by { |signal| signal.created_at.strftime("%B") }

    by_month.each do |month, values|
      ajaa = values.group_by { |signal| signal.created_at.strftime("%D") }
      logger.debug "ajaa: #{ajaa}"
      ajaa
    end
  end

  # def decode_avatar_data
  #   # If avatar_data is present, it means that we were sent an avatar over
  #   # JSON and it needs to be decoded.  After decoding, the avatar is processed
  #   # normally via Paperclip.
  #   if self.avatar_data.present?
  #     data = StringIO.new(Base64.decode64(self.avatar_data))
  #     data.class.class_eval {attr_accessor :original_filename, :content_type}
  #     data.original_filename = self.id.to_s + ".png"
  #     data.content_type = "image/png"
  #
  #     self.avatar = data
  #   end
  # end

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
