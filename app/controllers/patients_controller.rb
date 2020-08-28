class PatientsController < ApplicationController
  before_action :set_patient
  before_action :authenticate_user!

  def get_patient_info
    @patient = Patient.find_by(id: params[:id])
    render json: @patient, serializer: PatientSerializer, status: 201
  end

  private

    def set_patient
      @patient = Patient.find(params[:id])
    end
end
