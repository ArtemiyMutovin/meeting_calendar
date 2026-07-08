class CreateEmployees < ActiveRecord::Migration[7.2]
  def change
    create_table :employees do |t|
      t.string :name, null: false
      t.string :email

      t.timestamps
    end

    add_index :employees, :name, unique: true
  end
end
