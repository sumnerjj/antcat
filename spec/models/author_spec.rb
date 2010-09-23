require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Author do
  it "has many references" do
    author = Author.create! :name => 'Fisher, B.L.'

    reference = Factory(:reference)
    author.references << reference

    author.references.first.should == reference
  end

  describe "importing" do
    it "should create and return the authors" do
      Author.import(['Fisher, B.L.', 'Wheeler, W.M.']).map(&:name).should =~
      ['Fisher, B.L.', 'Wheeler, W.M.']
    end

    it "should reuse existing authors" do
      Author.import(['Fisher, B.L.', 'Wheeler, W.M.'])
      Author.import(['Fisher, B.L.', 'Wheeler, W.M.'])
      Author.count.should == 2
    end
  end

  describe "editing" do
    it "should update associated references when the name is changed" do
      author = Factory(:author, :name => 'Ward')
      reference = Factory(:reference)
      reference.authors << author
      author.update_attribute :name, 'Fisher'
      reference.reload.authors_string.should == 'Fisher'
    end
  end

  describe "parse_authors_string" do
    it "should find or create authors with names in the string" do
      Author.create! :name => 'Bolton, B.'
      authors = Author.import_authors_string('Ward, P.S.; Bolton, B.')
      authors.first.name.should == 'Ward, P.S.'
      authors.second.name.should == 'Bolton, B.'
      Author.count.should == 2
    end
  end

  describe "searching" do
    it "should find a prefix" do
      Author.create! :name => 'Bolton'
      Author.create! :name => 'Fisher'
      results = Author.search('Bol')
      results.count.should == 1
      results.first.should == 'Bolton'
    end

    it "should find an internal string" do
      Author.create! :name => 'Bolton'
      Author.create! :name => 'Fisher'
      results = Author.search('ol')
      results.count.should == 1
      results.first.should == 'Bolton'
    end

    it "should return authors in order of most recently used" do
      reference = Factory :reference
      ['Never Used', 'Recent', 'Old', 'Most Recent'].each do |name|
        Author.create! :name => name
      end
      AuthorParticipation.create! :created_at => Time.now, :author => Author.find_by_name('Most Recent'), :reference => reference
      AuthorParticipation.create! :created_at => Time.now - 1, :author => Author.find_by_name('Recent'), :reference => reference
      AuthorParticipation.create! :created_at => Time.now - 2, :author => Author.find_by_name('Old'), :reference => reference

      results = Author.search

      results.should == ['Most Recent', 'Recent', 'Old', 'Never Used']
    end
  end
end
