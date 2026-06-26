class CreateServices < ActiveRecord::Migration[8.1]
  def change
    create_table :services do |t|
      t.string :name, null: false
      t.string :url, null: false
      t.string :status, null: false, default: "operational"
      t.text :description

      t.timestamps
    end

    add_index :services, :name, unique: true
    add_index :services, :status
  end
end
