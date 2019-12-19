FactoryBot.define do
  factory :brexit_checker_group, class: BrexitChecker::Group do
    key { "living-uk" }
    heading { "You live in the UK" }

    initialize_with { BrexitChecker::Group.new(attributes) }
  end
end
