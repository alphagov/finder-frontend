require "spec_helper"
require 'gds_api/test_helpers/email_alert_api'

RSpec.feature "Checklist email signup", type: :feature do
  include GdsApi::TestHelpers::EmailAlertApi

  scenario "user clicks to signup to email alerts" do
    given_im_on_the_results_page
    then_i_click_to_signup_to_emails
    then_i_choose_a_weekly_digest
    then_i_see_text_to_insert_an_email_address
    and_the_url_contains_the_necessary_information
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

  def then_i_choose_a_weekly_digest
    expect(page).to have_content "How often do you want to get updates?"
    choose "frequency", option: 'weekly', visible: false

    click_on "Next"
  end

  def then_i_see_text_to_insert_an_email_address
    expect(page).to have_content("Insert email address here")
  end

  def and_the_url_contains_the_necessary_information
    url = 'http://www.example.com/find-brexit-guidance/email-signup/address?' \
          'frequency=weekly&' \
          'topic_id=some-non-sensical-slug-wfhihfiansfkjnad&' \
          'url=http%3A%2F%2Fwww.example.com%2Ffind-brexit-guidance%2Fresults%3Fc%255B%255D%3Ddoes-not-own-business%26c%255B%255D%3Deu-national'

    expect(current_url).to eq(url)
  end
end
