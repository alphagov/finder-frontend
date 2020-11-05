FactoryBot.define do
  factory :brexit_checker_group, class: BrexitChecker::Group do
    key { "living-uk" }
    heading { "You live in the UK" }
    audience { "citizen" }
    priority { 6 }
    initialize_with { BrexitChecker::Group.new(attributes) }

    trait :business do
      key { "placeholder-grouping-1" }
      audience { "business" }
    end
  end
end
