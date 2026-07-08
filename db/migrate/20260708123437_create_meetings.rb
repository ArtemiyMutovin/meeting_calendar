class CreateMeetings < ActiveRecord::Migration[7.2]
  def change
    create_table :meetings do |t|
      t.string :title, null: false
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false

      t.timestamps
    end

    add_index :meetings, :starts_at
  end
end
