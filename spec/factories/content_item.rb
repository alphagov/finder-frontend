FactoryBot.define do
  factory :content_item, class: ContentItem do
    sequence :content_id, 1 do |n|
      "content_id_#{n}"
    end
    slug { "/finder_slug" }
    title { "finder-title" }
    links { {} }
    details do
      {
        'details_show_summaries': true,
        "sort": [
          {
            "name": "Topic",
            "key": "topic",
            "default": true,
          },
          {
            "name": "Most viewed",
            "key": "-popularity",
          },
        ],
      }
    end
    initialize_with do
      new(attributes.deep_stringify_keys)
    end
  end
end
