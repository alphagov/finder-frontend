# Ensures that email alert filter keys and values provided by users
# and that Finder Frontend sends to Email Alert API are within the
# set of permitted keys and values provided in the content item or
# registries of people, organisations, taxons, and world locations.
module ParameterParser
  class EmailAlertParameterParser
    include ActiveModel::Validations

    validates :applied_filters, email_alert_params: true

    def initialize(content_item, filter_params, params)
      @content_item = content_item
      @filter_params = parsed_params(filter_params, params).deep_stringify_keys
    end

    def applied_filters
      @applied_filters ||= begin
        permitted_filter_keys.each_with_object({}) { |key, filter_hash|
          filter_hash[key] = permitted_values_for_filter_key(key)
        }.compact
      end
    end

    def required_facets_selected?
      required_facets.all? { |facet| applied_filters.key?(key_for_facet(facet)) }
    end

  private

    attr_reader :filter_params, :content_item

    def required_facets
      permitted_facets.select { |facet| facet.dig("required") }
    end

    def permitted_facets
      content_item.dig("details", "email_filter_facets") || []
    end

    def permitted_filter_keys
      allowed = permitted_facets.map { |facet| key_for_facet(facet) }
      given = filter_params.keys
      allowed & given
    end

    def permitted_values_for_filter_key(key)
      facet = find_facet_by_key(key)
      given_values = Array(filter_params[key])
      allowed_values = allowed_values_for_facet(facet)
      permitted = allowed_values & given_values
      permitted if permitted.any?
    end

    def find_facet_by_key(key)
      permitted_facets.find { |facet| key_for_facet(facet) == key }
    end

    def key_for_facet(facet)
      facet["filter_key"] || facet["facet_id"]
    end

    # TODO: this could be improved upon
    def allowed_values_for_facet(facet)
      # Facet choices used by /cma-cases/email-signup
      facet_choices = facet.fetch("facet_choices", [])
      facet_choice_values = facet_choices
        .map { |choice| choice["content_id"] || choice["key"] }
        .uniq
        .compact

      return facet_choice_values if facet_choice_values.any?

      # Option lookup used by /search/policy-papers-and-consultations/email-signup
      # TODO: remove option_lookup and make it consistent with other finders.
      option_lookup = facet.dig("option_lookup")
      return option_lookup.values.flatten if option_lookup.present?

      # Dynamic facets, such as people or organisations, used by
      # /search/news-and-communications/email-signup
      # TODO: Put is_a_dynamic_facet: bool into the content item schema
      key = key_for_facet(facet)
      if facet_choices.none? && could_be_a_dynamic_facet?(key)
        registry = Registries::BaseRegistries.new.all[key]
        return registry.values.keys if registry
      end

      []
    end

    def could_be_a_dynamic_facet?(key)
      %w(organisations people roles world_locations all_part_of_taxonomy_tree part_of_taxonomy_tree).include? key
    end

    def parsed_params(filter_params, params)
      # TODO: There are 3 params hashes here for the email-alert-api tags/links
      filter_params.fetch("subscriber_list_params", {}).merge(
        params
          .permit("filter" => {})
          .dig("filter")
          .to_h,
        )
    end
  end
end
