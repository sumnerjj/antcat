# coding: UTF-8
def reference_factory attributes = {}
  name = attributes.delete :author_name
  author_name = AuthorName.find_by_name name
  author_name ||= FactoryGirl.create :author_name, name: name
  reference = FactoryGirl.create(:reference, attributes.merge(:author_names => [author_name]))
  reference
end

FactoryGirl.define do

  factory :hol_datum do
    name "Atta major"
    author 'Fisher, B.L.'
    rank 'Species'
    status 'Original name/combination'
    is_valid 'Valid'
    fossil 0
    tnuid 5678
  end

  factory :hol_taxon_datum do
    name "Atta major"
    rank 'Species'
    status 'Original name/combination'
    is_valid 'Valid'
    fossil 0
    tnuid 5678
  end

  factory :taxon_state do
    review_state 'old'
    deleted 0
  end

  factory :author

  factory :author_name do
    sequence(:name) { |n| "Fisher#{n}, B.L." }
    author
  end

  factory :journal do
    sequence(:name) { |n| "Ants#{n}" }
  end

  factory :publisher do
    name 'Wiley'
    place
  end

  factory :place do
    name 'New York'
  end

  factory :reference do
    sequence(:title) { |n| "Ants are my life#{n}" }
    sequence(:citation_year) { |n| "201#{n}d" }
    author_names { [FactoryGirl.create(:author_name)] }
  end

  factory :article_reference do
    author_names { [FactoryGirl.create(:author_name)] }
    sequence(:title) { |n| "Ants are my life#{n}" }
    sequence(:citation_year) { |n| "201#{n}d" }
    journal
    sequence(:series_volume_issue) { |n| n }
    sequence(:pagination) { |n| n }
    doi '10.10.1038/nphys1170'
  end

  factory :book_reference do
    author_names { [FactoryGirl.create(:author_name)] }
    sequence(:title) { |n| "Ants are my life#{n}" }
    sequence(:citation_year) { |n| "201#{n}d" }
    publisher
    pagination '22 pp.'
    doi '10.10.1038/nphys1170'
  end

  factory :unknown_reference do
    author_names { [FactoryGirl.create(:author_name)] }
    sequence(:title) { |n| "Ants are my life#{n}" }
    sequence(:citation_year) { |n| "201#{n}d" }
    citation 'New York'
  end

  factory :missing_reference do
    title '(missing)'
    citation_year '2009'
    citation 'Latreille, 2009'
  end

  factory :nested_reference do
    author_names { [FactoryGirl.create(:author_name)] }
    sequence(:title) { |n| "Nested ants #{n}" }
    sequence(:citation_year) { |n| "201#{n}d" }
    pages_in 'In: '
    nesting_reference { FactoryGirl.create :book_reference }
    doi '10.10.1038/nphys1170'
  end

  factory :user do
    name 'Mark Wilden'
    sequence(:email) { |n| "mark#{n}@example.com" }
    password 'secret'
  end

  factory :editor, class: User do
    name 'Brian Fisher'
    sequence(:email) { |n| "brian#{n}@example.com" }
    password 'secret'
  end

  factory :bolton_reference, :class => Bolton::Reference do
    title 'New General Catalog'
    citation_year '2011'
    authors 'Fisher, B.L.'
  end

  factory :bolton_match, :class => Bolton::Match do
    bolton_reference
    reference
    similarity 0.9
  end

  factory :reference_document do
  end

  factory :synonym do
    association :junior_synonym, factory: :genus
    association :senior_synonym, factory: :genus
  end

  factory :reference_author_name do
    association :reference
    association :author_name
  end

  ####################################################
  factory :name do
    sequence(:name) { |n| raise }
    name_html { name }
    epithet { name }
    epithet_html { name_html }
  end

  factory :family_or_subfamily_name do
    name 'FamilyOrSubfamily'
    name_html { name }
    epithet { name }
    epithet_html { name_html }
  end

  factory :family_name do
    name 'Family'
    name_html { name }
    epithet { name }
    epithet_html { name_html }
  end

  factory :subfamily_name do
    sequence(:name) { |n| "Subfamily#{n}" }
    name_html { name }
    epithet { name }
    epithet_html { name_html }
  end

  factory :tribe_name do
    sequence(:name) { |n| "Tribe#{n}" }
    name_html { name }
    epithet { name }
    epithet_html { name_html }
  end

  factory :subtribe_name do
    sequence(:name) { |n| "Subtribe#{n}" }
    name_html { name }
    epithet { name }
    epithet_html { name_html }
  end

  factory :genus_name do
    sequence(:name) { |n| "Genus#{n}" }
    name_html { "<i>#{name}</i>" }
    epithet { name }
    epithet_html { "<i>#{name}</i>" }
  end

  factory :subgenus_name do
    sequence(:name) { |n| "Atta (Subgenus#{n})" }
    name_html { "<i>Atta</i> <i>(#{name})</i>" }
    epithet { name.split(' ').last }
    epithet_html { "<i>#{epithet}</i>" }
  end

  factory :species_name do
    sequence(:name) { |n| "Atta species#{n}" }
    name_html { "<i>#{name}</i>" }
    epithet { name.split(' ').last }
    epithet_html { "<i>#{epithet}</i>" }
    #protonym_html { name_html }
  end

  factory :subspecies_name do
    sequence(:name) { |n| "Atta species subspecies#{n}" }
    name_html { "<i>#{name}</i>" }
    epithet { name.split(' ').last }
    epithets { name.split(' ')[-2..-1].join(' ') }
    epithet_html { "<i>#{epithet}</i>" }
    #protonym_html { name_html }
  end

  ####################################################
  factory :taxon do
    after :create do |taxon|
      FactoryGirl.create(:taxon_state, taxon_id: taxon.id)
      taxon.touch_with_version
    end
    to_create { |instance| instance.save(validate: false) }

    association :name, factory: :genus_name
    association :type_name, factory: :species_name
    protonym
    status 'valid'
  end

  factory :family do
    after :create do |family|
      FactoryGirl.create(:taxon_state, taxon_id: family.id)
      family.touch_with_version
    end
    to_create { |instance| instance.save(validate: false) }

    association :name, factory: :family_name
    association :type_name, factory: :genus_name
    protonym
    status 'valid'
  end

  factory :subfamily do
    after :create do |subfamily|
      FactoryGirl.create(:taxon_state, taxon_id: subfamily.id)
      subfamily.touch_with_version
    end
    to_create { |instance| instance.save(validate: false) }

    association :name, factory: :subfamily_name
    association :type_name, factory: :genus_name
    protonym
    status 'valid'
  end

  factory :tribe do
    after :create do |tribe|
      FactoryGirl.create(:taxon_state, taxon_id: tribe.id)
      tribe.touch_with_version
    end
    to_create { |instance| instance.save(validate: false) }
    association :name, factory: :tribe_name
    association :type_name, factory: :genus_name
    subfamily
    protonym
    status 'valid'
  end

  factory :subtribe do
    after :create do |subtribe|
      FactoryGirl.create(:taxon_state, taxon_id: subtribe.id)
      subtribe.touch_with_version
    end
    to_create { |instance| instance.save(validate: false) }
    association :name, factory: :subtribe_name
    association :type_name, factory: :genus_name
    subfamily
    protonym
    status 'valid'
  end

  factory :genus do
    after :create do |genus|
      FactoryGirl.create(:taxon_state, taxon_id: genus.id)
      genus.touch_with_version
    end
    to_create { |instance| instance.save(validate: false) }
    association :name, factory: :genus_name
    association :type_name, factory: :species_name
    tribe
    subfamily { |a| a.tribe && a.tribe.subfamily }
    protonym
    status 'valid'
  end

  factory :subgenus do
    after :create do |subgenus|
      FactoryGirl.create(:taxon_state, taxon_id: subgenus.id)
      subgenus.touch_with_version
    end
    to_create { |instance| instance.save(validate: false) }
    association :name, factory: :subgenus_name
    association :type_name, factory: :species_name
    genus
    protonym
    status 'valid'
  end

  factory :species_group_taxon do
    after :create do |species_group_taxon|
      FactoryGirl.create(:taxon_state, taxon_id: species_group_taxon.id)
      species_group_taxon.touch_with_version
    end
    to_create { |instance| instance.save(validate: false) }
    association :name, factory: :species_name
    genus
    protonym
    status 'valid'
  end

  factory :species do
    after :create do |species|
      FactoryGirl.create(:taxon_state, taxon_id: species.id)
      species.touch_with_version
    end
    to_create { |instance| instance.save(validate: false) }
    association :name, factory: :species_name
    genus
    protonym
    status 'valid'
  end

  factory :subspecies do
    after :create do |subspecies|
      FactoryGirl.create(:taxon_state, taxon_id: subspecies.id)
      subspecies.touch_with_version
    end
    to_create { |instance| instance.save(validate: false) }
    association :name, factory: :species_name
    species
    genus
    protonym
    status 'valid'
  end

  ####################################################
  factory :citation do
    reference :factory => :article_reference
    pages '49'
  end

  factory :protonym do
    authorship factory: :citation
    association :name, factory: :genus_name
  end

  factory :taxon_history_item, class: TaxonHistoryItem do
    taxt 'Taxonomic history'
  end

  ####################################################
  factory :reference_section do
    association :taxon
    sequence(:position) { |n| n }
    sequence(:references_taxt) { |n| "Reference #{n}" }
  end

  ####################################################
  factory :antwiki_valid_taxon do
  end

  ####################################################
  factory :version, :class => PaperTrail::Version do
    item_type 'Taxon'
    event 'create'
    change_id 0
    association :whodunnit, factory: :user
  end

  factory :transaction do
    association :paper_trail_version, factory: :version
    association :change
  end

  factory :change do
    change_type "create"
  end

  ####################################################
  factory :tooltip do
    sequence(:key) { |n| "test.key#{n}" }
    sequence(:text) { |n| "Tooltip text #{n}" }
  end
end

def create_family
  create_taxon_object 'Formicidae', :family, :family_name
end

def create_subfamily name_or_attributes = 'Dolichoderinae', attributes = {}
  create_taxon_object name_or_attributes, :subfamily, :subfamily_name, attributes
end

def create_tribe name_or_attributes = 'Attini', attributes = {}
  create_taxon_object name_or_attributes, :tribe, :tribe_name, attributes
end

def create_taxon name_or_attributes = 'Atta', attributes = {}
  create_taxon_object name_or_attributes, :genus, :genus_name, attributes
end

def create_genus name_or_attributes = 'Atta', attributes = {}
  create_taxon_object name_or_attributes, :genus, :genus_name, attributes
end

def create_subgenus name_or_attributes = 'Atta (Subatta)', attributes = {}
  create_taxon_object name_or_attributes, :subgenus, :subgenus_name, attributes
end

def create_species name_or_attributes = 'Atta major', attributes = {}
  create_taxon_object name_or_attributes, :species, :species_name, attributes
end

def create_subspecies name_or_attributes = 'Atta major minor', attributes = {}
  create_taxon_object name_or_attributes, :subspecies, :subspecies_name, attributes
end

def create_taxon_object name_or_attributes, taxon_factory, name_factory, attributes = {}
  if name_or_attributes.kind_of? String
    name, epithet, epithets = get_name_parts name_or_attributes
    attributes = attributes.reverse_merge name: FactoryGirl.create(name_factory, name: name, epithet: epithet, epithets: epithets), name_cache: name
  else
    attributes = name_or_attributes
  end

  build_stubbed = attributes.delete :build_stubbed
  build = attributes.delete :build
  build_stubbed ||= build
  FactoryGirl.send(build_stubbed ? :build_stubbed : :create, taxon_factory, attributes)
end

def get_name_parts name
  parts = name.split ' '
  epithet = parts.last
  epithets = parts[1..-1].join(' ') unless parts.size < 2
  return name, epithet, epithets
end

def find_or_create_name name
  name, epithet, epithets = get_name_parts name
  FactoryGirl.create :name, name: name, epithet: epithet, epithets: epithets
end

def create_species_name name
  name, epithet, epithets = get_name_parts name
  FactoryGirl.create :species_name, name: name, epithet: epithet, epithets: epithets
end

def create_subspecies_name name
  name, epithet, epithets = get_name_parts name
  FactoryGirl.create :subspecies_name, name: name, epithet: epithet, epithets: epithets
end

def create_synonym senior, attributes = {}
  junior = create_genus attributes.merge status: 'synonym'
  synonym = Synonym.create! senior_synonym: senior, junior_synonym: junior
  junior
end

def create_taxon_with_state(taxon_type, name)
  taxon = FactoryGirl.create(taxon_type, name: name)
  FactoryGirl.create :taxon_state, taxon_id: taxon.id
  taxon.touch_with_version
  taxon
end

def create_taxon_version_and_change(review_state, user = @user, approver = nil, genus_name = 'default_genus')
  name = FactoryGirl.create :name, name: genus_name
  taxon = FactoryGirl.create :genus, name: name
  taxon.taxon_state.review_state = review_state

  change = FactoryGirl.create :change, user_changed_taxon_id: taxon.id, change_type: "create"
  FactoryGirl.create :version, item_id: taxon.id, whodunnit: user.id, change_id: change.id

  unless approver.nil?
    change.update_attributes! approver: approver, approved_at: Time.now if approver
  end
  #  FactoryGirl.create :transaction, paper_trail_version: version, change: change
  taxon
end
