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
      documents_by_facets: documents_by_facets,
      documents: documents,
      page_count: documents.count,
      finder_name: finder.name,
      any_filters_applied: any_filters_applied?,
      atom_url: atom_url,
      next_and_prev_links: next_and_prev_links,
      sort_options: sort_options,
      display_as_topics: grouped_display?,
    }
  end

  def grouped_display?
    @filter_params[:order] == "topic" || !@filter_params.has_key?(:order)
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

  def tagged_to_all(facet_key, metadata)
    facet = finder.facets.find { |f| f.key == facet_key }
    return false unless facet && metadata[:labels]

    values = facet.allowed_values.map { |v| v['value'] }
    values & metadata[:labels] == values
  end

  def documents_by_facets
    return {} unless grouped_display?

    sector_facets = {}
    all_businesses = {
      all_businesses: {
        facet_name: "All Businesses",
        facet_key: "all_businesses",
        documents: []
      }
    }
    other_facets = {}

    business_sectors = %W(sector_business_area business_activity)

    facet_filters = @filter_params.without(:order, :keywords)

    sorted_documents = documents.sort { |x, y| x[:document][:title] <=> y[:document][:title] }
    sorted_documents = sorted_documents.sort do |x, y|
      return -1 if x[:document][:promoted]

      y[:document][:promoted] ? 1 : 0
    end

    # If no filters are selected then put in all business
    if facet_filters.values.empty?
      all_businesses[:all_businesses][:documents] = sorted_documents
    end

    # TODO: Use Hash#group_by here to determine the groupings
    sorted_documents.each do |item|
      document_metadata = item[:document][:metadata]
      next unless document_metadata.present?

      # Loop through each metadata to group against the filter params
      document_metadata.each do |metadata|
        key = metadata[:id]
        next unless key && facet_filters.has_key?(key.to_sym)

        # Is this a business sector facet?
        if business_sectors.include?(key)
          # If the document is tagged to all sectors add to all businesses group
          if tagged_to_all("sector_business_area", metadata)
            all_businesses[:all_businesses][:documents] << item
          else
            # Match filters to metadata and group by value
            (metadata[:labels] & facet_filters.fetch(:sector_business_area, [])).each do |value|
              sector_facets[value] = empty_facet_group(value, facet_label_for(value)) unless sector_facets.has_key?(value)
              sector_facets[value][:documents] << item
            end
          end
        else
          # Add the document to the appropriate other facet group
          other_facets[key] = empty_facet_group(key, metadata[:label]) unless other_facets[key]
          other_facets[key][:documents] << item
        end
      end
    end

    all_businesses = {} if all_businesses[:all_businesses][:documents].empty?

    [sector_facets.sort.to_h, other_facets.sort.to_h, all_businesses].inject(&:merge).values
  end

  def metadata_for_filters(metadata, filters)
    metadata.select { |m| filters.key?(m[:id]) }
  end

  def empty_facet_group(key, name)
    { facet_key: key, facet_name: name, documents: [] }
  end

  def facet_label_for(key)
    allowed_values = finder.facets.map(&:allowed_values).flatten
    facet = allowed_values.find { |v| v["value"] == key }
    facet["label"] if facet
  end

  def sort_by_promoted(results)
    results.sort do |x, y|
      return -1 if x.promoted

      y.promoted ? 1 : 0
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
