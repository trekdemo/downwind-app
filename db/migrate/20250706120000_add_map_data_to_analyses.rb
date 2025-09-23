class AddMapDataToAnalyses < ActiveRecord::Migration[8.0]
  def up
    add_column :analyses, :route_bounds, :json, null: true
    add_column :analyses, :route_center_lat, :decimal, precision: 10, scale: 6
    add_column :analyses, :route_center_lng, :decimal, precision: 10, scale: 6
    add_column :analyses, :max_speed_kmh, :decimal, precision: 5, scale: 2
    add_column :analyses, :min_speed_kmh, :decimal, precision: 5, scale: 2

    add_index :analyses, [:route_center_lat, :route_center_lng]
  end

  def down
    remove_index :analyses, [:route_center_lat, :route_center_lng]
    remove_column :analyses, :min_speed_kmh
    remove_column :analyses, :max_speed_kmh
    remove_column :analyses, :route_center_lng
    remove_column :analyses, :route_center_lat
    remove_column :analyses, :route_bounds
  end
end