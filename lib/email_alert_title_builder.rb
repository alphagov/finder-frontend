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

  def prefix
    if facets.size == 1 && subscription_list_title_prefix.is_a?(Hash)
      subscription_list_title_prefix[plural_or_single].to_s
    elsif selected_facets.empty?
      subscription_list_title_prefix.to_s
    elsif subscription_list_title_prefix
      "#{subscription_list_title_prefix}with "
    end
  end

  def plural_or_single
    filter.fetch(facets.first["facet_id"], []).length == 1 ? "singular" : "plural"
  end

  def suffix
    return singular_suffix if facets.size == 1

    multiple_facets_suffix if selected_facets.present?
  end

  def singular_suffix
    facet_key = facets.first['filter_key'] || facets.first['facet_id']
    dynamic_suffix = dynamic_facet_sentence(facet_key, selected_facets.first)
    return dynamic_suffix unless dynamic_suffix.nil?

    topic_names_sentence(facets.first)
  end

  def multiple_facets_suffix
    grouped_facets.map { |facet_key, facet_group|
      dynamic_suffix = dynamic_facet_sentence(facet_key, facet_group.first)
      next dynamic_suffix unless dynamic_suffix.nil?

      facet_group.map { |facet| facet["facet_name"] + " of " + topic_names_sentence(facet) }.to_sentence
    }.to_sentence
  end

  def topic_names_sentence(facet)
    filter.fetch(facet["facet_id"], []).map { |key| choice_by_key(facet, key) }.to_sentence
  end

  def choice_by_key(facet, key)
    chosen = facet.fetch("facet_choices", []).detect { |choice| choice["key"] == key }

    chosen["topic_name"] if chosen
  end

  def selected_facets
    facets.select { |facet| filter[facet["facet_id"]].present? || filter[facet["filter_key"]].present? }
  end

  def grouped_facets
    selected_facets.group_by { |facet| facet['filter_key'] || facet['facet_id'] }
  end

  def dynamic_facet_sentence(facet_key, facet)
    return nil unless dynamic_filter_option?(facet_key)

    count = filter.fetch(facet_key, []).count
    word = count > 1 ? facet["facet_name"] : facet["facet_name"].singularize
    "#{count} #{word}"
  end

  def dynamic_filter_option?(filter_key)
    # these are keys such as organisations where it is not practical to
    # put all choices into the finder email signup content item.
    %w(
      world_locations
      organisations
      people
      part_of_taxonomy_tree
      document_type
    ).include?(filter_key)
  end
end
