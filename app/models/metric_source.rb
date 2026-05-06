class MetricSource < ApplicationRecord
  validates :source_name, presence: true, uniqueness: true
end
