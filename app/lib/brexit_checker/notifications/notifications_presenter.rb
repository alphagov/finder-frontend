class BrexitChecker::Notifications::NotificationsPresenter
  attr_reader :additions, :changes, :all_changes

  def initialize(addition_ids, change_ids)
    @additions = addition_ids.map { |id| format_notification(id, "addition") }
    @changes = change_ids.map { |id| format_notification(id, "content_change") }
    @all_changes = additions.push(*changes)
  end

  def notifications
    @notifications ||= all_changes.any? ? { "notifications" => all_changes } : {}
  end

private

  def format_notification(action_id, change_type)
    action_id = action_id.strip

    extra = if change_type == "content_change"
              { "note" => "INSERT CHANGE NOTE HERE" }
            else
              {}
            end

    {
      "uuid" => SecureRandom.uuid,
      "type" => change_type,
      "action_id" => action_id,
      "date" => Time.zone.now.strftime("%Y-%m-%d"),
    }.merge(extra)
  end
end
