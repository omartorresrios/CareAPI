class Doctors::SessionsController < ApplicationController
  def create
    doctor = Doctor.find_by(email: params[:email])
    if doctor = Doctor.authenticate(email_or_name, params[:password])
      render json: doctor, serializer: NewDoctorSerializer, status: 200
    else
      render json: { errors: ['Invalid email and password'] }, status: 422
    end
  end

  private

    def email_or_name
      params[:email]
    end
end
