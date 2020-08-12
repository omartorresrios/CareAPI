class PatientSerializer < ActiveModel::Serializer
  attributes :id, :authentication_token, :name, :email, :gender, :age, :phone, :height, :weight, :diagnosis, :avatar

  has_many :vital_signals, serializer: VitalSignalSerializer

  def authentication_token
    object.generate_auth_token(object.id)
  end
end
