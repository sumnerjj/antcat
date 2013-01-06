# coding: UTF-8
#  How to import a references file from Bolton
#  1) Open the file in Word
#  2) Save it as web page

class Importers::Bolton::Bibliography::Importer
  def initialize show_progress = false
    Progress.init show_progress, nil, self.class.name
  end

  def import_files filenames
    ::Bolton::Reference.update_all import_result: nil
    filenames.each do |filename|
      @filename = filename
      Progress.puts "Importing #{@filename}..."
      import_html File.read @filename
    end
    self.class.show_results
  end

  def import_html html
    doc = Nokogiri::HTML html
    ps = doc.css('p')
    ps.each do |p|
      line = p.inner_html
      next if header? line
      next if blank? line
      import_reference line
    end
  end

  def header? line
    line =~ /CATALOGUE REFERENCES/
  end

  def blank? line
    line.length < 20
  end

  def reference? string
    string.match(/^Note: /).blank?
  end

  def import_reference string
    string = pre_parse! string
    return unless reference? string
    original = string.dup
    attributes = Importers::Bolton::Bibliography::Grammar.parse(string, consume: false).value
    post_parse attributes
    attributes.merge! original: original
    ::Bolton::Reference.import attributes
  rescue Citrus::ParseError => e
  end

  def pre_parse! string
    string.gsub! / /, ' ' # 0x00A0, which is what we get from Nokogiri from &nbsp;
    string.gsub! /&nbsp;/, ' '
    string.replace CGI.unescapeHTML(string)
    string.gsub! /\n/, ' '
    remove_attributes! string
    string.strip!
    string = remove_span string
    string.strip!
    string.gsub /<p><\/p>/, ''
    string = fix_italic_title_and_journal_title string
    string
  end

  def fix_italic_title_and_journal_title string
    string.gsub /<i[^>]*>([[:upper:]][[:lower:]]+)\./, '<i>\1</i>.<i>'
  end

  def post_parse attributes
    attributes[:journal] = remove_italic(attributes[:journal]) if attributes[:journal]
    attributes[:series_volume_issue] = remove_bold attributes[:series_volume_issue] if attributes[:series_volume_issue]
    attributes[:place].strip! if attributes[:place]
    attributes[:title] = remove_period remove_italic remove_span remove_bold attributes[:title]
    attributes[:note] = remove_italic attributes[:note] if attributes[:note]
  end

  def remove_attributes! string
    string.gsub! /<(\w+).*?>/, '<\1>'
  end

  def remove_span string
    remove_tag 'span', string
  end

  def remove_italic string
    remove_tag 'i', string
  end

  def remove_bold string
    remove_tag 'b', string
  end

  def remove_tag tag, string
    string.gsub /<#{tag}.*?>(.*?)<\/#{tag}>/, '\1'
  end

  def remove_period string
    string = string.strip
    string = string[0..-2] if string[-1..-1] == '.'
    string
  end

  def self.show_results
    show_changed_references
    show_totals
  end

  def self.show_changed_references
    last_last_name = ''
    ::Bolton::Reference.where("(import_result = 'added') OR import_result IS NULL").all.sort_by do |a|
      a.authors + a.citation_year + a.title
    end.each do |reference|
      this_last_name = reference.authors.split(/,|\s/).first
      if this_last_name != last_last_name
        Progress.puts
        last_last_name = this_last_name
      end
      Progress.puts "#{reference.import_result.nil? ? "Deleted:" : "Added:  "} #{display_reference reference}"
    end
    Progress.puts
  end

  def self.show_totals
    Progress.puts "#{::Bolton::Reference.count.to_s.rjust(4)} total"
    Progress.puts "#{::Bolton::Reference.where(import_result: 'identical').count.to_s.rjust(4)} identical"

    added_count = ::Bolton::Reference.where(import_result: 'added').count
    Progress.puts "#{(added_count).to_s.rjust(4)} added"

    Progress.puts "#{::Bolton::Reference.where(import_result: 'updated_title').count.to_s.rjust(4)} updated title"
    Progress.puts "#{::Bolton::Reference.where(import_result: 'updated_authors').count.to_s.rjust(4)} updated authors"
    Progress.puts "#{::Bolton::Reference.where(import_result: 'updated_year').count.to_s.rjust(4)} updated year"
    Progress.puts "#{::Bolton::Reference.where(import_result: 'updated').count.to_s.rjust(4)} updated other"
    Progress.puts "#{::Bolton::Reference.where(import_result: 'updated_spans_removed').count.to_s.rjust(4)} updated (minor changes)"
    Progress.puts "#{::Bolton::Reference.where(import_result: nil).count.to_s.rjust(4)} deleted"
  end

  def self.display_reference reference
    "#{reference.to_s} #{reference.id}"
  end

  ########################################
  def get_new_references
    ::Bolton::Reference.where(import_result: 'added').select do |reference|
      not Reference.find_bolton reference
    end
  end

end
