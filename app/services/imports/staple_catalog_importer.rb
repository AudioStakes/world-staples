require "csv"

module Imports
  class StapleCatalogImporter
    TAGGING_WEIGHTS = {
      "Ingredient" => 5.0,
      "IngredientFamily" => 3.5,
      "Form" => 4.0,
      "Shape" => 3.0,
      "ProcessingMethod" => 3.5,
      "CookingMethod" => 3.5,
      "Texture" => 2.0,
      "Region" => 1.5,
      "CountryArea" => 1.5,
      "ServingStyle" => 1.0,
      "StapleLevel" => 1.0,
      "SearchKeyword" => 0.8
    }.freeze

    def initialize(path: Rails.root.join("db/seeds/staple_catalog.csv"))
      @path = Pathname(path)
    end

    def call
      raise ArgumentError, "CSV file not found: #{@path}" unless @path.exist?

      CSV.foreach(@path, headers: true, encoding: "UTF-8").with_index(2) do |row, row_number|
        import_row(row.to_h, row_number)
      end
    end

    private

    def import_row(row, row_number)
      staple = Staple.find_or_initialize_by(name_ja: row["name_ja"].to_s.strip)
      staple.assign_attributes(
        name_en: row["name_en"],
        local_name: row["local_name"],
        category: row.key?("category") ? row["category"] : staple.category,
        fermented: parse_boolean(row["fermented"]),
        description: row["notes"],
        note: row["note"],
        source_url: row["source_url"],
        confidence: row["confidence"].presence,
        review_status: row["review_status"].presence || "starter",
        source_row_number: row_number
      )
      staple.save!

      ingredient_family = find_ingredient_family(row["ingredient_family"])
      tag(staple, ingredient_family, "ingredient_family") if ingredient_family

      split(row["base_ingredients"]).each do |name|
        ingredient = Ingredient.find_or_create_by!(name_en: name)
        ingredient.update!(ingredient_family:) if ingredient.ingredient_family.nil? && ingredient_family
        tag(staple, ingredient, "base_ingredients")
      end

      tag_names = {
        Form => ["form", :name_en],
        Shape => ["shape", :name_en],
        ProcessingMethod => ["processing", :name_en],
        CookingMethod => ["cooking_method", :name_en],
        Texture => ["texture", :name_en],
        Region => ["region", :name_en],
        CountryArea => ["country_area", :name_en],
        ServingStyle => ["served_with", :name_en],
        StapleLevel => ["staple_level", :code],
        SearchKeyword => ["search_keywords", :keyword]
      }

      tag_names.each do |klass, (column, key)|
        split(row[column]).each do |value|
          record = klass.find_or_create_by!(key => value)
          tag(staple, record, column)
        end
      end

      make_aliases(staple, row)
      SearchTerms::Rebuilder.call(staple)
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
      split(row["similar_foods"]).each { |name| staple.staple_aliases.find_or_create_by!(name:, kind: "similar_food") }
    end

    def tag(staple, record, source_column)
      tagging = Tagging.find_or_initialize_by(staple:, taggable: record)
      tagging.source_column = source_column if tagging.source_column.blank?
      default_weight = Tagging.column_defaults["weight"].to_d
      target_weight = TAGGING_WEIGHTS.fetch(record.class.name)
      tagging.weight = target_weight if tagging.weight.blank? || tagging.weight == default_weight
      tagging.save!
    end

    def parse_boolean(value)
      normalized = value.to_s.strip.downcase
      return true if %w[true 1 yes y].include?(normalized)
      return false if %w[false 0 no n].include?(normalized) || normalized.blank?

      false
    end

    def split(value)
      value.to_s.split(",").map(&:strip).reject(&:blank?)
    end
  end
end
