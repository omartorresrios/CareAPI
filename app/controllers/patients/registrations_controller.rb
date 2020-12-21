class Patients::RegistrationsController < ApplicationController
  def create

    patient = Patient.new(patient_params)
    if patient.save
      render json: patient, serializer: NewPatientSerializer, status: 201
    else
      render json: { errors: patient.errors.full_messages }, status: 422
    end
  end

  private

    def patient_params
      params.permit(:first_name, :last_name, :email, :password, :gender, :age)
    end
end
