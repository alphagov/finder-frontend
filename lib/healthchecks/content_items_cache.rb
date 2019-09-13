module Healthchecks
  class ContentItemsCache
    def name
      :content_items_are_cached
    end

    def status
      if in_warning_state?
        :warning
      else
        :ok
      end
    rescue StandardError
      :warning
    end

    def message
      if in_warning_state?
        <<~WARNING
          Content items aren't cached. Searches may be slower. Is content store unavailable?
          These content items are uncached:
          #{uncached_content_items.to_sentence}
        WARNING
      else
        "OK"
      end
    rescue StandardError => e
      <<~WARNING
        A #{e.class} error occurred when checking the content item cache health:
        #{e.message}
      WARNING
    end

    # Optional
    def enabled?
      true # false if the check is not relevant at this time
    end

  private

    def in_warning_state?
      uncached_content_items.any?
    end

    def uncached_content_items
      @uncached_content_items ||= finder_paths.select { |path|
        Rails.cache.fetch(Services.content_store.cache_key(path)).nil?
      }
    end

    def finder_paths
      FetchFinders.from_search_api.map { |result| result['link'] }.compact
    end

    def registries
      Registries::BaseRegistries.new.all
    end
  end
end
