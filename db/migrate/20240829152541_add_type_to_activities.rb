class AddTypeToActivities < ActiveRecord::Migration[7.2]
  def change
    add_column :activities, :kind, :integer
    change_column_default :activities, :kind, from: nil, to: 0
    add_index :activities, :kind
  end
end
