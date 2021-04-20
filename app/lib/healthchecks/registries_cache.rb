module Healthchecks
  class RegistriesCache
    def name
      :registries_have_data
    end

    def status
      if empty_registries.any?
        :critical
      else
        :ok
      end
    end

    # Optional
    def message
      if empty_registries.any?
        "The following registry caches are empty: #{empty_registries.keys.join(', ')}."
      else
        "OK"
      end
    end

    # Optional
    def enabled?
      true # false if the check is not relevant at this time
    end

  private

    def empty_registries
      @empty_registries ||= registries.select do |_key, registry|
        Rails.cache.fetch(registry.cache_key).nil?
      end
    end

    def registries
      Registries::BaseRegistries.new.all
    end
  end
end
