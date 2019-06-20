# typed: true
module FixturesHelper
  def fixtures_path
    File.expand_path(Rails.root + "features/fixtures")
  end

  def aaib_reports_content_item
    @aaib_reports_content_item ||= JSON.parse(File.read(fixtures_path + "/aaib_reports_example.json"))
  end

  def aaib_reports_qa_config
    YAML.load_file(fixtures_path + "/aaib_reports_qa.yaml")
  end

  def uk_nationals_in_eu_config
    YAML.load_file(fixtures_path + "/uk_nationals_in_eu.yaml")
  end

  def cma_cases_content_item
    JSON.parse(File.read(fixtures_path + "/cma_cases_content_item.json"))
  end

  def cma_cases_signup_content_item
    JSON.parse(File.read(fixtures_path + "/cma_cases_signup_content_item.json"))
  end

  def news_and_communications_signup_content_item
    JSON.parse(File.read(fixtures_path + "/news_and_communications_signup_content_item.json"))
  end

  def cma_cases_with_multi_facets_signup_content_item
    JSON.parse(File.read(fixtures_path + "/cma_cases_with_multi_facets_signup_content_item.json"))
  end

  def business_readiness_content_item
    JSON.parse(File.read(fixtures_path + "/business_readiness.json"))
  end

  def business_readiness_signup_content_item
    JSON.parse(File.read(fixtures_path + "/business_readiness_email_signup.json"))
  end
end
