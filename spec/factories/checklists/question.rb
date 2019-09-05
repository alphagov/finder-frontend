FactoryBot.define do
  factory :checklists_question, class: Checklists::Question do
    text { 'A title' }
    key { SecureRandom.uuid }
    type { 'single' }
    options { [] }

    initialize_with { Checklists::Question.new(attributes) }
  end
end
