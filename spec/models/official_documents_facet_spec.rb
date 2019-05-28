require "spec_helper"

describe OfficialDocumentsFacet do
  let(:facet_data) {
    {
      'type' => "official_documents",
      'key' => "content_store_document_type",
      'filterable' => true
    }
  }
  describe "#query_params" do
    context "value selected" do
      subject { OfficialDocumentsFacet.new(facet_data, "command_papers") }
      specify {
        expect(subject.query_params).to eq("content_store_document_type" => "command_papers")
      }
    end
  end

  describe "#options" do
    context 'valid value' do
      subject { OfficialDocumentsFacet.new(facet_data, "command_papers") }
      it 'sets the options, selecting the correct value' do
        expect(subject.options).to eq([
                                        {
                                          value: 'command_or_act_papers',
                                          text: 'Command or act papers',
                                          checked: false
                                        },
                                        {
                                          value: 'command_papers',
                                          text: 'Command papers only',
                                          checked: true,
                                        },
                                        {
                                          value: 'act_papers',
                                          text: 'Act papers only',
                                          checked: false,
                                        }
                                      ])
      end
    end
    context 'invalid value' do
      subject { OfficialDocumentsFacet.new(facet_data, "something") }
      it 'sets the options, selecting the default value' do
        expect(subject.options).to include(
          value: 'command_or_act_papers',
          text: 'Command or act papers',
          checked: true,
                                   )
      end
    end
  end
end
