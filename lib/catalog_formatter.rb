# coding: UTF-8
class CatalogFormatter
  extend ERB::Util
  extend ActionView::Helpers::TagHelper
  extend ActionView::Helpers::TextHelper
  extend ActionView::Helpers::NumberHelper
  extend ActionView::Context

  extend Formatter
  extend Catalog::StatisticsFormatter
  extend Catalog::IndexFormatter
  extend Catalog::AntwebFormatter

  def self.taxon_label_and_css_classes taxon, options = {}
    fossil_symbol = taxon.fossil? ? "&dagger;" : ''
    css_classes = css_classes_for_rank taxon
    css_classes << taxon.status.gsub(/ /, '_')
    css_classes << 'selected' if options[:selected]
    name = taxon.name.dup
    name.upcase! if options[:uppercase]
    label = fossil_symbol + h(name)
    {:label => label.html_safe, :css_classes => css_classes_for_taxon(taxon, options[:selected])}
  end

  def self.css_classes_for_rank taxon
    [taxon.type.downcase, 'taxon']
  end

  def self.status_plural status
    status_labels[status][:plural]
  end

  def self.status_labels
    @status_labels || begin
      @status_labels = ActiveSupport::OrderedHash.new
      @status_labels['synonym']             = {:singular => 'synonym', :plural => 'synonyms'}
      @status_labels['homonym']             = {:singular => 'homonym', :plural => 'homonyms'}
      @status_labels['unavailable']         = {:singular => 'unavailable', :plural => 'unavailable'}
      @status_labels['unidentifiable']      = {:singular => 'unidentifiable', :plural => 'unidentifiable'}
      @status_labels['excluded']            = {:singular => 'excluded', :plural => 'excluded'}
      @status_labels['unresolved homonym']  = {:singular => 'unresolved homonym', :plural => 'unresolved homonyms'}
      @status_labels['recombined']          = {:singular => 'transferred out of this genus', :plural => 'transferred out of this genus'}
      @status_labels['nomen nudum']         = {:singular => 'nomen nudum', :plural => 'nomina nuda'}
      @status_labels
    end
  end

  def self.ordered_statuses
    status_labels.keys
  end

  def self.pluralize_with_delimiters count, word, plural = nil
    if count != 1
      word = plural ? plural : word.pluralize
    end
    "#{number_with_delimiter(count)} #{word}"
  end

  def self.css_classes_for_taxon taxon, selected = false
    css_classes = css_classes_for_rank taxon
    css_classes << taxon.status.gsub(/ /, '_')
    css_classes << 'selected' if selected
    css_classes = css_classes.sort.join ' '
  end

end
