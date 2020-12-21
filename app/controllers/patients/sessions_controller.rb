class Patients::SessionsController < ApplicationController
  def create
    patient = Patient.find_by(email: params[:email])
    if patient = Patient.authenticate(email_or_name, params[:password])
      render json: patient, serializer: NewPatientSerializer, status: 200
    else
      render json: { errors: ['Invalid email and password'] }, status: 422
    end
  end

  private

    def email_or_name
      params[:email]
    end
end
