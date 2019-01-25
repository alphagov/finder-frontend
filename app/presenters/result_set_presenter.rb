class ResultSetPresenter
  include ERB::Util
  include ActionView::Helpers::NumberHelper

  attr_reader :finder, :document_noun, :results, :total

  delegate :document_noun,
           :filters,
           :keywords,
           :atom_url,
           to: :finder

  def initialize(finder, filter_params, view_context)
    @finder = finder
    @results = finder.results.documents
    @total = finder.results.total
    @filter_params = filter_params
    @view_context = view_context
  end

  def to_hash
    {
      total: number_with_delimiter(total),
      generic_description: generic_description,
      pluralised_document_noun: document_noun.pluralize(total),
      applied_filters: selected_filter_descriptions,
      documents_by_facits: documents_by_facits,
      documents: documents,
      page_count: documents.count,
      finder_name: finder.name,
      any_filters_applied: any_filters_applied?,
      atom_url: atom_url,
      next_and_prev_links: next_and_prev_links,
      sort_options: sort_options,
      display_as_topics: true #@filter_params[:order] === "most-relevant" # change to topic once this is available
    }
  end

  def any_filters_applied?
    selected_filters.length.positive? || keywords.present?
  end

  def generic_description
    publications = "publication".pluralize(total)
    "#{publications} matched your criteria"
  end

  def selected_filter_descriptions
    selected_filters.map { |filter|
      FacetTagPresenter.new(filter.sentence_fragment, filter.value, finder.slug).present
    }.reject(&:empty?)
  end

  def documents_by_facits
    facet_grouping = {}
    @filter_params.each do | key, options |
      next unless options.is_a? Array

      facet_options = {}
      options.each do | option_key |
        facet_options[option_key] = {
          documents: []
        }
      end

      facet_group = {
        facet_key: key,
        options: facet_options,
      }

      facet_grouping[key] = facet_options
    end

    displayed_docs = []

    documents.each do | doc |
      next unless doc[:document][:metadata].present?
      doc[:document][:metadata].each do | metadata |
        next unless facet_grouping[ metadata[:id] ]
        facet_grouping[ metadata[:id] ][:facet_name] = metadata[:label] unless facet_grouping[ metadata[:id] ][:facet_name]
        metadata[:labels].each do | value |
          next if displayed_docs.include? doc[:document_index]
          if facet_grouping[ metadata[:id] ][ value ]
            facet_grouping[ metadata[:id] ][ value ][ :documents ] << doc
            displayed_docs << doc[:document_index]
          end
        end 
      end
    end

    return_data = [];
    
    facet_grouping.values.each do | group |
      facet_data = {
        facet_name: group[:facet_name],
        documents: []
      }

      group.values.each do | facet_value |
        next unless facet_value.is_a? Hash
        facet_data[:documents].concat(facet_value[:documents])
      end

      return_data.push(facet_data)
    end


    return return_data;
  end

  def documents
    results.each_with_index.map do |result, index|
      {
        document: SearchResultPresenter.new(result).to_hash,
        document_index: index + 1
      }
    end
  end

  def user_supplied_date(date_facet_key, date_facet_from_to)
    @filter_params.fetch(date_facet_key, {}).fetch(date_facet_from_to, nil)
  end

  def user_supplied_keywords
    @filter_params.fetch('keywords', '')
  end

  def sort_options
    return if finder.sort.blank?

    sort_option = if @filter_params['order']
                    finder.sort.detect { |option| option['name'].parameterize == @filter_params['order'] }
                  end

    sort_option ||= finder.default_sort_option

    "<span class='visually-hidden'>sorted by <strong>" + sort_option['name'] + "</strong></span>" if sort_option.present?
  end

private

  attr_reader :view_context

  def next_and_prev_links
    return unless finder.pagination

    current_page = finder.pagination['current_page']
    previous_page = current_page - 1 if current_page > 1
    next_page = current_page + 1 if current_page < finder.pagination['total_pages']
    pages = {}

    pages[:previous_page] = build_page_link("Previous page", previous_page) if previous_page
    pages[:next_page] = build_page_link("Next page", next_page) if next_page

    view_context.render(formats: %w[html], partial: 'govuk_publishing_components/components/previous_and_next_navigation', locals: pages) if pages
  end

  def build_page_link(page_label, page)
    {
      url: [finder.slug, finder.values.merge(page: page).to_query].reject(&:blank?).join("?"),
      title: page_label,
      label: "#{page} of #{finder.pagination['total_pages']}",
    }
  end

  def selected_filters
    (filters + [KeywordFacet.new(keywords)]).select(&:has_filters?)
  end
end
