require "test_helper"

class Imports::StapleCatalogImporterTest < ActiveSupport::TestCase
  test "raises clear error when file missing" do
    importer = Imports::StapleCatalogImporter.new(path: Rails.root.join("tmp/missing.csv"))
    assert_raises(ArgumentError) { importer.call }
  end

  test "imports fixture csv idempotently and updates by source_id" do
    path = Rails.root.join("test/fixtures/files/staple_catalog.csv")
    importer = Imports::StapleCatalogImporter.new(path: path)
    importer.call

    idli = Staple.find_by!(name_ja: "イドゥリ")
    assert_equal true, idli.fermented
    assert_equal "南インドの発酵生地を蒸した主食", idli.description
    assert_includes idli.processing_methods.map(&:name_en), "発酵"
    assert_includes idli.cooking_methods.map(&:name_en), "蒸す"
    assert_equal 3, idli.source_id
    assert idli.staple_aliases.exists?(kind: "similar_food", name: "ドーサ")
    assert_not SearchTerm.exists?(staple: idli, term: "ドーサ", source_type: "StapleAlias")

    japan = CountryArea.find_by!(name_en: "Japan")
    assert_equal "East Asia", japan.region.name_en

    counts = {
      staples: Staple.count,
      ingredient_families: IngredientFamily.count,
      ingredients: Ingredient.count,
      taggings: Tagging.count,
      staple_aliases: StapleAlias.count,
      search_terms: SearchTerm.count,
      search_keywords: SearchKeyword.count
    }

    tag = Tagging.first
    tag.update!(weight: 9.9, source_column: "old")
    importer.call
    tag.reload
    assert_equal FeatureWeights.for(tag.taggable_type), tag.weight.to_f

    assert_equal counts[:staples], Staple.count
    assert_equal counts[:ingredient_families], IngredientFamily.count
    assert_equal counts[:ingredients], Ingredient.count
    assert_equal counts[:taggings], Tagging.count
    assert_equal counts[:staple_aliases], StapleAlias.count
    assert_equal counts[:search_terms], SearchTerm.count
    assert_equal counts[:search_keywords], SearchKeyword.count

    csv2 = Rails.root.join("tmp/staple_catalog_rename.csv")
    File.write(csv2, File.read(path).sub("ご飯", "白ご飯"))
    Imports::StapleCatalogImporter.new(path: csv2).call
    assert_equal 1, Staple.where(source_id: 1).count
    assert_equal "白ご飯", Staple.find_by!(source_id: 1).name_ja
  end


  test "raises on blank/zero/non-integer id" do
    base = File.read(Rails.root.join("test/fixtures/files/staple_catalog.csv"))

    blank = Rails.root.join("tmp/staple_catalog_blank_id.csv")
    File.write(blank, base.sub("1,ご飯", ",ご飯"))
    e1 = assert_raises(ArgumentError) { Imports::StapleCatalogImporter.new(path: blank).call }
    assert_match(/column id/, e1.message)

    zero = Rails.root.join("tmp/staple_catalog_zero_id.csv")
    File.write(zero, base.sub("1,ご飯", "0,ご飯"))
    e2 = assert_raises(ArgumentError) { Imports::StapleCatalogImporter.new(path: zero).call }
    assert_match(/column id/, e2.message)

    nonint = Rails.root.join("tmp/staple_catalog_nonint_id.csv")
    File.write(nonint, base.sub("1,ご飯", "abc,ご飯"))
    e3 = assert_raises(ArgumentError) { Imports::StapleCatalogImporter.new(path: nonint).call }
    assert_match(/column id/, e3.message)
  end

  test "raises on unknown fermented value" do
    bad = Rails.root.join("tmp/staple_catalog_bad.csv")
    File.write(bad, File.read(Rails.root.join("test/fixtures/files/staple_catalog.csv")).sub("false", "maybe"))
    error = assert_raises(ArgumentError) { Imports::StapleCatalogImporter.new(path: bad).call }
    assert_match(/fermented/, error.message)
  end
end

class Imports::StapleCatalogImporterTest < ActiveSupport::TestCase
  test "imports staple metrics and updates without duplication" do
    path = Rails.root.join("tmp/staple_metrics_import.csv")
    File.write(path, "id,name_ja,name_en,local_name,ingredient_family,base_ingredients,form,shape,processing,cooking_method,fermented,texture,region,country_area,served_with,staple_level,search_keywords,similar_foods,notes,source_url,confidence,review_status,price_level,satiety_level,storage_duration,popularity_level,calories_kcal_per_100g,metrics_confidence\n1,ご飯,rice,,grain,rice,bowl,solid,none,boiled,false,soft,asia,japan,plain,primary,rice,,note,https://a,0.8,starter,low,high,long,high,168.5,0.75\n")
    importer = Imports::StapleCatalogImporter.new(path: path)
    importer.call
    metric = Staple.find_by!(source_id: 1).staple_metric
    assert_equal 168.5, metric.calories_kcal_per_100g.to_f
    assert_equal 0.75, metric.metrics_confidence.to_f
    assert_equal "low", metric.price_level

    File.write(path, File.read(path).sub("low", "medium"))
    assert_no_difference("StapleMetric.count") { importer.call }
    assert_equal "medium", Staple.find_by!(source_id: 1).staple_metric.price_level
  end

  test "partial metric csv does not clear missing columns" do
    path1 = Rails.root.join("tmp/staple_metrics_partial1.csv")
    path2 = Rails.root.join("tmp/staple_metrics_partial2.csv")
    base = "id,name_ja,name_en,local_name,ingredient_family,base_ingredients,form,shape,processing,cooking_method,fermented,texture,region,country_area,served_with,staple_level,search_keywords,similar_foods,notes,source_url,confidence,review_status"
    File.write(path1, "#{base},price_level,satiety_level\n1,ご飯,rice,,grain,rice,bowl,solid,none,boiled,false,soft,asia,japan,plain,primary,rice,,note,https://a,0.8,starter,low,high\n")
    File.write(path2, "#{base},price_level\n1,ご飯,rice,,grain,rice,bowl,solid,none,boiled,false,soft,asia,japan,plain,primary,rice,,note,https://a,0.8,starter,medium\n")
    Imports::StapleCatalogImporter.new(path: path1).call
    Imports::StapleCatalogImporter.new(path: path2).call
    metric = Staple.find_by!(source_id: 1).staple_metric
    assert_equal "medium", metric.price_level
    assert_equal "high", metric.satiety_level
  end
end
