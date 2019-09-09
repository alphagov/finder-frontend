require "spec_helper"
require "gds_api/test_helpers/email_alert_api"

RSpec.describe "Change notifications" do
  include GdsApi::TestHelpers::EmailAlertApi

  describe "checklists:change_notification" do
    let(:endpoint) do
      GdsApi::TestHelpers::EmailAlertApi::EMAIL_ALERT_API_ENDPOINT
    end

    let(:addition) do
      FactoryBot.build(:checklists_change_note,
                       type: "addition",
                       action_id: "addition")
    end

    let(:content_change) do
      FactoryBot.build(:checklists_change_note,
                       type: "content_change",
                       note: "Something has changed",
                       action_id: "content_change")
    end

    before do
      stub_email_alert_api_accepts_message
      Rake::Task["checklists:change_notification"].reenable
      allow(Checklists::ChangeNote).to receive(:load_all) { [addition, content_change] }

      allow(Checklists::Action).to receive(:load_all) do
        [
          FactoryBot.build(
            :checklists_action,
            id: "addition",
            criteria: [
              { "all_of" => %w(nationality-eu living-uk) }
            ]
          ),
          FactoryBot.build(
            :checklists_action,
            id: "content_change",
            criteria: [
              {
                "all_of" => [
                  { "any_of" => %w(nationality-row nationality-eu) },
                  { "any_of" => %w(living-row living-eu) },
                  "join-family-uk-yes"
                ],
              }
            ]
          )
        ]
      end
    end

    it "asks Email Alert API to notify subscribers about additions" do
      Rake::Task["checklists:change_notification"].invoke(addition.id)

      assert_requested(:post, "#{endpoint}/messages") do |request|
        payload = JSON.parse(request.body)
        expect(payload["title"]).to eq addition.action.title
        expect(payload["url"]).to eq addition.action.title_url
        expect(payload["sender_message_id"]).to eq addition.id
        expect(payload["body"]).to match(addition.action.consequence)

        date = DateTime.parse(addition.time)
        expect(payload["body"]).to match(date.strftime("%-d %B, %Y"))

        note = I18n.t!("checklists_mailer.change_notification.added")
        expect(payload["body"]).to match(note)

        expect(payload["criteria_rules"]).to eq([
          {
            "all_of" => [
              {
                "type" => "tag",
                "key" => "brexit_checklist_criteria",
                "value" => "nationality-eu"
              },
              {
                "type" => "tag",
                "key" => "brexit_checklist_criteria",
                "value" => "living-uk"
              }
            ]
          }
        ])
      end
    end

    it "asks Email Alert API to notify subscribers about content changes" do
      Rake::Task["checklists:change_notification"].invoke(content_change.id)

      assert_requested(:post, "#{endpoint}/messages") do |request|
        payload = JSON.parse(request.body)
        expect(payload["title"]).to eq content_change.action.title
        expect(payload["url"]).to eq content_change.action.title_url

        date = DateTime.parse(content_change.time)
        expect(payload["body"]).to match(date.strftime("%-d %B, %Y"))
        expect(payload["body"]).to match(content_change.note)

        expect(payload["criteria_rules"]).to eq([
          {
            "all_of" => [
              {
                "any_of" => [
                  {
                    "type" => "tag",
                    "key" => "brexit_checklist_criteria",
                    "value" => "nationality-row"
                  },
                  {
                    "type" => "tag",
                    "key" => "brexit_checklist_criteria",
                    "value" => "nationality-eu"
                  }
                ]
              },
              {
                "any_of" => [
                  {
                    "type" => "tag",
                    "key" => "brexit_checklist_criteria",
                    "value" => "living-row"
                  },
                  {
                    "type" => "tag",
                    "key" => "brexit_checklist_criteria",
                    "value" => "living-eu"
                  }
                ]
              },
              {
                "type" => "tag",
                "key" => "brexit_checklist_criteria",
                "value" => "join-family-uk-yes"
              }
            ]
          }
        ])
      end
    end

    it "raises an error if the change notification has been sent already" do
      stub_request(:post, "#{endpoint}/messages")
        .to_return(status: 409)

      expect { Rake::Task["checklists:change_notification"].invoke(addition.id) }
        .to raise_error("Notification already sent")
    end

    it "raises an error if the change note cannot be found" do
      expect { Rake::Task["checklists:change_notification"].invoke("missing") }
        .to raise_error("Change note not found")
    end
  end
end
