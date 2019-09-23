FactoryBot.define do
  factory :brexit_checker_action, class: BrexitChecker::Action do
    title { "A title" }
    title_url { "http://www.gov.uk" }
    id { SecureRandom.uuid }
    consequence { "A consequence" }
    criteria { %w(construction) }
    audience { "citizen" }
    priority { 5 }

    initialize_with { BrexitChecker::Action.new(attributes) }
  end
end
