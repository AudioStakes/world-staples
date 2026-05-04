class Region < ApplicationRecord
  include Taggable
  belongs_to :parent_region, class_name: "Region", optional: true
  has_many :child_regions, class_name: "Region", foreign_key: :parent_region_id, dependent: :nullify, inverse_of: :parent_region
  validates :name_en, presence: true
end
