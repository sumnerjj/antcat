# coding: UTF-8
require 'spec_helper'

describe Parsers::ReferenceKeyParser do
  before do
    @parser = Parsers::ReferenceKeyParser
  end

  describe "Parsing a key string into its components" do
    it "should return an author and a year" do
      @parser.parse('Bolton, 1975').should == {author_last_names: ['Bolton'], nester_last_names: [], year: '1975', year_ordinal: nil}
    end
  end

end
