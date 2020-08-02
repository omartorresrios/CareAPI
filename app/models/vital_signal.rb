class VitalSignal < ApplicationRecord
  belongs_to :patient

  validates :respiratory_rate, presence: true
  validates :heart_rate, presence: true
  validates :temperature, presence: true
  validates :diastolic_pressure, presence: true
  validates :systolic_pressure, presence: true
  
end
