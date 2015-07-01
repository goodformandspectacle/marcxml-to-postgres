class CreateRecords < ActiveRecord::Migration
  def change
    create_table :records do |table|

      table.text :title, null: false
      table.text :identifier, null: false

      table.jsonb :metadata, null: false, default: '{}'

    end

    add_index :records, :identifier, unique: true
    add_index :records, :metadata, using: :gin
  end
end
