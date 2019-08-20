class Checklists::Action
  attr_accessor :title, :description, :path, :due_date

  def initialize(params)
    @title = params['title']
    @description = params['description']
    @path = params['path']
    @due_date = params['due_date']
  end

  def self.all
    actions = YAML.load_file("lib/checklists/actions.yaml")
    actions['actions'].map { |a| new(a) }
  end
end
