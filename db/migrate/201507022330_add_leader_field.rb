class AddLeaderField < ActiveRecord::Migration
  def change
    add_column :records, :leader, :text, null: false
  end
end
