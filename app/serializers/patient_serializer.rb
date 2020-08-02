class PatientSerializer < ActiveModel::Serializer
  attributes :id, :authentication_token, :name, :age, :email, :gender, :phone, :height, :diagnosis, :avatar

  has_many :vital_signals, serializer: VitalSignalSerializer
  
  def authentication_token
    object.generate_auth_token(object.id)
  end
end
