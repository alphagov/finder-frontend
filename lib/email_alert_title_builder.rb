class EmailAlertTitleBuilder
  def self.call(*args)
    new(*args).call
  end

  def initialize(filter:, subscription_list_title_prefix:, facets:)
    @filter = filter
    @subscription_list_title_prefix = subscription_list_title_prefix
    @facets = facets
  end

  def call
    (prefix.to_s + suffix.to_s).upcase_first
  end

private

  attr_reader :filter, :subscription_list_title_prefix, :facets

  def topic_names(facet)
    filter.fetch(facet["facet_id"], []).map { |key| choice_by_key(facet, key) }
  end

  def topic_names_sentence(facet)
    topic_names(facet).to_sentence
  end

  def choice_by_key(facet, key)
    if facet.dig("facet_choices")
      facet["facet_choices"].detect { |choice| choice["key"] == key }["topic_name"]
    else
      []
    end
  end

  def selected_facets
    facets.select { |facet| filter[facet["facet_id"]].present? }
  end

  def plural_or_single
    if filter.fetch(facets.first["facet_id"], []).length == 1
      "singular"
    else
      "plural"
    end
  end

  def prefix
    if facets.size == 1
      subscription_list_title_prefix[plural_or_single].to_s
    elsif selected_facets.empty?
      subscription_list_title_prefix.to_s
    elsif subscription_list_title_prefix
      "#{subscription_list_title_prefix}with "
    end
  end

  def suffix
    if facets.size == 1
      topic_names_sentence(facets.first)
    elsif selected_facets.present?
      selected_facets.map { |facet| facet["facet_name"] + " of " + topic_names_sentence(facet) }.to_sentence
    end
  end
end
