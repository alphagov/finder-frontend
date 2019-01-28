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

  def document_in_all_sectors(metadata)
    metadata[:id] === "sector_business_area" && metadata[:labels].count > 42
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

      if key === "sector_business_area"
        facet_options[:all_businesses] = {
          documents: []
        }
      end

      facet_group = {
        facet_key: key,
        options: facet_options,
      }

      facet_grouping[key] = facet_options
    end

    new_facet_grouping = {}

    displayed_docs = []

    documents.each do | doc |
      
      # return if there is no metadata
      next unless doc[:document][:metadata].present?

      # Loop through each metadata to group against the filter params
      doc[:document][:metadata].each do | metadata |
        # next unless metadata is in the filter
        next unless facet_grouping[ metadata[:id] ]

        # if document already added then do not add to list to reduce duplicates
        next if displayed_docs.include? doc[:document_index]

        # if the facet group name is not set then set it
        unless facet_grouping[ metadata[:id] ][:facet_name]
          facet_grouping[ metadata[:id] ][:facet_name] = metadata[:label]
        end

        # if the document belongs to all sectors then put it in all business sector
        if document_in_all_sectors(metadata)
          facet_grouping[ metadata[:id] ][ :all_businesses ][ :documents ] << doc
          displayed_docs << doc[:document_index]
        else
          # if not for all sectors then add to each sector
          metadata[:labels].each do | value |
            # if the documents has a facet that exists in the search then add doc to list
            if facet_grouping[ metadata[:id] ][ value ]
              facet_grouping[ metadata[:id] ][ value ][ :documents ] << doc
              displayed_docs << doc[:document_index]
            end
          end
        end
      end
    end

    return_data = []

    all_businesses_group = nil
    
    facet_grouping.each do | key, group |

      if key === "sector_business_area"
        group.each do | facet_key, facet_option |
          next unless facet_option.is_a? Hash
          if facet_key === :all_businesses
            all_businesses_group = {
              facet_key: facet_key,
              facet_name: get_sector_name(facet_key),
              documents: facet_option[:documents]
            }
          else
            return_data.push({
              facet_key: facet_key,
              facet_name: get_sector_name(facet_key),
              documents: facet_option[:documents]
            })
          end
        end
        next
      else
        facet_data = {
          facet_key: key,
          facet_name: group[:facet_name],
          documents: []
        }
        group.each do | facet_key, facet_option |
          next unless facet_option.is_a? Hash
          facet_data[:documents].concat(facet_option[:documents])
        end
        next if facet_data[:documents].count === 0
      end

      return_data.push(facet_data)
    end

    return_data.push(all_businesses_group) if all_businesses_group

    return return_data;
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
