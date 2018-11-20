require "spec_helper"

describe CheckboxFacet do
  describe "#checkbox_label" do
    context "uses checkbox label if specified" do
      let(:subject) {
        Checkbox.new(
          'label' => "Allowed value 1",
          'checkbox_label' => "Show allowed value 1",
          'value' => "allowed-value-1"
        )
      }

      specify {
        expect(subject.checkbox_label).to eql("Show allowed value 1")
      }
    end

    context "label if checkbox_label not specified" do
      let(:subject) {
        Checkbox.new(
          'label' => "Allowed value 1",
          'value' => "allowed-value-1"
        )
      }

      specify {
        expect(subject.checkbox_label).to eql("Allowed value 1")
      }
    end
  end
end
