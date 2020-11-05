class BrexitChecker::Group
  include ActiveModel::Validations
  validates_with BrexitChecker::Validators::GroupValidator

  GROUPS_PATH = Rails.root.join("app/lib/brexit_checker/groups.yaml")

  attr_reader :key, :heading, :priority, :audience

  def initialize(attrs)
    attrs.each { |key, value| instance_variable_set("@#{key}", value) }
    validate!
  end

  def self.load_all
    @load_all = nil if Rails.env.development?
    @load_all ||= YAML.load_file(GROUPS_PATH)["groups"].map { |a| new(a) }
  end

  def self.find_by(key)
    load_all.detect { |group| group.key == key }
  end

  delegate :hash, to: :key

  def eql?(other)
    key == other.key
  end

  def actions
    BrexitChecker::Action.load_all.select { |action| action.grouping_criteria&.include?(key) }
  end
end
