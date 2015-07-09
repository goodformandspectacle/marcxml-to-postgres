require 'elasticsearch'
require_relative 'models/record'

class ElasticsearchImporter
  def import!
    establish_connection
    client = Elasticsearch::Client.new url: ENV.fetch('SEARCHBOX_URL')

    total = 0
    puts "Importing records into Elasticsearch…"

    Record.find_in_batches do |records|
      puts "Importing records #{total + 1}–#{total + records.length}…"
      total = total + records.length

      body =
        records.map { |record|
          {
            index: {
              _index: 'library',
              _type:  'record',
              _id:    record.identifier,
              data:   record.metadata.merge(record.attributes.slice(:title, :leader))
            }
          }
        }

      client.bulk body: body
    end

    puts "Finished importing #{total} records"
  end

  private

  def establish_connection
    ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
  end
end
