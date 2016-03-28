# coding: UTF-8
require 'spec_helper'
include Capybara::RSpecMatchers


describe CoinsHelper, type: 'helper' do
  it "should format a journal reference correctly" do
    coins = helper.coins(ArticleReference.new(
      :author_names => [FactoryGirl.create(:author_name, :name => 'MacKay, W.')],
      :year => '1941',
      :title => 'A title',
      :journal => FactoryGirl.create(:journal, :name => 'Journal Title'),
      :series_volume_issue => '1(2)',
      :pagination => '3-4'
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

  it "should bail on a class it doesn't know about " do
    expect {helper.coins(String.new)}.to raise_error
  end

  it "should use the numeric year" do
    coins = helper.coins(ArticleReference.new(
      :author_names => [FactoryGirl.create(:author_name, :name => 'MacKay, W.')],
      :year => '1941a ("1942")',
      :title => 'A title',
      :journal => FactoryGirl.create(:journal, :name => 'Journal Title'),
      :series_volume_issue => '1(2)',
      :pagination => '3-4'
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
    coins = helper.coins(ArticleReference.new(
      :author_names => [FactoryGirl.create(:author_name, :name => 'MacKay, W. P.'),
                        FactoryGirl.create(:author_name, :name => 'Lowrie, D.')],
      :year => '1941',
      :title => 'A title',
      :journal => FactoryGirl.create(:journal, :name => 'Journal Title'),
      :series_volume_issue => '1(2)',
      :pagination => '3-4'
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

  it "should strip out italics formatting" do
    coins = helper.coins(ArticleReference.new(
      :author_names => [FactoryGirl.create(:author_name, :name => 'Ward, P.S.')],
      :year => '1941',
      :title => 'A *title*',
      :journal => FactoryGirl.create(:journal, :name => 'Journal Title'),
      :series_volume_issue => '1(2)',
      :pagination => '3-4'
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
    coins = helper.coins(ArticleReference.new(
      :author_names => [FactoryGirl.create(:author_name, :name => 'Ward, P.S.')],
      :year => '1941',
      :title => '<script>',
      :journal => FactoryGirl.create(:journal, :name => 'Journal Title'),
      :series_volume_issue => '1(2)',
      :pagination => '3-4'
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
    FactoryGirl.create :place, :name => 'Dresden'
    coins = helper.coins(BookReference.new(
      :author_names => [FactoryGirl.create(:author_name, :name => 'MacKay, W.')],
      :year => '1933',
      :title => 'Another title',
      :publisher => FactoryGirl.create(:publisher, :name => 'Springer Verlag', :place => FactoryGirl.create(:place, :name => 'Dresden')),
      :pagination => 'ix + 33pp.'
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
    coins = helper.coins(UnknownReference.new(
      :author_names => [FactoryGirl.create(:author_name, :name => 'MacKay, W.')],
      :year => '1933',
      :title => 'Another title',
      :citation => 'Dresden'))
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
    reference = FactoryGirl.create :reference
    nested_reference = FactoryGirl.create :nested_reference, :pages_in => 'In:',
      :nesting_reference => reference,
      :author_names => [FactoryGirl.create(:author_name, :name => 'Bolton, B.')],
      :title => 'Title', :citation_year => '2010'
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
    expect(match).not_to be_nil
    expect(match[1]).not_to be_nil
    parameters = match[1].to_str.split("&amp;")
    expect(parameters).to match_array(expected_parameters)
  end
end