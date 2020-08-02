class Disease < ApplicationRecord
  has_many :diseasings, dependent: :destroy
  has_many :patients, through: :diseasings
end
