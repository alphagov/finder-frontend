require "spec_helper"

RSpec.describe BrexitChecker::Notification do
  describe "validations" do
    let(:notification_missing_action_id) { FactoryBot.build(:brexit_checker_notification, action_id: nil) }

    it "action id can't be blank" do
      message = "Validation failed: Action can't be blank"
      expect { notification_missing_action_id.valid? }.to raise_error(ActiveModel::ValidationError, message)
    end
  end

  describe "factories" do
    it "has a valid default factory" do
      notification = FactoryBot.build(:brexit_checker_notification)
      expect(notification.valid?).to be(true)
    end
  end

  describe "#action" do
    let(:action) { FactoryBot.build(:brexit_checker_action) }
    let(:action2) { FactoryBot.build(:brexit_checker_action) }
    let(:notification) { FactoryBot.build(:brexit_checker_notification, action_id: action.id) }

    before :each do
      allow(BrexitChecker::Action).to receive(:load_all).and_return([action, action2])
    end

    it "returns the action relating to that notification" do
      expect(notification.action).to eq action
    end
  end

  describe ".load" do
    let(:uuid) { "5fe018d7-edb1-4d7a-858e-065e46d0917e" }
    let(:type) { "addition" }
    let(:type2) { "content_change" }
    let(:action_id) { "T092" }
    let(:date) { "2019-09-09" }

    let(:single_notification_yaml) do
      <<-YAML
          - uuid: "#{uuid}"
            type: "#{type}"
            action_id: "#{action_id}"
            date: "#{date}"
      YAML
    end

    let(:attrs) { YAML.safe_load(single_notification_yaml).first }

    it "builds a notification from attributes in the yaml" do
      notification = described_class.load(attrs)

      expect(notification.action_id).to eq(action_id)
      expect(notification.type).to eq(type)
      expect(notification.id).to eq(uuid)
      expect(notification.date).to eq(date)
    end
  end

  describe ".find_by_id" do
    let(:notification) { FactoryBot.build(:brexit_checker_notification) }
    let(:notification2) { FactoryBot.build(:brexit_checker_notification) }

    before :each do
      allow(described_class).to receive(:load_all).and_return([notification, notification2])
    end

    it "returns a group by key" do
      expect(described_class.find_by_id(notification.id)).to eq notification
    end
  end
end
