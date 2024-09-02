module TopicFinderHelper
  def topic_finder?(filter_params)
    filter_params.include?("topic") && topic_finder_parent(filter_params)
  end

  def topic_finder_parent(filter_params)
    Services.registries.all["full_topic_taxonomy"][filter_params["topic"]]
  end

  def is_inverse?
    topic_finder?(filter_params) && !content_item.all_content_finder?
  end
end
