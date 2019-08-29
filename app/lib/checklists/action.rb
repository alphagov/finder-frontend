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
                :guidance_prompt,
                :priority

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
    @priority = params['priority']
  end

  def applies_to?(criteria_keys)
    all_criteria = Checklists::Criterion.load_all.map(&:key)
    CriteriaLogic.new(criteria, criteria_keys, all_criteria).applies?
  end

  def self.find_by_id(id)
    load_all.find { |a| a.id == id }
  end

  def self.load_all(exclude_deleted: true)
    CHECKLISTS_ACTIONS.reject { |a| a['soft_deleted'] && exclude_deleted }.map { |a| new(a) }
  end
end

class CriteriaLogic
  def initialize(string, selected_options, all_options)
    @string = string&.underscore
    @selected_options = selected_options.map(&:underscore)
    @all_options = all_options.map(&:underscore)
  end

  def applies?
    return false if string.blank?

    eval(string, context) # rubocop:disable Security/Eval
  end

private

  attr_reader :string, :selected_options, :all_options

  def context
    all_options_hash = all_options.each_with_object({}) do |key, hash|
      hash[key] = false
    end

    options_hash = selected_options.each_with_object(all_options_hash) do |key, hash|
      hash[key] = true
    end

    HashBinding.new(options_hash).context
  end
end

class HashBinding
  def initialize(hash)
    hash.each do |key, value|
      singleton_class.send(:define_method, key) { value }
    end
  end

  def context
    binding
  end
end
