FactoryBot.define do
  factory :content_item, class: ContentItem do
    sequence :content_item, 1 do |n|
      "content_item_#{n}"
    end
    slug { "/finder_slug" }
    name { "finder_name" }
    links { {} }
    details {
      {
        "sort": [
         {
           "name": "Topic",
           "key": "topic",
           "default": true
         },
         {
           "name": "Most viewed",
           "key": "-popularity"
         }
        ],
      }
    }
    initialize_with { new(attributes.deep_stringify_keys) }
  end
end
