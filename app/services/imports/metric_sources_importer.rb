require "csv"
module Imports
  class MetricSourcesImporter
    def initialize(path: Rails.root.join("db/seeds/metric_sources.csv")) = @path = Pathname(path)
    def call
      raise ArgumentError, "CSV file not found: #{@path}" unless @path.exist?
      CSV.foreach(@path, headers: true, encoding: "UTF-8") do |row|
        source = MetricSource.find_or_initialize_by(source_name: row["source_name"].to_s.strip)
        source.assign_attributes(metric_category: row["metric_category"].to_s.strip.presence, source_url: row["source_url"].to_s.strip.presence, use_note: row["use_note"].to_s.strip.presence, license_or_access_note: row["license_or_access_note"].to_s.strip.presence)
        source.save!
      end
    end
  end
end
