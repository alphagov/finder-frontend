namespace :brexit_checker do
  desc "Notify Email Alert API subscribers about a change"
  task :change_notification, [:notification_id] => :environment do |_, args|
    id = args[:notification_id]
    notification = BrexitChecker::Notification.find_by_id(id)
    raise "Notification not found" if notification.nil?

    payload = BrexitChecker::Notifications::Payload.new(notification).to_h
    GdsApi.email_alert_api.create_message(payload)
  rescue GdsApi::HTTPConflict
    raise "Notification already sent"
  end
end
