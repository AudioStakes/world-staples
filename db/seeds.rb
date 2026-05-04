synonyms = {
  "米" => "rice", "ごはん" => "rice", "ライス" => "rice", "小麦" => "wheat",
  "トウモロコシ" => "maize", "とうもろこし" => "maize", "コーン" => "maize", "キャッサバ" => "cassava",
  "タピオカ" => "cassava", "麺" => "noodle", "めん" => "noodle", "薄焼き" => "flatbread",
  "発酵" => "fermented", "蒸す" => "steamed", "茹でる" => "boiled", "ゆでる" => "boiled",
  "酸っぱい" => "sour", "酸味" => "sour"
}

synonyms.each do |term, normalized|
  Synonym.find_or_create_by!(term:, locale: "ja") { |s| s.normalized_term = normalized }
end

xlsx_path = Rails.root.join("db/seeds/world_staple_catalog_starter.xlsx")
if xlsx_path.exist?
  Imports::StapleCatalogImporter.new(path: xlsx_path).call
else
  Rails.logger.warn("Skipping staple catalog import: #{xlsx_path} not found")
end
