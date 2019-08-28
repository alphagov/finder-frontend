require 'spec_helper'

describe ChecklistHelper, type: :helper do
  describe "#filter_actions" do
    let(:action1) { Checklists::Action.new('criteria' => []) }
    let(:action2) { Checklists::Action.new('criteria' => %w[A]) }
    let(:action3) { Checklists::Action.new('criteria' => %w[B C]) }
    let(:actions) { [action1, action2, action3] }

    subject { filter_actions(actions, criteria_keys) }

    context "when there is no criteria" do
      let(:criteria_keys) { [] }

      it "returns no actions" do
        expect(subject).to eq([])
      end
    end

    context "when there is a criteria" do
      let(:criteria_keys) { %w[A] }

      it "returns some actions" do
        expect(subject).to eq([action2])
      end
    end

    context "when there is multiple criteria" do
      let(:criteria_keys) { %w[A B] }

      it "returns some actions" do
        expect(subject).to eq([action2, action3])
      end
    end
  end

  describe "#format_action_audiences" do
    let(:citizen_action) { Checklists::Action.new('audience' => 'citizen') }
    let(:business_action) { Checklists::Action.new('audience' => 'business') }

    subject { format_action_audiences(actions) }

    context "when there are actions for each section" do
      let(:actions) { [citizen_action, business_action] }
      it "return formatted sections" do
        expect(subject).to eq([
          {
            heading: I18n.t("checklists_results.audiences.citizen.heading"),
            actions: [citizen_action]
          },
          {
            heading: I18n.t("checklists_results.audiences.business.heading"),
            actions: [business_action]
          }
        ])
      end
    end

    context "when there are not actions" do
      let(:actions) { [] }
      it "returns no sections" do
        expect(subject).to eq([])
      end
    end
  end
end
