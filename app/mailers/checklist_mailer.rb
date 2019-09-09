class ChecklistMailer < ApplicationMailer
  def change_notification(change_note)
    @change_note = change_note
    @action = @change_note.action
    mail(subject: @action.title)
  end
end
