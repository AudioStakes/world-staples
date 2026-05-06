require "test_helper"

class Imports::MetricSourcesImporterTest < ActiveSupport::TestCase
  test "blank source_name raises row context" do
    path = Rails.root.join("tmp/metric_sources_importer_test.csv")
    File.write(path, "source_name,metric_category\n,calories\n")

    error = assert_raises(ArgumentError) { Imports::MetricSourcesImporter.new(path: path).call }
    assert_match(/row 2/, error.message)
    assert_match(/column source_name/, error.message)
  end
end
