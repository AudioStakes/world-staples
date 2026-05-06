class CreateMetricsTables < ActiveRecord::Migration[8.1]
  def change
    create_table :staple_metrics do |t|
      t.references :staple, null: false, foreign_key: true, index: false
      t.text :production_volume_note
      t.string :price_level
      t.string :cultivation_ease
      t.string :satiety_level
      t.decimal :calories_kcal_per_100g, precision: 8, scale: 2
      t.string :calorie_basis
      t.string :deliciousness_level
      t.string :sweetness_level
      t.string :taste_profile
      t.string :storage_duration
      t.string :storage_method
      t.string :popularity_level
      t.string :metrics_source_url
      t.decimal :metrics_confidence, precision: 4, scale: 2
      t.text :metrics_note
      t.timestamps
    end
    add_index :staple_metrics, :staple_id, unique: true
    add_index :staple_metrics, :price_level
    add_index :staple_metrics, :satiety_level
    add_index :staple_metrics, :storage_duration
    add_index :staple_metrics, :popularity_level

    create_table :ingredient_metrics do |t|
      t.references :ingredient, null: false, foreign_key: true, index: false
      t.string :ingredient_name_en, null: false
      t.string :ingredient_name_ja
      t.string :ingredient_family
      t.string :production_volume_level
      t.text :production_volume_note
      t.string :price_level
      t.string :cultivation_ease
      t.string :satiety_basis
      t.decimal :calories_kcal_per_100g_basic, precision: 8, scale: 2
      t.string :calorie_basis
      t.string :storage_duration
      t.string :storage_method
      t.text :representative_staples
      t.string :source_url
      t.decimal :confidence, precision: 4, scale: 2
      t.text :note
      t.timestamps
    end
    add_index :ingredient_metrics, :ingredient_id, unique: true
    add_index :ingredient_metrics, :ingredient_name_en
    add_index :ingredient_metrics, :production_volume_level
    add_index :ingredient_metrics, :price_level
    add_index :ingredient_metrics, :cultivation_ease

    create_table :metric_sources do |t|
      t.string :source_name, null: false
      t.string :metric_category
      t.string :source_url
      t.text :use_note
      t.text :license_or_access_note
      t.timestamps
    end
    add_index :metric_sources, :source_name, unique: true
    add_index :metric_sources, :metric_category
  end
end
