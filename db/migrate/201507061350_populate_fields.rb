class PopulateFields < ActiveRecord::Migration
  class Record < ActiveRecord::Base
  end

  class Field < ActiveRecord::Base
  end

  def up
    '000'.upto('999').each do |tag|
      puts "Counting occurrences of field #{tag}…"
      count = Record.where("metadata ? '#{tag}'").count
      Field.create! tag: tag, count: count
    end
  end

  def down
    Field.destroy_all
  end
end
