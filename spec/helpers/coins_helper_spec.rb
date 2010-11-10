require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CoinsHelper do
  it "should format a journal reference correctly" do
    coins = helper.coins(ward_reference_factory(
      :authors => 'MacKay, W.',
      :year => '1941',
      :title => 'A title',
      :citation => 'Journal Title 1(2):3-4'
    ))
    check_parameters coins, [
      "ctx_ver=Z39.88-2004",
      "rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal",
      "rfr_id=antcat.org",
      "rft.aulast=MacKay",
      "rft.aufirst=W.",
      "rft.genre=article",
      "rft.atitle=A+title",
      "rft.jtitle=Journal+Title",
      "rft.volume=1",
      "rft.issue=2",
      "rft.spage=3",
      "rft.epage=4",
      "rft.date=1941"
    ]
  end

  it "should use the numeric year" do
    coins = helper.coins(ward_reference_factory(
      :authors => 'MacKay, W.',
      :year => '1941a ("1942")',
      :title => 'A title',
      :citation => 'Journal Title 1(2):3-4'
    ))
    check_parameters coins, [
      "ctx_ver=Z39.88-2004",
      "rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal",
      "rft.aulast=MacKay",
      "rft.aufirst=W.",
      "rfr_id=antcat.org",
      "rft.genre=article",
      "rft.atitle=A+title",
      "rft.jtitle=Journal+Title",
      "rft.volume=1",
      "rft.issue=2",
      "rft.spage=3",
      "rft.epage=4",
      "rft.date=1941"
    ]
  end

  it "should add multiple authors" do
    coins = helper.coins(ward_reference_factory(
      :authors => 'MacKay, W. P.; Lowrie, D.',
      :year => '1941',
      :title => 'A title',
      :citation => 'Journal Title 1(2):3-4'
    ))
    check_parameters coins, [
      "ctx_ver=Z39.88-2004",
      "rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal",
      "rfr_id=antcat.org",
      "rft.genre=article",
      "rft.atitle=A+title",
      "rft.jtitle=Journal+Title",
      "rft.volume=1",
      "rft.issue=2",
      "rft.spage=3",
      "rft.epage=4",
      "rft.date=1941",
      "rft.aulast=MacKay",
      "rft.aufirst=W.+P.",
      "rft.aulast=Lowrie",
      "rft.aufirst=D.",
    ]
  end

  it "should handle authors without commas" do
    coins = helper.coins(ward_reference_factory(
      :authors => 'Anonymous',
      :year => '1941',
      :title => 'A title',
      :citation => 'Journal Title 1(2):3-4'
    ))
    check_parameters coins, [
      "ctx_ver=Z39.88-2004",
      "rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal",
      "rfr_id=antcat.org",
      "rft.genre=article",
      "rft.atitle=A+title",
      "rft.jtitle=Journal+Title",
      "rft.volume=1",
      "rft.issue=2",
      "rft.spage=3",
      "rft.epage=4",
      "rft.date=1941",
      "rft.au=Anonymous",
    ]
  end

  it "should strip out italics formatting" do
    coins = helper.coins(ward_reference_factory(
      :authors => 'Ward, P.S.',
      :year => '1941',
      :title => 'A *title*',
      :citation => 'Journal Title 1(2):3-4'
    ))
    check_parameters coins, [
      "ctx_ver=Z39.88-2004",
      "rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal",
      "rfr_id=antcat.org",
      "rft.genre=article",
      "rft.atitle=A+title",
      "rft.jtitle=Journal+Title",
      "rft.volume=1",
      "rft.issue=2",
      "rft.spage=3",
      "rft.epage=4",
      "rft.date=1941",
      "rft.aufirst=P.S.",
      "rft.aulast=Ward",
    ]
  end

  it "should escape HTML" do
    coins = helper.coins(ward_reference_factory(
      :authors => 'Ward, P.S.',
      :year => '1941',
      :title => '<script>',
      :citation => 'Journal Title 1(2):3-4'
    ))
    check_parameters coins, [
      "ctx_ver=Z39.88-2004",
      "rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal",
      "rfr_id=antcat.org",
      "rft.genre=article",
      "rft.atitle=%3Cscript%3E",
      "rft.jtitle=Journal+Title",
      "rft.volume=1",
      "rft.issue=2",
      "rft.spage=3",
      "rft.epage=4",
      "rft.date=1941",
      "rft.aufirst=P.S.",
      "rft.aulast=Ward",
    ]
  end

  it "should format a book reference correctly" do
    Factory :place, :name => 'Dresden'
    coins = helper.coins(ward_reference_factory(
      :authors => 'MacKay, W.',
      :year => '1933',
      :title => 'Another title',
      :citation => 'Dresden: Springer Verlag, ix + 33pp.'
    ))
    check_parameters coins, [
      "ctx_ver=Z39.88-2004",
      "rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Abook",
      "rft.aulast=MacKay",
      "rft.aufirst=W.",
      "rfr_id=antcat.org",
      "rft.genre=book",
      "rft.btitle=Another+title",
      "rft.pub=Springer+Verlag",
      "rft.place=Dresden",
      "rft.date=1933",
      "rft.pages=ix+%2B+33pp.",
    ]
  end

  it "should format an unknown reference correctly" do
    coins = helper.coins(ward_reference_factory(
      :authors => 'MacKay, W.',
      :year => '1933',
      :title => 'Another title',
      :citation => 'Dresden.'))
    check_parameters coins, [
      "ctx_ver=Z39.88-2004",
      "rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Adc",
      "rft.aulast=MacKay",
      "rft.aufirst=W.",
      "rfr_id=antcat.org",
      "rft.genre=",
      "rft.title=Another+title",
      "rft.source=Dresden",
      "rft.date=1933",
    ]
  end

  it "should just provide very basic stuff for nested references for now" do
    reference = Factory :reference
    nested_reference = Factory :nested_reference, :pages_in => 'In:', :nested_reference => reference,
      :authors => [Factory :author, :name => 'Bolton, B.'], :title => 'Title', :citation_year => '2010'
    coins = helper.coins nested_reference
    check_parameters coins, [
      "ctx_ver=Z39.88-2004",
      "rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Adc",
      "rft.aulast=Bolton",
      "rft.aufirst=B.",
      "rfr_id=antcat.org",
      "rft.genre=",
      "rft.title=Title",
      "rft.date=2010",
    ]
  end

  def check_parameters coins, expected_parameters
    match = coins.match(/<span class="Z3988" title="(.*)"/)
    match.should_not be_nil
    match[1].should_not be_nil
    parameters = match[1].split("&amp;")
    parameters.should =~ expected_parameters
  end
end
