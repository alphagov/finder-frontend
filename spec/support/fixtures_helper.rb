module FixturesHelper
  def fixtures_path
    File.expand_path(Rails.root + "features/fixtures")
  end

  def aaib_reports_content_item
    @content_item ||= JSON.parse(File.read(fixtures_path + "/aaib_reports_example.json"))
  end

  def aaib_reports_qa_config
    YAML.load_file(fixtures_path + "/aaib_reports_qa.yaml")
  end

  def cma_cases_content_item
    JSON.parse(File.read(fixtures_path + "/cma_cases_content_item.json"))
  end

  def cma_cases_signup_content_item
    JSON.parse(File.read(fixtures_path + "/cma_cases_signup_content_item.json"))
  end

  def cma_cases_with_multi_facets_signup_content_item
    JSON.parse(File.read(fixtures_path + "/cma_cases_with_multi_facets_signup_content_item.json"))
  end
end
