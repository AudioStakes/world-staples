require "csv"

module Imports
  class IngredientMetricsImporter
    def initialize(path: Rails.root.join("db/seeds/ingredient_metrics.csv"))
      @path = Pathname(path)
      @skipped_count = 0
    end

    def call
      raise ArgumentError, "CSV file not found: #{@path}" unless @path.exist?

      CSV.foreach(@path, headers: true, encoding: "UTF-8").with_index(2) do |row, row_number|
        import_row(row.to_h, row_number)
      end
      Rails.logger.warn("IngredientMetricsImporter skipped #{@skipped_count} rows") if @skipped_count.positive?
    end

    private

    def import_row(row, row_number)
      name_en = row["ingredient_name_en"].to_s.strip
      raise ArgumentError, "Missing ingredient_name_en at row #{row_number}, column ingredient_name_en" if name_en.blank?

      ingredient = Ingredient.find_by(name_en: name_en)
      unless ingredient
        @skipped_count += 1
        Rails.logger.warn("Skipping ingredient metric at row #{row_number}: ingredient not found: #{name_en}")
        return
      end

      if ingredient.name_ja.blank? && row["ingredient_name_ja"].present?
        ingredient.update!(name_ja: row["ingredient_name_ja"].to_s.strip)
      end

      metric = IngredientMetric.find_or_initialize_by(ingredient: ingredient)
      metric.assign_attributes(attributes_from(row))
      metric.calories_kcal_per_100g_basic = parse_decimal(row["calories_kcal_per_100g_basic"], row_number, "calories_kcal_per_100g_basic")
      metric.confidence = parse_decimal(row["confidence"], row_number, "confidence")
      metric.save!
    end

    def attributes_from(row)
      row.slice("ingredient_name_en", "ingredient_name_ja", "ingredient_family", "production_volume_level", "production_volume_note", "price_level", "cultivation_ease", "satiety_basis", "calorie_basis", "storage_duration", "storage_method", "representative_staples", "source_url", "note").transform_values { |v| blank_to_nil(v) }
    end

    def parse_decimal(value, row_number, column)
      return nil if value.to_s.strip.empty?
      BigDecimal(value.to_s)
    rescue ArgumentError
      raise ArgumentError, "Invalid decimal at row #{row_number}, column #{column}: #{value}"
    end

    def blank_to_nil(value)
      value.to_s.strip.presence
    end
  end
end
