FactoryBot.define do
  factory :checklists_action, class: Checklists::Action do
    title { 'A title' }
    title_url { 'http://www.gov.uk' }
    id { SecureRandom.uuid }
    consequence { 'A consequence' }
    criteria { %w(construction) }
    audience { 'citizen' }
    priority { 5 }

    initialize_with { Checklists::Action.new(attributes) }
  end
end
