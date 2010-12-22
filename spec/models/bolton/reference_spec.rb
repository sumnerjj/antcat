require 'spec_helper'

describe Bolton::Reference do

  describe "string representation" do
    it "should be readable and informative" do
      bolton = Bolton::Reference.new(:authors => 'Allred, D.M.', :title => "Ants of Utah", :year => 1982)
      bolton.to_s.should == "Allred, D.M. 1982. Ants of Utah."
    end
  end

  describe "changing the citation year" do
    it "should change the year" do
      reference = Factory(:bolton_reference, :citation_year => '1910a')
      reference.year.should == 1910
      reference.citation_year = '2010b'
      reference.save!
      reference.year.should == 2010
    end

    it "should set the year to the stated year, if present" do
      reference = Factory(:bolton_reference, :citation_year => '1910a ["1958"]')
      reference.year.should == 1958
      reference.citation_year = '2010b'
      reference.save!
      reference.year.should == 2010
    end
  end

  describe 'last name of principal author' do
    it 'should work' do
      Bolton::Reference.new(:authors => 'Bolton, B.').principal_author_last_name.should == 'Bolton'
    end
  end

  describe 'matching against Ward' do
    before do
      @ward = ArticleReference.create! :author_names => [Factory :author_name, :name => "Arnol'di, G."],
                                       :title => "My life among the ants",
                                       :journal => Factory(:journal, :name => "Psyche"),
                                       :series_volume_issue => '1',
                                       :pagination => '15-43',
                                       :citation_year => '1965'
      @bolton = Bolton::Reference.create! :authors => "Arnol'di, G.",
                                          :title => "My life among the ants",
                                          :reference_type => 'ArticleReference',
                                          :series_volume_issue => '1',
                                          :pagination => '15-43',
                                          :journal => 'Psyche',
                                          :year => '1965a'
    end

    describe "author matching" do
      it "should not match if the author name is a prefix" do
        @ward.update_attributes :author_names => [Factory :author_name, :name => 'Abensperg-Traun, M.']
        @bolton.update_attributes :authors  => 'Abe, M.'
        @bolton.match(@ward).should == 0
      end
    end

    describe "matching unknown types of reference" do

      it "should match the author for unknown references" do
        ward = Factory :unknown_reference
        bolton = Bolton::Reference.create! :authors => ward.author_names_string, :title => 'Ants', :year => ward.year,
                                           :reference_type => 'UnknownReference'
        bolton.match(ward).should == 1
      end

      it "should match the title for unknown references" do
        ward = Factory :unknown_reference
        bolton = Bolton::Reference.create! :authors => ward.author_names_string, :title => ward.title, :year => ward.year,
                                           :reference_type => 'UnknownReference'
        bolton.match(ward).should == 100
      end

    end

    describe "title matching" do
      it "should match with complete confidence if the author and title are the same" do
        @bolton.update_attributes :title => @ward.title
        @bolton.match(@ward).should == 100
      end

      it "should match with very low confidence the author is the same but the title is different" do
        @bolton.update_attributes :title => 'Spiders', :pagination => nil
        @bolton.match(@ward).should be == 1
      end

      it "should match when Ward includes taxon names, as long as one of them is one we know about" do
        @bolton.update_attributes :title => 'The genus-group names of Symphyta and their type species'
        @ward.update_attributes :title => 'The genus-group names of Symphyta (Hymenoptera: Formicidae) and their type species'
        @bolton.match(@ward).should be == 90
      end

      it "should not match when the only difference is parenthetical, but is not a toxon name" do
        @bolton.update_attributes :title => 'The genus-group names of Symphyta and their type species', :series_volume_issue => nil
        @ward.update_attributes :title => 'The genus-group names of Symphyta (unknown) and their type species'
        @bolton.match(@ward).should be == 1
      end

      it "should match when the only difference is in square brackets" do
        @bolton.update_attributes :title => 'Ants [sic] and pants'
        @ward.update_attributes :title => 'Ants and pants [sic]'
        @bolton.match(@ward).should be == 90
      end

      it "should match when the only difference is accents" do
        @bolton.update_attributes :title => 'Sobre los caracteres morfólogicos de Goniomma, con algunas sugerencias sobre su taxonomia'
        @ward.update_attributes :title =>   'Sobre los caracteres morfólogicos de Goniomma, con algunas sugerencias sobre su taxonomía'
        @bolton.match(@ward).should be == 90
      end

      it "should match when the only difference is case" do
        @bolton.update_attributes :title => 'Ants'
        @ward.update_attributes :title =>   'ANTS'
        @bolton.match(@ward).should be == 90
      end

      it "should match when the only difference is punctuation" do
        @bolton.update_attributes :title => 'Sobre los caracteres morfólogicos de Goniomma, con algunas sugerencias sobre su taxonomia'
        @ward.update_attributes :title =>   'Sobre los caracteres morfólogicos de *Goniomma*, con algunas sugerencias sobre su taxonomía'
        @bolton.match(@ward).should be == 90
      end

    end

    describe 'matching series/volume/issue + pagination with different titles' do
      it "should match a perfect match" do
        ward = Factory :article_reference, :title => 'Studier',
                       :series_volume_issue => '(21) 4', :pagination => '1-76'
        bolton = Factory :bolton_reference, :title => 'Study', :authors => ward.principal_author_last_name, :reference_type => 'ArticleReference',
                       :series_volume_issue => '(21) 4', :pagination => '1-76'
        bolton.match(ward).should be == 85
      end
      it "should match when the series/volume/issue has a space after the series" do
        ward = Factory :article_reference, :title => 'Studier',
                       :series_volume_issue => '21 (4)', :pagination => '1-76'
        bolton = Factory :bolton_reference, :title => 'Study', :authors => ward.principal_author_last_name, :reference_type => 'ArticleReference',
                       :series_volume_issue => '21(4)', :pagination => '1-76'
        bolton.match(ward).should be == 85
      end
      it "should not match when the series/volume/issue has a space after the series, but the space separates words" do
        ward = Factory :article_reference, :title => 'Studier',
                       :series_volume_issue => '21 4', :pagination => '1-76'
        bolton = Factory :bolton_reference, :title => 'Study', :authors => ward.principal_author_last_name, :reference_type => 'ArticleReference',
                       :series_volume_issue => '214', :pagination => '1-76'
        bolton.match(ward).should be == 1
      end
    end

  end
end
