FactoryBot.define do
  factory :document, class: Document do
    transient do
      index { 1 }
    end
    initialize_with { new(FactoryBot.build(:document_hash, attributes), index) }
  end
end
