class AddFastestFull10kmToAnalyses < ActiveRecord::Migration[8.1]
  def change
    add_column :analyses, :fastest_full_10km, :integer
  end
end
