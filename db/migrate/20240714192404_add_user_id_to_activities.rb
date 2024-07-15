class AddUserIdToActivities < ActiveRecord::Migration[7.1]
  def change
    add_reference :activities, :user, foreign_key: true
    safety_assured do
      execute 'UPDATE activities SET user_id = (SELECT id FROM users LIMIT 1)'
    end
    change_column_null :activities, :user_id, false
  end
end
