module FixturesHelper
  def fixtures_path
    File.expand_path(Rails.root.join("features/fixtures"))
  end

  def aaib_reports_content_item
    @aaib_reports_content_item ||= JSON.parse(File.read("#{fixtures_path}/aaib_reports_example.json"))
  end

  def cma_cases_content_item
    JSON.parse(File.read("#{fixtures_path}/cma_cases_content_item.json"))
  end

  def cma_cases_signup_content_item
    JSON.parse(File.read("#{fixtures_path}/cma_cases_signup_content_item.json"))
  end

  def news_and_communications_content_item
    JSON.parse(File.read("#{fixtures_path}/news_and_communications.json"))
  end

  def news_and_communications_signup_content_item
    JSON.parse(File.read("#{fixtures_path}/news_and_communications_signup_content_item.json"))
  end

  def cma_cases_with_multi_facets_signup_content_item
    JSON.parse(File.read("#{fixtures_path}/cma_cases_with_multi_facets_signup_content_item.json"))
  end

  def policy_papers_finder_content_item
    JSON.parse(File.read("#{fixtures_path}/policy_and_engagement.json"))
  end

  def policy_papers_finder_signup_content_item
    JSON.parse(File.read("#{fixtures_path}/policy_papers_and_consultations_email_signup.json"))
  end

  def research_and_stats_finder_content_item
    JSON.parse(File.read("#{fixtures_path}/statistics.json"))
  end

  def research_and_stats_finder_signup_content_item
    JSON.parse(File.read("#{fixtures_path}/research_and_statistics_email_signup.json"))
  end

  def bad_input_finder_signup_content_item
    JSON.parse(File.read("#{fixtures_path}/bad_input_email_signup.json"))
  end
end
