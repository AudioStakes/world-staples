class MakeMetricFkIndexesUnique < ActiveRecord::Migration[8.1]
  def change
    remove_index :staple_metrics, :staple_id if index_exists?(:staple_metrics, :staple_id)
    add_index :staple_metrics, :staple_id, unique: true

    remove_index :ingredient_metrics, :ingredient_id if index_exists?(:ingredient_metrics, :ingredient_id)
    add_index :ingredient_metrics, :ingredient_id, unique: true
  end
end
