require "addressable/uri"

class BrexitChecker::Action
  include ActiveModel::Validations

  CONFIG_PATH = Rails.root.join("app/lib/brexit_checker/actions.yaml")

  validates_presence_of :id, :title, :consequence, :grouping_criteria
  validates_inclusion_of :audience, in: %w[business citizen]
  validates_presence_of :guidance_link_text, if: :guidance_url
  validates_numericality_of :priority, only_integer: true
  validate :has_criteria

  attr_reader :id,
              :title,
              :consequence,
              :exception,
              :title_url,
              :title_path,
              :lead_time,
              :criteria,
              :audience,
              :guidance_link_text,
              :guidance_url,
              :guidance_path,
              :guidance_prompt,
              :priority,
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
    BrexitChecker::Criterion.load_by(all_criteria_keys)
  end

  def all_criteria_keys
    BrexitChecker::Criteria::Extractor.extract(criteria)
  end

  delegate :hash, to: :id

  def eql?(other)
    id == other.id
  end

  def multiple_grouping_criteria?
    grouping_criteria.count > 1
  end

  def urgent?
    priority >= 9
  end

private

  def has_criteria
    return unless all_criteria_keys.none?

    errors.add(:criteria, "can't be blank")
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
