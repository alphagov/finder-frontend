require 'spec_helper'

describe ChecklistHelper, type: :helper do
  describe "#filter_actions" do
    let(:action1) { Checklists::Action.new('criteria' => "a") }
    let(:action2) { Checklists::Action.new('criteria' => "b || c") }
    let(:actions) { [action1, action2] }

    before do
      allow(Checklists::CriteriaLogic).to receive(:all_options).and_return(%w(a b c))
      allow(Checklists::CriteriaLogic).to receive(:all_options_hash).and_return("a" => false, "b" => false, "c" => false)
    end

    subject { filter_actions(actions, criteria_keys) }

    context "when there is no criteria" do
      let(:criteria_keys) { [] }

      it "returns no actions" do
        expect(subject).to eq([])
      end
    end

    context "when there is a criteria" do
      let(:criteria_keys) { %w[a] }

      it "returns some actions" do
        expect(subject).to eq([action1])
      end
    end

    context "when there is multiple criteria" do
      let(:criteria_keys) { %w[a b] }

      it "returns some actions" do
        expect(subject).to eq([action1, action2])
      end
    end
  end

  describe "#format_action_audiences" do
    let(:action1) { Checklists::Action.new('audience' => 'citizen', 'priority' => 5) }
    let(:action2) { Checklists::Action.new('audience' => 'citizen', 'priority' => 8) }
    let(:action3) { Checklists::Action.new('audience' => 'business', 'priority' => 5) }
    let(:action4) { Checklists::Action.new('audience' => 'business', 'priority' => 5) }

    subject { format_action_audiences(actions) }

    context "when there are actions for each audience" do
      let(:actions) { [action1, action2, action3, action4] }

      it "return actions grouped by audience and sorted by priority" do
        expect(subject).to eq([
          {
            heading: I18n.t("checklists_results.audiences.citizen.heading"),
            actions: [action2, action1]
          },
          {
            heading: I18n.t("checklists_results.audiences.business.heading"),
            actions: [action3, action4]
          }
        ])
      end
    end
  end

  describe "#persistent_criteria_keys" do
    let(:criteria_keys) { %w[A B C D] }
    let(:question_criteria_keys) { %w[C D] }

    subject { persistent_criteria_keys(question_criteria_keys) }

    it 'returns all but the questions criteria' do
      expect(subject).to contain_exactly('A', 'B')
    end
  end

  describe "#format_question_options" do
    it "filters options which should not be shown" do
      option = Checklists::Question::Option.new({})
      allow(option).to receive(:show?).with([]) { false }
      results = format_question_options([option], [])
      expect(results).to be_empty
    end

    it "returns a hash of options for rendering" do
      option = Checklists::Question::Option.new('label' => 'label',
                                                'value' => 'value',
                                                'hint_text' => 'hint_text')

      allow(option).to receive(:show?) { true }
      results = format_question_options([option], [])

      expect(results[0]).to match(label: 'label',
                                  text: 'label',
                                  value: 'value',
                                  hint_text: 'hint_text',
                                  checked: false)
    end

    it "returns a hash of any checked options" do
      option = Checklists::Question::Option.new('value' => 'value')
      allow(option).to receive(:show?) { true }
      results = format_question_options([option], %w(value))
      expect(results[0][:checked]).to be_truthy
    end
  end
end
