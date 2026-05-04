require "test_helper"

class Imports::StapleCatalogImporterTest < ActiveSupport::TestCase
  test "raises clear error when file missing" do
    importer = Imports::StapleCatalogImporter.new(path: Rails.root.join("tmp/missing.csv"))
    assert_raises(ArgumentError) { importer.call }
  end

  test "imports fixture csv idempotently" do
    path = Rails.root.join("test/fixtures/files/staple_catalog.csv")
    importer = Imports::StapleCatalogImporter.new(path: path)

    importer.call
    importer.call

    assert_equal 3, Staple.count
    assert_equal false, Staple.find_by(name_ja: "ご飯").fermented
    assert_equal "米を炊いた最も基本的な主食形態", Staple.find_by(name_ja: "ご飯").description
    assert_equal "https://www.fao.org/4/U8480E/U8480E07.htm", Staple.find_by(name_ja: "ご飯").source_url
    assert_equal BigDecimal("0.9"), Staple.find_by(name_ja: "ご飯").confidence
    assert_equal "starter", Staple.find_by(name_ja: "ご飯").review_status

    assert_operator IngredientFamily.count, :>=, 1
    ingredient = Ingredient.find_by(name_en: "rice")
    assert_not_nil ingredient
    assert_not_nil ingredient.ingredient_family

    assert_operator Tagging.count, :>, 0
    assert_operator StapleAlias.count, :>, 0
    assert_operator SearchTerm.count, :>, 0

    assert_equal 3, Staple.count
    assert_equal 1, Ingredient.where(name_en: "rice").count
    assert_equal Tagging.count, Tagging.distinct.count
  end
end
