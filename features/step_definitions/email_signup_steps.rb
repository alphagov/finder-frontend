When(/^I sign up to notifications for a filtered set of Medical Safety Alerts$/) do
  # Stubbing the finder shouldnt be required once we remove this dependency
  stub_medical_safety_alert_finder_artefact_api_request
  stub_alert_collection_api_request

  stub_delivery_api
  stub_email_alert_subscription_artefact_api_request
  visit new_email_alert_subscriptions_path('drug-device-alerts')

  click_button "Create subscription"
end

Then(/^I should be subscribed to those filtered notifications$/) do
  expect(fake_delivery_api).to have_received(:signup_url)
    .with("#{Plek.current.find('finder-frontend')}/drug-device-alerts.atom")
end
