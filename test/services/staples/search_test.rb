require "test_helper"

module Staples
  class SearchTest < ActiveSupport::TestCase
    setup do
      SearchTerm.delete_all
      Synonym.delete_all
      Tagging.delete_all
      StapleAlias.delete_all
      Staple.delete_all
      Ingredient.delete_all
      Region.delete_all
      CookingMethod.delete_all
      SearchKeyword.delete_all
    end

    test "blank query + no filters returns empty results" do
      assert_equal [], Search.call(nil)
      assert_equal [], Search.call("")
      assert_equal [], Search.call(" 　\t ")
    end


    test "blank query + fermented filter returns matching staples" do
      fermented = create_staple!(name_ja: "イドゥリ", fermented: true)
      create_staple!(name_ja: "ご飯", fermented: false)

      results = Search.call("", filters: { fermented: true })
      assert_equal [ fermented ], results.map(&:staple)
      assert_equal 0.0, results.first.score
      assert_equal [], results.first.matched_terms
      assert_equal [], results.first.matched_search_terms
    end

    test "blank query + region filter returns matching staples" do
      matched = create_staple!(name_ja: "蒸し飯")
      other = create_staple!(name_ja: "焼きパン")
      region = Region.create!(name_en: "East Asia", name_ja: "東アジア")
      Tagging.create!(staple: matched, taggable: region, taggable_type: "Region")

      results = Search.call("", filters: { region: "East Asia" })
      assert_equal [ matched ], results.map(&:staple)
      assert_not_includes results.map(&:staple), other
    end

    test "blank query + ingredient filter returns matching staples" do
      matched = create_staple!(name_ja: "ビーフン")
      ingredient = Ingredient.create!(name_en: "rice", name_ja: "米")
      Tagging.create!(staple: matched, taggable: ingredient, taggable_type: "Ingredient")

      results = Search.call("", filters: { ingredient: "rice" })
      assert_equal [ matched ], results.map(&:staple)
    end

    test "blank query + cooking_method filter returns matching staples" do
      matched = create_staple!(name_ja: "蒸しパン")
      cm = CookingMethod.create!(name_en: "steamed", name_ja: "蒸す")
      Tagging.create!(staple: matched, taggable: cm, taggable_type: "CookingMethod")

      results = Search.call("", filters: { cooking_method: "steamed" })
      assert_equal [ matched ], results.map(&:staple)
    end

    test "filter-only search respects limit" do
      east_asia = Region.create!(name_en: "East Asia", name_ja: "東アジア")
      3.times do |i|
        staple = create_staple!(name_ja: "米#{i}", source_id: 77_000 + i)
        Tagging.create!(staple:, taggable: east_asia, taggable_type: "Region")
      end

      assert_equal 2, Search.call("", filters: { region: "East Asia" }, limit: 2).size
    end

    test "simple name search hits staple" do
      staple = create_staple!(name_ja: "ご飯", name_en: "rice")
      SearchTerms::Rebuilder.call(staple)

      assert_includes Search.call("ご飯").map(&:staple), staple
      assert_includes Search.call("rice").map(&:staple), staple
    end

    test "synonym search maps query term" do
      staple = create_staple!(name_ja: "ご飯", name_en: "rice")
      Synonym.create!(term: "米", normalized_term: "rice", locale: "ja")
      SearchTerms::Rebuilder.call(staple)

      result = Search.call("米").first
      assert_equal staple, result.staple
      assert_includes result.matched_terms, "rice"
    end

    test "multi-term scoring with matched terms" do
      staple = create_staple!(name_ja: "イドゥリ", name_en: "idli", fermented: true)
      ingredient = Ingredient.create!(name_en: "rice", name_ja: "米")
      cooking_method = CookingMethod.create!(name_en: "steamed", name_ja: "蒸す")
      keyword = SearchKeyword.create!(keyword: "fermented", locale: "en", normalized_keyword: "fermented")

      Tagging.create!(staple:, taggable: ingredient, taggable_type: "Ingredient")
      Tagging.create!(staple:, taggable: cooking_method, taggable_type: "CookingMethod")
      Tagging.create!(staple:, taggable: keyword, taggable_type: "SearchKeyword")
      Synonym.create!(term: "米", normalized_term: "rice", locale: "ja")
      Synonym.create!(term: "発酵", normalized_term: "fermented", locale: "ja")

      SearchTerms::Rebuilder.call(staple)

      result = Search.call("米 発酵 蒸す").first
      assert_equal staple, result.staple
      assert_equal [ "rice", "fermented", "蒸す" ], result.matched_terms
    end

    test "score ordering favors more matches" do
      top = create_staple!(name_ja: "イドゥリ", name_en: "idli")
      low = create_staple!(name_ja: "米団子", name_en: "rice dumpling")

      SearchTerm.create!(staple: top, term: "rice", normalized_term: "rice", source_type: "SearchKeyword", source_id: 1, source_column: "keyword", weight: 2)
      SearchTerm.create!(staple: top, term: "steamed", normalized_term: "steamed", source_type: "SearchKeyword", source_id: 2, source_column: "keyword", weight: 2)
      SearchTerm.create!(staple: low, term: "rice", normalized_term: "rice", source_type: "SearchKeyword", source_id: 3, source_column: "keyword", weight: 2)

      results = Search.call("rice steamed")
      assert_equal [ top, low ], results.map(&:staple)
    end

    test "limit option" do
      2.times do |i|
        staple = create_staple!(name_ja: "米#{i}", source_id: 10_000 + i)
        SearchTerm.create!(staple:, term: "rice", normalized_term: "rice", source_type: "Staple", source_id: staple.id, source_column: "name_ja", weight: 1)
      end

      assert_equal 1, Search.call("rice", limit: 1).size
      assert_equal [], Search.call("rice", limit: 0)
    end

    test "fermented filter" do
      fermented = create_staple!(name_ja: "イドゥリ", fermented: true)
      plain = create_staple!(name_ja: "ご飯", fermented: false, source_id: 9_999)
      [ fermented, plain ].each do |staple|
        SearchTerm.create!(staple:, term: "rice", normalized_term: "rice", source_type: "Staple", source_id: staple.id, source_column: "name_ja", weight: 1)
      end

      results = Search.call("rice", filters: { fermented: true })
      assert_equal [ fermented ], results.map(&:staple)
    end


    test "direct filter option also works" do
      fermented = create_staple!(name_ja: "イドゥリ", fermented: true)
      plain = create_staple!(name_ja: "ご飯", fermented: false, source_id: 8_888)
      [ fermented, plain ].each do |staple|
        SearchTerm.create!(staple:, term: "rice", normalized_term: "rice", source_type: "Staple", source_id: staple.id, source_column: "name_ja", weight: 1)
      end

      results = Search.call("rice", fermented: true)
      assert_equal [ fermented ], results.map(&:staple)
    end
    test "region filter" do
      staple = create_staple!(name_ja: "ご飯")
      region = Region.create!(name_en: "East Asia", name_ja: "東アジア")
      Tagging.create!(staple:, taggable: region, taggable_type: "Region")
      SearchTerm.create!(staple:, term: "rice", normalized_term: "rice", source_type: "Staple", source_id: staple.id, source_column: "name_ja", weight: 1)

      assert_equal [ staple ], Search.call("rice", filters: { region: "East Asia" }).map(&:staple)
      assert_equal [ staple ], Search.call("rice", filters: { region: "東アジア" }).map(&:staple)
    end

    test "ingredient filter" do
      staple = create_staple!(name_ja: "ビーフン")
      ingredient = Ingredient.create!(name_en: "rice", name_ja: "米")
      Tagging.create!(staple:, taggable: ingredient, taggable_type: "Ingredient")
      SearchTerm.create!(staple:, term: "noodle", normalized_term: "noodle", source_type: "Staple", source_id: staple.id, source_column: "name_ja", weight: 1)

      assert_equal [ staple ], Search.call("noodle", filters: { ingredient: "rice" }).map(&:staple)
      assert_equal [ staple ], Search.call("noodle", filters: { ingredient: "米" }).map(&:staple)
    end

    test "cooking_method filter" do
      staple = create_staple!(name_ja: "蒸しパン")
      cm = CookingMethod.create!(name_en: "steamed", name_ja: "蒸す")
      Tagging.create!(staple:, taggable: cm, taggable_type: "CookingMethod")
      SearchTerm.create!(staple:, term: "bread", normalized_term: "bread", source_type: "Staple", source_id: staple.id, source_column: "name_ja", weight: 1)

      assert_equal [ staple ], Search.call("bread", filters: { cooking_method: "steamed" }).map(&:staple)
      assert_equal [ staple ], Search.call("bread", filters: { cooking_method: "蒸す" }).map(&:staple)
    end

    test "similar_food alias is not searched as alias" do
      staple = create_staple!(name_ja: "イドゥリ", name_en: "idli")
      StapleAlias.create!(staple:, name: "ドーサ", kind: "similar_food", locale: "ja")
      SearchTerms::Rebuilder.call(staple)

      assert_empty Search.call("ドーサ")
    end

    private

    def create_staple!(name_ja:, name_en: nil, fermented: false, source_id: nil)
      Staple.create!(name_ja:, name_en:, fermented:, source_id: source_id || rand(100_000..999_999))
    end
  end
end

module Staples
  class SearchTest < ActiveSupport::TestCase
    test "metric filters work for blank and text query" do
      with_metric = create_staple!(name_ja: "玄米")
      without_metric = create_staple!(name_ja: "白米")
      StapleMetric.create!(staple: with_metric, price_level: "low", satiety_level: "high", storage_duration: "long", popularity_level: "high")
      [ with_metric, without_metric ].each do |staple|
        SearchTerm.create!(staple:, term: "rice", normalized_term: "rice", source_type: "Staple", source_id: staple.id, source_column: "name_ja", weight: 1)
      end

      assert_equal [ with_metric ], Search.call("", filters: { price_level: "low" }).map(&:staple)
      assert_equal [ with_metric ], Search.call("", filters: { satiety_level: "high" }).map(&:staple)
      assert_equal [ with_metric ], Search.call("", filters: { storage_duration: "long" }).map(&:staple)
      assert_equal [ with_metric ], Search.call("", filters: { popularity_level: "high" }).map(&:staple)
      assert_equal [ with_metric ], Search.call("rice", filters: { price_level: "low" }).map(&:staple)
      assert_equal [], Search.call("rice", filters: { price_level: "ultra" }).map(&:staple)
    end
  end
end
