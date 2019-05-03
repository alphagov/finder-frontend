Given(/^I visit the business finder email screen$/) do
  content_store_has_business_readiness_email_signup # stub content API for email signup page
  visit finder_path('find-eu-exit-guidance-business/email-signup')
end

When(/^I click the "(.+)" button$/) do |button_name|
  # Before we click on the Signup button, we need to stub a lot of things that are triggered downstream of this.

  # stub content API for POST message to business finder
  content_store_has_business_readiness_finder

  # stub API request to email-alerts-api, which is called via the POST message above
  # TODO I want to stub the fetching of the signup URL (which is determined by topic ID, facet, etc)
  # But I don't want to stub the EmailAlertSubscriptionsController itself, because that's where we look for default_frequency 🤔
  stub_request(:get, "http://email-alert-api.dev.gov.uk/subscriber-lists?links%5Bfacet_groups%5D%5Bany%5D%5B0%5D=52435175-82ed-4a04-adef-74c0199d0f46").
  to_return(body: '{
    "subscriber_list": {
      "subscription_url": "/email/subscriptions/new?topic_id=find-eu-exit-guidance-for-your-business-appear-in-find-eu-exit-guidance-business-finder&foo=bar"
    }
  }')

  # stub content store item for the redirected page
  content_store_has_item('/email/subscriptions/new', business_readiness_signup_content_item)

  # stub the search API call made by the redirected page... 😅
  stub_request(:get, "http://search.dev.gov.uk/batch_search.json?search%5B%5D%5B0%5D%5Bcount%5D=1500&search%5B%5D%5B0%5D%5Bfields%5D=title,link,description,public_timestamp,popularity,content_purpose_supergroup&search%5B%5D%5B0%5D%5Border%5D=-public_timestamp&search%5B%5D%5B0%5D%5Bstart%5D=0").
  to_return(body: filtered_business_readiness_results_json)

  # there will be render errors, as we haven't stubbed everything perfectly, but all we care about is the redirected URL, so wrap in a rescue
  begin
    click_button button_name
  rescue
    puts "Ignoring errors in the page. The thing we're testing is the value of #{current_url}"
  end
end

Then(/^I should be redirected to "(.+)"$/) do |expected_url|
  expect(current_url).to eq "http://www.example.com#{expected_url}" # TODO, just check the `/` portion onwards (remove reference to example.com)
end
