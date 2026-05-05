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
        import_row(row.to_h, row_number, synonym_map:)
      end
    end

    private

    def import_row(row, row_number, synonym_map:)
      source_id = parse_source_id(row["id"], row_number)
      staple = Staple.find_or_initialize_by(source_id: source_id)
      staple.assign_attributes(name_ja: row["name_ja"], name_en: row["name_en"], local_name: row["local_name"], fermented: parse_boolean(row["fermented"], row_number), description: row["notes"], source_url: row["source_url"], confidence: row["confidence"].presence, review_status: row["review_status"].presence || "starter", source_row_number: row_number)
      staple.save!
      import_staple_metric(staple, row, row_number) if (METRIC_COLUMNS & row.keys).any?
      # ... keep existing tagging behavior
      primary_region = split(row["region"]).first
      region_record = primary_region.present? ? Region.find_or_create_by!(name_en: primary_region) : nil
      split(row["region"]).each { |v| tag(staple, Region.find_or_create_by!(name_en: v), "region") }
      ingredient_family = find_ingredient_family(row["ingredient_family"])
      tag(staple, ingredient_family, "ingredient_family") if ingredient_family
      split(row["base_ingredients"]).each do |name|
        ingredient = Ingredient.find_or_create_by!(name_en: name)
        ingredient.update!(ingredient_family:) if ingredient.ingredient_family.nil? && ingredient_family
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
      SearchTerms::Rebuilder.call(staple, synonym_map:)
    end

    def import_staple_metric(staple, row, row_number)
      metric = StapleMetric.find_or_initialize_by(staple:)
      metric.assign_attributes(
        production_volume_note: row["production_volume_note"].presence,
        price_level: row["price_level"].presence,
        cultivation_ease: row["cultivation_ease"].presence,
        satiety_level: row["satiety_level"].presence,
        calories_kcal_per_100g: parse_decimal(row["calories_kcal_per_100g"], row_number, "calories_kcal_per_100g"),
        calorie_basis: row["calorie_basis"].presence,
        deliciousness_level: row["deliciousness_level"].presence,
        sweetness_level: row["sweetness_level"].presence,
        taste_profile: row["taste_profile"].presence,
        storage_duration: row["storage_duration"].presence,
        storage_method: row["storage_method"].presence,
        popularity_level: row["popularity_level"].presence,
        metrics_source_url: row["metrics_source_url"].presence,
        metrics_confidence: parse_decimal(row["metrics_confidence"], row_number, "metrics_confidence"),
        metrics_note: row["metrics_note"].presence
      )
      metric.save!
    end

    def parse_decimal(value, row_number, column)
      return nil if value.to_s.strip.empty?
      BigDecimal(value.to_s)
    rescue ArgumentError
      raise ArgumentError, "Invalid decimal at row #{row_number}, column #{column}: #{value}"
    end
    # rest
    def parse_source_id(value, row_number);raw=value.to_s.strip;raise ArgumentError, "Invalid id at row #{row_number}, column id: #{value}" if raw.blank?;id=Integer(raw, exception: false);raise ArgumentError, "Invalid id at row #{row_number}, column id: #{value}" if id.nil?||id<=0;id;end
    def parse_boolean(value, row_number);n=value.to_s.strip.downcase;return true if %w[true 1 yes y].include?(n);return false if %w[false 0 no n].include?(n)||n.blank?;raise ArgumentError, "Invalid boolean at row #{row_number}, column fermented: #{value}";end
    def find_ingredient_family(name);c=name.to_s.strip;return if c.blank?;IngredientFamily.find_or_create_by!(name_en: c);end
    def make_aliases(staple, row);{ "name_ja"=>row["name_ja"], "name_en"=>row["name_en"], "local_name"=>row["local_name"] }.each { |k, n|next if n.to_s.strip.empty?;staple.staple_aliases.find_or_create_by!(name: n.to_s.strip, kind: k) };split(row["similar_foods"]).each { |name|staple.staple_aliases.find_or_create_by!(name:, kind: "similar_food") };end
    def tag(staple, record, source_column);t=Tagging.find_or_initialize_by(staple:, taggable: record);t.source_column=source_column;t.weight=FeatureWeights.for(record.class.name);t.save!;end
    def split(value);value.to_s.split(",").map(&:strip).reject(&:blank?);end
  end
end
