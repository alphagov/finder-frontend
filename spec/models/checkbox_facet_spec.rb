require "spec_helper"

describe CheckboxFacet do
  let(:facet_data) {
    {
      "type" => "checkbox",
      "filter_value" => "selectedvalue",
      "key" => "show_extra_information",
      "name" => "Show extra information",
      "short_name" => "Show more",
      "value" => "yes",
      "preposition" => "of value",
    }
  }

  describe "#sentence_fragment" do
    context "single value" do
      subject { CheckboxFacet.new(facet_data, "yes") }

      specify {
        expect(subject.sentence_fragment["preposition"]).to eql("of value")
        expect(subject.sentence_fragment["values"].first["label"]).to eql("Show more")
        expect(subject.sentence_fragment["values"].first["parameter_key"]).to eql("show_extra_information")
      }
    end

    context "when multiple values are provided" do
      context "when a value is provided" do
        subject { CheckboxFacet.new(facet_data, true) }

        specify {
          expect(subject.sentence_fragment["preposition"]).to eql("of value")
          expect(subject.sentence_fragment["values"].count).to eql 1
          expect(subject.sentence_fragment["values"].first["parameter_key"]).to eql("show_extra_information")
        }
      end

      context "when no value is provided" do
        subject { CheckboxFacet.new(facet_data, nil) }
        specify { expect(subject.sentence_fragment).to be_nil }
      end
    end
  end

  describe "#checked?" do
    context "checkbox is selected" do
      subject { CheckboxFacet.new(facet_data, "yes") }
      specify {
        expect(subject.is_checked?).to eql(true)
      }
    end

    context "checkbox is not selected" do
      subject { CheckboxFacet.new(facet_data, nil) }
      specify {
        expect(subject.is_checked?).to eql(false)
      }
    end
  end

  describe "#query_params" do
    context "checkbox is selected" do
      subject { CheckboxFacet.new(facet_data, "yes") }
      specify {
        expect(subject.query_params).to eql("show_extra_information" => "selectedvalue")
      }
    end

    context "checkbox is not selected" do
      subject { CheckboxFacet.new(facet_data, nil) }
      specify {
        expect(subject.query_params).to eql({})
      }
    end
  end
end
