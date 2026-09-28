class AddRoutePreviewToAnalyses < ActiveRecord::Migration[8.1]
  def change
    add_column :analyses, :route_preview, :json
  end
end
