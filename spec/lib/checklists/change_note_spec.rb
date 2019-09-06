require 'spec_helper'

describe Checklists::ChangeNote do
  describe ".load_all" do
    subject { described_class.load_all }

    it "returns a list of change notes with required fields" do
      subject.each do |change_note|
        expect(change_note.id.length).to eq SecureRandom.uuid.length
        expect(change_note.time).to match(/\d{4}-\d{2}-\d{2}/)
        expect(%w(content_change addition)).to include(change_note.type)

        if change_note.type == "content_change"
          expect(change_note.note).to be_present
        end
      end
    end

    it "returns change notes that reference actions" do
      action_ids = Checklists::Action.load_all.map(&:id)

      subject.each do |change_note|
        expect(action_ids).to include(change_note.action_id)
      end
    end

    it "returns change notes with unique ids" do
      ids = subject.map(&:id)
      expect(ids.uniq.count).to eq(ids.count)
    end
  end
end
