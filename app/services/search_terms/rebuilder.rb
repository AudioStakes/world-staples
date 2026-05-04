module SearchTerms
  class Rebuilder
    WEIGHTS = {
      "Staple" => 10.0,
      "StapleAlias" => 8.0,
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

    def self.call(staple) = new(staple).call

    def initialize(staple)
      @staple = staple
      @seen = Set.new
    end

    def call
      staple.search_terms.delete_all
      add_staple_terms
      add_alias_terms
      staple.taggings.includes(:taggable).find_each { |tagging| add_taggable_terms(tagging) }
    end

    private

    attr_reader :staple, :seen

    def add_staple_terms
      { name_ja: staple.name_ja, name_en: staple.name_en, local_name: staple.local_name }.each do |column, value|
        add_term(value, "Staple", staple.id, column.to_s, WEIGHTS.fetch("Staple"))
      end
    end

    def add_alias_terms
      staple.staple_aliases.find_each { |a| add_term(a.name, "StapleAlias", a.id, "name", WEIGHTS.fetch("StapleAlias")) }
    end

    def add_taggable_terms(tagging)
      taggable = tagging.taggable
      return if taggable.nil?
      [["name_en", taggable.try(:name_en)], ["name_ja", taggable.try(:name_ja)], ["code", taggable.try(:code)], ["keyword", taggable.try(:keyword)]].each do |col, v|
        add_term(v, tagging.taggable_type, taggable.id, col, WEIGHTS.fetch(tagging.taggable_type))
      end
    end

    def add_term(raw, source_type, source_id, source_column, weight)
      return if raw.blank?
      normalized = normalize_with_synonym(raw)
      key = [normalized, source_type, source_id, source_column]
      return if seen.include?(key)
      seen << key
      staple.search_terms.create!(term: raw, normalized_term: normalized, source_type:, source_id:, source_column:, weight:)
    end

    def normalize_with_synonym(raw)
      normalized = TextNormalizer.normalize(raw)
      Synonym.find_by(term: normalized)&.normalized_term || normalized
    end
  end
end
