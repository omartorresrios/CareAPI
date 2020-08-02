class AddWeightToPatient < ActiveRecord::Migration[6.0]
  def change
    add_column :patients, :weight, :string
  end
end
