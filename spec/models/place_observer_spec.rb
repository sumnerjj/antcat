# coding: UTF-8
require 'spec_helper'

describe PlaceObserver do
  describe "Invalidating the formatted reference cache" do
    it "should be asked to invalidate the cache when a change occurs" do
      place = FactoryGirl.create :place, name: 'Constantinople'
      expect_any_instance_of(PlaceObserver).to receive :before_update
      place.name = 'Istanbul'
      place.save!
    end

    it "should invalidate the cache for the references that use the place" do
      place = FactoryGirl.create :place
      publisher = FactoryGirl.create :publisher, place: place
      references = []
      (0..2).each do |i|
        if i < 2
          references[i] = FactoryGirl.create :book_reference, publisher: publisher
        else
          references[i] = FactoryGirl.create :book_reference
        end
        ReferenceFormatterCache.instance.populate references[i]
      end

      expect(references[0].formatted_cache).not_to be_nil
      expect(references[1].formatted_cache).not_to be_nil
      expect(references[2].formatted_cache).not_to be_nil

      PlaceObserver.instance.before_update place

      expect(references[0].reload.formatted_cache).to be_nil
      expect(references[1].reload.formatted_cache).to be_nil
      expect(references[2].reload.formatted_cache).not_to be_nil
    end
  end
end
