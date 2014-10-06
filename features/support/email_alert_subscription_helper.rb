module EmailAlertSubscriptionHelper

  def stub_alert_collection_api_request
    stub_request(:get, rummager_all_alerts_url).to_return(
      body: all_alerts_json,
    )

    stub_request(:get, medical_safety_alert_schema_url).to_return(
      body: medical_safety_alert_schema_json,
    )
  end

  def all_alerts_json
    %|{
      "results": [],
      "total": 0,
      "start": 0,
      "facets": {},
      "suggested_queries": []
    }|
  end

  def alert_search_params(params = {})
    default_alert_search_params.merge(params).to_a.map { |tuple|
      tuple.join("=")
    }.join("&")
  end

  def default_alert_search_params
    {
      "count" => "1000",
      "fields" => alert_search_fields.join(","),
      "filter_document_type" => "medical_safety_alert",
    }
  end

  def alert_search_fields
    %w(
      title
      link
      description
      alert_type
      medical_specialism
    )
  end

  def rummager_all_alerts_url
    params = {
      "order" => "-last_update",
    }

    "#{Plek.current.find('search')}/unified_search.json?#{alert_search_params(params)}"
  end

  def stub_medical_safety_alert_finder_artefact_api_request
    artefact_data = artefact_for_slug('drug-device-alerts').merge(drug_device_alert_artefact)
    content_api_has_an_artefact('drug-device-alerts', artefact_data)
  end

  def drug_device_alert_artefact
    {
      :id => "http://contentapi.dev.gov.uk/drug-device-alerts.json",
      :web_url => "http://finder-frontend.dev.gov.uk/drug-device-alerts",
      :title => "Drug and Device alerts",
      :format => "finder",
      :updated_at => "2014-06-26T13:44:57+01:00",
      :tags => [
        {
          :id => "http://contentapi.dev.gov.uk/tags/organisation/medicines-and-healthcare-products-regulatory-agency.json",
          :slug => "medicines-and-healthcare-products-regulatory-agency",
          :web_url => "http://www.dev.gov.uk/government/organisations/medicines-and-healthcare-products-regulatory-agency",
          :title => "Medicines and healthcare products regulatory agency",
          :details => {
            :description => nil,
            :short_description => nil,
            :type => "organisation"
          },
          :content_with_tag => {
            :id => "http://contentapi.dev.gov.uk/with_tag.json?organisation=medicines-and-healthcare-products-regulatory-agency",
            :web_url => nil
          },
          :parent => nil
        }
      ]
    }
  end

  def stub_email_alert_subscription_artefact_api_request
    artefact_data = artefact_for_slug('drug-device-alerts/email-signup').merge(medical_safety_alert_email_alert_artefact)
    content_api_has_an_artefact('drug-device-alerts/email-signup', artefact_data)
  end

  def medical_safety_alert_email_alert_artefact
    {
      :id => "http://contentapi.dev.gov.uk/drug-device-alerts%2Femail-signup.json",
      :web_url => "http://finder-frontend.dev.gov.uk/drug-device-alerts/email-signup",
      :title => "Medical Safety Alert",
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
