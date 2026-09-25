class AddUniqueIndexOnAnalysesActivityId < ActiveRecord::Migration[8.1]
  def up
    # Keep only the newest analysis per activity so the unique index can be built.
    safety_assured do
      execute <<~SQL
        DELETE FROM analyses
        WHERE id NOT IN (SELECT MAX(id) FROM analyses GROUP BY activity_id)
      SQL
    end

    remove_index :analyses, :activity_id, name: "index_analyses_on_activity_id"
    add_index :analyses, :activity_id, unique: true
  end

  def down
    remove_index :analyses, :activity_id
    add_index :analyses, :activity_id
  end
end
