class Checklists::Criterion
  CONFIG_PATH = Rails.root.join('lib', 'checklists', 'criteria.yaml')

  attr_reader :key, :text

  def initialize(attrs)
    attrs.each { |key, value| instance_variable_set("@#{key}", value) }
  end

  def self.load_all
    @load_all = nil if Rails.env.development?
    @load_all ||= YAML.load_file(CONFIG_PATH)['criteria'].map { |c| new(c) }
  end

  def self.load_by(criteria_keys)
    load_all.select { |c| criteria_keys.include?(c.key) }
  end
end
