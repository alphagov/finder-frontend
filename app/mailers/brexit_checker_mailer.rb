class BrexitCheckerMailer < ApplicationMailer
  helper BrexitCheckerHelper

  def change_notification(notification)
    @notification = notification
    @action = @notification.action
    mail(subject: subject)
  end

private

  def subject
    I18n.t!("brexit_checker_mailer.change_notification.title")
  end
end
