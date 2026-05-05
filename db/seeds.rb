# frozen_string_literal: true

synonyms = {
  "米" => "rice", "ごはん" => "rice", "ライス" => "rice", "小麦" => "wheat",
  "トウモロコシ" => "maize", "とうもろこし" => "maize", "コーン" => "maize", "キャッサバ" => "cassava",
  "タピオカ" => "cassava", "麺" => "noodle", "めん" => "noodle", "薄焼き" => "flatbread",
  "発酵" => "fermented", "蒸す" => "steamed", "茹でる" => "boiled", "ゆでる" => "boiled",
  "酸っぱい" => "sour", "酸味" => "sour"
}

synonyms.each do |term, normalized|
  synonym = Synonym.find_or_initialize_by(term:, locale: "ja")
  synonym.normalized_term = normalized
  synonym.save!
end

catalog_300 = Rails.root.join("db/seeds/staple_catalog_300_with_metrics.csv")
legacy_catalog = Rails.root.join("db/seeds/staple_catalog.csv")
catalog_path = catalog_300.exist? ? catalog_300 : legacy_catalog
if catalog_path.exist?
  Imports::StapleCatalogImporter.new(path: catalog_path).call
else
  Rails.logger.warn("Skipping staple catalog import: no catalog CSV found")
end

ingredient_metrics = Rails.root.join("db/seeds/ingredient_metrics.csv")
if ingredient_metrics.exist?
  Imports::IngredientMetricsImporter.new(path: ingredient_metrics).call
else
  Rails.logger.warn("Skipping ingredient metrics import: db/seeds/ingredient_metrics.csv not found")
end

metric_sources = Rails.root.join("db/seeds/metric_sources.csv")
if metric_sources.exist?
  Imports::MetricSourcesImporter.new(path: metric_sources).call
else
  Rails.logger.warn("Skipping metric sources import: db/seeds/metric_sources.csv not found")
end
