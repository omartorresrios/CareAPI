class CreateCarings < ActiveRecord::Migration[6.0]
  def change
    create_table :carings do |t|
      t.references :patient, null: false, foreign_key: true
      t.references :doctor, null: false, foreign_key: true

      t.timestamps
    end
  end
end
