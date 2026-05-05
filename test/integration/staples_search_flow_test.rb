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
    matched = Staple.create!(name_ja: "蒸し飯", source_id: 1)
    other = Staple.create!(name_ja: "焼きパン", source_id: 2)
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
    matched = Staple.create!(name_ja: "ビーフン", source_id: 3)
    other = Staple.create!(name_ja: "うどん", source_id: 4)
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
    matched = Staple.create!(name_ja: "蒸しパン", source_id: 5)
    other = Staple.create!(name_ja: "焼きパン", source_id: 6)
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

  test "show page region/ingredient/cooking_method tags link back to search" do
    staple = Staple.create!(name_ja: "アレパ", source_id: 7)
    region = Region.create!(name_ja: "ラテンアメリカ", name_en: "Latin America")
    ingredient = Ingredient.create!(name_ja: "トウモロコシ", name_en: "corn")
    cooking_method = CookingMethod.create!(name_ja: "焼く", name_en: "grilled")
    Tagging.create!(staple:, taggable: region, taggable_type: "Region")
    Tagging.create!(staple:, taggable: ingredient, taggable_type: "Ingredient")
    Tagging.create!(staple:, taggable: cooking_method, taggable_type: "CookingMethod")

    get staple_path(staple)

    assert_response :success
    assert_includes response.body, "href=\"/staples?region=Latin+America\""
    assert_includes response.body, "href=\"/staples?ingredient=corn\""
    assert_includes response.body, "href=\"/staples?cooking_method=grilled\""
  end
end
