class ContentItem
  def initialize(base_path)
    @base_path = base_path
    @content_item = fetch_content_item
  end

  def as_hash
    @content_item
  end

  def is_search?
    document_type == 'search'
  end

  def is_finder?
    document_type == 'finder'
  end

  def is_redirect?
    document_type == 'redirect'
  end

private

  attr_reader :base_path

  def document_type
    @content_item['document_type']
  end

  def fetch_content_item
    if development_env_finder_json
      JSON.parse(File.read(development_env_finder_json))
    else
      Services.cached_content_item(base_path)
    end
  end

  # Add a finder with the base path as a key and the finder name
  # without filetype as the value; example:
  # "/guidance-and-regulation" => "guidance_and_regulation"
  FINDERS_IN_DEVELOPMENT = {
    "/prepare-eu-exit/all" => "citizen_readiness",
    "/prepare-eu-exit/all/email-signup" => "citizen_readiness_signup",
    "/search/policy-papers-and-consultations" => 'policy_and_engagement',
    "/search/policy-papers-and-consultations/email-signup" => 'policy_and_engagement_email_signup',
    "/search/research-and-statistics" => "statistics",
    "/search/research-and-statistics/email-signup" => "statistics_email_signup",
  }.freeze

  def development_env_finder_json
    return development_json if is_development_json?

    ENV["DEVELOPMENT_FINDER_JSON"]
  end

  def development_json
    "features/fixtures/#{FINDERS_IN_DEVELOPMENT[base_path]}.json"
  end

  def is_development_json?
    base_path.present? && FINDERS_IN_DEVELOPMENT[base_path].present?
  end
end
