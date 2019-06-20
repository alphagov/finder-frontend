# typed: false
require "spec_helper"

describe RadioFacetForMultipleFilters do
  let(:facet_data) {
    {
      'type' => "radio_facet",
      'key' => "type",
      'value' => "selected_value",
      "allowed_values" => [{ "value" => "selected_value" }],
      'filterable' => true
    }
  }

  let(:filter_hashes) {
    [
      {
        'key' => 'key_1',
        'label' => 'label_1',
        'filter' => {
          'field' => "value_1",
        }
      },
      {
        'key' => 'key_2',
        'label' => 'label_2',
        'filter' => {
          'field' => "value_2"
        }
      },
      {
        'key' => 'default_key',
        'label' => 'default_label',
        'filter' => {
          'field' => "default_feld"
        },
        'default' => true
      }
    ]
  }

  describe "#options" do
    context 'valid value' do
      subject { described_class.new(facet_data, "key_1", filter_hashes) }
      it 'sets the options, selecting the correct value' do
        expect(subject.options).to eq([
                                        {
                                          value: 'key_1',
                                          text: 'label_1',
                                          checked: true,
                                        },
                                        {
                                          value: 'key_2',
                                          text: 'label_2',
                                          checked: false,
                                        },
                                        {
                                          value: 'default_key',
                                          text: 'default_label',
                                          checked: false
                                        }
                                      ])
      end
    end

    context 'invalid value' do
      subject { described_class.new(facet_data, "something", filter_hashes) }
      it 'sets the options, selecting the default value' do
        expect(subject.options).to include(
          value: 'default_key',
          text: 'default_label',
          checked: true,
                                   )
      end
    end
  end

  describe "#query_params" do
    context "value selected" do
      subject { described_class.new(facet_data, "key_1", filter_hashes) }
      specify {
        expect(subject.query_params).to eq("type" => "key_1")
      }
    end
  end
end
