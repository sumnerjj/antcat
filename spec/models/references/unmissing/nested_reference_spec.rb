# coding: UTF-8
require 'spec_helper'

describe NestedReference do

  describe "Validation" do
    before do
      @reference = NestedReference.new :title => 'asdf', :author_names => [FactoryGirl.create(:author_name)], :citation_year => '2010',
        :nesting_reference => FactoryGirl.create(:reference), :pages_in => 'Pp 2 in:'
    end
    it "should be valid with the attributes given above" do
      expect(@reference).to be_valid
    end
    it "should not be valid without a nesting_reference" do
      @reference.nesting_reference = nil
      expect(@reference).not_to be_valid
    end
    it "should be valid without a title" do
      @reference.title = nil
      expect(@reference).to be_valid
    end
    it "should not be valid without a pages in" do
      @reference.pages_in = nil
      expect(@reference).not_to be_valid
    end
    it "should refer to an existing reference" do
      @reference.nesting_reference_id = 232434
      expect(@reference).not_to be_valid
    end
    it "should not point to itself" do
      @reference.nesting_reference_id = @reference.id
      expect(@reference).not_to be_valid
    end
    it "should not point to something that points to itself" do
      inner_most = FactoryGirl.create :book_reference
      middle = FactoryGirl.create :nested_reference, :nesting_reference => inner_most
      top = FactoryGirl.create :nested_reference, :nesting_reference => middle
      middle.nesting_reference = top
      expect(middle).not_to be_valid
    end
    it "can have a nesting_reference" do
      nesting_reference = FactoryGirl.create :reference
      nestee = FactoryGirl.create :nested_reference, nesting_reference: nesting_reference
      expect(nestee.nesting_reference).to eq(nesting_reference)
    end
  end

  describe "Deletion" do
    it "should not be possible to delete a nestee" do
      reference = NestedReference.create! :title => 'asdf', :author_names => [FactoryGirl.create(:author_name)], :citation_year => '2010',
        :nesting_reference => FactoryGirl.create(:reference), :pages_in => 'Pp 2 in:'
      expect(reference.nesting_reference.destroy).to be_falsey
    end

  end

end
