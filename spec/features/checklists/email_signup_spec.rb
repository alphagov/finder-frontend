require "spec_helper"
require 'gds_api/test_helpers/email_alert_api'

RSpec.feature "Checklist email signup", type: :feature do
  include GdsApi::TestHelpers::EmailAlertApi

  scenario "user clicks to signup to email alerts" do
    given_im_on_the_results_page
    then_i_click_to_signup_to_emails
    then_i_can_see_the_frequency_options_to_select
  end

  def given_im_on_the_results_page
    visit "/find-brexit-guidance/results?do_you_own_a_business%5B%5D=does-not-own-business&eu_national_in_uk%5B%5D=eu-national"
  end

  def then_i_click_to_signup_to_emails
    email_alert_api_has_subscriber_list(
      "title" => "General title",
      "slug" => "some-non-sensical-slug-wfhihfiansfkjnad",
      "tags" => { "brexit_checklist_criteria" => { "any" => %w[does-not-own-business eu-national] } },
      "url" => "https://results-url.com"
    )

    click_on "Sign up for emails"
  end

  def then_i_can_see_the_frequency_options_to_select
    expect(page).to have_content "How often do you want to get updates?"
  end
end
