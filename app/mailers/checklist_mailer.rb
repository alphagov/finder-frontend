class ChecklistMailer < ApplicationMailer
  def change_notification(change_note)
    @change_note = change_note
    @action = @change_note.action
    mail(subject: subject)
  end

private

  def subject
    prefix = @change_note.type == "addition" ? "Added" : "Changed"
    "#{prefix}: #{@action.title}"
  end
end
