require "test_helper"

class StapleAliasTest < ActiveSupport::TestCase
  test "requires name and belongs to staple and normalizes" do
    staple = Staple.create!(name_ja: "米")
    model = StapleAlias.new(staple:, name: " ＲＩＣＥ ")
    assert model.valid?
    model.save!
    assert_equal "rice", model.normalized_name
  end
end
