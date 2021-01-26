require "addressable/uri"

module BrexitCheckerHelper
  def encoded_results_url
    CGI.escape(request.original_url)
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

  def account_signup_jwt(criteria_keys, subscriber_list_slug)
    account_jwt = BrexitChecker::AccountJwt.new(
      criteria_keys: criteria_keys,
      subscriber_list_slug: subscriber_list_slug,
      post_register_uri: Services.oidc.auth_uri(redirect_path: transition_checker_saved_results_path)[:uri],
      post_login_uri: Services.oidc.auth_uri(redirect_path: transition_checker_save_results_confirm_path(c: criteria_keys))[:uri],
    )
    account_jwt.encode
  end

  def path_based_on_account_feature_flag
    if accounts_available?
      transition_checker_save_results_path(c: criteria_keys)
    else
      transition_checker_email_signup_path(c: criteria_keys)
    end
  end

  def results_comparison(old_criteria_keys, new_criteria_keys)
    answers_diff = BrexitChecker::Question.load_all.map do |question|
      flattened_options = flatten_options(question.options)
      old_values = flattened_options.select { |k, _v| old_criteria_keys.include? k }
      new_values = flattened_options.select { |k, _v| new_criteria_keys.include? k }
      unless old_values.keys == new_values.keys
        [{ text: question.text }, { text: old_values.values.join(", ") }, { text: new_values.values.join(", ") }]
      end
    end
    answers_diff.compact
  end

  def flatten_options(options, hash = nil)
    hash ||= {}
    options.each do |option|
      hash[option.value] = option.label if option.value
      flatten_options(option.sub_options, hash)
    end
    hash
  end
end
