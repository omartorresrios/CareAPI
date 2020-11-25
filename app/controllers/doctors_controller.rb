class DoctorsController < ApplicationController
  before_action :set_doctor
  before_action :authenticate_user!

  def get_patients
     @patients = @doctor.patients.all
    render json: @patients, status: 200
  end

  private

    def set_doctor
      @doctor = Doctor.find(params[:id])
    end
end
