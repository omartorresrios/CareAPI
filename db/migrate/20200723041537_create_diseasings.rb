class CreateDiseasings < ActiveRecord::Migration[6.0]
  def change
    create_table :diseasings do |t|
      t.references :disease, null: false, foreign_key: true
      t.references :patient, null: false, foreign_key: true

      t.timestamps
    end
  end
end
