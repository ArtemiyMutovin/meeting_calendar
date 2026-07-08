class AddOverlapExclusionToMeetingParticipants < ActiveRecord::Migration[7.2]
  def up
    # GiST-индекс по скалярному = требует расширения btree_gist
    enable_extension "btree_gist" unless extension_enabled?("btree_gist")

    # Денормализуем время встречи на строку участника: exclusion constraint
    # работает в пределах одной таблицы.
    add_column :meeting_participants, :starts_at, :datetime
    add_column :meeting_participants, :ends_at, :datetime

    execute <<~SQL
      UPDATE meeting_participants mp
      SET starts_at = m.starts_at, ends_at = m.ends_at
      FROM meetings m
      WHERE mp.meeting_id = m.id
    SQL

    change_column_null :meeting_participants, :starts_at, false
    change_column_null :meeting_participants, :ends_at, false

    # Гарантия на уровне БД: у одного сотрудника не может быть двух встреч
    # с пересекающимися интервалами [starts_at, ends_at) (полуоткрытый —
    # встречи 10:00–11:00 и 11:00–12:00 не конфликтуют).
    execute <<~SQL
      ALTER TABLE meeting_participants
      ADD CONSTRAINT no_overlapping_meetings
      EXCLUDE USING gist (
        employee_id WITH =,
        tsrange(starts_at, ends_at) WITH &&
      )
    SQL
  end

  def down
    execute "ALTER TABLE meeting_participants DROP CONSTRAINT IF EXISTS no_overlapping_meetings"
    remove_column :meeting_participants, :starts_at
    remove_column :meeting_participants, :ends_at
    disable_extension "btree_gist"
  end
end
