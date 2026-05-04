require "test_helper"

class MasterModelsTest < ActiveSupport::TestCase
  test "required fields" do
    assert_not Ingredient.new.valid?
    assert_not IngredientFamily.new.valid?
    assert_not Form.new.valid?
    assert_not Shape.new.valid?
    assert_not ProcessingMethod.new.valid?
    assert_not CookingMethod.new.valid?
    assert_not Texture.new.valid?
    assert_not Region.new.valid?
    assert_not CountryArea.new.valid?
    assert_not ServingStyle.new.valid?
    assert_not StapleLevel.new.valid?
    assert_not SearchKeyword.new.valid?
  end

  test "region optional parent" do
    assert Region.new(name_en: "East Asia", parent_region: nil).valid?
  end
end
