module Healthcheck
  class RegistriesCacheCheck
    attr_reader :message

    def name
      :registries_have_data
    end

    def status
      if empty_registries.any?
        @message = "The following registry caches are empty: #{empty_registries.keys.join(', ')}."
        GovukHealthcheck::CRITICAL
      else
        GovukHealthcheck::OK
      end
    rescue StandardError => e
      @message = e.message
      GovukHealthcheck::CRITICAL
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
