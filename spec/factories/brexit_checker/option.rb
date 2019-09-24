FactoryBot.define do
  factory :brexit_checker_option, class: BrexitChecker::Question::Option do
    label { "A title" }
    sub_options { [] }

    initialize_with { BrexitChecker::Question::Option.new(attributes) }
  end
end
