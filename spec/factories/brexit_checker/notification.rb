FactoryBot.define do
  factory :brexit_checker_notification, class: BrexitChecker::Notification do
    id { SecureRandom.uuid }
    action_id { SecureRandom.uuid }
    type { "addition" }
    date { "2019-08-07" }

    initialize_with { BrexitChecker::Notification.new(attributes) }
  end
end
