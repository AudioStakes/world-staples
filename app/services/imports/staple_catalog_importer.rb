module Imports
  class StapleCatalogImporter
    def initialize(path: Rails.root.join("db/seeds/world_staple_catalog_starter.xlsx"))
      @path = Pathname(path)
    end

    def call
      raise ArgumentError, "Excel file not found: #{@path}" unless @path.exist?
      xlsx = Roo::Excelx.new(@path.to_s)
      sheet = xlsx.sheet("Staple_Catalog")
      headers = sheet.row(1).map { |h| h.to_s.strip }
      (2..sheet.last_row).each { |i| import_row(headers.zip(sheet.row(i)).to_h, i) }
    end

    private

    def import_row(row, row_number)
      staple = Staple.find_or_initialize_by(name_ja: row["name_ja"].to_s.strip)
      staple.assign_attributes(name_en: row["name_en"], local_name: row["local_name"], source_row_number: row_number)
      staple.save!
      make_aliases(staple, row)
      tag(staple, IngredientFamily, row["ingredient_family"], "ingredient_family", :name_en)
      split(row["base_ingredients"]).each { |v| tag(staple, Ingredient, v, "base_ingredients", :name_en) }
      { Form=>"form", Shape=>"shape", ProcessingMethod=>"processing", CookingMethod=>"cooking_method", Texture=>"texture", Region=>"region", CountryArea=>"country_area", ServingStyle=>"served_with", StapleLevel=>"staple_level", SearchKeyword=>"search_keywords" }.each do |klass,col|
        split(row[col]).each { |v| tag(staple, klass, v, col, klass == StapleLevel ? :code : (klass == SearchKeyword ? :keyword : :name_en)) }
      end
      SearchTerms::Rebuilder.call(staple)
    end

    def make_aliases(staple, row)
      { "name_ja"=>row["name_ja"], "name_en"=>row["name_en"], "local_name"=>row["local_name"] }.each do |kind, name|
        next if name.to_s.strip.empty?
        staple.staple_aliases.find_or_create_by!(name: name.to_s.strip, kind: kind)
      end
      split(row["similar_foods"]).each { |n| staple.staple_aliases.find_or_create_by!(name: n, kind: "similar_food") }
    end

    def tag(staple, klass, value, source_column, key)
      return if value.to_s.strip.empty?
      record = klass.find_or_create_by!(key => value.to_s.strip)
      Tagging.find_or_create_by!(staple:, taggable: record) { |t| t.source_column = source_column }
    end

    def split(value) = value.to_s.split(",").map(&:strip).reject(&:empty?)
  end
end
