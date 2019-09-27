FactoryBot.define do
  factory :brexit_checker_change_note, class: BrexitChecker::ChangeNote do
    id { SecureRandom.uuid }
    action_id { SecureRandom.uuid }
    type { "addition" }
    date { "2019-08-07" }

    trait :with_criteria_rules do
      criteria_rules { [{ any_of: %w[forestry] }] }
    end

    initialize_with { BrexitChecker::ChangeNote.new(attributes) }
  end
end
