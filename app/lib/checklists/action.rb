class Checklists::Action
  CONFIG_PATH = Rails.root.join('lib', 'checklists', 'actions.yaml')

  attr_accessor :id,
                :title,
                :consequence,
                :exception,
                :title_url,
                :lead_time,
                :criteria,
                :audience,
                :guidance_link_text,
                :guidance_url,
                :guidance_prompt,
                :priority

  def initialize(params)
    @id = params['action_id']
    @title = params['title']
    @consequence = params['consequence']
    @exception = params['exception']
    @title_url = params['title_url']
    @lead_time = params['lead_time']
    @criteria = params['criteria']
    @audience = params['audience']
    @guidance_link_text = params['guidance_link_text']
    @guidance_url = params['guidance_url']
    @guidance_prompt = params['guidance_prompt']
    @priority = params['priority']
  end

  def valid?
    Checklists::CriteriaLogic.new(criteria, []).valid?
  end

  def show?(selected_criteria)
    Checklists::CriteriaLogic.new(criteria, selected_criteria).applies?
  end

  def self.find_by_id(id)
    load_all.find { |a| a.id == id }
  end

  def self.load_all
    @load_all = nil if Rails.env.development?
    @load_all ||= YAML.load_file(CONFIG_PATH)['actions'].map { |a| new(a) }
  end
end
