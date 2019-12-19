FactoryBot.define do
  factory :brexit_checker_criterion, class: BrexitChecker::Criterion do
    key { "forestry" }
    text { "You work in plants and forestry" }

    initialize_with { BrexitChecker::Criterion.new(attributes) }
  end
end
