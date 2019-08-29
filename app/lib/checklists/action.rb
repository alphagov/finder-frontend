class Checklists::Action
  attr_accessor :id,
                :title,
                :consequence,
                :title_url,
                :lead_time,
                :criteria,
                :audience,
                :guidance_link_text,
                :guidance_url,
                :guidance_prompt

  def initialize(params)
    @id = params['action_id']
    @title = params['title']
    @consequence = params['consequence']
    @title_url = params['title_url']
    @lead_time = params['lead_time']
    @criteria = params['criteria']
    @audience = params['audience']
    @guidance_link_text = params['guidance_link_text']
    @guidance_url = params['guidance_url']
    @guidance_prompt = params['guidance_prompt']
  end

  def applies_to?(criteria_keys)
    criteria.any? do |key|
      criteria_keys.include?(key)
    end
  end

  def self.find_by_title(title)
    load_all.find { |a| a.title.match(title) }
  end

  def self.load_all(exclude_deleted: true)
    CHECKLISTS_ACTIONS.reject { |a| a['soft_deleted'] && exclude_deleted }.map { |a| new(a) }
  end
end
