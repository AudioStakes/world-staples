require "test_helper"

class StaplesSearchFlowTest < ActionDispatch::IntegrationTest
  setup do
    SearchTerm.delete_all
    Tagging.delete_all
    StapleAlias.delete_all
    Staple.delete_all
    Ingredient.delete_all
    Region.delete_all
    CookingMethod.delete_all
  end

  test "root route points to staples index" do
    get "/"
    assert_response :success
    assert_includes response.body, "World Staples"
  end

  test "index returns success and blank index shows browse staples" do
    Staple.create!(name_ja: "ご飯", source_id: 1)

    get staples_path

    assert_response :success
    assert_includes response.body, "Browse staples"
  end

  test "search query shows result" do
    staple = Staple.create!(name_ja: "イドゥリ", name_en: "idli", fermented: true, source_id: 2)
    SearchTerms::Rebuilder.call(staple)

    get staples_path, params: { q: "イドゥリ" }

    assert_response :success
    assert_includes response.body, "results for"
    assert_includes response.body, "イドゥリ"
  end

  test "search query with no matches shows no results" do
    staple = Staple.create!(name_ja: "ご飯", source_id: 3)
    SearchTerms::Rebuilder.call(staple)

    get staples_path, params: { q: "不存在" }

    assert_response :success
    assert_includes response.body, "No staples found"
  end

  test "fermented filter works through controller params" do
    fermented = Staple.create!(name_ja: "イドゥリ", fermented: true, source_id: 4)
    plain = Staple.create!(name_ja: "ご飯", fermented: false, source_id: 5)
    SearchTerm.create!(staple: fermented, term: "rice", normalized_term: "rice", source_type: "Staple", source_id: fermented.id, source_column: "name_ja", weight: 1)
    SearchTerm.create!(staple: plain, term: "rice", normalized_term: "rice", source_type: "Staple", source_id: plain.id, source_column: "name_ja", weight: 1)

    get staples_path, params: { q: "rice", fermented: "true" }

    assert_response :success
    assert_includes response.body, "イドゥリ"
    assert_not_includes response.body, "ご飯"
  end

  test "index renders region/ingredient/cooking_method select options" do
    Region.create!(name_en: "East Asia", name_ja: "東アジア")
    Ingredient.create!(name_en: "rice", name_ja: "米")
    CookingMethod.create!(name_en: "steamed", name_ja: "蒸す")

    get staples_path

    assert_response :success
    assert_includes response.body, 'name="region"'
    assert_includes response.body, "Any region"
    assert_includes response.body, 'value="East Asia"'
    assert_includes response.body, 'name="ingredient"'
    assert_includes response.body, 'value="rice"'
    assert_includes response.body, 'name="cooking_method"'
    assert_includes response.body, 'value="steamed"'
  end

  test "q blank + region select param shows matching results" do
    matched = Staple.create!(name_ja: "蒸し飯", source_id: 6)
    other = Staple.create!(name_ja: "焼きパン", source_id: 7)
    east_asia = Region.create!(name_en: "East Asia", name_ja: "東アジア")
    europe = Region.create!(name_en: "Europe", name_ja: "ヨーロッパ")
    Tagging.create!(staple: matched, taggable: east_asia, taggable_type: "Region")
    Tagging.create!(staple: other, taggable: europe, taggable_type: "Region")

    get staples_path, params: { region: "East Asia" }

    assert_response :success
    assert_includes response.body, "蒸し飯"
    assert_not_includes response.body, "焼きパン"
  end

  test "q blank + ingredient select param shows matching results" do
    matched = Staple.create!(name_ja: "ビーフン", source_id: 8)
    other = Staple.create!(name_ja: "うどん", source_id: 9)
    rice = Ingredient.create!(name_en: "rice", name_ja: "米")
    wheat = Ingredient.create!(name_en: "wheat", name_ja: "小麦")
    Tagging.create!(staple: matched, taggable: rice, taggable_type: "Ingredient")
    Tagging.create!(staple: other, taggable: wheat, taggable_type: "Ingredient")

    get staples_path, params: { ingredient: "rice" }

    assert_response :success
    assert_includes response.body, "ビーフン"
    assert_not_includes response.body, "うどん"
  end

  test "q blank + cooking_method select param shows matching results" do
    matched = Staple.create!(name_ja: "蒸しパン", source_id: 10)
    other = Staple.create!(name_ja: "焼きパン", source_id: 11)
    steamed = CookingMethod.create!(name_en: "steamed", name_ja: "蒸す")
    baked = CookingMethod.create!(name_en: "baked", name_ja: "焼く")
    Tagging.create!(staple: matched, taggable: steamed, taggable_type: "CookingMethod")
    Tagging.create!(staple: other, taggable: baked, taggable_type: "CookingMethod")

    get staples_path, params: { cooking_method: "steamed" }

    assert_response :success
    assert_includes response.body, "蒸しパン"
    assert_not_includes response.body, "焼きパン"
  end

  test "selected filter value remains selected after request" do
    Region.create!(name_en: "East Asia", name_ja: "東アジア")

    get staples_path, params: { region: "East Asia" }

    assert_response :success
    assert_includes response.body, '<option selected="selected" value="East Asia"'
  end

  test "active filters are displayed" do
    get staples_path, params: { q: "rice", region: "East Asia", ingredient: "rice" }

    assert_response :success
    assert_includes response.body, "Filters:"
    assert_includes response.body, "Region = East Asia"
    assert_includes response.body, "Ingredient = rice"
  end

  test "clear filters link keeps q and removes filters" do
    get staples_path, params: { q: "rice", region: "East Asia" }

    assert_response :success
    assert_includes response.body, 'href="/staples?q=rice"'
  end

  test "show returns success and displays staple name and related tags" do
    staple = Staple.create!(name_ja: "ビーフン", name_en: "rice noodles", source_id: 12)
    ingredient = Ingredient.create!(name_ja: "米", name_en: "rice")
    Tagging.create!(staple:, taggable: ingredient, taggable_type: "Ingredient")

    get staple_path(staple)

    assert_response :success
    assert_includes response.body, "ビーフン"
    assert_includes response.body, "Ingredients"
    assert_includes response.body, "米"
  end

  test "show page region/ingredient/cooking_method tags link back to search" do
    staple = Staple.create!(name_ja: "アレパ", source_id: 13)
    region = Region.create!(name_ja: "ラテンアメリカ", name_en: "Latin America")
    ingredient = Ingredient.create!(name_ja: "トウモロコシ", name_en: "corn")
    cooking_method = CookingMethod.create!(name_ja: "焼く", name_en: "grilled")
    Tagging.create!(staple:, taggable: region, taggable_type: "Region")
    Tagging.create!(staple:, taggable: ingredient, taggable_type: "Ingredient")
    Tagging.create!(staple:, taggable: cooking_method, taggable_type: "CookingMethod")

    get staple_path(staple)

    assert_response :success
    assert_includes response.body, 'href="/staples?region=Latin+America"'
    assert_includes response.body, 'href="/staples?ingredient=corn"'
    assert_includes response.body, 'href="/staples?cooking_method=grilled"'
  end

  test "show page displays staple metrics" do
    staple = Staple.create!(name_ja: "ご飯", source_id: 91)
    StapleMetric.create!(staple: staple, price_level: "low", satiety_level: "high", calories_kcal_per_100g: 168.0)

    get staple_path(staple)

    assert_response :success
    assert_includes response.body, "Staple metrics"
    assert_includes response.body, "Price level"
    assert_includes response.body, "168.0"
  end

  test "search result card displays metric snippet" do
    staple = Staple.create!(name_ja: "米粉パン", source_id: 92)
    SearchTerms::Rebuilder.call(staple)
    StapleMetric.create!(staple: staple, price_level: "low", satiety_level: "medium", storage_duration: "short", popularity_level: "high")

    get staples_path, params: { q: "米粉パン" }

    assert_response :success
    assert_includes response.body, "Metrics:"
    assert_includes response.body, "price: low"
  end
end
