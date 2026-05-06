require "test_helper"

class Imports::MetricSourcesImporterTest < ActiveSupport::TestCase
  test "imports and updates idempotently" do
    path = Rails.root.join("tmp/metric_sources_importer_test.csv")
    File.write(path, "source_name,metric_category,source_url,use_note,license_or_access_note\nFAO,production,https://a.test,note1,license1\n")

    importer = Imports::MetricSourcesImporter.new(path: path)
    importer.call
    assert_equal 1, MetricSource.count

    File.write(path, "source_name,metric_category,source_url,use_note,license_or_access_note\nFAO,calories,https://b.test,note2,license2\n")
    assert_no_difference("MetricSource.count") { importer.call }
    source = MetricSource.find_by!(source_name: "FAO")
    assert_equal "calories", source.metric_category
    assert_equal "note2", source.use_note
  end

  test "blank source_name raises row context" do
    path = Rails.root.join("tmp/metric_sources_importer_blank.csv")
    File.write(path, "source_name,metric_category\n,calories\n")

    error = assert_raises(ArgumentError) { Imports::MetricSourcesImporter.new(path: path).call }
    assert_match(/row 2/, error.message)
    assert_match(/column source_name/, error.message)
  end
end
