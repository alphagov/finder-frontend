module Registries
  class Registry
    NAMESPACE = "registries".freeze

    def can_refresh_cache?
      false
    end
  end
end
