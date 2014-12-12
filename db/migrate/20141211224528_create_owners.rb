class CreateOwners < ActiveRecord::Migration
  def change
    create_table :owners do |t|
      t.timestamps null: false
      t.integer :github_id, null: false
      t.string :github_name, null: false

      t.index :github_name, unique: true
      t.index :github_id, unique: true
    end
  end
end
