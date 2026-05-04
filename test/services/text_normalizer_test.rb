require "test_helper"

class TextNormalizerTest < ActiveSupport::TestCase
  test "normalization" do
    assert_equal "", TextNormalizer.normalize(nil)
    assert_equal "abc", TextNormalizer.normalize("  ABC ")
    assert_equal "a b", TextNormalizer.normalize("a   b")
    assert_equal "abc123", TextNormalizer.normalize("ＡＢＣ１２３")
  end
end
