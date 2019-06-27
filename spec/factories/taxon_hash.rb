FactoryBot.define do
  factory :taxon_hash, class: Hash do
    sequence :title, 1 do |n|
      "taxon_title_#{n}"
    end

    content_id { SecureRandom.uuid }

    sequence :base_path, 1 do |n|
      "/path/taxon_#{n}"
    end

    sequence :description, 1 do |n|
      "this is taxon #{n}"
    end

    initialize_with { attributes }
  end
end
