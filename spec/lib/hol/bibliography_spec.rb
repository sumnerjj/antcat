require 'spec_helper'

describe Hol::Bibliography do
  describe "getting the contents for an author" do
    before do
      @hol = Hol::Bibliography.new
      @reference = Factory :reference
    end

    it "should get the contents for an author initially" do
      @hol.should_receive(:read_references).and_return []
      @hol.match @reference
    end
    it "should cache an author's contents" do
      @hol.should_receive(:read_references).once().and_return []
      @hol.match @reference
      @hol.match @reference
    end
    it "should get a different author's contents" do
      bolton_reference = Factory :reference, :author_names => [Factory(:author_name, :name => 'Bolton')]
      fisher_reference = Factory :reference, :author_names => [Factory(:author_name, :name => 'Fisher')]
      @hol.should_receive(:read_references).with('Bolton').once().and_return []
      @hol.should_receive(:read_references).with('Fisher').once().and_return []
      @hol.match bolton_reference
      @hol.match fisher_reference
    end
  end

  describe "getting an author's bibliography" do
    before do
      @scraper = mock Scraper
      Scraper.stub!(:new).and_return @scraper
      @hol = Hol::Bibliography.new
    end

    it "should go to the right URL" do
      @scraper.should_receive(:get).with("http://osuc.biosci.ohio-state.edu/hymenoptera/manage_lit.list_pubs?author=fisher").and_return(Nokogiri::HTML '')
      @hol.read_references 'fisher'
    end

    it "should URL-encode a name with diacritic" do
      @scraper.should_receive(:get).with("http://osuc.biosci.ohio-state.edu/hymenoptera/manage_lit.list_pubs?author=h%F6lldobler").and_return(Nokogiri::HTML '')
      @hol.read_references 'hölldobler'
    end

    it "should not abort on this name" do
      @scraper.should_receive(:get).and_return(Nokogiri::HTML '')
      @hol.read_references "O’Donnell"
      @hol.read_references "O\x2019Donnell"
    end

    it "should URL-encode a name with spaces" do
      @scraper.should_receive(:get).with("http://osuc.biosci.ohio-state.edu/hymenoptera/manage_lit.list_pubs?author=baroni+urbani").and_return(Nokogiri::HTML '')
      @hol.read_references 'baroni urbani'
    end

    it "should parse each reference" do
      @scraper.stub!(:get).and_return Nokogiri::HTML <<-SEARCH_RESULTS
<HTML>
<HEAD>
<TITLE>Hymenoptera On-Line Database</TITLE>
</HEAD>
<BODY BGCOLOR="#FFFFFF">
<H3>Publications of Barry Bolton:</h3><p>

<li>
<strong><a href="http://holBibliography.osu.edu/reference-full.html?id=22169" title="View extended reference information from Hymenoptera Online">22169</a></strong>
<a href="http://holBibliography.osu.edu/agent-full.html?id=493">Bolton, B.</a> and <a href="http://holbibliography.osu.edu/agent-full.html?id=4746">B. L. Fisher</a>.
 2008. Afrotropical ants of the ponerine genera Centromyrmex Mayr, Promyopias Santschi gen. rev. and Feroponera gen. n., with a revised key to genera of African Ponerinae (Hymenoptera: Formicidae). Zootaxa <strong>1929</strong>: 1-37.
<A HREF="http://osuc.biosci.ohio-state.edu/hymDB/nomenclator.hlviewer?id=22169" TARGET="_blank">Browse</A>
 or download 
<A HREF="http://antbase.org/ants/publications/22169/22169.pdf" TARGET="_blank"> entire file (514K)</A>

<IMG SRC="http://osuc.biosci.ohio-state.edu/images/pdf.gif">
<li>
<strong><a href="http://holBibliography.osu.edu/reference-full.html?id=8085" title="View extended reference information from Hymenoptera Online">8085</a></strong>
<a href="http://holBibliography.osu.edu/agent-full.html?id=493">Bolton, B.</a>
 1999. Ant genera of the tribe Dacetonini (Hymenoptera: Formicidae). Journal of Natural History <strong>33</strong>: 1639-1689.

<a target="_blank" href=http://antbase.org/ants/publications/8085/8085.pdf>(6.2M PDF file)</a>
<IMG SRC="http://osuc.biosci.ohio-state.edu/images/pdf.gif">
<li>
<strong><a href="http://holBibliography.osu.edu/reference-full.html?id=22424" title="View extended reference information from Hymenoptera Online">22424</a></strong>
<a href="http://holBibliography.osu.edu/agent-full.html?id=493">Bolton, B.</a> and <a href="http://holbibliography.osu.edu/agent-full.html?id=4746">B. L. Fisher</a>.
 2008. The Afrotropical ponerine ant genus Phrynoponera Wheeler (Hymenoptera: Formicidae). Zootaxa <strong>1892</strong>: 35-52.
<A HREF="http://osuc.biosci.ohio-state.edu/hymDB/nomenclator.hlviewer?id=22424" TARGET="_blank">Browse</A>
 or download 
<A HREF="http://antbase.org/ants/publications/22424/22424.pdf" TARGET="_blank"> entire file (771K)</A>

<IMG SRC="http://osuc.biosci.ohio-state.edu/images/pdf.gif">
 or download 
<P>
<CENTER>
<a href="http://osuc.biosci.ohio-state.edu/hymDB/hym_utilities.site_stats">
See Site Statistics</a><p>
<IMG SRC="http://iris.biosci.ohio-state.edu/gifs/bl_bds.gif"><P>
<A HREF="http://iris.biosci.ohio-state.edu/hymenoptera/hym_db_form.html">Return to Hymenoptera On-Line Opening Page</A>
<BR>
<A HREF="http://iris.biosci.ohio-state.edu/index.html">Return to OSU Insect Collection Home Page</A>
<BR>
02 September, 2010
</CENTER>
</BODY>
</HTML>
      SEARCH_RESULTS

      @hol.read_references('fisher').should have(3).items
    end

    it "should parse a reference where the journal name begins with a UTF-8 character" do
      result = @hol.parse_reference(Nokogiri::HTML(<<-LI).at_css('html body'))
<strong><a href="http://hol.osu.edu/reference-full.html?id=22662" title="View extended reference information from Hymenoptera Online">22662</a></strong>
<a href="http://hol.osu.edu/agent-full.html?id=2767">Adlerz, G.</a>
 1896. Stridulationsorgan och ljudf"ornimmelser hos myror. Öfversigt af Kongliga Ventenskaps-Akadamiens Förhandlingar <strong>52</strong>: 769-782.
<A HREF="http://osuc.biosci.ohio-state.edu/hymDB/nomenclator.hlviewer?id=22662" TARGET="_blank">Browse</A>
 or download 
<A HREF="http://128.146.250.117/pdfs/22662/22662.pdf" TARGET="_blank"> entire file (557k)</A>
<IMG SRC="http://osuc.biosci.ohio-state.edu/images/pdf.gif">
      LI
      result[:title].should == 'Stridulationsorgan och ljudf"ornimmelser hos myror'
    end

    it "should at least not crash when information is absent" do
      result = @hol.parse_reference(Nokogiri::HTML(<<-LI).at_css('html body'))
<strong><a href="http://hol.osu.edu/reference-full.html?id=22662" title="View extended reference information from Hymenoptera Online">22662</a></strong>
<a href="http://hol.osu.edu/agent-full.html?id=2767">Adlerz, G.</a>
 1846. Nomenclatoris zoologici index universalis, continens nomina systematica classium, ordinum, familiarum, et generum animalium omnium.... Soloduri, .
<A HREF="http://osuc.biosci.ohio-state.edu/hymDB/nomenclator.hlviewer?id=22662" TARGET="_blank">Browse</A>
 or download 
<A HREF="http://128.146.250.117/pdfs/22662/22662.pdf" TARGET="_blank"> entire file (557k)</A>
<IMG SRC="http://osuc.biosci.ohio-state.edu/images/pdf.gif">
      LI
      result[:title].should be_nil
    end

    it "should parse an article reference" do
      result = @hol.parse_reference(Nokogiri::HTML(<<-LI).at_css('html body'))
<strong><a href="http://holBibliography.osu.edu/reference-full.html?id=22169" title="View extended reference information from Hymenoptera Online">22169</a></strong>
<a href="http://holBibliography.osu.edu/agent-full.html?id=493">Bolton, B.</a> and <a href="http://holbibliography.osu.edu/agent-full.html?id=4746">B. L. Fisher</a>.
 2008. Afrotropical ants of the ponerine genera Centromyrmex Mayr, Promyopias Santschi gen. rev. and Feroponera gen. n., with a revised key to genera of African Ponerinae (Hymenoptera: Formicidae). Zootaxa <strong>1929</strong>(1): 1-37.
<A HREF="http://osuc.biosci.ohio-state.edu/hymDB/nomenclator.hlviewer?id=22169" TARGET="_blank">Browse</A>
 or download 
<A HREF="http://antbase.org/ants/publications/22169/22169.pdf" TARGET="_blank"> entire file (514K)</A>

<IMG SRC="http://osuc.biosci.ohio-state.edu/images/pdf.gif">
      LI

      result[:document_url].should == 'http://antbase.org/ants/publications/22169/22169.pdf'
      result[:year].should == 2008
      result[:series_volume_issue].should == '1929(1)'
      result[:title].should == 'Afrotropical ants of the ponerine genera Centromyrmex Mayr, Promyopias Santschi gen. rev. and Feroponera gen. n., with a revised key to genera of African Ponerinae (Hymenoptera: Formicidae)'
      result[:pagination].should == '1-37'
    end

    it "should parse an article reference with a single author" do
      result = @hol.parse_reference(Nokogiri::HTML(<<-LI).at_css('html body'))
<strong><a href="http://hol.osu.edu/reference-full.html?id=22497" title="View extended reference information from Hymenoptera Online">22497</a></strong>
<a href="http://hol.osu.edu/agent-full.html?id=2767">Adlerz, G.</a>
 1887. Myrmecologiska notiser. Entomologisk Tidskrift <strong>8</strong>: 41-50.
<A HREF="http://osuc.biosci.ohio-state.edu/hymDB/nomenclator.hlviewer?id=22497" TARGET="_blank">Browse</A>
 or download 
<A HREF="http://128.146.250.117/pdfs/22497/22497.pdf" TARGET="_blank"> entire file (583k)</A>
<IMG SRC="http://osuc.biosci.ohio-state.edu/images/pdf.gif">
      LI

      result[:title].should == 'Myrmecologiska notiser'
    end

    it "should parse a book reference" do
      result = @hol.parse_reference(Nokogiri::HTML(<<-LI).at_css('html body'))
<strong><a href=\"http://hol.osu.edu/reference-full.html?id=6373\" title=\"View extended reference information from Hymenoptera Online\">6373</a></strong>\n<a href=\"http://hol.osu.edu/agent-full.html?id=2711\">Foerster, J. R.</a>\n 1771. Novae species insectorum. Centuria I. T. Davies, London. 100 pp.\n<p>\n</p>\n<center>\n<a href=\"http://osuc.biosci.ohio-state.edu/hymDB/hym_utilities.site_stats\">\nSee Site Statistics</a><p>\n<img src=\"http://iris.biosci.ohio-state.edu/gifs/bl_bds.gif\"></p>\n<p>\n<a href=\"http://iris.biosci.ohio-state.edu/hymenoptera/hym_db_form.html\">Return to Hymenoptera On-Line Opening Page</a>\n<br><a href=\"http://iris.biosci.ohio-state.edu/index.html\">Return to OSU Insect Collection Home Page</a>\n<br>\n10 October  , 2010\n</p>\n</center>\n\n\n\n\n<title>Hymenoptera On-Line Database</title>\n<script language=\"JAVASCRIPT\">\n<!-- Hide script from old browsers\nfunction popup(url, x, y) {\n  newWindow = window.open(url, \"coverwin\",\n    \"toolbar=yes,directories=yes,menubar=yes,status=yes,width=800,height=600,resizable=yes,scrollbars=yes\")\n  newWindow.focus()\n}\n// end hiding script from old browsers -->\n</script><title>Hymenoptera On-Line Database</title>\n<script language=\"JAVASCRIPT\">\n<!-- Hide script from old browsers\nfunction popup(url, x, y) {\n  newWindow = window.open(url, \"coverwin\",\n    \"toolbar=yes,directories=yes,menubar=yes,status=yes,width=800,height=600,resizable=yes,scrollbars=yes\")\n  newWindow.focus()\n}\n// end hiding script from old browsers -->\n</script><h3>Publications of Luis A. Foerster:</h3>\n<p>\n</p>
      LI
      result[:document_url].should == 'http://antbase.org/ants/publications/6373/6373.pdf'
      result[:year].should == 1771
      result[:pagination].should == '100 pp.'
    end

    it "should parse the URL out of the document, if it exists" do
      result = @hol.parse_reference(Nokogiri::HTML(<<-LI).at_css('html body'))
                <strong><a href="http://hol.osu.edu/reference-full.html?id=22497" title="View extended reference information from Hymenoptera Online">22497</a></strong>
                <a href="http://hol.osu.edu/agent-full.html?id=2767">Adlerz, G.</a>
                 1887. Myrmecologiska notiser. Entomologisk Tidskrift <strong>8</strong>: 41-50.
                 <A HREF="http://osuc.biosci.ohio-state.edu/hymDB/nomenclator.hlviewer?id=22497" TARGET="_blank">Browse</A>
                  or download 
                  <A HREF="http://128.146.250.117/pdfs/22497/22497.pdf" TARGET="_blank"> entire file (583k)</A>
                  <IMG SRC="http://osuc.biosci.ohio-state.edu/images/pdf.gif">
      LI

      result[:document_url].should == "http://128.146.250.117/pdfs/22497/22497.pdf" 
    end
  end

  describe "matching against Ward" do
    before do
      @hol = Hol::Bibliography.new
    end

    it "should match an article reference based on year + series/volume/issue + pagination" do
      reference = Factory :article_reference, :year => 2010, :series_volume_issue => '2', :pagination => '2-3'
      hol_references = [
        {:document_url => 'a source', :year => 2010, :series_volume_issue => '1', :pagination => '2-3'},
        {:document_url => 'another source', :year => 2010, :series_volume_issue => '2', :pagination => '2-3'},
      ]
      @hol.stub!(:references_for).and_return hol_references
      @hol.match(reference)[:document_url].should == 'another source'
    end

    it "should match an article reference based on year + title if series/volume/issue isn't found" do
      reference = Factory :article_reference, :year => 2010, :series_volume_issue => '44', :pagination => '325-335',
        :title => 'Adelomyrmecini new tribe and Cryptomyrmex new genus of myrmicine ants'
      hol_references = [
        {:document_url => 'fernandez_source', :year => 2010, :series_volume_issue => '44(3)', :pagination => '325-335',
          :title => 'Adelomyrmecini new tribe and Cryptomyrmex new genus of myrmicine ants'},
      ]
      @hol.stub!(:references_for).and_return hol_references
      @hol.match(reference)[:document_url].should == 'fernandez_source'
    end

    it "ignore punctuation when comparing titles" do
      reference = Factory :article_reference, :year => 2010, :series_volume_issue => '44', :pagination => '325-335',
        :title => 'Adelomyrmecini new tribe and Cryptomyrmex new genus of myrmicine ants (Hymenoptera, Formicidae)'
      hol_references = [
        {:document_url => 'fernandez_source', :year => 2010, :series_volume_issue => '44(3)', :pagination => '325-335',
          :title => 'Adelomyrmecini new tribe and Cryptomyrmex new genus of myrmicine ants (Hymenoptera: Formicidae)'},
      ]
      @hol.stub!(:references_for).and_return hol_references
      @hol.match(reference)[:document_url].should == 'fernandez_source'
    end

    it "should report as much when a failed match was because the author had no entries" do
      reference = Factory :reference
      @hol.stub!(:references_for).and_return []
      result = @hol.match reference
      result[:document_url].should be_nil
    end

  end

end
