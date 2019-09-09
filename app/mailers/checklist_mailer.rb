class ChecklistMailer < ApplicationMailer
  def change_notification(change_note)
    @change_note = change_note
    @action = @change_note.action
    mail(subject: subject)
  end

private

  def subject
    I18n.t!("checklists_mailer.change_notification.title")
  end
end
