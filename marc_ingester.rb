require 'nokogiri'

require_relative 'models/record'


class MarcRecord

  def initialize(element)
    @element = element
  end

  def id
    datafield_subfield('907', 'a').gsub(".", "")
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
    element = datafield(tag_number).xpath('marc:subfield').detect {|e| e.attribute('code').to_s == subfield_letter }
    element ? element.content : nil
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

  def initialize
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

        record = Record.find_or_initialize_by(identifier: marc_record.id)
        record.title = marc_record.title
        record.metadata = marc_record.metadata
        record.save!

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