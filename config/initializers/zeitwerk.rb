Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect(
    "email_alert_signup_api" => "EmailAlertSignupAPI",
  )
end
