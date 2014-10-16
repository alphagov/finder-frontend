When(/^I sign up to notifications for a filtered set of Medical Safety Alerts$/) do
  stub_request(:get, medical_safety_alert_schema_url).to_return(
    body: medical_safety_alert_schema_json,
  )

  stub_email_alert_api
  stub_email_alert_subscription_artefact_api_request
  visit new_email_alert_subscriptions_path('drug-device-alerts')

  check 'drugs'
  check 'devices'

  click_button "Create subscription"
end

Then(/^I should be subscribed to those filtered notifications$/) do
  expect(fake_email_alert_api).to have_received(:find_or_create_subscriber_list)
    .with(
      "title" => "Alerts and recalls for drugs and medical devices",
      "tags" => {
        "document_type" => ["medical_safety_alert"],
        "alert_type" => ["drugs", "devices"],
      }
    )
end
