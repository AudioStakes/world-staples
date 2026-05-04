require "test_helper"

class StapleTest < ActiveSupport::TestCase
  test "valid with name_ja" do
    assert Staple.new(source_id: 10, name_ja: "米").valid?
  end

  test "associations and polymorphic access" do
    staple = Staple.create!(source_id: 3, name_ja: "ご飯")
    ingredient = Ingredient.create!(name_en: "rice")
    cooking = CookingMethod.create!(name_en: "boiling")
    Tagging.create!(staple:, taggable: ingredient)
    Tagging.create!(staple:, taggable: cooking)

    assert_includes staple.ingredients, ingredient
    assert_includes staple.cooking_methods, cooking
    assert_respond_to staple, :taggings
    assert_respond_to staple, :staple_aliases
    assert_respond_to staple, :search_terms
  end
end
