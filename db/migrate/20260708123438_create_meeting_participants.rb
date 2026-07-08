class CreateMeetingParticipants < ActiveRecord::Migration[7.2]
  def change
    create_table :meeting_participants do |t|
      t.references :meeting, null: false, foreign_key: true
      t.references :employee, null: false, foreign_key: true

      t.timestamps
    end

    # Один сотрудник не может участвовать в одной встрече дважды
    add_index :meeting_participants, [:meeting_id, :employee_id], unique: true
  end
end
