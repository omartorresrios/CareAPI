class DoctorSerializer < ActiveModel::Serializer
  attributes :id, :authentication_token, :first_name, :last_name, :email, :specialty, :avatar

  def authentication_token
    object.generate_auth_token(object.id)
  end
end
