require 'elasticsearch'
require_relative 'models/record'

class ElasticsearchImporter
  def import!
    establish_connection

    logging = false
    index_name = 'library'

    client = Elasticsearch::Client.new url: ENV.fetch('SEARCHBOX_URL'), log: logging

    client.indices.delete index: index_name

    client.indices.create index: index_name,
      body: {
        mappings: {
          record: {
            properties: {
              title: {type: 'string', analyzer: :english},
              year: {type: 'string', index: :not_analyzed},
              subjects: {
                properties: {
                  id: { type: 'string', index: :not_analyzed},
                  label: { type: 'string', index: :not_analyzed},
                  scheme: { type: 'string', index: :not_analyzed}
                }
              },
              authors: {
                properties: {
                  id: { type: 'string', index: :not_analyzed},
                  name: { type: 'string', index: :not_analyzed}
                }
              }
            }
          }
        }
      }

    total = 0


    puts "Importing records into Elasticsearch…"

    Record.select(:id, :identifier, :title, :year, :metadata).find_in_batches do |records|
      puts "Importing records #{total + 1}–#{total + records.length}…"
      total = total + records.length

      body =
        records.map { |record|

          {
            index: {
              _index: index_name,
              _type:  'record',
              _id:    record.identifier,
              data:   record.to_elasticsearch
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
