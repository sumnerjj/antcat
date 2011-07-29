require 'spec_helper'

describe Hol::ReferenceMatcher do
  before do
    @matcher = Hol::ReferenceMatcher.new
  end

  describe "No matching authors" do
    it "should return :no_entries_for_author" do
      mock_bibliography = mock 'Bibliography'
      Hol::Bibliography.stub!(:new).and_return mock_bibliography
      mock_bibliography.stub!(:read_references).and_return []
      reference = Factory.build :reference
      @matcher.match(reference).should == :no_entries_for_author
    end
  end

  describe "Returning just one match" do
    it "should return the best match" do
      best_match = mock
      good_match = mock
      bibliography = mock 'Bibliography'
      Hol::Bibliography.stub!(:new).and_return bibliography
      reference = Factory.build :article_reference
      bibliography.stub!(:read_references).and_return [good_match, best_match]
      reference.should_receive(:<=>).with(best_match).and_return 0.9
      reference.should_receive(:<=>).with(good_match).and_return 0.8
      @matcher.match(reference).should == best_match
    end
  end

  describe "No match found, but matching author exists" do
    it "should return nil" do
      reference = Factory.build :article_reference
      @matcher.stub!(:candidates_for).and_return [reference]
      reference.stub(:<=>).and_return 0.0
      @matcher.match(reference).should be_nil
    end
  end

  describe "Two matches with equal similarity found" do
    it "should raise exception" do
      best_match = mock
      good_match = mock
      bibliography = mock 'Bibliography'
      Hol::Bibliography.stub!(:new).and_return bibliography
      reference = Factory.build :article_reference
      bibliography.stub!(:read_references).and_return [good_match, best_match]
      reference.should_receive(:<=>).with(best_match).and_return 0.9
      reference.should_receive(:<=>).with(good_match).and_return 0.9
      lambda {@matcher.match(reference)}.should raise_error
    end
  end

end
