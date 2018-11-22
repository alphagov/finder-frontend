module Registries
  NAMESPACE = Rails.env.test? ? 'test/registries' : 'registries'

  class BaseRegistries
    def all
      @all ||= {
        'world_locations' => world_locations,
        'part_of_taxonomy_tree' => topic_taxonomy
      }
    end

  private

    def world_locations
      @world_locations ||= WorldLocationsRegistry.new
    end

    def topic_taxonomy
      @topic_taxonomy ||= TopicTaxonomyRegistry.new
    end
  end
end
