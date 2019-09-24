FactoryBot.define do
  factory :document_hash, class: Hash do
    sequence :title, 1 do |n|
      "document_title_#{n}"
    end
    sequence :link, 1 do |n|
      "path/to/document_#{n}"
    end
    content_id { SecureRandom.uuid }
    sequence :description, 1 do |n|
      "description_#{n}"
    end
    public_timestamp { Time.now }
    release_timestamp { Time.now }
    document_type { "answer" }
    organisations {
      [{
          "acronym" => "DWP",
          "content_id" => "b548a09f-8b35-4104-89f4-f1a40bf3136d",
          "title" => "Department for Work and Pensions",
       }]
    }
    content_purpose_supergroup { "guidance_and_regulation" }
    is_historic { false }
    government_name { "2015 Conservative government" }
    es_score { nil }
    format { "answer" }
    facet_values { [] }

    initialize_with { attributes.deep_stringify_keys }
  end
end
