class TaxonDecorator::Statistics
  include ActionView::Helpers
  include ActionView::Context
  include ApplicationHelper #pluralize_with_delimiters, count_and_status

  def statistics statistics, options = {}
    options.reverse_merge! :include_invalid => true, :include_fossil => true
    return '' unless statistics && statistics.present?

    strings = [:extant, :fossil].inject({}) do |strings, extant_or_fossil|
      extant_or_fossil_statistics = statistics[extant_or_fossil]
      if extant_or_fossil_statistics
        string = [:subfamilies, :tribes, :genera, :species, :subspecies].inject([]) do |rank_strings, rank|
          string = rank_statistics(extant_or_fossil_statistics, rank, options[:include_invalid])
          rank_strings << string if string.present?
          rank_strings
        end.join ', '
        strings[extant_or_fossil] = string
      end
      strings
    end

    strings = if strings[:extant] && strings[:fossil] && options[:include_fossil]
                strings[:extant].insert 0, 'Extant: '
                strings[:fossil].insert 0, 'Fossil: '
                [strings[:extant], strings[:fossil]]
              elsif strings[:extant]
                [strings[:extant]]
              elsif options[:include_fossil]
                ['Fossil: ' + strings[:fossil]]
              else
                []
              end

    strings.map do |string|
      content_tag :p, string, class: 'taxon_statistics'
    end.join.html_safe
  end

  private
    def rank_statistics statistics, rank, include_invalid
      statistics = statistics[rank]
      return unless statistics

      statistics_strings = []
      string = valid_statistics statistics, rank, include_invalid
      statistics_strings << string if string.present?

      if include_invalid
        string = invalid_statistics statistics
        statistics_strings << string if string.present?
      end

      statistics_strings.join ' '
    end

    def valid_statistics statistics, rank, include_invalid
      string = ''
      if statistics['valid']
        string << rank_status_count(rank, 'valid', statistics['valid'], include_invalid)
        statistics.delete 'valid'
      end
      string
    end

    def invalid_statistics statistics
      sorted_keys = statistics.keys.sort_by do |key|
        Status.ordered_statuses.index key
      end

      status_strings = sorted_keys.map do |status|
        rank_status_count(:genera, status, statistics[status])
      end

      if status_strings.present?
        "(#{status_strings.join(', ')})"
      else
        ''
      end
    end

    def rank_status_count rank, status, count, label_statuses = true
      if label_statuses
        options = if status == 'valid' then :nil else :plural end
        count_and_status = pluralize_with_delimiters count, status, Status[status].to_s(options)
      else
        count_and_status = number_with_delimiter count
      end

      string = count_and_status
      if status == 'valid'
        # we must first singularize because rank may already be pluralized
        string << " #{rank.to_s.singularize.pluralize(count)}"
      end
      string
    end
end