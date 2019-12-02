require "spec_helper"
require "gds_api/test_helpers/email_alert_api"

RSpec.describe "Change notifications" do
  include GdsApi::TestHelpers::EmailAlertApi

  describe "brexit_checker:change_notification" do
    let(:endpoint) do
      GdsApi::TestHelpers::EmailAlertApi::EMAIL_ALERT_API_ENDPOINT
    end

    let(:addition) do
      FactoryBot.build(:brexit_checker_notification,
                       type: "addition",
                       action_id: "addition")
    end

    let(:content_change) do
      FactoryBot.build(:brexit_checker_notification,
                       type: "content_change",
                       note: "Something has changed",
                       action_id: "content_change")
    end

    before do
      stub_email_alert_api_accepts_message
      Rake::Task["brexit_checker:change_notification"].reenable
      allow(BrexitChecker::Notification).to receive(:load_all) { [addition, content_change] }

      allow(BrexitChecker::Action).to receive(:load_all) do
        [
          FactoryBot.build(
            :brexit_checker_action,
            :business,
            id: "addition",
            criteria: [
              { "all_of" => %w(nationality-eu living-uk) },
            ],
          ),
          FactoryBot.build(
            :brexit_checker_action,
            :business,
            id: "content_change",
            criteria: [
              {
                "all_of" => [
                  { "any_of" => %w(nationality-row nationality-eu) },
                  { "any_of" => %w(living-row living-eu) },
                  "join-family-uk-yes",
                ],
              },
            ],
          ),
        ]
      end
    end

    it "asks Email Alert API to notify subscribers about additions" do
      Rake::Task["brexit_checker:change_notification"].invoke(addition.id)

      assert_requested(:post, "#{endpoint}/messages") do |request|
        payload = JSON.parse(request.body)
        expect(payload["sender_message_id"]).to eq addition.id
        expect(payload["body"]).to match(addition.action.title)
        expect(payload["body"]).to match(addition.action.consequence)

        title = I18n.t!("brexit_checker_mailer.change_notification.title")
        expect(payload["title"]).to eq title

        change_text = I18n.t!("brexit_checker_mailer.change_notification.addition")
        expect(payload["body"]).to match(change_text)

        date = DateTime.parse(addition.date)
        expect(payload["body"]).to match(date.strftime("%-d %B %Y"))

        expect(payload["criteria_rules"]).to eq([
          {
            "all_of" => [
              {
                "type" => "tag",
                "key" => "brexit_checklist_criteria",
                "value" => "nationality-eu",
              },
              {
                "type" => "tag",
                "key" => "brexit_checklist_criteria",
                "value" => "living-uk",
              },
            ],
          },
        ])
      end
    end

    it "asks Email Alert API to notify subscribers about content changes" do
      Rake::Task["brexit_checker:change_notification"].invoke(content_change.id)

      assert_requested(:post, "#{endpoint}/messages") do |request|
        payload = JSON.parse(request.body)
        expect(payload["sender_message_id"]).to eq content_change.id
        expect(payload["body"]).to match(content_change.action.title)

        title = I18n.t!("brexit_checker_mailer.change_notification.title")
        expect(payload["title"]).to eq title

        change_text = I18n.t!("brexit_checker_mailer.change_notification.content_change")
        expect(payload["body"]).to match(change_text)

        date = DateTime.parse(content_change.date)
        expect(payload["body"]).to match(date.strftime("%-d %B %Y"))
        expect(payload["body"]).to match(content_change.note)

        expect(payload["criteria_rules"]).to eq([
          {
            "all_of" => [
              {
                "any_of" => [
                  {
                    "type" => "tag",
                    "key" => "brexit_checklist_criteria",
                    "value" => "nationality-row",
                  },
                  {
                    "type" => "tag",
                    "key" => "brexit_checklist_criteria",
                    "value" => "nationality-eu",
                  },
                ],
              },
              {
                "any_of" => [
                  {
                    "type" => "tag",
                    "key" => "brexit_checklist_criteria",
                    "value" => "living-row",
                  },
                  {
                    "type" => "tag",
                    "key" => "brexit_checklist_criteria",
                    "value" => "living-eu",
                  },
                ],
              },
              {
                "type" => "tag",
                "key" => "brexit_checklist_criteria",
                "value" => "join-family-uk-yes",
              },
            ],
          },
        ])
      end
    end

    describe "when a notification has criteria rules" do
      let(:content_note_criteria_change) do
        FactoryBot.build(:brexit_checker_notification,
                         type: "content_change",
                         note: "Something has changed",
                         action_id: "content_change",
                         criteria: [{ any_of: %w[forestry] }])
      end

      before do
        allow(BrexitChecker::Notification).to receive(:load_all) {
          [content_note_criteria_change]
        }
      end

      it "should notify subscribers based on the notification's criteria rules" do
        Rake::Task["brexit_checker:change_notification"].invoke(content_note_criteria_change.id)
        assert_requested(:post, "#{endpoint}/messages") do |request|
          payload = JSON.parse(request.body)
          expect(payload["criteria_rules"]).to eq([
            {
              "any_of" => [
                {
                  "key" => "brexit_checklist_criteria",
                  "type" => "tag",
                  "value" => "forestry",
                },
              ],
            },
          ])
        end
      end
    end

    it "raises an error if the change notification has been sent already" do
      stub_request(:post, "#{endpoint}/messages")
        .to_return(status: 409)

      expect { Rake::Task["brexit_checker:change_notification"].invoke(addition.id) }
        .to raise_error("Notification already sent")
    end

    it "raises an error if the notification cannot be found" do
      expect { Rake::Task["brexit_checker:change_notification"].invoke("missing") }
        .to raise_error("Notification not found")
    end
  end
end
