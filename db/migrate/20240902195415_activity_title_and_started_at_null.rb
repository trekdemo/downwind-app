class ActivityTitleAndStartedAtNull < ActiveRecord::Migration[7.2]
  def change
    change_column_null(:activities, :title, true)
    change_column_null(:activities, :started_at, true)
  end
end
