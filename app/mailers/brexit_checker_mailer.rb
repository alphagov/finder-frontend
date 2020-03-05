class BrexitCheckerMailer < ApplicationMailer
  add_template_helper(BrexitCheckerHelper)

  def change_notification(notification)
    @notification = notification
    @action = @notification.action
    mail(subject: subject(@notification))
  end

private

  def subject(notification)
    I18n.t!("brexit_checker_mailer.change_notification.#{notification.type}.title")
  end
end
