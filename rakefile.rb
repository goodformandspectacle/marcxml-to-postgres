require 'active_record'
require 'active_support/core_ext'
require 'pg'

require_relative 'marc_ingester'

desc "Ingest MARC XML files"
task :ingest do
  MarcIngester.new.ingest!
end


namespace :db do

  desc "Run migrations"
  task :migrate do
    ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
    ActiveRecord::Migrator.migrate('db/migrate', ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
  end

end