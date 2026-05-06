class StapleMetric < ApplicationRecord
  belongs_to :staple

  validates :staple_id, uniqueness: true
  validates :calories_kcal_per_100g, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :metrics_confidence, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }, allow_nil: true
end
