class AddMapDataToAnalyses < ActiveRecord::Migration[8.0]
  def up
    add_column :analyses, :route_bounds, :json, null: true
  end

  def down
    remove_column :analyses, :route_bounds
  end
end
