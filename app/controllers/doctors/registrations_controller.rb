class Doctors::RegistrationsController < ApplicationController
  def create

    doctor = Doctor.new(doctor_params)
    if doctor.save
      render json: doctor, serializer: DoctorSerializer, status: 201
    else
      render json: { errors: doctor.errors.full_messages }, status: 422
    end
  end

  private

    def doctor_params
      params.permit(:first_name, :last_name, :email, :password, :specialty, :avatar)
    end
end
