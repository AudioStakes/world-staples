require "test_helper"

class TaggingTest < ActiveSupport::TestCase
  test "validation rules" do
    staple = Staple.create!(name_ja: "米")
    ingredient = Ingredient.create!(name_en: "rice")
    assert Tagging.new(staple:, taggable: ingredient).valid?

    invalid = Tagging.new(staple:, taggable_type: "BadType", taggable_id: 1)
    assert_not invalid.valid?

    Tagging.create!(staple:, taggable: ingredient)
    dup = Tagging.new(staple:, taggable: ingredient)
    assert_not dup.valid?

    missing = Tagging.new(staple:, taggable_type: "Ingredient", taggable_id: 999_999)
    assert_not missing.valid?

    other = Staple.create!(name_ja: "パン")
    assert Tagging.new(staple: other, taggable: ingredient).valid?
  end
end
