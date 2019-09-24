FactoryBot.define do
  factory :brexit_checker_question, class: BrexitChecker::Question do
    text { "A title" }
    key { SecureRandom.uuid }
    type { "single" }
    options { [] }

    initialize_with { BrexitChecker::Question.new(attributes) }
  end
end
