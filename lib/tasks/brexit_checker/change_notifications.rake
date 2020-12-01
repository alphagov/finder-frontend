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

  desc <<~DESC
    Create Brexit notifications.
    This task generates yaml that may replace app/lib/brexit_checker/notifications.yaml.
    It's intended to ease the generation of that configuration by emitting snippets
    of configuration when given a list of action IDs. You'll need to copy and paste
    the config into notifications.yaml, and will need to provide change notes for
    and changed actions.
    If you need to add custom criteria, then that will need to be manually added
    to the appropriate actions.

    Usage:
    ```
      rake brexit_checker:configure_notifications NEW_ACTIONS="A001 A099" CHANGED_ACTIONS="S007"
    ```
  DESC
  task configure_notifications: :environment do
    addition_ids = ENV["NEW_ACTIONS"]&.split(" ") || []
    change_ids = ENV["CHANGED_ACTIONS"]&.split(" ") || []

    presenter = BrexitChecker::Notifications::NotificationsPresenter.new(addition_ids, change_ids)

    if presenter.notifications.any?
      puts presenter.notifications.to_yaml
    else
      puts "Nothing to do. Consider setting NEW_ACTIONS and/or CHANGED_ACTIONS environment variables."
    end
  end
end
