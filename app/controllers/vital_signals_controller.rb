class VitalSignalsController < ApplicationController
  before_action :authenticate_patient!

  def new
    vital_signal = VitalSignal.new
  end

  def create
    vital_signal = current_patient.vital_signals.build(vital_signal_params)
    if vital_signal.save
      render json: vital_signal, serializer: VitalSignalSerializer, status: 201
    else
      render json: { errors: vital_signal.errors.full_messages }, status: 422
    end
  end

  private

  def vital_signal_params
    params.require(:vital_signal).permit(:respiratory_rate, :heart_rate, :temperature, :diastolic_pressure, :systolic_pressure)
  end

end
