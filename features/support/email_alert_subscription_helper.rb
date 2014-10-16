module EmailAlertSubscriptionHelper

  def stub_email_alert_subscription_artefact_api_request
    artefact_data = artefact_for_slug('drug-device-alerts/email-signup').merge(medical_safety_alert_email_alert_artefact)
    content_api_has_an_artefact('drug-device-alerts/email-signup', artefact_data)
  end

  def medical_safety_alert_email_alert_artefact
    {
      :id => "http://contentapi.dev.gov.uk/drug-device-alerts%2Femail-signup.json",
      :web_url => "http://finder-frontend.dev.gov.uk/drug-device-alerts/email-signup",
      :title => "Alerts and recalls for drugs and medical devices",
      :format => "finder_email_signup",
      :updated_at => "2014-09-30T10:09:27+01:00",
      # :tags => [],
      # :related => [],
      :details => {
        :need_ids => [],
        :business_proposition => false,
        :description => "You'll get an email each time an alert is updated or a new alert is published.",
      },
      :related_external_links => []
    }
  end

  def medical_safety_alert_schema_url
    "#{Plek.current.find('finder-api')}/finders/drug-device-alerts/schema.json"
  end

  def medical_safety_alert_schema_json
    %|{
        "slug": "drug-device-alerts",
        "name": "Alerts and recalls for drugs and medical devices",
        "document_noun": "alert",
        "facets": [
          {
            "key": "alert_type",
            "name": "Alert type",
            "type": "multi-select",
            "include_blank": false,
            "preposition": "for",
            "allowed_values": [
              {"label": "Drug Alert", "value": "drugs"},
              {"label": "Medical Device Alert", "value": "devices"}
            ]
          },
          {
            "key": "medical_specialism",
            "name": "Medical specialism",
            "type": "multi-select",
            "include_blank": false,
            "preposition": "about",
            "allowed_values": [
              {"label": "Anaesthetics", "value": "anaesthetics" },
              {"label": "Cardiology", "value": "cardiology" },
              {"label": "Care home staff", "value": "care-home-staff" },
              {"label": "Cosmetic surgery", "value": "cosmetic-surgery" },
              {"label": "Critical care", "value": "critical-care" },
              {"label": "Dentistry", "value": "dentistry" },
              {"label": "General practice", "value": "general-practice" },
              {"label": "General surgery", "value": "general-surgery" },
              {"label": "Haematology and oncology", "value": "haematology-oncology" },
              {"label": "Infection prevention", "value": "infection-prevention" },
              {"label": "Obstetrics and gynaecology", "value": "obstetrics-gynaecology" },
              {"label": "Ophthalmology", "value": "ophthalmology" },
              {"label": "Orthopaedics", "value": "orthopaedics" },
              {"label": "Paediatrics", "value": "paediatrics" },
              {"label": "Pathology", "value": "pathology" },
              {"label": "Pharmacy", "value": "pharmacy" },
              {"label": "Physiotherapy and occupational therapy", "value": "physiotherapy-occupational-therapy" },
              {"label": "Radiology", "value": "radiology" },
              {"label": "Renal medicine", "value": "renal-medicine" },
              {"label": "Theatre practitioners", "value": "theatre-practitioners" },
              {"label": "Urology", "value": "urology" },
              {"label": "Vascular and cardiac surgery", "value": "vascular-cardiac-surgery" }
            ]
          }
        ]
      }
    |
  end

end
