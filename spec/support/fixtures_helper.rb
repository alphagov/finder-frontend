module FixturesHelper
  def fixtures_path
    File.expand_path(Rails.root + "features/fixtures")
  end

  def cma_cases_content_item
    JSON.parse(File.read(fixtures_path + "/cma_cases_content_item.json"))
  end

  def cma_cases_signup_content_item
    JSON.parse(File.read(fixtures_path + "/cma_cases_signup_content_item.json"))
  end
end
