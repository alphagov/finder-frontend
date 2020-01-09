FactoryBot.define do
  factory :level_one_taxon_hash, class: Hash do
    sequence :title, 1 do |n|
      "level_one_taxon_title_#{n}"
    end

    content_id { SecureRandom.uuid }

    sequence :base_path, 1 do |n|
      "/path/level_one_taxon_#{n}"
    end

    sequence :description, 1 do |n|
      "this is level one taxon #{n}"
    end

    transient do
      number_of_children { 0 }
    end

    transient do
      child_taxons { [] }
    end

    after(:build) do |taxon, evaluator|
      taxon[:links] =
        if evaluator.child_taxons.any?
          { child_taxons: evaluator.child_taxons }
        elsif evaluator.number_of_children == 0
          {}
        else
          { child_taxons: FactoryBot.build_list(:taxon_hash, evaluator.number_of_children) }
        end
      taxon.deep_stringify_keys!
    end

    initialize_with { attributes }
  end
end
