class BrexitChecker::Notifications::Payload
  attr_reader :notification

  def initialize(notification)
    @notification = notification
  end

  def to_h
    mail = BrexitCheckerMailer.change_notification(notification)
    criteria = notification.criteria.presence || notification.action.criteria

    {
      title: mail.subject,
      url: notification.action.title_url,
      body: mail.body.raw_source,
      sender_message_id: notification.id,
      criteria_rules: criteria_rules(criteria),
    }
  end

private

  def criteria_rules(criteria)
    if criteria.is_a? String
      return {
        type: "tag",
        key: "brexit_checklist_criteria",
        value: criteria,
      }
    end

    if criteria.is_a? Hash
      return criteria.transform_values { |v| criteria_rules(v) }
    end

    if criteria.is_a? Array
      return criteria.map { |c| criteria_rules(c) }
    end

    raise "Unexpected criteria class #{criteria}"
  end
end
