class Checklists::Action
  attr_accessor :title, :description, :path, :due_date

  def initialize(params)
    @title = params['title']
    @description = params['description']
    @path = params['path']
    @due_date = params['due_date']
  end

  def self.load_all
    CHECKLISTS_ACTIONS.map { |a| new(a) }
  end
end
