class BrexitCheckerMailer < ApplicationMailer
  add_template_helper(BrexitCheckerHelper)

  def change_notification(change_note)
    @change_note = change_note
    @action = @change_note.action
    mail(subject: subject)
  end

private

  def subject
    I18n.t!("brexit_checker_mailer.change_notification.title")
  end
end
