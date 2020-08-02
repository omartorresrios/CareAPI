class VitalSignalSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :respiratory_rate, :heart_rate, :temperature, :diastolic_pressure, :systolic_pressure
end
