require 'spec_helper'

describe Checklists::ChangeNote do
  describe ".load_all" do
    subject { described_class.load_all }

    it "returns a list of change notes with required fields" do
      subject.each do |change_note|
        expect(change_note.id).to be_present
        expect(change_note.title).to be_present
        expect(change_note.text).to be_present
      end
    end

    it "requires an action_id or a question_key, but not both" do
      subject.each do |change_note|
        expect([change_note.action_id, change_note.question_key].compact.count).to eq(1)
      end
    end

    it "returns change notes that reference actions or questions" do
      action_changes = subject.map(&:action_id).compact
      question_changes = subject.map(&:question_key).compact

      action_ids = Checklists::Action.load_all.map(&:id)
      action_changes.each { |action_id|
        expect(action_ids).to include(action_id)
      }

      question_keys = Checklists::Question.load_all.map(&:key)
      question_changes.each { |question_key|
        expect(question_keys).to include(question_key)
      }
    end
  end
end
