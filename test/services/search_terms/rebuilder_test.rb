require "test_helper"

class SearchTerms::RebuilderTest < ActiveSupport::TestCase
  test "rebuilds with locale aware synonym map and skips similar_food aliases" do
    staple = Staple.create!(source_id: 1, name_ja: "米", name_en: "Rice")
    staple.staple_aliases.create!(name: "ごはん", kind: "synonym")
    staple.staple_aliases.create!(name: "粥", kind: "similar_food")
    ingredient = Ingredient.create!(name_en: "rice")
    Tagging.create!(staple:, taggable: ingredient)
    Synonym.create!(term: "米", normalized_term: "rice", locale: nil)
    Synonym.create!(term: "rice", normalized_term: "rice-en", locale: "en")

    SearchTerms::Rebuilder.call(staple)

    assert SearchTerm.exists?(staple:, source_type: "Staple", weight: FeatureWeights.for("Staple"))
    assert SearchTerm.exists?(staple:, source_type: "StapleAlias", weight: FeatureWeights.for("StapleAlias"))
    assert_not SearchTerm.exists?(staple:, term: "粥", source_type: "StapleAlias")
    assert SearchTerm.exists?(staple:, source_column: "name_en", normalized_term: "rice-en")
  end
end
