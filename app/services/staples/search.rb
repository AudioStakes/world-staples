require "set"

module Staples
  class Search
    DEFAULT_LIMIT = 20

    Result = Data.define(:staple, :score, :matched_terms, :matched_search_terms)

    def self.call(query, limit: DEFAULT_LIMIT, filters: {})
      new(query:, limit:, filters:).call
    end

    def initialize(query:, limit: DEFAULT_LIMIT, filters: {})
      @query = query
      @limit = limit
      @filters = (filters || {}).symbolize_keys
      @synonym_map = SearchTerms::Rebuilder.preload_synonym_map
    end

    def call
      return [] if limit&.<= 0

      query_terms = normalize_query_terms(query)
      return [] if query_terms.empty?

      terms = SearchTerm.where(normalized_term: query_terms).includes(:staple)
      bucket = Hash.new { |h, k| h[k] = { score: 0.0, matched_terms: Set.new, matched_search_terms: [] } }

      terms.each do |term|
        row = bucket[term.staple]
        row[:score] += term.weight.to_f
        row[:matched_terms] << term.normalized_term
        row[:matched_search_terms] << term
      end

      results = bucket.map do |staple, data|
        Result.new(
          staple: staple,
          score: data[:score],
          matched_terms: data[:matched_terms].to_a.sort,
          matched_search_terms: data[:matched_search_terms]
        )
      end

      results = apply_filters(results)
      results = results.sort_by { |result| [ -result.score, result.staple.name_ja.to_s ] }
      limit.nil? ? results : results.first(limit)
    end

    private

    attr_reader :query, :limit, :filters, :synonym_map

    def normalize_query_terms(raw)
      return [] if raw.blank?

      normalized = TextNormalizer.normalize(raw)
      return [] if normalized.blank?

      normalized
        .split(/[\s,\/　]+/)
        .map(&:strip)
        .reject(&:blank?)
        .map { |term| normalize_with_synonym(term) }
        .uniq
    end

    def normalize_with_synonym(term)
      synonym_map[[ nil, term ]] || synonym_map[[ "ja", term ]] || synonym_map[[ "en", term ]] || term
    end

    def apply_filters(results)
      return results if filters.empty?

      results.select do |result|
        staple = result.staple
        fermented_match?(staple) && region_match?(staple) && ingredient_match?(staple) && cooking_method_match?(staple)
      end
    end

    def fermented_match?(staple)
      return true unless filters.key?(:fermented)

      staple.fermented == filters[:fermented]
    end

    def region_match?(staple)
      return true if filters[:region].blank?

      value = TextNormalizer.normalize(filters[:region])
      staple.regions.any? do |region|
        [ region.name_en, region.name_ja ].compact.map { |n| TextNormalizer.normalize(n) }.include?(value)
      end
    end

    def ingredient_match?(staple)
      return true if filters[:ingredient].blank?

      value = TextNormalizer.normalize(filters[:ingredient])
      staple.ingredients.any? do |ingredient|
        [ ingredient.name_en, ingredient.name_ja ].compact.map { |n| TextNormalizer.normalize(n) }.include?(value)
      end
    end

    def cooking_method_match?(staple)
      return true if filters[:cooking_method].blank?

      value = TextNormalizer.normalize(filters[:cooking_method])
      staple.cooking_methods.any? do |cooking_method|
        [ cooking_method.name_en, cooking_method.name_ja ].compact.map { |n| TextNormalizer.normalize(n) }.include?(value)
      end
    end
  end
end
