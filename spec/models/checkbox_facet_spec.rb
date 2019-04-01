require "spec_helper"

describe CheckboxFacet do
  let(:facet_data) {
    {
      'type' => "checkbox",
      'key' => "show_extra_information",
      'name' => "Show extra information",
      'short_name' => "Show more",
      'value' => "yes",
      'preposition' => "of value",
    }
  }

  subject { CheckboxFacet.new(facet_data) }

  describe "#sentence_fragment" do
    before do
      subject.value = value
    end

    context "single value" do
      let(:value) { "yes" }

      specify {
        expect(subject.sentence_fragment['preposition']).to eql("of value")
        expect(subject.sentence_fragment['values'].first['label']).to eql("Show more")
        expect(subject.sentence_fragment['values'].first['parameter_key']).to eql("show_extra_information")
      }
    end

    context "when multiple values are provided" do
      context "when a value is provided" do
        let(:value) { true }

        specify {
          expect(subject.sentence_fragment['preposition']).to eql("of value")
          expect(subject.sentence_fragment['values'].count).to eql 1
          expect(subject.sentence_fragment['values'].first['parameter_key']).to eql("show_extra_information")
        }
      end

      context "when no value is provided" do
        let(:value) { nil }
        specify { expect(subject.sentence_fragment).to be_nil }
      end
    end
  end

  describe "#checked?" do
    before do
      subject.value = value
    end

    context "checkbox is selected" do
      let(:value) { "yes" }
      specify {
        expect(subject.is_checked?).to eql(true)
      }
    end

    context "checkbox is not selected" do
      let(:value) { nil }
      specify {
        expect(subject.is_checked?).to eql(false)
      }
    end
  end


  describe "#has_value?" do
    context "true if checkbox is selected" do
      subject { CheckboxFacet.new(facet_data, "yes") }
      specify {
        expect(subject.has_value?).to eql(true)
      }
    end

    context "checkbox is not selected" do
      subject { CheckboxFacet.new(facet_data, nil) }
      specify {
        expect(subject.has_value?).to eql(false)
      }
    end
  end
end
