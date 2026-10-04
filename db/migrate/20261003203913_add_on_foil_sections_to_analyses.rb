class AddOnFoilSectionsToAnalyses < ActiveRecord::Migration[8.1]
  def change
    add_column :analyses, :on_foil_sections, :json
  end
end
