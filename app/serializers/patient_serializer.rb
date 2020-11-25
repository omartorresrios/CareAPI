class PatientSerializer < ActiveModel::Serializer
  attributes :id, :authentication_token, :first_name, :last_name, :email, :gender, :age, :phone, :height, :weight, :diagnosis, :avatar, :signals_by_month

  def signals_by_month
    object.signals_by_month
  end

  def authentication_token
    object.generate_auth_token(object.id)
  end
end
