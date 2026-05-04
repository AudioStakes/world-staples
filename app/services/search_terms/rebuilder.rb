require "set"

module SearchTerms
  class Rebuilder
    def self.call(staple) = new(staple).call

    def initialize(staple)
      @staple = staple
      @seen = Set.new
      @synonym_map = build_synonym_map
    end

    def call
      SearchTerm.transaction do
        staple.search_terms.delete_all
        add_staple_terms
        add_alias_terms
        staple.taggings.includes(:taggable).find_each { |tagging| add_taggable_terms(tagging) }
      end
    end

    private

    attr_reader :staple, :seen, :synonym_map

    def build_synonym_map
      Synonym.all.each_with_object({}) do |synonym, map|
        map[[ synonym.locale, synonym.term ]] = synonym.normalized_term
      end
    end

    def add_staple_terms
      { name_ja: staple.name_ja, name_en: staple.name_en, local_name: staple.local_name }.each do |column, value|
        add_term(value, "Staple", staple.id, column.to_s, FeatureWeights.for("Staple"))
      end
    end

    def add_alias_terms
      staple.staple_aliases.where.not(kind: "similar_food").find_each do |a|
        add_term(a.name, "StapleAlias", a.id, "name", FeatureWeights.for("StapleAlias"))
      end
    end

    def add_taggable_terms(tagging)
      taggable = tagging.taggable
      return if taggable.nil?

      [ [ "name_en", taggable.try(:name_en) ], [ "name_ja", taggable.try(:name_ja) ], [ "code", taggable.try(:code) ], [ "keyword", taggable.try(:keyword) ] ].each do |col, v|
        add_term(v, tagging.taggable_type, taggable.id, col, FeatureWeights.for(tagging.taggable_type))
      end
    end

    def add_term(raw, source_type, source_id, source_column, weight)
      return if raw.blank?

      normalized = normalize_with_synonym(raw)
      key = [ normalized, source_type, source_id, source_column ]
      return if seen.include?(key)

      seen << key
      staple.search_terms.create!(term: raw, normalized_term: normalized, source_type:, source_id:, source_column:, weight:)
    end

    def normalize_with_synonym(raw, locale: nil)
      normalized = TextNormalizer.normalize(raw)
      synonym_map[[ locale, normalized ]] || synonym_map[[ nil, normalized ]] || synonym_map[[ "ja", normalized ]] || normalized
    end
  end
end
