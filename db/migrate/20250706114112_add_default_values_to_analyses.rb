class AddDefaultValuesToAnalyses < ActiveRecord::Migration[8.0]
  def change
    change_column_default :analyses, :duration, from: nil, to: 0
    change_column_default :analyses, :starts, from: nil, to: 0
    change_column_default :analyses, :time_on_foil, from: nil, to: 0
    change_column_default :analyses, :distance_total, from: nil, to: 0
    change_column_default :analyses, :distance_on_foil, from: nil, to: 0
    change_column_default :analyses, :speed_avg, from: nil, to: 0
    change_column_default :analyses, :speed_max, from: nil, to: 0
    change_column_default :analyses, :speed_avg_on_foil, from: nil, to: 0
    change_column_default :analyses, :hr_avg, from: nil, to: 0
    change_column_default :analyses, :hr_max, from: nil, to: 0
  end
end
