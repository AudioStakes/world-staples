require "csv"

module Imports
  class StapleCatalogImporter
    METRIC_COLUMNS = %w[production_volume_note price_level cultivation_ease satiety_level calories_kcal_per_100g calorie_basis deliciousness_level sweetness_level taste_profile storage_duration storage_method popularity_level metrics_source_url metrics_confidence metrics_note].freeze

    def initialize(path: Rails.root.join("db/seeds/staple_catalog.csv"))
      @path = Pathname(path)
    end

    def call
      raise ArgumentError, "CSV file not found: #{@path}" unless @path.exist?

      synonym_map = SearchTerms::Rebuilder.preload_synonym_map
      CSV.foreach(@path, headers: true, encoding: "UTF-8").with_index(2) do |row, row_number|
        import_row(row.to_h, row_number, synonym_map: synonym_map)
      end
    end

    private

    def import_row(row, row_number, synonym_map:)
      source_id = parse_source_id(row["id"], row_number)
      staple = Staple.find_or_initialize_by(source_id: source_id)
      staple.assign_attributes(
        name_ja: row["name_ja"], name_en: row["name_en"], local_name: row["local_name"],
        fermented: parse_boolean(row["fermented"], row_number), description: row["notes"],
        source_url: row["source_url"], confidence: row["confidence"].presence,
        review_status: row["review_status"].presence || "starter", source_row_number: row_number
      )
      staple.save!

      import_staple_metric(staple, row, row_number) if (METRIC_COLUMNS & row.keys).any?

      primary_region = split(row["region"]).first
      region_record = primary_region.present? ? Region.find_or_create_by!(name_en: primary_region) : nil
      split(row["region"]).each { |v| tag(staple, Region.find_or_create_by!(name_en: v), "region") }

      ingredient_family = find_ingredient_family(row["ingredient_family"])
      tag(staple, ingredient_family, "ingredient_family") if ingredient_family
      split(row["base_ingredients"]).each do |name|
        ingredient = Ingredient.find_or_create_by!(name_en: name)
        ingredient.update!(ingredient_family: ingredient_family) if ingredient.ingredient_family.nil? && ingredient_family
        tag(staple, ingredient, "base_ingredients")
      end

      split(row["country_area"]).each do |name|
        area = CountryArea.find_or_create_by!(name_en: name)
        area.update!(region: region_record) if area.region.nil? && region_record
        tag(staple, area, "country_area")
      end

      { Form => [ "form", :name_en ], Shape => [ "shape", :name_en ], ProcessingMethod => [ "processing", :name_en ], CookingMethod => [ "cooking_method", :name_en ], Texture => [ "texture", :name_en ], ServingStyle => [ "served_with", :name_en ], StapleLevel => [ "staple_level", :code ], SearchKeyword => [ "search_keywords", :keyword ] }.each do |klass, (column, key)|
        split(row[column]).each { |value| tag(staple, klass.find_or_create_by!(key => value), column) }
      end

      make_aliases(staple, row)
      SearchTerms::Rebuilder.call(staple, synonym_map: synonym_map)
    end

    def import_staple_metric(staple, row, row_number)
      metric = StapleMetric.find_or_initialize_by(staple: staple)
      attrs = {}
      attrs[:production_volume_note] = blank_to_nil(row["production_volume_note"]) if row.key?("production_volume_note")
      attrs[:price_level] = blank_to_nil(row["price_level"]) if row.key?("price_level")
      attrs[:cultivation_ease] = blank_to_nil(row["cultivation_ease"]) if row.key?("cultivation_ease")
      attrs[:satiety_level] = blank_to_nil(row["satiety_level"]) if row.key?("satiety_level")
      attrs[:calories_kcal_per_100g] = parse_decimal(row["calories_kcal_per_100g"], row_number, "calories_kcal_per_100g") if row.key?("calories_kcal_per_100g")
      attrs[:calorie_basis] = blank_to_nil(row["calorie_basis"]) if row.key?("calorie_basis")
      attrs[:deliciousness_level] = blank_to_nil(row["deliciousness_level"]) if row.key?("deliciousness_level")
      attrs[:sweetness_level] = blank_to_nil(row["sweetness_level"]) if row.key?("sweetness_level")
      attrs[:taste_profile] = blank_to_nil(row["taste_profile"]) if row.key?("taste_profile")
      attrs[:storage_duration] = blank_to_nil(row["storage_duration"]) if row.key?("storage_duration")
      attrs[:storage_method] = blank_to_nil(row["storage_method"]) if row.key?("storage_method")
      attrs[:popularity_level] = blank_to_nil(row["popularity_level"]) if row.key?("popularity_level")
      attrs[:metrics_source_url] = blank_to_nil(row["metrics_source_url"]) if row.key?("metrics_source_url")
      attrs[:metrics_confidence] = parse_decimal(row["metrics_confidence"], row_number, "metrics_confidence") if row.key?("metrics_confidence")
      attrs[:metrics_note] = blank_to_nil(row["metrics_note"]) if row.key?("metrics_note")
      metric.assign_attributes(attrs)
      metric.save!
    end

    def blank_to_nil(value)
      value.to_s.strip.presence
    end

    def parse_decimal(value, row_number, column)
      return nil if value.to_s.strip.empty?
      BigDecimal(value.to_s)
    rescue ArgumentError
      raise ArgumentError, "Invalid decimal at row #{row_number}, column #{column}: #{value}"
    end

    def parse_source_id(value, row_number)
      raw = value.to_s.strip
      raise ArgumentError, "Invalid id at row #{row_number}, column id: #{value}" if raw.blank?

      source_id = Integer(raw, exception: false)
      raise ArgumentError, "Invalid id at row #{row_number}, column id: #{value}" if source_id.nil? || source_id <= 0
      source_id
    end

    def parse_boolean(value, row_number)
      normalized = value.to_s.strip.downcase
      return true if %w[true 1 yes y].include?(normalized)
      return false if %w[false 0 no n].include?(normalized) || normalized.blank?
      raise ArgumentError, "Invalid boolean at row #{row_number}, column fermented: #{value}"
    end

    def find_ingredient_family(name)
      cleaned = name.to_s.strip
      return if cleaned.blank?
      IngredientFamily.find_or_create_by!(name_en: cleaned)
    end

    def make_aliases(staple, row)
      { "name_ja" => row["name_ja"], "name_en" => row["name_en"], "local_name" => row["local_name"] }.each do |kind, name|
        next if name.to_s.strip.empty?
        staple.staple_aliases.find_or_create_by!(name: name.to_s.strip, kind: kind)
      end
      split(row["similar_foods"]).each { |name| staple.staple_aliases.find_or_create_by!(name: name, kind: "similar_food") }
    end

    def tag(staple, record, source_column)
      tagging = Tagging.find_or_initialize_by(staple: staple, taggable: record)
      tagging.source_column = source_column
      tagging.weight = FeatureWeights.for(record.class.name)
      tagging.save!
    end

    def split(value)
      value.to_s.split(",").map(&:strip).reject(&:blank?)
    end
  end
end
