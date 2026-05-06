# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_05_05_010000) do
  create_table "cooking_methods", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "heat_type"
    t.string "name_en", null: false
    t.string "name_ja"
    t.datetime "updated_at", null: false
    t.index ["name_en"], name: "index_cooking_methods_on_name_en", unique: true
  end

  create_table "country_areas", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name_en", null: false
    t.string "name_ja"
    t.integer "region_id"
    t.datetime "updated_at", null: false
    t.index ["name_en"], name: "index_country_areas_on_name_en", unique: true
    t.index ["region_id"], name: "index_country_areas_on_region_id"
  end

  create_table "forms", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name_en", null: false
    t.string "name_ja"
    t.datetime "updated_at", null: false
    t.index ["name_en"], name: "index_forms_on_name_en", unique: true
  end

  create_table "ingredient_families", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name_en", null: false
    t.string "name_ja"
    t.datetime "updated_at", null: false
    t.index ["name_en"], name: "index_ingredient_families_on_name_en", unique: true
  end

  create_table "ingredient_metrics", force: :cascade do |t|
    t.string "calorie_basis"
    t.decimal "calories_kcal_per_100g_basic", precision: 8, scale: 2
    t.decimal "confidence", precision: 4, scale: 2
    t.datetime "created_at", null: false
    t.string "cultivation_ease"
    t.string "ingredient_family"
    t.integer "ingredient_id", null: false
    t.string "ingredient_name_en", null: false
    t.string "ingredient_name_ja"
    t.text "note"
    t.string "price_level"
    t.string "production_volume_level"
    t.text "production_volume_note"
    t.text "representative_staples"
    t.string "satiety_basis"
    t.string "source_url"
    t.string "storage_duration"
    t.string "storage_method"
    t.datetime "updated_at", null: false
    t.index ["cultivation_ease"], name: "index_ingredient_metrics_on_cultivation_ease"
    t.index ["ingredient_id"], name: "index_ingredient_metrics_on_ingredient_id", unique: true
    t.index ["ingredient_name_en"], name: "index_ingredient_metrics_on_ingredient_name_en"
    t.index ["price_level"], name: "index_ingredient_metrics_on_price_level"
    t.index ["production_volume_level"], name: "index_ingredient_metrics_on_production_volume_level"
  end

  create_table "ingredients", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "ingredient_family_id"
    t.string "name_en", null: false
    t.string "name_ja"
    t.datetime "updated_at", null: false
    t.index ["ingredient_family_id"], name: "index_ingredients_on_ingredient_family_id"
    t.index ["name_en"], name: "index_ingredients_on_name_en", unique: true
    t.index ["name_ja"], name: "index_ingredients_on_name_ja"
  end

  create_table "metric_sources", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "license_or_access_note"
    t.string "metric_category"
    t.string "source_name", null: false
    t.string "source_url"
    t.datetime "updated_at", null: false
    t.text "use_note"
    t.index ["metric_category"], name: "index_metric_sources_on_metric_category"
    t.index ["source_name"], name: "index_metric_sources_on_source_name", unique: true
  end

  create_table "processing_methods", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name_en", null: false
    t.string "name_ja"
    t.datetime "updated_at", null: false
    t.index ["name_en"], name: "index_processing_methods_on_name_en", unique: true
  end

  create_table "regions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name_en", null: false
    t.string "name_ja"
    t.integer "parent_region_id"
    t.datetime "updated_at", null: false
    t.index ["name_en"], name: "index_regions_on_name_en", unique: true
    t.index ["parent_region_id"], name: "index_regions_on_parent_region_id"
  end

  create_table "search_keywords", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "keyword", null: false
    t.string "locale"
    t.string "normalized_keyword"
    t.datetime "updated_at", null: false
    t.index ["keyword", "locale"], name: "index_search_keywords_on_keyword_and_locale", unique: true
    t.index ["normalized_keyword"], name: "index_search_keywords_on_normalized_keyword"
  end

  create_table "search_terms", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "normalized_term", null: false
    t.string "source_column"
    t.bigint "source_id"
    t.string "source_type", null: false
    t.integer "staple_id", null: false
    t.string "term", null: false
    t.datetime "updated_at", null: false
    t.decimal "weight", precision: 6, scale: 2, default: "1.0", null: false
    t.index ["normalized_term"], name: "index_search_terms_on_normalized_term"
    t.index ["source_type", "source_id"], name: "index_search_terms_on_source_type_and_source_id"
    t.index ["staple_id", "normalized_term"], name: "index_search_terms_on_staple_id_and_normalized_term"
    t.index ["staple_id"], name: "index_search_terms_on_staple_id"
  end

  create_table "serving_styles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name_en", null: false
    t.string "name_ja"
    t.datetime "updated_at", null: false
    t.index ["name_en"], name: "index_serving_styles_on_name_en", unique: true
  end

  create_table "shapes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name_en", null: false
    t.string "name_ja"
    t.datetime "updated_at", null: false
    t.index ["name_en"], name: "index_shapes_on_name_en", unique: true
  end

  create_table "staple_aliases", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "kind"
    t.string "locale"
    t.string "name", null: false
    t.string "normalized_name"
    t.integer "staple_id", null: false
    t.datetime "updated_at", null: false
    t.index ["normalized_name"], name: "index_staple_aliases_on_normalized_name"
    t.index ["staple_id", "name", "kind"], name: "index_staple_aliases_on_staple_id_and_name_and_kind", unique: true
    t.index ["staple_id"], name: "index_staple_aliases_on_staple_id"
  end

  create_table "staple_levels", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name_ja"
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_staple_levels_on_code", unique: true
  end

  create_table "staple_metrics", force: :cascade do |t|
    t.string "calorie_basis"
    t.decimal "calories_kcal_per_100g", precision: 8, scale: 2
    t.datetime "created_at", null: false
    t.string "cultivation_ease"
    t.string "deliciousness_level"
    t.decimal "metrics_confidence", precision: 4, scale: 2
    t.text "metrics_note"
    t.string "metrics_source_url"
    t.string "popularity_level"
    t.string "price_level"
    t.text "production_volume_note"
    t.string "satiety_level"
    t.integer "staple_id", null: false
    t.string "storage_duration"
    t.string "storage_method"
    t.string "sweetness_level"
    t.string "taste_profile"
    t.datetime "updated_at", null: false
    t.index ["popularity_level"], name: "index_staple_metrics_on_popularity_level"
    t.index ["price_level"], name: "index_staple_metrics_on_price_level"
    t.index ["satiety_level"], name: "index_staple_metrics_on_satiety_level"
    t.index ["staple_id"], name: "index_staple_metrics_on_staple_id", unique: true
    t.index ["storage_duration"], name: "index_staple_metrics_on_storage_duration"
  end

  create_table "staples", force: :cascade do |t|
    t.string "category"
    t.decimal "confidence", precision: 4, scale: 2
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "fermented", default: false, null: false
    t.string "local_name"
    t.string "name_en"
    t.string "name_ja", null: false
    t.text "note"
    t.string "review_status", default: "starter", null: false
    t.integer "source_id", null: false
    t.integer "source_row_number"
    t.string "source_url"
    t.datetime "updated_at", null: false
    t.index ["name_en"], name: "index_staples_on_name_en"
    t.index ["name_ja"], name: "index_staples_on_name_ja"
    t.index ["review_status"], name: "index_staples_on_review_status"
    t.index ["source_id"], name: "index_staples_on_source_id", unique: true
  end

  create_table "synonyms", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "locale"
    t.string "normalized_term", null: false
    t.text "note"
    t.string "term", null: false
    t.datetime "updated_at", null: false
    t.index ["normalized_term"], name: "index_synonyms_on_normalized_term"
    t.index ["term", "locale"], name: "index_synonyms_on_term_and_locale", unique: true
  end

  create_table "taggings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "note"
    t.boolean "primary", default: false, null: false
    t.string "source_column"
    t.integer "staple_id", null: false
    t.bigint "taggable_id", null: false
    t.string "taggable_type", null: false
    t.datetime "updated_at", null: false
    t.decimal "weight", precision: 4, scale: 2, default: "1.0", null: false
    t.index ["staple_id", "taggable_type", "taggable_id"], name: "index_taggings_on_staple_and_taggable", unique: true
    t.index ["staple_id", "taggable_type"], name: "index_taggings_on_staple_and_type"
    t.index ["staple_id"], name: "index_taggings_on_staple_id"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable"
  end

  create_table "textures", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name_en", null: false
    t.string "name_ja"
    t.datetime "updated_at", null: false
    t.index ["name_en"], name: "index_textures_on_name_en", unique: true
  end

  add_foreign_key "country_areas", "regions"
  add_foreign_key "ingredient_metrics", "ingredients"
  add_foreign_key "ingredients", "ingredient_families"
  add_foreign_key "regions", "regions", column: "parent_region_id"
  add_foreign_key "search_terms", "staples"
  add_foreign_key "staple_aliases", "staples"
  add_foreign_key "staple_metrics", "staples"
  add_foreign_key "taggings", "staples"
end
