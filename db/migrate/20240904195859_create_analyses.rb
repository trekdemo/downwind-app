class CreateAnalyses < ActiveRecord::Migration[7.2]
  def change
    create_table :analyses do |t|
      t.belongs_to :activity, foreign_key: true

      t.datetime :started_at
      t.datetime :ended_at
      t.float :duration, comment: 'Duration in seconds'

      t.integer :starts, comment: 'How many times came the board on foil. Speed goas above lift speed'

      t.float :time_on_foil, comment: 'Duration in seconds, speed above lift speed'
      t.virtual :time_on_foil_percentage, type: :float, stored: true,
                as: "time_on_foil / duration * 100"

      t.integer :distance_total, comment: 'In meters'
      t.integer :distance_on_foil, comment: 'In meters'
      t.virtual :distance_on_foil_percentage, type: :float, stored: true,
                as: "1.0 * distance_on_foil / distance_total * 100"

      t.float :speed_avg
      t.float :speed_max
      t.float :speed_avg_on_foil

      t.float :hr_avg
      t.float :hr_max

      t.timestamps
    end
  end
end
