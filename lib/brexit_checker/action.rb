class BrexitChecker::Action
  include ActiveModel::Validations

  CONFIG_PATH = Rails.root.join("lib", "brexit_checker", "actions.yaml")
  GROUPS_PATH = Rails.root.join("lib", "brexit_checker", "groups.yaml")

  validates_presence_of :id, :title, :consequence, :criteria
  validates_inclusion_of :audience, in: %w(business citizen)
  validates_presence_of :guidance_link_text, if: :guidance_url
  validates_numericality_of :priority, only_integer: true
  validate :citizen_actions_must_have_groupings

  attr_reader :id, :title, :consequence, :exception, :title_url,
              :lead_time, :criteria, :audience, :guidance_link_text,
              :guidance_url, :guidance_prompt, :priority, :result_groups,
              :groups

  def initialize(attrs)
    attrs.each { |key, value| instance_variable_set("@#{key}", value) }
    validate!
    load_groups
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

private

  def load_groups
    all_groups ||= YAML.load_file(GROUPS_PATH)["groups"]
    @groups ||= all_groups.select { |group| result_groups.include?(group["key"]) } if result_groups
  end

  def citizen_actions_must_have_groupings
    if audience == "citizen" && result_groups.nil?
      errors.add(:result_groups, "can't be empty for citizen actions")
    end
  end
end
