require "test_helper"

class SynonymTest < ActiveSupport::TestCase
  test "validations and uniqueness" do
    assert_not Synonym.new.valid?
    Synonym.create!(term: "米", normalized_term: "rice", locale: "ja")
    assert_not Synonym.new(term: "米", normalized_term: "rice", locale: "ja").valid?
  end

  test "normalizes term and normalized_term" do
    synonym = Synonym.create!(term: " ＲＩＣＥ ", normalized_term: " 米 ")
    assert_equal "rice", synonym.term
    assert_equal "米", synonym.normalized_term
  end
end
