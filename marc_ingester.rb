require 'nokogiri'

require_relative 'models/record'


class MarcRecord

  def initialize(element)
    @element = element
  end

  def id
    datafield_subfield('907', 'a').to_s.gsub(".", "")
  end

  def title
    key_title = datafield_subfield('245', 'a')
    qualifying_title = datafield_subfield('245', 'b')

    [key_title, qualifying_title].compact.join(' ')
  end

  def metadata

    @metadata = {}

    datafields.each do |datafield|

      @metadata[datafield.attribute('tag').to_s] ||= []


      field = datafield.to_h
      field.delete('tag')

      datafield.xpath('marc:subfield').each do |subfield|
        field[subfield.attribute('code').to_s] = subfield.content.to_s
      end

      @metadata[datafield.attribute('tag').to_s] << field
    end

    @metadata
  end

  def datafield_subfield(tag_number, subfield_letter)

    datafield = datafield(tag_number)

    unless datafield.nil?
      element = datafield(tag_number).xpath('marc:subfield').detect {|e| e.attribute('code').to_s == subfield_letter }
      element ? element.content : nil
    end

  end

  def datafield(tag_number)
    datafields.detect {|element| element.attribute("tag").to_s == tag_number }
  end

  private

  def datafields
    @datafields ||= @element.xpath('marc:datafield')
  end

end


class MarcIngester

  def initialize(optimize_for_insert = true)
    @optimize_for_insert = optimize_for_insert
  end

  def ingest!

    establish_connection

    files = 0
    records_count = 0


    Dir.entries("import").select {|file| file =~ /\.xml\z/ }.each do |file|

      files += 1

      file = File.open("import/#{file}")

      document = Nokogiri::XML::Document.parse(file)

      record_elements = document.xpath('//marc:record')
      records_count += record_elements.length

      record_elements.each do |record_element|

        marc_record = MarcRecord.new(record_element)

        if @optimize_for_insert

          # In this mode the code tries to insert the record, and falls back to finding and updating
          # the existing record if the insert fails a uniqueness index on the id.

          attributes = {identifier: marc_record.id, title: marc_record.title, metadata: marc_record.metadata}

          begin
            Record.create!(attributes)
          rescue ActiveRecord::RecordNotUnique
            record = Record.find_by!(identifier: marc_record.id)
            record.attributes = attributes
            record.save!
          end

        else

          # In this mode the code always looks for an existing record first, before deciding whether
          # to insert or update.

          record = Record.find_or_initialize_by(identifier: marc_record.id)
          record.title = marc_record.title
          record.metadata = marc_record.metadata
          record.save!

        end

      end

      print "\r#{records_count} records (#{files}/193) files"
      STDOUT.flush

    end

  end

  private

  def establish_connection
    ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
  end


end