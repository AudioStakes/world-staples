class Staple < ApplicationRecord
  has_many :taggings, dependent: :destroy
  has_many :staple_aliases, dependent: :destroy
  has_many :search_terms, dependent: :destroy

  has_many :ingredient_family_taggings, -> { where(taggable_type: "IngredientFamily") }, class_name: "Tagging"
  has_many :ingredient_families, through: :ingredient_family_taggings, source: :taggable, source_type: "IngredientFamily"
  has_many :ingredient_taggings, -> { where(taggable_type: "Ingredient") }, class_name: "Tagging"
  has_many :ingredients, through: :ingredient_taggings, source: :taggable, source_type: "Ingredient"
  has_many :form_taggings, -> { where(taggable_type: "Form") }, class_name: "Tagging"
  has_many :forms, through: :form_taggings, source: :taggable, source_type: "Form"
  has_many :shape_taggings, -> { where(taggable_type: "Shape") }, class_name: "Tagging"
  has_many :shapes, through: :shape_taggings, source: :taggable, source_type: "Shape"
  has_many :processing_method_taggings, -> { where(taggable_type: "ProcessingMethod") }, class_name: "Tagging"
  has_many :processing_methods, through: :processing_method_taggings, source: :taggable, source_type: "ProcessingMethod"
  has_many :cooking_method_taggings, -> { where(taggable_type: "CookingMethod") }, class_name: "Tagging"
  has_many :cooking_methods, through: :cooking_method_taggings, source: :taggable, source_type: "CookingMethod"
  has_many :texture_taggings, -> { where(taggable_type: "Texture") }, class_name: "Tagging"
  has_many :textures, through: :texture_taggings, source: :taggable, source_type: "Texture"
  has_many :region_taggings, -> { where(taggable_type: "Region") }, class_name: "Tagging"
  has_many :regions, through: :region_taggings, source: :taggable, source_type: "Region"
  has_many :country_area_taggings, -> { where(taggable_type: "CountryArea") }, class_name: "Tagging"
  has_many :country_areas, through: :country_area_taggings, source: :taggable, source_type: "CountryArea"
  has_many :serving_style_taggings, -> { where(taggable_type: "ServingStyle") }, class_name: "Tagging"
  has_many :serving_styles, through: :serving_style_taggings, source: :taggable, source_type: "ServingStyle"
  has_many :staple_level_taggings, -> { where(taggable_type: "StapleLevel") }, class_name: "Tagging"
  has_many :staple_levels, through: :staple_level_taggings, source: :taggable, source_type: "StapleLevel"
  has_many :search_keyword_taggings, -> { where(taggable_type: "SearchKeyword") }, class_name: "Tagging"
  has_many :search_keywords, through: :search_keyword_taggings, source: :taggable, source_type: "SearchKeyword"

  validates :name_ja, presence: true
  validates :source_id, presence: true, uniqueness: true
end
