require "addressable/uri"

class BrexitChecker::Action
  include ActiveModel::Validations

  CONFIG_PATH = Rails.root.join("lib", "brexit_checker", "actions.yaml")
  GROUPS_PATH = Rails.root.join("lib", "brexit_checker", "groups.yaml")

  validates_presence_of :id, :title, :consequence, :criteria
  validates_inclusion_of :audience, in: %w(business citizen)
  validates_presence_of :guidance_link_text, if: :guidance_url
  validates_numericality_of :priority, only_integer: true
  validate :citizen_actions_must_have_groupings

  attr_reader :id, :title, :consequence, :exception, :title_url, :title_path,
              :lead_time, :criteria, :audience, :guidance_link_text,
              :guidance_url, :guidance_path, :guidance_prompt, :priority,
              :grouping_criteria

  def initialize(attrs)
    attrs.each { |key, value| instance_variable_set("@#{key}", value) }
    @title_path = path_from_url(title_url) if title_url
    @guidance_path = path_from_url(guidance_url) if guidance_url
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

  def all_criteria
    extract_criteria(criteria)
  end

private

  def extract_criteria(object)
    case object
    when Array
      object.flat_map { |element| extract_criteria(element) }
    when Hash
      extract_criteria(object.fetch("any_of", [])) + extract_criteria(object.fetch("all_of", []))
    when String
      object
    end
  end

  def citizen_actions_must_have_groupings
    if audience == "citizen" && grouping_criteria.nil?
      errors.add(:grouping_criteria, "can't be empty for citizen actions")
    end
  end

  def path_from_url(full_url)
    url = Addressable::URI.parse(full_url)
    if url.host == "www.gov.uk"
      url.path
    else
      full_url
    end
  end
end
