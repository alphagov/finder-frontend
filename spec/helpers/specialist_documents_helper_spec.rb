require "spec_helper"

describe SpecialistDocumentsHelper do

  describe "#document_metadata_attribute_html" do
    let(:name)  { double(:label) }
    let(:type)  { double(:type) }
    let(:value) { double(:value) }
    subject     { helper.document_metadata_attribute_html(name, type, value) }

    before do
      allow(helper).to receive(:document_metadata_label_html) { 'my label html' }
      allow(helper).to receive(:document_metadata_value_html) { 'my value html' }
    end

    it "returns a string containing the label" do
      expect(subject).to match("my label html")
    end

    it "returns a string containing the value" do
      expect(subject).to match("my value html")
    end

    it "returns a html safe string" do
      expect(subject).to be_html_safe
    end
  end

  describe "#document_metadata_label_html" do
    let(:name)  { "my label" }
    let(:type)  { "text" }
    subject     { helper.document_metadata_label_html(name, type) }


    it "returns a string containing the label and element" do
      expect(subject).to eql("<dt class=\"metadata-text-label\">my label:</dt>")
    end

    it "returns a html safe string" do
      expect(subject).to be_html_safe
    end
  end

  describe "#document_metadata_value_html" do
    subject { helper.document_metadata_value_html(value, type) }

    context "given a date type" do
      let(:value) { Date.current }
      let(:type)  { "date" }
      let(:formatted_date) { "my formatted date" }

      before { allow(helper).to receive(:formatted_date_html).and_return(formatted_date) }

      it "contains the correct element and class" do
        expect(subject).to eql("<dd class=\"metadata-date-value\">#{formatted_date}</dd>")
      end

      it "returns a html safe string" do
        expect(subject).to be_html_safe
      end
    end

    context "given a text type" do
      let(:value) { "my value" }
      let(:type)  { "text" }

      it "returns a string containing the label and element" do
        expect(subject).to eql("<dd class=\"metadata-text-value\">my value</dd>")
      end

      it "returns a html safe string" do
        expect(subject).to be_html_safe
      end
    end
  end

end
