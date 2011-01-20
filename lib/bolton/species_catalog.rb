#  A Bolton species catalog file is named NGC-Sp<start-letters>-<end-letters>.docx,
#  e.g. NGC-Spa-an.docx

#  To convert a species catalog file from Bolton to a format we can use
#  1) Open the file in Word
#  2) Save it as web page

#  To import these files, run
#    rake bolton:import:species

class Bolton::SpeciesCatalog
  attr_reader :logger

  def initialize show_progress = false
    Progress.init show_progress
    file = File.open 'log/bolton_species_import.log', 'w'
    file.sync = true
    @logger = Logger.new file
    @success_count = 0
  end

  def clear
    Species.delete_all
  end

  def import_files filenames
    @genus = nil
    filenames.each do |filename|
      @filename = filename
      Progress.puts "Importing #{@filename}..."
      import_html File.read @filename
      Progress.show_results
      Progress.puts
    end
    Progress.show_results
    @logger.info Progress.results_string
  end

  def import_html html
    doc = Nokogiri::HTML html
    ps = doc.css('p')
    ps.each do |p|
      record = parse p.inner_html
      case record[:type]
      when :genus then @genus = record[:genus]
      when :species then import_species record
      end
    end
  end

  def parse string
    string = string.gsub /\n/, ' '
    Bolton::SpeciesCatalogGrammar.parse(string).value
  rescue Citrus::ParseError => e
    @logger.info 'Parse error'
    @logger.info e
    nil
  end

  def import_species record
    unless @genus
      @logger.info 'No genus'
      @logger.info @filename
      @logger.info record
      return
    end
    genus = Genus.find_or_create_by_name @genus
    Species.create! :name => record[:species], :parent => genus
    Progress.tally_and_show_progress 100
  end

end
