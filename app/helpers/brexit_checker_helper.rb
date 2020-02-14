require "addressable/uri"

module BrexitCheckerHelper
  def encoded_results_url
    CGI.escape(request.original_url)
  end

  def criteria_aside_label(heading = nil)
    return "you-and-your-family-actions-group-#{heading.downcase.gsub(' ', '-')}-criteria" if !heading.nil?

    "business-actions-criteria"
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

  def brexit_results_email_link_label(actions)
    if actions.any?
      t("brexit_checker.results.email_sign_up_link")
    else
      t("brexit_checker.results.email_sign_up_link_no_actions")
    end
  end

  def brexit_results_title(actions, criteria_keys)
    if actions.any?
      t("brexit_checker.results.title")
    elsif criteria_keys.any?
      t("brexit_checker.results.title_no_actions")
    else
      t("brexit_checker.results.title_no_answers")
    end
  end

  def brexit_results_description(actions, criteria_keys)
    if actions.any?
      t("brexit_checker.results.description")
    elsif criteria_keys.present?
      t("brexit_checker.results.description_no_actions")
    else
      t("brexit_checker.results.description_no_answers").html_safe
    end
  end
end
