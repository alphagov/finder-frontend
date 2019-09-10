FactoryBot.define do
  factory :brexit_checker_change_note, class: BrexitChecker::ChangeNote do
    id { SecureRandom.uuid }
    action_id { SecureRandom.uuid }
    type { "addition" }
    date { "2019-08-07" }

    initialize_with { BrexitChecker::ChangeNote.new(attributes) }
  end
end
