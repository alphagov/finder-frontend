require "spec_helper"

describe BrexitChecker::Results::ResultPresenter do
  let(:action) { BrexitChecker::Action }
  let(:action1) { instance_double action, priority: 1, title: "a", show?: true }
  let(:action2) { instance_double action, priority: 1, title: "b", show?: true }
  let(:action3) { instance_double action, priority: 2, title: "c", show?: true }
  let(:action4) { instance_double action, priority: 2, title: "d", show?: false }
  let(:all_actions) { [action1, action2, action3, action4] }
  let(:criteria_keys) { %w[key-one key-two] }

  subject { described_class.new(criteria_keys) }

  before :each do
    allow(BrexitChecker::Action).to receive(:load_all).and_return(all_actions)
  end

  describe "#actions" do
    it "returns all actions that should be shown" do
      all_actions.each do |action|
        expect(action).to receive(:show?).with(criteria_keys)
      end

      expect(subject.actions).to include(action1, action2, action3)
      expect(subject.actions).not_to include(action4)
    end

    it "sorts the actions by priority and then title" do
      expect(subject.actions).to eq([action3, action1, action2])
    end
  end
end
