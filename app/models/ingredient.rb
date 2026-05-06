class Ingredient < ApplicationRecord
  include Taggable
  belongs_to :ingredient_family, optional: true
  has_one :ingredient_metric, dependent: :destroy
  validates :name_en, presence: true
end
