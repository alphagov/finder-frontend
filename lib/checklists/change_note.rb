class Checklists::ChangeNote
  CONFIG_PATH = Rails.root.join('lib/checklists/change_notes.yaml')

  attr_reader :id, :action_id, :type, :note, :time

  def initialize(params)
    @id = params['uuid']
    @action_id = params['action_id']
    @type = params['type']
    @note = params['note']
    @time = params['time']
  end

  def action
    Checklists::Action.find_by_id(action_id)
  end

  def self.load_all
    @load_all ||= YAML.load_file(CONFIG_PATH)['change_notes'].to_a
      .map { |c| new(c) }
  end

  def self.find_by_id(id)
    load_all.find { |c| c.id == id }
  end
end
