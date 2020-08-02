class CreateDoctors < ActiveRecord::Migration[6.0]
  def change
    create_table :doctors do |t|
      t.string :name
      t.string :email
      t.string :avatar

      t.timestamps
    end
  end
end
