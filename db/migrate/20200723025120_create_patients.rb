class CreatePatients < ActiveRecord::Migration[6.0]
  def change
    create_table :patients do |t|
      t.string :name
      t.integer :age
      t.string :email
      t.string :gender
      t.string :phone
      t.float :height
      t.string :diagnosis
      t.string :type
      t.string :avatar

      t.timestamps
    end
  end
end
