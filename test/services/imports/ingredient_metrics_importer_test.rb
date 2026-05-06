require "test_helper"

class Imports::IngredientMetricsImporterTest < ActiveSupport::TestCase
  test "skips missing ingredient and does not create" do
    path = Rails.root.join("tmp/ingredient_metrics_importer_skip.csv")
    File.write(path, "ingredient_name_en,ingredient_name_ja\nnoodles,麺\n")

    assert_no_difference("Ingredient.count") do
      Imports::IngredientMetricsImporter.new(path: path).call
    end
  end

  test "fills name_ja when ingredient exists" do
    ingredient = Ingredient.create!(name_en: "rice")
    path = Rails.root.join("tmp/ingredient_metrics_importer_existing.csv")
    File.write(path, "ingredient_name_en,ingredient_name_ja,ingredient_family\nrice,米,grain_legume\n")

    Imports::IngredientMetricsImporter.new(path: path).call
    assert_equal "米", ingredient.reload.name_ja
    assert IngredientMetric.exists?(ingredient: ingredient)
    assert_equal 0, IngredientFamily.where(name_en: "grain_legume").count
  end
end
