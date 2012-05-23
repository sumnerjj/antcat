# coding: UTF-8
class Species < Taxon
  belongs_to :subfamily
  belongs_to :genus
  belongs_to :subgenus
  has_many :subspecies, order: :name
  before_create :set_subfamily

  def set_subfamily
    self.subfamily = genus.subfamily if genus
  end

  def children
    subspecies
  end

  def full_name
    "#{genus.name} #{name}"
  end

  def full_label
    "<i>#{full_name}</i>"
  end

  def statistics
    get_statistics [:subspecies]
  end

  def siblings
    genus.species
  end

  def self.import data
    transaction do
      protonym = Protonym.import data[:protonym] if data[:protonym]

      attributes = {
        genus: data[:genus],
        name: data[:name],
        fossil: data[:fossil] || false,
        status: data[:status] || 'valid',
        protonym: protonym,
      }

      species = create! attributes
      data[:history].each do |item|
        species.taxonomic_history_items.create! taxt: item
      end
      set_status_from_history species, data[:raw_history]

      species
    end
  end

  def self.set_status_from_history species, history
    return unless history
    synonym_of = history.first[:synonym_ofs].try :first
    if synonym_of
      genus = species.genus
      senior_name = synonym_of[:species_epithet]
      senior = Species.find_by_genus_id_and_name genus.id, senior_name
      if senior
        species.update_attributes status: 'synonym', synonym_of: senior
      else
        ForwardReference.create! source_id: species.id, target_parent: genus.id, target_name: senior_name
      end
    else
      species.update_attributes status: 'valid'
    end
  end

end
