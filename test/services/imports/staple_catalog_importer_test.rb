require "test_helper"
require "fileutils"

class Imports::StapleCatalogImporterTest < ActiveSupport::TestCase
  FakeSheet = Struct.new(:rows) do
    def row(i) = rows[i - 1]
    def last_row = rows.size
  end

  test "raises clear error when file missing" do
    importer = Imports::StapleCatalogImporter.new(path: Rails.root.join("tmp/missing.xlsx"))
    assert_raises(ArgumentError) { importer.call }
  end

  test "imports idempotently" do
    headers = %w[name_ja name_en local_name ingredient_family base_ingredients form shape processing cooking_method texture region country_area served_with staple_level search_keywords similar_foods]
    values = ["ご飯", "Rice", "Gohan", "cereal", "rice", "porridge", "grain", "milling", "boiling", "sticky", "East Asia", "Japan", "with soup", "primary_staple", "daily", "congee"]
    fake_book = Minitest::Mock.new
    fake_book.expect(:sheet, FakeSheet.new([headers, values]), ["Staple_Catalog"])
    path = Rails.root.join("tmp/exists.xlsx")
    FileUtils.mkdir_p(path.dirname)
    File.write(path, "stub")

    Roo::Excelx.stub(:new, fake_book) do
      importer = Imports::StapleCatalogImporter.new(path: path)
      importer.call
      importer.call
    end

    assert_equal 1, Staple.count
    assert_equal 1, Ingredient.count
    assert_equal 1, Tagging.where(taggable_type: "Ingredient").count
    assert_operator StapleAlias.count, :>=, 3
    assert_operator SearchTerm.count, :>, 0
  end
end
