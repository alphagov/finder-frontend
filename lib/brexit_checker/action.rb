class BrexitChecker::Action
  include ActiveModel::Validations

  CONFIG_PATH = Rails.root.join("lib", "brexit_checker", "actions.yaml")

  validates_presence_of :id, :title, :consequence, :criteria
  validates_inclusion_of :audience, in: %w(business citizen)
  validates_presence_of :guidance_link_text, if: :guidance_url
  validates_numericality_of :priority, only_integer: true

  attr_reader :id, :title, :consequence, :exception, :title_url,
              :lead_time, :criteria, :audience, :guidance_link_text,
              :guidance_url, :guidance_prompt, :priority

  def initialize(attrs)
    attrs.each { |key, value| instance_variable_set("@#{key}", value) }
    validate!
  end

  def show?(selected_criteria)
    BrexitChecker::Criteria::Evaluator.evaluate(criteria, selected_criteria)
  end

  def self.find_by_id(id)
    load_all.find { |a| a.id == id }
  end

  def self.load_all
    @load_all = nil if Rails.env.development?
    @load_all ||= YAML.load_file(CONFIG_PATH)["actions"].map { |a| new(a) }
  end
end
