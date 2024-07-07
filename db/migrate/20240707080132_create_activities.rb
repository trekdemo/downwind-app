class CreateActivities < ActiveRecord::Migration[7.1]
  def change
    create_table :activities do |t|
      t.string :title, null: false
      t.decimal :lift_speed_kmh, null: false, default: 15.0
      t.timestamp :started_at, null: false

      t.timestamps
    end
  end
end
