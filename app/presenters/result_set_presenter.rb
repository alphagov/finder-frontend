class ResultSetPresenter
  include ERB::Util

  attr_reader :finder, :document_noun, :results, :total

  delegate :document_noun,
           :filter_sentence_fragments,
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
      total: total > 1000 ? "1,000+" : total,
      pluralised_document_noun: document_noun.pluralize(total),
      applied_filters: describe_filters_in_sentence,
      documents: documents,
      page_count: documents.count,
      finder_name: finder.name,
      any_filters_applied: any_filters_applied?,
      atom_url: atom_url,
      next_and_prev_links: next_and_prev_links,
    }
  end

  def any_filters_applied?
    filter_sentence_fragments.length.positive? || keywords.present?
  end

  def describe_filters_in_sentence
    [
      keywords_description,
      selected_filter_descriptions
    ].compact.join(' ')
  end

  def keywords_description
    if keywords.present?
      "containing <strong>#{html_escape(keywords)}</strong>"
    else
      ""
    end
  end

  def selected_filter_descriptions
    filter_sentence_fragments.flat_map { |fragment|
      fragment_description(fragment)
    }.join(' ')
  end

  def fragment_description(fragment)
    [
      fragment['preposition'],
      fragment_to_s(fragment),
    ]
  end

  def fragment_to_s(fragment)
    values = fragment['values'].map { |value|
      "<strong>#{html_escape(value['label'])}</strong>"
    }

    if fragment['type'] == "text"
      values.to_sentence(two_words_connector: ' or ', last_word_connector: ' or ')
    elsif fragment['type'] == "date" || fragment['type'] == "checkbox"
      values.to_sentence(two_words_connector: ' and ')
    end
  end

  def documents
    results.each_with_index.map do |result, index|
      {
        document: SearchResultPresenter.new(result).to_hash,
        document_index: index + 1,
      }
    end
  end

  def user_supplied_date(date_facet_key, date_facet_from_to)
    @filter_params.fetch(date_facet_key, {}).fetch(date_facet_from_to, nil)
  end

  def user_supplied_keywords
    @filter_params.fetch('keywords', '')
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
end
