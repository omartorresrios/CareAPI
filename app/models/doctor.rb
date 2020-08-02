class Doctor < ApplicationRecord
  has_many :carings, dependent: :destroy
  has_many :patients, through: :carings
end
