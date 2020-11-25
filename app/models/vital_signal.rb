class VitalSignal < ApplicationRecord
  belongs_to :patient

  validates :respiratory_rate, presence: true
  validates :heart_rate, presence: true
  validates :temperature, presence: true
  validates :diastolic_pressure, presence: true
  validates :systolic_pressure, presence: true

  # after_save :convert_date_time
  # scope :signals_by_month, -> { where(created_at: strftime("%B")) }
  # before_save { |vital_signal| vital_signal.created_at = vital_signal.created_at.strftime("%H:%M") }
  #
  def signals_by_day
    signals_by_month = VitalSignal.find(:all).group_by { |signal| signal.created_at.strftime("%B") }
    signals_by_month
  end

  def convert_date_time
    self.created_at = self.created_at.strftime("%H:%M")
  end

end
