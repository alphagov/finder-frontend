class BrexitChecker::Groups
  include ActiveModel::Validations

  GROUPS_PATH = Rails.root.join("lib/brexit_checker/groups.yaml")

  validates_inclusion_of :key, in: %w(visiting-eu
                                      visiting-uk
                                      visiting-ie
                                      living-eu
                                      living-ie
                                      living-uk
                                      working-uk
                                      studying-eu
                                      studying-uk)

  attr_reader :key, :text

  def initialize(attrs)
    attrs.each { |key, value| instance_variable_set("@#{key}", value) }
    validate!
  end

  def self.load_all
    @load_all = nil if Rails.env.development?
    @load_all ||= YAML.load_file(GROUPS_PATH)["groups"].map { |a| new(a) }
  end

  def self.get_by_key(group_criterion)
    load_all.find { |group| group.key == group_criterion }
  end
end
