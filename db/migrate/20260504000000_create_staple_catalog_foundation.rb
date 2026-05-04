class CreateStapleCatalogFoundation < ActiveRecord::Migration[8.1]
  def change
    create_table :staples do |t|
      t.string :name_ja, null: false
      t.string :name_en
      t.string :local_name
      t.string :category
      t.boolean :fermented, null: false, default: false
      t.text :description
      t.string :source_url
      t.decimal :confidence, precision: 4, scale: 2
      t.string :review_status, null: false, default: "starter"
      t.text :note
      t.integer :source_row_number
      t.timestamps
    end
    add_index :staples, :name_ja
    add_index :staples, :name_en
    add_index :staples, :review_status

    create_table :ingredient_families do |t|
      t.string :name_en, null: false
      t.string :name_ja
      t.text :description
      t.timestamps
    end
    add_index :ingredient_families, :name_en, unique: true

    create_table :ingredients do |t|
      t.string :name_en, null: false
      t.string :name_ja
      t.references :ingredient_family, foreign_key: true
      t.text :description
      t.timestamps
    end
    add_index :ingredients, :name_en, unique: true
    add_index :ingredients, :name_ja

    %i[forms shapes processing_methods textures serving_styles].each do |table_name|
      create_table table_name do |t|
        t.string :name_en, null: false
        t.string :name_ja
        t.text :description
        t.timestamps
      end
      add_index table_name, :name_en, unique: true
    end

    create_table :cooking_methods do |t|
      t.string :name_en, null: false
      t.string :name_ja
      t.string :heat_type
      t.text :description
      t.timestamps
    end
    add_index :cooking_methods, :name_en, unique: true

    create_table :regions do |t|
      t.string :name_en, null: false
      t.string :name_ja
      t.references :parent_region, foreign_key: { to_table: :regions }
      t.text :description
      t.timestamps
    end
    add_index :regions, :name_en, unique: true
    add_index :regions, :parent_region_id

    create_table :country_areas do |t|
      t.string :name_en, null: false
      t.string :name_ja
      t.references :region, foreign_key: true
      t.text :description
      t.timestamps
    end
    add_index :country_areas, :name_en, unique: true
    add_index :country_areas, :region_id

    create_table :staple_levels do |t|
      t.string :code, null: false
      t.string :name_ja
      t.text :description
      t.timestamps
    end
    add_index :staple_levels, :code, unique: true

    create_table :search_keywords do |t|
      t.string :keyword, null: false
      t.string :normalized_keyword
      t.string :locale
      t.text :description
      t.timestamps
    end
    add_index :search_keywords, %i[keyword locale], unique: true
    add_index :search_keywords, :normalized_keyword

    create_table :taggings do |t|
      t.references :staple, null: false, foreign_key: true
      t.string :taggable_type, null: false
      t.bigint :taggable_id, null: false
      t.decimal :weight, precision: 4, scale: 2, null: false, default: 1.0
      t.boolean :primary, null: false, default: false
      t.string :source_column
      t.text :note
      t.timestamps
    end
    add_index :taggings, %i[staple_id taggable_type taggable_id], unique: true, name: "index_taggings_on_staple_and_taggable"
    add_index :taggings, %i[taggable_type taggable_id], name: "index_taggings_on_taggable"
    add_index :taggings, %i[staple_id taggable_type], name: "index_taggings_on_staple_and_type"

    create_table :staple_aliases do |t|
      t.references :staple, null: false, foreign_key: true
      t.string :name, null: false
      t.string :normalized_name
      t.string :locale
      t.string :kind
      t.timestamps
    end
    add_index :staple_aliases, :normalized_name
    add_index :staple_aliases, %i[staple_id name kind], unique: true

    create_table :synonyms do |t|
      t.string :term, null: false
      t.string :normalized_term, null: false
      t.string :locale
      t.text :note
      t.timestamps
    end
    add_index :synonyms, %i[term locale], unique: true
    add_index :synonyms, :normalized_term

    create_table :search_terms do |t|
      t.references :staple, null: false, foreign_key: true
      t.string :term, null: false
      t.string :normalized_term, null: false
      t.string :source_type, null: false
      t.bigint :source_id
      t.string :source_column
      t.decimal :weight, precision: 6, scale: 2, null: false, default: 1.0
      t.timestamps
    end
    add_index :search_terms, :normalized_term
    add_index :search_terms, %i[staple_id normalized_term]
    add_index :search_terms, %i[source_type source_id]
  end
end
