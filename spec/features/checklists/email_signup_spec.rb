require "spec_helper"
require 'gds_api/test_helpers/email_alert_api'

RSpec.feature "Checklist email signup", type: :feature do
  include GdsApi::TestHelpers::ContentStore
  include GdsApi::TestHelpers::EmailAlertApi

  scenario "user clicks to signup to email alerts" do
    given_im_on_the_results_page
    then_i_click_to_signup_to_emails
    and_i_am_taken_to_email_alert_frontend
  end

  def given_im_on_the_results_page
    visit "/find-brexit-guidance/results?do_you_own_a_business%5B%5D=does-not-own-business&eu_national_in_uk%5B%5D=eu-national"
  end

  def then_i_click_to_signup_to_emails
    stub_email_alert_api_has_subscriber_list(
      "title" => "General title",
      "slug" => "brexit-checklist-does-not-own-business-eu-national",
      "tags" => { "brexit_checklist_criteria" => { "any" => %w[does-not-own-business eu-national] } },
      "url" => "/results?c[]=eu-national"
    )

    click_on "Sign up for emails"
  end

  def and_i_am_taken_to_email_alert_frontend
    expect(page).to have_current_path("/email/subscriptions/new?topic_id=brexit-checklist-does-not-own-business-eu-national")
  end
end
