class AddPatientToVitalSignals < ActiveRecord::Migration[6.0]
  def change
    add_reference :vital_signals, :patient, null: false, foreign_key: true
  end
end
