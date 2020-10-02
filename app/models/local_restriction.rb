class LocalRestriction
  FILE_PATH = "app/lib/local_restrictions/local-restrictions.yaml".freeze

  attr_reader :gss_code

  def initialize(gss_code)
    @gss_code = gss_code
  end

  def area_name
    restriction["name"]
  end

  def alert_level
    restriction["alert_level"]
  end

  def guidance
    restriction["guidance"]
  end

  def extra_restrictions
    restriction["extra_restrictions"]
  end

  def start_date
    restriction["start_date"]&.to_date
  end

  def end_date
    restriction["end_date"]&.to_date
  end

private

  def all_restrictions
    @all_restrictions ||= YAML.load_file(FILE_PATH)
  end

  def restriction
    all_restrictions[gss_code] || {}
  end
end
