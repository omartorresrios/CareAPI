class NewDoctorSerializer < ActiveModel::Serializer
  attributes :id, :authentication_token
  
  def authentication_token
    object.generate_auth_token(object.id)
  end
end
