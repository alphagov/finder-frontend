class Checklists::ChangeNote
  attr_reader :id, :title, :text, :action_id, :question_key

  def initialize(params)
    @id             = params['id']
    @title          = params['title']
    @text           = params['text']
    @action_id      = params['action_id']
    @question_key   = params['question_key']
  end

  def self.load_all
    change_notes = YAML.load_file(Rails.root.join('lib/checklists/changenotes.yaml'))['change_notes']
    change_notes.map do |change_note|
      Checklists::ChangeNote.new(change_note)
    end
  end
end
