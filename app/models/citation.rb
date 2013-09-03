# coding: UTF-8
class Citation < ActiveRecord::Base
  include Importers::Bolton::Catalog::Updater
  belongs_to :reference
  validates :reference, presence: true
  has_paper_trail

  include CleanNewlines
  before_save {|record| clean_newlines record, :notes_taxt}

  def title
    # for PaperTrailManager's RSS output
    id.to_s
  end

  def authorship_string
    reference and "#{author_names_string}, #{reference.year}"
  end

  def author_names_string
    names = reference.author_names.map &:last_name
    case
    when names.size == 0
      '[no authors]'
    when names.size == 1
      "#{names.first}"
    when names.size == 2
      "#{names.first} & #{names.second}"
    else
      string = names[0..-2].join ', '
      string << " & " << names[-1]
    end
  end

  #######
  def self.import data
    reference = Reference.find_by_bolton_key data
    notes_taxt = data[:notes] ? Importers::Bolton::Catalog::TextToTaxt.notes_item(data[:notes]) : nil
    create! reference: reference, pages: data[:pages], forms: data[:forms], notes_taxt: notes_taxt
  end

  def update_data data
    attributes = {}
    update_reference data
    update_field 'pages', data[:pages], attributes
    update_field 'forms', data[:forms], attributes
    update_notes_taxt data, attributes
    update_attributes attributes
  end

  def update_reference data
    before = reference
    after = Reference.find_by_bolton_key data
    if before != after
      Update.create! name: 'Citation', class_name: self.class.to_s, record_id: id, field_name: 'reference',
        before: before.key.to_s, after: after.key.to_s
      self.reference = after
    end
  end

  def update_notes_taxt data, attributes
    before = self['notes_taxt']
    after = data[:notes] ? Importers::Bolton::Catalog::TextToTaxt.notes_item(data[:notes]) : nil
    if before != after
      Update.create! name: 'Citation', class_name: self.class.to_s, record_id: id, field_name: 'notes_taxt',
        before: before, after: after
      attributes['notes_taxt'] = after
    end
  end

end
