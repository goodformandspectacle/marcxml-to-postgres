require 'active_record'

class Record < ActiveRecord::Base

  SCHEME_MAPPINGS = {
    '0' => 'library_of_congress_subject_headings',
    '1' => 'library_of_congress_childrens_subject_headings',
    '2' => 'medical_subject_headings',
    '3' => 'national_agricultural_library_subject_authority_file',
    '5' => 'canadian_subject_headings',
    '6' => 'repertoire_de_vedettes-matiere'
  }


  def to_elasticsearch

    subjects = metadata.fetch('650', []).collect do |field|
      {id: field['0'], label: field['a'], scheme: SCHEME_MAPPINGS.fetch(field['ind2'], field['2']) }
    end

    authors = metadata.fetch('100', []).collect do |field|
      {id: field['0'], name: field['a']}
    end

    {
      identifier: identifier,
      title: title,
      year: year,
      subjects: subjects,
      authors: authors
    }
    #.merge(metadata)

  end

end