require "test_helper"

class Imports::IngredientMetricsImporterTest < ActiveSupport::TestCase
  test "imports existing ingredient metric and is idempotent/updateable" do
    ingredient = Ingredient.create!(name_en: "rice")
    path = Rails.root.join("tmp/ingredient_metrics_importer_existing.csv")
    File.write(path, "ingredient_name_en,ingredient_name_ja,ingredient_family,price_level,calories_kcal_per_100g_basic,confidence\nrice,米,grain_legume,low,168,0.80\n")

    importer = Imports::IngredientMetricsImporter.new(path: path)
    importer.call
    metric = IngredientMetric.find_by!(ingredient: ingredient)
    assert_equal "米", ingredient.reload.name_ja
    assert_equal "grain_legume", metric.ingredient_family
    assert_equal "low", metric.price_level
    assert_equal 0, IngredientFamily.where(name_en: "grain_legume").count

    File.write(path, "ingredient_name_en,ingredient_name_ja,ingredient_family,price_level,calories_kcal_per_100g_basic,confidence\nrice,コメ,grain_legume,medium,170,0.90\n")
    assert_no_difference("IngredientMetric.count") { importer.call }
    metric.reload
    assert_equal "medium", metric.price_level
    assert_equal 170.0, metric.calories_kcal_per_100g_basic.to_f
    assert_equal 0.9, metric.confidence.to_f
    assert_equal "米", ingredient.reload.name_ja
  end

  test "skip missing ingredient row" do
    path = Rails.root.join("tmp/ingredient_metrics_importer_skip.csv")
    File.write(path, "ingredient_name_en,ingredient_name_ja\nnoodles,麺\n")

    assert_no_difference("Ingredient.count") do
      assert_no_difference("IngredientMetric.count") do
        Imports::IngredientMetricsImporter.new(path: path).call
      end
    end
  end

  test "invalid decimal errors include row and column" do
    ingredient = Ingredient.create!(name_en: "wheat", name_ja: "小麦")
    path = Rails.root.join("tmp/ingredient_metrics_importer_bad.csv")
    File.write(path, "ingredient_name_en,calories_kcal_per_100g_basic,confidence\nwheat,abc,0.8\n")
    err = assert_raises(ArgumentError) { Imports::IngredientMetricsImporter.new(path: path).call }
    assert_match(/row 2/, err.message)
    assert_match(/calories_kcal_per_100g_basic/, err.message)

    File.write(path, "ingredient_name_en,calories_kcal_per_100g_basic,confidence\nwheat,120,ng\n")
    err2 = assert_raises(ArgumentError) { Imports::IngredientMetricsImporter.new(path: path).call }
    assert_match(/row 2/, err2.message)
    assert_match(/confidence/, err2.message)
  end
end
