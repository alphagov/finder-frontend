class TaxonFacet < FilterableFacet
  LEVEL_ONE_TAXON_KEY = "level_one_taxon".freeze
  LEVEL_TWO_TAXON_KEY = "level_two_taxon".freeze

  def initialize(facet, value_hash)
    @value_hash = value_hash
    super(facet)
  end

  def name
    facet["name"]
  end

  def topics
    level_one_taxons.unshift(default_topic_value)
  end

  def sub_topics
    return [default_sub_topic_value] unless level_two_taxons

    level_two_taxons.unshift(default_sub_topic_value)
  end

  def sentence_fragment
    return nil if selected_level_one_value.nil?

    {
      "type" => "taxon",
      "preposition" => preposition,
      "values" => value_fragments,
      "word_connectors" => and_word_connectors,
    }
  end

  def has_filters?
    selected_level_one_value.present?
  end

  def query_params
    {
      LEVEL_ONE_TAXON_KEY => (selected_level_one_value || {})[:value],
      LEVEL_TWO_TAXON_KEY => (selected_level_two_value || {})[:value],
    }
  end

  def selected_taxon_value
    selected_level_one_value || selected_level_two_value || selected_topic_value
  end

private

  def selected_topic_value
    return unless @value_hash["topic"]

    content_id = ContentItem.from_content_store(@value_hash["topic"]).content_id
    topic = full_topic_taxonomy.taxonomy.dig(content_id)

    {
      value: topic["content_id"],
      text: topic["title"],
      sub_topics: topic["children"],
    }
  end

  def value_fragments
    [
      value_fragment(selected_level_one_value, LEVEL_ONE_TAXON_KEY),
      value_fragment(selected_level_two_value, LEVEL_TWO_TAXON_KEY),
    ].compact
  end

  def value_fragment(value, key)
    return nil if value.nil?

    {
      "label" => value[:text],
      "parameter_key" => key,
      "value" => value[:value],
    }
  end

  def level_one_taxons
    @level_one_taxons ||= partial_topic_taxonomy.taxonomy_tree.values.map do |v|
      {
        value: v["content_id"],
        text: v["title"],
        sub_topics: v["children"],
        data_attributes: {
          track_category: "filterClicked",
          track_action: "level_one_taxon",
          track_label: v["title"],
        },
        selected: v["content_id"] == @value_hash[LEVEL_ONE_TAXON_KEY],
      }
    end
  end

  def level_two_taxons
    @level_two_taxons ||= level_one_taxons
      .map { |v| v[:sub_topics] }
      .compact
      .flatten
      .map do |v|
        {
          text: v["title"],
          value: v["content_id"],
          sub_topics: v["children"],
          data_attributes: {
            track_category: "filterClicked",
            track_action: "level_two_taxon",
            track_label: v["title"],
            topic_parent: v["parent"],
          },
          selected: v["content_id"] == @value_hash[LEVEL_TWO_TAXON_KEY],
        }
      end
  end

  def selected_level_two_value
    @selected_level_two_value ||= level_two_taxons.find do |v|
      v[:value] == @value_hash[LEVEL_TWO_TAXON_KEY]
    end
  end

  def selected_level_one_value
    @selected_level_one_value ||= level_one_taxons.find do |v|
      v[:value] == @value_hash[LEVEL_ONE_TAXON_KEY]
    end
  end

  def default_sub_topic_value
    { text: "All sub-topics", value: "", parent: "" }
  end

  def default_topic_value
    { text: "All topics", value: "" }
  end

  def full_topic_taxonomy
    @full_topic_taxonomy ||= Registries::BaseRegistries.new.all["full_topic_taxonomy"]
  end

  def partial_topic_taxonomy
    @partial_topic_taxonomy ||= Registries::BaseRegistries.new.all["part_of_taxonomy_tree"]
  end
end
