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
        "topical_events" => topical_events,
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

    def topical_events
      @topical_events ||= TopicalEventsRegistry.new
    end
  end
end
