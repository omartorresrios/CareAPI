class RemoveDiagnosisTypeFromPatient < ActiveRecord::Migration[6.0]
  def change
    remove_column :patients, :diagnosis_type, :string
  end
end
