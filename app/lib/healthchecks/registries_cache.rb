# typed: true
module Healthchecks
  class RegistriesCache
    def name
      :registries_have_data
    end

    def status
      if in_warning_state?
        :warning
      else
        :ok
      end
    end

    # Optional
    def message
      if in_warning_state?
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

    def in_warning_state?
      empty_registries.any?
    end

    def empty_registries
      @empty_registries ||= registries.select { |_key, registry|
        Rails.cache.fetch(registry.cache_key).nil?
      }
    end

    def registries
      Registries::BaseRegistries.new.all
    end
  end
end
