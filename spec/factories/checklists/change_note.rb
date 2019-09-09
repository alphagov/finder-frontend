FactoryBot.define do
  factory :checklists_change_note, class: Checklists::ChangeNote do
    id { SecureRandom.uuid }
    action_id { SecureRandom.uuid }
    type { "addition" }
    time { "2019-08-07 10:10" }

    initialize_with { Checklists::ChangeNote.new(attributes) }
  end
end
