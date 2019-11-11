require "addressable/uri"

module BrexitCheckerHelper
  def extract_criteria(object)
    case object
    when Array
      object.flat_map { |element| extract_criteria(element) }
    when Hash
      extract_criteria(object.fetch("any_of", [])) + extract_criteria(object.fetch("all_of", []))
    when String
      object
    end
  end

  def select_criteria(criteria, actions)
    criteria.select do |criterion|
      actions.any? do |action|
        extract_criteria(action.criteria).include? criterion.key
      end
    end
  end

  def format_criteria(criteria, actions = [])
    selected_criteria = if !actions.empty?
                          select_criteria(criteria, actions)
                        else
                          criteria
                        end
    selected_criteria.map { |criterion| { readable_text: criterion.text } }
  end

  def format_action_audiences(actions, criteria)
    business, citizen = actions.partition { |action| action.audience == "business" }
    business_groups = format_business_group(business, criteria)
    citizens_groups = format_citizen_groups(citizen, criteria)
    business_results = if !business_groups.empty?
                         {
                           heading: I18n.t("brexit_checker.results.audiences.business.heading"),
                           groups: business_groups,
                         }
                       end
    citizen_results = if !citizens_groups.empty?
                        {
                          heading: I18n.t("brexit_checker.results.audiences.citizen.heading"),
                          groups: citizens_groups,
                        }
                      end
    [business_results, citizen_results].compact
  end

  def format_business_group(actions, criteria)
    business_actions = order_actions_by_priority(actions)
    if business_actions.any?
      [{
        heading: nil,
        priority: 10,
        actions: business_actions,
        criteria: format_criteria(criteria, business_actions),
      }]
    else
      []
    end
  end

  def format_citizen_groups(actions, criteria)
    all_groups = actions.map(&:groups).flatten.uniq
    citizen_groups = all_groups.map do |group|
      grouped_actions = format_citizen_actions(actions, group["key"])
      if grouped_actions.any?
        {
          heading: group["text"],
          priority: group["priority"],
          actions: grouped_actions,
          criteria: format_criteria(criteria, grouped_actions),
        }
      end
    end
    order_citizen_groups(citizen_groups)
  end

  def format_citizen_actions(actions, group_key)
    grouped_actions = actions.select { |action| action.result_groups.include?(group_key) }
    order_actions_by_priority(grouped_actions)
  end

  def order_citizen_groups(citizen_groups)
    citizen_groups.sort_by { |group| -group[:priority] }
  end

  def order_actions_by_priority(actions)
    actions.sort_by.with_index do |action, index|
      [-action.priority, index]
    end
  end

  def filter_items(items, criteria_keys)
    items.select { |i| i.show?(criteria_keys) }
  end

  def persistent_criteria_keys(question_criteria_keys)
    criteria_keys - question_criteria_keys
  end

  def format_question_options(options, criteria_keys)
    options.map { |o| format_question_option(o, criteria_keys) }
  end

  def format_question_option(option, criteria_keys)
    checked = criteria_keys.include?(option.value)

    { label: option.label,
      text: option.label,
      value: option.value,
      checked: checked,
      hint_text: option.hint_text }
  end

  def next_question_index(all_questions:, criteria_keys: [], previous_question_index: 0)
    available_questions = all_questions[previous_question_index..] || []

    relative_next_question_index = available_questions.find_index { |question| question.show?(criteria_keys) }
    relative_next_question_index ? previous_question_index + relative_next_question_index : nil
  end

  def previous_question_index(all_questions:, criteria_keys: [], current_question_index: 0)
    previous_questions = all_questions[0...current_question_index]
    previous_questions.rindex { |question| question.show?(criteria_keys) }
  end

  def notification_email_link(non_tracked_url, notification)
    url = Addressable::URI.parse(non_tracked_url)
    return non_tracked_url unless url.host == "www.gov.uk"

    url.query_values = (url.query_values || {}).merge(
      utm_source: notification.id,
      utm_medium: "email",
      utm_campaign: "govuk-brexit-checker",
    )

    url.to_s
  end
end
