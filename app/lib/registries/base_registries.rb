module Registries
  class BaseRegistries
    def all
      @all ||= {
        'world_locations' => world_locations
      }
    end

  private

    def world_locations
      @world_locations ||= WorldLocationsRegistry.new
    end
  end
end
