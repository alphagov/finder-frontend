FactoryBot.define do
  factory :document, class: Document do
    transient do
      finder { nil }
      index { 1 }
    end
    initialize_with { new(FactoryBot.build(:document_hash, attributes), finder, index) }
  end
end
