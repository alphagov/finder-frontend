class Checklists::Criterion
  attr_reader :key, :text, :depends_on

  def initialize(params)
    @key = params['key']
    @text = params['text']
    @depends_on = params.fetch('depends_on', [])
  end

  def self.load_all
    CHECKLISTS_CRITERIA.map do |criteria|
      Checklists::Criterion.new(criteria)
    end
  end

  def self.load_by(criteria_keys)
    load_all.select do |c|
      criteria_keys.include?(c.key) && (c.depends_on - criteria_keys).blank?
    end
  end
end
