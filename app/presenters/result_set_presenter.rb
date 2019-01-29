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
      pluralised_document_noun: "result".pluralize(total),
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

  def document_in_all_sectors(metadata)
    metadata[:id] === "sector_business_area" && metadata[:labels].count > 42
  end

  def documents_by_facits
    sector_facets = {}
    all_businesses = {
      all_businesses: {
        facet_name: "All Businesses",
        facet_key: "all_businesses",
        documents: []
      }
    }
    other_facets = {}

    displayed_docs = []

    documents.each do | doc |
      
      # return if there is no metadata
      next unless doc[:document][:metadata].present?

      _filters = @filter_params.without('order','keywords')

      # if no filters are selected then put in all business
      if _filters.values.length == 0
        all_businesses[:all_businesses][ :documents ] << doc
        displayed_docs << doc[:document_index]
        next
      end

      # Loop through each metadata to group against the filter params
      doc[:document][:metadata].each do | metadata |
        # next unless metadata is in the filter
        next unless _filters[ metadata[:id] ]


        # if document already added then do not add to list to reduce duplicates
        next if doc[:document_index].in?(displayed_docs)

        sector_business_activity = ( metadata[:id] === "sector_business_area" || metadata[:id] === "business_activity" ) 

        # if the document belongs to all sectors then put it in all business sector
        if sector_business_activity && ( document_in_all_sectors(metadata) || !_filters[:sector_business_area])
          all_businesses[:all_businesses][ :documents ] << doc
          displayed_docs << doc[:document_index]
        else
          # if not for all sectors then add to each sector
          metadata[:labels].each do | value |
            # if the documents has a facet that exists in the search then add doc to list

            # if sector is chosen and in the list
            if sector_business_activity && _filters[:sector_business_area] && value.in?(_filters[:sector_business_area])
              unless sector_facets[value]
                sector_facets[value] = {
                  facet_key: value,
                  facet_name: get_sector_name(value),
                  documents: []
                }
              end
              sector_facets[value][:documents] << doc
            
            # if sector is set but not selected then put in all businesses
            elsif sector_business_activity
              all_businesses[:all_businesses][ :documents ] << doc
            
            # other facets
            else
              unless other_facets[value]
                other_facets[metadata[:id]] = {
                  facet_key: metadata[:id],
                  facet_name: metadata[:label],
                  documents: []
                }
              end
              other_facets[metadata[:id]][ :documents ] << doc
            end

            # stop duplications
            displayed_docs << doc[:document_index]
            break;
          end
        end
      end
    end

    # return merged results
    [sector_facets, other_facets, all_businesses].inject(&:merge).values
  end

  def get_sector_name(sector_key)
    unless @sector_key_map.present?
      @finder.filters.each do | facet |
        next unless facet.key === 'sector_business_area'
        @sector_key_map = {:all_businesses => "All businesses"}
        facet.allowed_values.each do | facet_option |
          @sector_key_map[facet_option["value"]] = facet_option["label"]
        end
        break
      end
    end
    @sector_key_map[sector_key]
  end

  def sort_by_promoted(results)
    results.sort do |x, y|
      (x.promoted ? -1 : (y.promoted ? 1 : 0))
    end
  end

  def documents
    sorted_results = sort_by_promoted(results)
    sorted_results.each_with_index.map do |result, index|
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
