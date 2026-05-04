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

    assert_equal 3, Staple.count
    gohan = Staple.find_by!(name_ja: "ご飯")
    assert_equal false, gohan.fermented
    assert_equal "米を炊いた最も基本的な主食形態", gohan.description
    assert_equal "https://example.com/rice", gohan.source_url
    assert_equal BigDecimal("0.9"), gohan.confidence
    assert_equal "starter", gohan.review_status

    idli = Staple.find_by!(name_ja: "イドゥリ")
    assert_equal true, idli.fermented
    assert_equal "南インドの発酵生地を蒸した主食", idli.description
    assert_includes idli.processing_methods.map(&:name_en), "発酵"
    assert_includes idli.cooking_methods.map(&:name_en), "蒸す"

    ingredient = Ingredient.find_by!(name_en: "rice")
    assert_not_nil ingredient.ingredient_family

    counts = {
      staples: Staple.count,
      ingredient_families: IngredientFamily.count,
      ingredients: Ingredient.count,
      taggings: Tagging.count,
      staple_aliases: StapleAlias.count,
      search_terms: SearchTerm.count,
      search_keywords: SearchKeyword.count
    }

    importer.call

    assert_equal counts[:staples], Staple.count
    assert_equal counts[:ingredient_families], IngredientFamily.count
    assert_equal counts[:ingredients], Ingredient.count
    assert_equal counts[:taggings], Tagging.count
    assert_equal counts[:staple_aliases], StapleAlias.count
    assert_equal counts[:search_terms], SearchTerm.count
    assert_equal counts[:search_keywords], SearchKeyword.count
  end
end
