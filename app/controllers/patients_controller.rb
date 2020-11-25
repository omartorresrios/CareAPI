class PatientsController < ApplicationController
  before_action :set_patient
  before_action :authenticate_user!

  def get_patient_info
    @patient = Patient.find_by(id: params[:id])
    render json: @patient, serializer: PatientSerializer, status: 201
  end

  def get_doctors
    @doctors = Doctor.all
    render json: @doctors, status: 200
  end

  def assign_patient_to_doctor
    @doctor = Doctor.find_by(id: params[:doctor_id])
    @patient = Patient.find_by(id: params[:id])
    @doctor.patients << @patient
  end

  private

    def set_patient
      @patient = Patient.find(params[:id])
    end
end
