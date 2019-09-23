class EmailAlertListTitleBuilder
  def self.call(*args)
    new(*args).call
  end

  def initialize(filter:, subscription_list_title_prefix:, facets:)
    @filter = filter
    @subscription_list_title_prefix = subscription_list_title_prefix
    @facets = facets
  end

  def call
    join_fragment = "in the following #{'category'.pluralize(selected_facet_choice_names.count)}"
    "#{subscription_list_title_prefix.strip} #{join_fragment}: #{comma_separated_facet_choices}"
  end

private

  attr_accessor :filter, :subscription_list_title_prefix, :facets

  def comma_separated_facet_choices
    selected_facet_choice_names.map { |choice_name| "'#{choice_name}'" }.join(", ")
  end

  def selected_facet_choice_names
    @selected_facet_choice_names ||= begin
      overwritten_filters = filter.map do |selected_facet_id, selected_facet_choices|
        selected_facet_choices.map do |selected_facet_choice_id|
          fetch_facet_choice_name(selected_facet_id, selected_facet_choice_id)
        end
      end
      overwritten_filters.flatten
    end
  end

  def fetch_facet_choice_name(facet_id, facet_choice_id)
    fetch_facet_choice_name_from_overrides(facet_id, facet_choice_id) || fetch_facet_choice_name_from_data(facet_id, facet_choice_id)
  end

  def fetch_facet_choice_name_from_overrides(facet_id, facet_choice_id)
    facet_name_overrides.fetch(facet_id, {})[facet_choice_id]
  end

  def fetch_facet_choice_name_from_data(selected_facet_id, selected_facet_choice_key)
    facets.detect { |facet| facet["facet_id"] == selected_facet_id }
      .fetch("facet_choices")
      .detect { |choice| choice["content_id"] == selected_facet_choice_key }
      .fetch("topic_name")
  end

  def facet_name_overrides
    {
      "employ_eu_citizens" => {
        "5476f0c7-d029-459b-8a17-196374ae3366" => "Employing EU citizens",
        "bbdbda71-b1ec-46b8-a5b8-931d933288e9" => "Employing non-EU citizens",
      },
      "public_sector_procurement" => {
        "f165dc7c-7cef-446a-bdfd-8a1ca685d091" => "Public sector procurement - civil government contracts",
        "33fc20d7-6a45-40c9-b31f-e4678f962ff1" => "Public sector procurement - defence contracts",
      },
    }
  end
end
