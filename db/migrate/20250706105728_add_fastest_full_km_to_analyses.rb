class AddFastestFullKmToAnalyses < ActiveRecord::Migration[8.0]
  def up
    add_column :analyses, :fastest_full_km, :integer, comment: "In seconds"
    change_column_default :analyses, :fastest_full_km, 0
  end

  def down
    remove_column :analyses, :fastest_full_km
  end
end
