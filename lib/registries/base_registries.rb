module Registries
  NAMESPACE = "registries".freeze

  class BaseRegistries
    def all
      @all ||= {
        "world_locations" => world_locations,
        "all_part_of_taxonomy_tree" => full_topic_taxonomy,
        "part_of_taxonomy_tree" => topic_taxonomy,
        "people" => people,
        "roles" => roles,
        "organisations" => organisations,
        "manual" => manuals,
        "full_topic_taxonomy" => full_topic_taxonomy,
        # this isn't called "topical_events" because we don't want the
        # facet tag to appear automatically
        "full_topical_events" => full_topical_events,
      }
    end

    def ensure_warm_cache
      all.each_value do |registry|
        if registry.can_refresh_cache?
          registry.fetch_from_cache
        end
      end
    end

    def refresh_cache
      all.each_value do |registry|
        if registry.can_refresh_cache?
          registry.refresh_cache
        end
      end
    end

    def topic_taxon_with_content_id(content_id)
      topic_taxonomy
        .taxonomy_tree
        .select { |key, _value| key == content_id }
        .dig(content_id)
    end

  private

    def full_topic_taxonomy
      @full_topic_taxonomy ||= FullTopicTaxonomyRegistry.new
    end

    def world_locations
      @world_locations ||= WorldLocationsRegistry.new
    end

    def topic_taxonomy
      @topic_taxonomy ||= TopicTaxonomyRegistry.new
    end

    def people
      @people ||= PeopleRegistry.new
    end

    def roles
      @roles ||= RolesRegistry.new
    end

    def organisations
      @organisations ||= OrganisationsRegistry.new
    end

    def manuals
      @manuals ||= ManualsRegistry.new
    end

    def full_topical_events
      @full_topical_events ||= TopicalEventsRegistry.new
    end
  end
end
