class CreateFields < ActiveRecord::Migration
  def change
    create_table :fields do |table|
      table.text :tag, null: false
      table.integer :count, null: false
    end

    add_index :fields, :tag, unique: true
  end
end
