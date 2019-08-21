class Checklists::Criterion
  attr_reader :key, :text, :depends_on

  def initialize(params)
    @key = params['key']
    @text = params['text']
    @depends_on = params.fetch('depends_on', [])
  end

  def self.load_by(criteria_keys)
    file = YAML.load_file("lib/checklists/criteria.yaml")

    criteria = file['criteria'].map do |c|
      Checklists::Criterion.new(c) if criteria_keys.include?(c['key'])
    end

    criteria.select do |c|
      c.present? && (c.depends_on - criteria_keys).blank?
    end
  end
end
