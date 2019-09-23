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
    "#{prefix.to_s.strip} #{suffix}".strip.upcase_first
  end

private

  attr_reader :filter, :subscription_list_title_prefix, :facets

  def prefix
    if facets.size == 1 && subscription_list_title_prefix.is_a?(Hash)
      subscription_list_title_prefix[plural_or_single].to_s
    elsif selected_facets.empty?
      subscription_list_title_prefix.to_s
    elsif subscription_list_title_prefix
      "#{subscription_list_title_prefix.strip} with"
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
    facet_key = facets.first["filter_key"] || facets.first["facet_id"]

    if dynamic_filter_option?(facet_key)
      return dynamic_facet_sentence(facet_key, selected_facets.first["facet_name"])
    end

    topic_names_sentence(facets.first)
  end

  def multiple_facets_suffix
    grouped_facets.map { |facet_key, facet_group|
      if dynamic_filter_option?(facet_key)
        dynamic_facet_sentence(facet_key, facet_group.first["facet_name"])
      else
        facet_group.map { |facet| facet["facet_name"] + " of " + topic_names_sentence(facet) }.to_sentence
      end
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
    facets.select do |facet|
      (
        filter[facet["facet_id"]].present? && !ignore_facet?(facet["facet_id"])
      ) ||
        filter[facet["filter_key"]].present?
    end
  end

  def grouped_facets
    selected_facets.group_by { |facet| facet["filter_key"] || facet["facet_id"] }
  end

  def dynamic_facet_sentence(facet_key, facet_name)
    registry              = registry(facet_key)
    all_values            = filter_values(facet_key, registry)
    values, blank_values  = all_values.partition(&:present?)
    total_values          = all_values.count
    word                  = total_values > 1 ? facet_name : facet_name.singularize

    return "#{total_values} #{word}" if registry.nil? || values.count.zero?

    return "#{word} of #{values.to_sentence}" if blank_values.count.zero?

    other_word = blank_values.count > 1 ? facet_name : facet_name.singularize
    values_with_unknown_others = values.concat(["#{blank_values.count} other #{other_word}"])

    "#{word} of #{values_with_unknown_others.to_sentence}"
  end

  def filter_values(facet_key, registry)
    filter.fetch(facet_key, []).map { |value|
      find_title_by_slug(value, registry)
    }
  end

  def find_title_by_slug(slug, registry)
    return "" if registry.nil?

    return "Brexit" if is_brexit?(registry, slug)

    item = registry[slug] || {}
    item.fetch("title", "")
  end

  def registry(facet_key)
    registries.all[facet_key]
  end

  def registries
    @registries ||= Registries::BaseRegistries.new
  end

  def dynamic_filter_option?(filter_key)
    # these are keys such as organisations where it is not practical to
    # put all choices into the finder email signup content item.
    %w(
      world_locations
      organisations
      people
      part_of_taxonomy_tree
      all_part_of_taxonomy_tree
      document_type
      content_store_document_type
    ).include?(filter_key)
  end

  def is_brexit?(registry, content_id)
    registry.is_a?(Registries::TopicTaxonomyRegistry) && content_id == "d6c2de5d-ef90-45d1-82d4-5f2438369eea"
  end

  def ignore_facet?(facet_id)
    %W(facet_groups).include?(facet_id)
  end
end
