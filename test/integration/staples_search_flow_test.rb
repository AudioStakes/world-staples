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

  test "show returns success and displays staple name and related tags" do
    staple = Staple.create!(name_ja: "ビーフン", name_en: "rice noodles", source_id: 6)
    ingredient = Ingredient.create!(name_ja: "米", name_en: "rice")
    Tagging.create!(staple:, taggable: ingredient, taggable_type: "Ingredient")

    get staple_path(staple)

    assert_response :success
    assert_includes response.body, "ビーフン"
    assert_includes response.body, "Ingredients"
    assert_includes response.body, "米"
  end
  test "search results display related tags" do
    staple = Staple.create!(name_ja: "アレパ", name_en: "arepa", source_id: 7)
    ingredient = Ingredient.create!(name_ja: "トウモロコシ", name_en: "corn")
    region = Region.create!(name_ja: "ラテンアメリカ", name_en: "Latin America")
    cooking_method = CookingMethod.create!(name_ja: "焼く", name_en: "grilled")

    Tagging.create!(staple:, taggable: ingredient, taggable_type: "Ingredient")
    Tagging.create!(staple:, taggable: region, taggable_type: "Region")
    Tagging.create!(staple:, taggable: cooking_method, taggable_type: "CookingMethod")
    SearchTerms::Rebuilder.call(staple)

    get staples_path, params: { q: "アレパ" }

    assert_response :success
    assert_includes response.body, "トウモロコシ"
    assert_includes response.body, "ラテンアメリカ"
    assert_includes response.body, "焼く"
  end
  test "region ingredient and cooking_method filters work through controller params" do
    matched = Staple.create!(name_ja: "蒸し飯", source_id: 8)
    other = Staple.create!(name_ja: "焼きパン", source_id: 9)

    east_asia = Region.create!(name_en: "East Asia", name_ja: "東アジア")
    europe = Region.create!(name_en: "Europe", name_ja: "ヨーロッパ")
    rice = Ingredient.create!(name_en: "rice", name_ja: "米")
    wheat = Ingredient.create!(name_en: "wheat", name_ja: "小麦")
    steamed = CookingMethod.create!(name_en: "steamed", name_ja: "蒸す")
    baked = CookingMethod.create!(name_en: "baked", name_ja: "焼く")

    Tagging.create!(staple: matched, taggable: east_asia, taggable_type: "Region")
    Tagging.create!(staple: matched, taggable: rice, taggable_type: "Ingredient")
    Tagging.create!(staple: matched, taggable: steamed, taggable_type: "CookingMethod")

    Tagging.create!(staple: other, taggable: europe, taggable_type: "Region")
    Tagging.create!(staple: other, taggable: wheat, taggable_type: "Ingredient")
    Tagging.create!(staple: other, taggable: baked, taggable_type: "CookingMethod")

    SearchTerm.create!(staple: matched, term: "rice", normalized_term: "rice", source_type: "Staple", source_id: matched.id, source_column: "name_ja", weight: 1)
    SearchTerm.create!(staple: other, term: "rice", normalized_term: "rice", source_type: "Staple", source_id: other.id, source_column: "name_ja", weight: 1)

    get staples_path, params: { q: "rice", region: "East Asia" }
    assert_response :success
    assert_includes response.body, "蒸し飯"
    assert_not_includes response.body, "焼きパン"

    get staples_path, params: { q: "rice", ingredient: "米" }
    assert_response :success
    assert_includes response.body, "蒸し飯"
    assert_not_includes response.body, "焼きパン"

    get staples_path, params: { q: "rice", cooking_method: "蒸す" }
    assert_response :success
    assert_includes response.body, "蒸し飯"
    assert_not_includes response.body, "焼きパン"
  end
end
