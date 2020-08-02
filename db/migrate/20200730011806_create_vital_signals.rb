class CreateVitalSignals < ActiveRecord::Migration[6.0]
  def change
    create_table :vital_signals do |t|
      t.float :respiratory_rate
      t.float :heart_rate
      t.float :temperature
      t.float :diastole_pressure
      t.float :systolic_pressure

      t.timestamps
    end
  end
end
