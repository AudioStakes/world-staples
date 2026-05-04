class Ingredient < ApplicationRecord
  include Taggable
  belongs_to :ingredient_family, optional: true
  validates :name_en, presence: true
end
