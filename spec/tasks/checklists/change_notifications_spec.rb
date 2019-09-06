require "spec_helper"
require "gds_api/test_helpers/email_alert_api"

RSpec.describe "Change notifications" do
  include GdsApi::TestHelpers::EmailAlertApi

  describe "checklists:change_notification" do
    let(:endpoint) do
      GdsApi::TestHelpers::EmailAlertApi::EMAIL_ALERT_API_ENDPOINT
    end

    before do
      stub_email_alert_api_accepts_message
      Rake::Task["checklists:change_notification"].reenable

      allow(Checklists::ChangeNote).to receive(:load_all) do
        [
          Checklists::ChangeNote.new("uuid" => "addition",
                                     "action_id" => "addition",
                                     "type" => "addition",
                                     "time" => "2019-08-07 10:20"),
          Checklists::ChangeNote.new("uuid" => "content_change",
                                     "action_id" => "content_change",
                                     "note" => "Something has changed",
                                     "type" => "content_change",
                                     "time" => "2019-08-07 10:20")
        ]
      end

      allow(Checklists::Action).to receive(:load_all) do
        [
          Checklists::Action.new(
            "action_id" => "addition",
            "title" => "A new title",
            "title_url" => "http://www.google.com",
            "consequence" => "A new consequence",
            "criteria" => [
              { "all_of" => %w(nationality-eu living-uk) }
            ]
          ),
          Checklists::Action.new(
            "action_id" => "content_change",
            "title" => "A changed title",
            "title_url" => "http://www.google.com",
            "criteria" => [
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
      change_note = Checklists::ChangeNote.find_by_id("addition")
      action = Checklists::Action.find_by_id(change_note.action_id)
      Rake::Task["checklists:change_notification"].invoke("addition")

      assert_requested(:post, "#{endpoint}/messages") do |request|
        payload = JSON.parse(request.body)
        expect(payload["title"]).to eq "Added: #{action.title}"
        expect(payload["url"]).to eq action.title_url
        expect(payload["sender_message_id"]).to eq action.id
        expect(payload["body"]).to match(action.consequence)

        date = DateTime.parse(change_note.time)
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
      change_note = Checklists::ChangeNote.find_by_id("content_change")
      action = Checklists::Action.find_by_id(change_note.action_id)
      Rake::Task["checklists:change_notification"].invoke("content_change")

      assert_requested(:post, "#{endpoint}/messages") do |request|
        payload = JSON.parse(request.body)
        expect(payload["title"]).to eq "Changed: #{action.title}"
        expect(payload["url"]).to eq action.title_url
        expect(payload["sender_message_id"]).to eq action.id

        date = DateTime.parse(change_note.time)
        expect(payload["body"]).to match(date.strftime("%-d %B, %Y"))
        expect(payload["body"]).to match(change_note.note)

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

      expect { Rake::Task["checklists:change_notification"].invoke("addition") }
        .to raise_error("Notification already sent")
    end

    it "raises an error if the change note cannot be found" do
      expect { Rake::Task["checklists:change_notification"].invoke("missing") }
        .to raise_error("Change note not found")
    end
  end
end
