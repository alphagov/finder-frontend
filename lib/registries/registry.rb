module Registries
  class Registry
    def can_refresh_cache?
      false
    end

    def is_dynamic?
      false
    end
  end
end
