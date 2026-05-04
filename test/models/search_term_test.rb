require "test_helper"

class SearchTermTest < ActiveSupport::TestCase
  test "requires fields and belongs to staple" do
    assert_not SearchTerm.new.valid?
    staple = Staple.create!(name_ja: "米")
    assert SearchTerm.new(staple:, term: "rice", normalized_term: "rice", source_type: "Staple").valid?
  end
end
