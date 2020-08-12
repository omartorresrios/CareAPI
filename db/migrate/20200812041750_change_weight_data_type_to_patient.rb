class ChangeWeightDataTypeToPatient < ActiveRecord::Migration[6.0]
  def self.up
    change_column :patients, :weight, :float, using: 'weight::float'
  end

  def self.down
    change_column :patients, :weight, :string
  end
end
