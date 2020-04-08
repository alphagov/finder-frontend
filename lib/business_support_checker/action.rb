require "addressable/uri"

class BusinessSupportChecker::Action
  include ActiveModel::Validations

  CONFIG_PATH = Rails.root.join("lib/business_support_checker/actions.yaml")

  validates_presence_of :id, :title, :criteria
  validates_numericality_of :priority, only_integer: true
  validate :has_criteria

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
    BusinessSupportChecker::Criteria::Evaluator.evaluate(criteria, selected_criteria)
  end

  def self.find_by_id(id)
    load_all.find { |a| a.id == id }
  end

  def self.load_all
    @load_all = nil if Rails.env.development?
    @load_all ||= YAML.load_file(CONFIG_PATH)["actions"].map { |a| new(a) }
  end

  def all_criteria
    BusinessSupportChecker::Criterion.load_by(all_criteria_keys)
  end

  def all_criteria_keys
    BusinessSupportChecker::Criteria::Extractor.extract(criteria)
  end

  def hash
    id.hash
  end

  def eql?(other)
    id == other.id
  end

private

  def has_criteria
    return unless all_criteria_keys.none?

    errors.add "Action must have at least one criterion"
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
