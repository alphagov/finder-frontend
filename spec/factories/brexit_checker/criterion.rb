FactoryBot.define do
  factory :brexit_checker_criterion, class: BrexitChecker::Criterion do
    key { "visiting-eu" }
    text { "You plan to travel to the EU" }

    initialize_with { BrexitChecker::Criterion.new(attributes) }
  end
end
