class NewPatientSerializer < ActiveModel::Serializer
  attributes :id, :authentication_token

  def signals_by_month
    object.signals_by_month
  end

  def authentication_token
    object.generate_auth_token(object.id)
  end
end
