require 'active_record'
require 'active_support/core_ext'
require 'pg'

require_relative 'marc_ingester'
require_relative 'elasticsearch_importer'

desc "Ingest MARC XML files"
task :ingest do
  MarcIngester.new.ingest!
end

desc "Import records into Elasticsearch"
task :import do
  $stdout.sync = true
  ElasticsearchImporter.new.import!
end
