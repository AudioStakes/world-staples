class IngredientFamily < ApplicationRecord
  include Taggable
  has_many :ingredients, dependent: :nullify
  validates :name_en, presence: true
end
