require "test_helper"

class SynonymTest < ActiveSupport::TestCase
  test "validations and uniqueness" do
    assert_not Synonym.new.valid?
    Synonym.create!(term: "米", normalized_term: "rice", locale: "ja")
    assert_not Synonym.new(term: "米", normalized_term: "rice", locale: "ja").valid?
  end
end
