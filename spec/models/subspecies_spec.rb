# coding: UTF-8
require 'spec_helper'

describe Subspecies do
  before do
    @genus = create_genus 'Atta'
  end

  it "has no statistics" do
    Subspecies.new.statistics.should be_nil
  end

  it "does not have to have a species (before being fixed up, e.g.)" do
    subspecies = create_subspecies 'Atta major colobopsis', genus: @genus, species: nil
    subspecies.should be_valid
  end

  it "must have a genus" do
    subspecies = create_subspecies 'Atta major colobopsis', genus: nil, species: nil, build: true
    subspecies.should_not be_valid
  end

  it "has its subfamily assigned from its genus" do
    subspecies = create_subspecies 'Atta major colobopsis', genus: @genus
    subspecies.subfamily.should == @genus.subfamily
  end

  describe "Elevating to species" do
    it "should turn the record into a Species" do
      taxon = create_subspecies 'Atta major colobopsis'
      taxon.should be_kind_of Subspecies
      taxon.elevate_to_species
      taxon = Species.find taxon.id
      taxon.should be_kind_of Species
    end
    it "should form the new species name from the epithet" do
      species = create_species 'Atta major', genus: @genus
      subspecies_name = SubspeciesName.create!({
        name:           'Atta major colobopsis',
        name_html:      '<i>Atta major colobopsis</i>',
        epithet:        'colobopsis',
        epithet_html:   '<i>colobopsis</i>',
        epithets:       'major colobopsis',
        protonym_html:  '<i>Atta major colobopsis</i>',
      })
      taxon = create_subspecies name: subspecies_name, genus: @genus, species: species
      taxon.elevate_to_species
      taxon = Species.find taxon.id
      taxon.name.name.should == 'Atta colobopsis'
      taxon.name.name_html.should == '<i>Atta colobopsis</i>'
      taxon.name.epithet.should == 'colobopsis'
      taxon.name.epithet_html.should == '<i>colobopsis</i>'
      taxon.name.epithets.should be_nil
      taxon.name.protonym_html.should == '<i>Atta major colobopsis</i>'
    end
    it "should create the new species name, if necessary" do
      species = create_species 'Atta major', genus: @genus
      subspecies_name = SubspeciesName.create!({
        name:           'Atta major colobopsis',
        name_html:      '<i>Atta major colobopsis</i>',
        epithet:        'colobopsis',
        epithet_html:   '<i>colobopsis</i>',
        epithets:       'major colobopsis',
        protonym_html:  '<i>Atta major colobopsis</i>',
      })
      taxon = create_subspecies name: subspecies_name, genus: @genus, species: species
      name_count = Name.count
      taxon.elevate_to_species
      Name.count.should == name_count + 1
    end
    it "should find an existing species name, if possible" do
      species = create_species 'Atta major', genus: @genus
      subspecies_name = SubspeciesName.create!({
        name:           'Atta major colobopsis',
        name_html:      '<i>Atta major colobopsis</i>',
        epithet:        'colobopsis',
        epithet_html:   '<i>colobopsis</i>',
        epithets:       'major colobopsis',
        protonym_html:  '<i>Atta major colobopsis</i>',
      })
      species_name = SpeciesName.create!({
        name:           'Atta colobopsis',
        name_html:      '<i>Atta colobopsis</i>',
        epithet:        'colobopsis',
        epithet_html:   '<i>colobopsis</i>',
        epithets:       nil,
        protonym_html:  '<i>Atta major colobopsis</i>',
      })
      taxon = create_subspecies name: subspecies_name, genus: @genus, species: species
      taxon.elevate_to_species
      taxon = Species.find taxon.id
      taxon.name.should == species_name
    end
    it "should crash and burn if the species already exists" do
      species = create_species 'Atta major', genus: @genus
      subspecies_name = SubspeciesName.create!({
        name:           'Atta batta major',
        name_html:      '<i>Atta batta major</i>',
        epithet:        'major',
        epithet_html:   '<i>major</i>',
        epithets:       'batta major',
        protonym_html:  '<i>Atta batta major</i>',
      })
      taxon = create_subspecies name: subspecies_name, species: species
      -> {taxon.elevate_to_species}.should raise_error
    end
  end

  describe "Importing" do
    before do
      @reference = FactoryGirl.create :article_reference, bolton_key_cache: 'Latreille 1809'
    end
    it "should create the subspecies and the forward ref" do
      genus = create_genus 'Camponotus'
      subspecies = Subspecies.import(
        genus:                  genus,
        species_group_epithet:  'refectus',
        protonym: {
          authorship:           [{author_names: ["Latreille"], year: "1809", pages: "124"}],
          genus_name:           'Camponotus',
          subgenus_epithet:     'Myrmeurynota',
          species_epithet:      'gilviventris',
          subspecies: [{type:   'var.',
            subspecies_epithet: 'refectus',
        }]})
      subspecies = Subspecies.find subspecies
      subspecies.name.to_s.should == 'Camponotus gilviventris refectus'
      ref = ForwardRefToParentSpecies.first
      ref.fixee.should == subspecies
      ref.genus.should == genus
      ref.epithet.should == 'gilviventris'
    end

    describe "When the protonym has a different species" do
      describe "Currently subspecies of:" do
        it "should insert the species from the 'Currently subspecies of' history item" do
          genus = create_genus 'Camponotus'
          create_species 'Camponotus hova'
          subspecies = Species.import(
            genus:                  genus,
            species_group_epithet:  'radamae',
            protonym: {
              authorship:           [{author_names: ["Latreille"], year: "1809", pages: "124"}],
              genus_name:           'Camponotus',
              species_epithet:      'maculatus',
              subspecies: [{type:   'r.', subspecies_epithet: 'radamae'}]
            },
            raw_history: [{currently_subspecies_of: {species: {species_epithet: 'hova'}}}]
          )
          Subspecies.find(subspecies).name.to_s.should == 'Camponotus hova radamae'
        end
        it "should import a subspecies that has a species protonym" do
          genus = create_genus 'Acromyrmex'
          subspecies = Species.import(
            genus:                  genus,
            species_group_epithet:  'boliviensis',
            protonym: {
              authorship:           [{author_names: ["Latreille"], year: "1809", pages: "124"}],
              genus_name:           'Acromyrmex',
              species_epithet:      'boliviensis',
            },
            raw_history: [{currently_subspecies_of: {species: {species_epithet: 'lundii'}}}]
          )
          subspecies = Subspecies.find subspecies
          subspecies.name.to_s.should == 'Acromyrmex lundii boliviensis'
        end
        it "if it's already a subspecies, don't just keep adding on to its epithets, but replace the middle one(s)" do
          genus = create_genus 'Crematogaster'
          create_species 'Crematogaster jehovae'
          subspecies = Species.import(
            genus:                  genus,
            species_group_epithet:  'mosis',
            protonym: {
              authorship:           [{author_names: ["Latreille"], year: "1809", pages: "124"}],
              genus_name:           'Camponotus',
              species_epithet:      'auberti',
              subspecies: [{type:   'var.', subspecies_epithet: 'mosis'}]
            },
            raw_history: [{currently_subspecies_of: {species: {species_epithet: 'jehovae'}}}]
          )
          Subspecies.find(subspecies).name.to_s.should == 'Crematogaster jehovae mosis'
        end
      end

      it "should insert the species from the 'Revived from synonymy as subspecies of' history item" do
        genus = create_genus 'Crematogaster'
        create_species 'Crematogaster castanea'

        subspecies = Species.import(
          genus:                  genus,
          species_group_epithet:  'mediorufa',
          protonym: {
            authorship:           [{author_names: ["Latreille"], year: "1809", pages: "124"}],
            genus_name:           'Crematogaster',
            species_epithet:      'tricolor',
            subspecies: [{type:   'var.', subspecies_epithet: 'mediorufa'}]
          },
          raw_history: [{revived_from_synonymy: {subspecies_of: {species_epithet: 'castanea'}}}],
        )
        Subspecies.find(subspecies).name.to_s.should == 'Crematogaster castanea mediorufa'
      end
    end

    it "should use the right epithet when the protonym differs" do
      subspecies = Species.import(
        species_group_epithet:  'brunneus',
        protonym: {
          genus_name:           'Aenictus',
          authorship:           [{author_names: ["Latreille"], year: "1809", pages: "124"}],
          species_epithet:      'soudanicus',
          subspecies: [{type:   'var.', subspecies_epithet: 'brunnea'}]
        },
        genus: @genus,
      )
      subspecies.name.epithet.should == 'brunneus'
    end

  end

  describe "Updating" do
    before do
      @reference = FactoryGirl.create :article_reference, bolton_key_cache: 'Latreille 1809'
    end
    it "when updating, should use the the subspecies" do
      genus = create_genus 'Camponotus'
      data = {
        genus:                  genus,
        species_group_epithet:  'refectus',
        history:                [],
        protonym: {
          authorship:           [{author_names: ["Latreille"], year: "1809", pages: "124"}],
          genus_name:           'Camponotus',
          subgenus_epithet:     'Myrmeurynota',
          species_epithet:      'gilviventris',
          subspecies: [{type:   'var.',
            subspecies_epithet: 'refectus'}]}}
      subspecies = Subspecies.import data
      subspecies = Subspecies.find subspecies
      subspecies.name.to_s.should == 'Camponotus gilviventris refectus'

      updated_subspecies = Subspecies.import data
      updated_subspecies.should == subspecies
    end
  end

end
