namespace :brexit_checker do
  desc "Notify Email Alert API subscribers about a change"
  task :change_notification, [:notification_id] => :environment do |_, args|
    id = args[:notification_id]
    notification = BrexitChecker::Notification.find_by_id(id)
    raise "Notification not found" if notification.nil?

    mail = BrexitCheckerMailer.change_notification(notification)

    criteria = notification.criteria.presence || notification.action.criteria

    GdsApi.email_alert_api.create_message(
      title: mail.subject,
      url: notification.action.title_url,
      body: mail.body.raw_source,
      sender_message_id: notification.id,
      criteria_rules: criteria_rules(criteria),
    )

  rescue GdsApi::HTTPConflict
    raise "Notification already sent"
  end

  def criteria_rules(criteria)
    if criteria.is_a? String
      return {
        type: "tag",
        key: "brexit_checklist_criteria",
        value: criteria,
      }
    end

    if criteria.is_a? Hash
      return Hash[criteria.map { |k, v| [k, criteria_rules(v)] }]
    end

    if criteria.is_a? Array
      return criteria.map { |c| criteria_rules(c) }
    end

    raise "Unexpected criteria class #{criteria}"
  end
end
