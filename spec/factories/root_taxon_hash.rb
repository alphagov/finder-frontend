FactoryBot.define do
  factory :root_taxon_hash, class: Hash do
    title { "root taxon" }
    content_id { SecureRandom.uuid }
    base_path { "/" }
    description { "The root taxon" }

    transient do
      level_one_taxon_hashes { [] }
    end

    initialize_with { attributes }

    after(:build) do |taxon, evaluator|
      taxon[:links] =
        if evaluator.level_one_taxon_hashes.empty?
          {}
        else
          { level_one_taxons: evaluator.level_one_taxon_hashes.map { |t| t.except(:links).merge(links: {}) } }
        end
      taxon.deep_stringify_keys!
    end
  end
end
