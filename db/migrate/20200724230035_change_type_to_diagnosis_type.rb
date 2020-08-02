class ChangeTypeToDiagnosisType < ActiveRecord::Migration[6.0]
  def change
    rename_column :patients, :type, :diagnosis_type
  end
end
