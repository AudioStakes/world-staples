require "csv"
module Imports
  class IngredientMetricsImporter
    def initialize(path: Rails.root.join("db/seeds/ingredient_metrics.csv")) = @path = Pathname(path)
    def call
      raise ArgumentError, "CSV file not found: #{@path}" unless @path.exist?
      CSV.foreach(@path, headers: true, encoding: "UTF-8").with_index(2) { |row, n| import_row(row.to_h, n) }
    end
    private
    def import_row(row, n)
      name_en = row["ingredient_name_en"].to_s.strip
      raise ArgumentError, "Missing ingredient_name_en at row #{n}" if name_en.blank?
      ingredient = Ingredient.find_or_create_by!(name_en: name_en)
      ingredient.update!(name_ja: row["ingredient_name_ja"].presence) if ingredient.name_ja.blank? && row["ingredient_name_ja"].present?
      if ingredient.ingredient_family.nil? && row["ingredient_family"].present?
        ingredient.update!(ingredient_family: IngredientFamily.find_or_create_by!(name_en: row["ingredient_family"].strip))
      end
      metric = IngredientMetric.find_or_initialize_by(ingredient:)
      metric.assign_attributes(row.slice("ingredient_name_en", "ingredient_name_ja", "ingredient_family", "production_volume_level", "production_volume_note", "price_level", "cultivation_ease", "satiety_basis", "calorie_basis", "storage_duration", "storage_method", "representative_staples", "source_url", "note").transform_values { _1.to_s.strip.presence })
      metric.calories_kcal_per_100g_basic = parse_decimal(row["calories_kcal_per_100g_basic"], n, "calories_kcal_per_100g_basic")
      metric.confidence = parse_decimal(row["confidence"], n, "confidence")
      metric.save!
    end
    def parse_decimal(value, row, col); return nil if value.to_s.strip.empty?; BigDecimal(value.to_s); rescue ArgumentError; raise ArgumentError, "Invalid decimal at row #{row}, column #{col}: #{value}"; end
  end
end
