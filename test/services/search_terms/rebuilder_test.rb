require "test_helper"

class SearchTerms::RebuilderTest < ActiveSupport::TestCase
  test "rebuilds from staple alias and taggings and synonym" do
    staple = Staple.create!(name_ja: "米", name_en: "Rice")
    staple.staple_aliases.create!(name: "ごはん", kind: "synonym")
    ingredient = Ingredient.create!(name_en: "rice")
    Tagging.create!(staple:, taggable: ingredient)
    Synonym.create!(term: "米", normalized_term: "rice", locale: nil)

    SearchTerms::Rebuilder.call(staple)

    assert SearchTerm.exists?(staple:, source_type: "Staple")
    assert SearchTerm.exists?(staple:, source_type: "StapleAlias")
    assert SearchTerm.exists?(staple:, source_type: "Ingredient")
    assert_equal 1, SearchTerm.where(staple:, normalized_term: "rice", source_type: "Staple", source_column: "name_ja").count
  end
end
