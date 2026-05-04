class FeatureWeights
  WEIGHTS = {
    "Staple" => 10.0,
    "StapleAlias" => 8.0,
    "Ingredient" => 5.0,
    "IngredientFamily" => 3.5,
    "Form" => 4.0,
    "Shape" => 3.0,
    "ProcessingMethod" => 3.5,
    "CookingMethod" => 3.5,
    "Texture" => 2.0,
    "Region" => 1.5,
    "CountryArea" => 1.5,
    "ServingStyle" => 1.0,
    "StapleLevel" => 1.0,
    "SearchKeyword" => 0.8
  }.freeze

  def self.for(type)
    WEIGHTS.fetch(type)
  end
end
