class Checklists::Criterion
  CONFIG_PATH = Rails.root.join('lib', 'checklists', 'criteria.yaml')

  attr_reader :key, :text, :depends_on

  def initialize(params)
    @key = params['key']
    @text = params['text']
    @depends_on = params.fetch('depends_on', [])
  end

  def self.load_all
    @load_all = nil if Rails.env.development?

    @load_all ||= YAML.load_file(CONFIG_PATH)['criteria']
      .map { |c| new(c) }
  end

  def self.load_by(criteria_keys)
    load_all.select do |c|
      criteria_keys.include?(c.key)
    end
  end
end
