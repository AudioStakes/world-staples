class IngredientMetric < ApplicationRecord
  belongs_to :ingredient

  validates :ingredient_id, uniqueness: true
  validates :ingredient_name_en, presence: true
  validates :calories_kcal_per_100g_basic, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :confidence, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }, allow_nil: true
end
