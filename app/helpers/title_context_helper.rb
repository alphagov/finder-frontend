module TitleContextHelper
  def title_context(filter_params = nil)
    filter_params ||= params

    topical_events = filter_params["topical_events"]
    topical_events = [topical_events] if topical_events.is_a? String

    if topical_events && topical_events.count == 1
      registry = Services.registries.all["topical_events"]
      (registry[topical_events.first] || {})["title"]
    end
  end
end
