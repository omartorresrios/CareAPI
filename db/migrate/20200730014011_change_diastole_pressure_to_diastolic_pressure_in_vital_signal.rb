class ChangeDiastolePressureToDiastolicPressureInVitalSignal < ActiveRecord::Migration[6.0]
  def change
    rename_column :vital_signals, :diastole_pressure, :diastolic_pressure
  end
end
