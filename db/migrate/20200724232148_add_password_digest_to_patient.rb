class AddPasswordDigestToPatient < ActiveRecord::Migration[6.0]
  def change
    add_column :patients, :password_digest, :string
  end
end
