require "spec_helper"

describe ResearchAndStatisticsFacet do
  let(:facet_data) {
    {
      'type' => "research_and_statistics",
      'key' => "facet_key",
      'filterable' => true
    }
  }
  describe "#query_params" do
    context "value selected" do
      subject { ResearchAndStatisticsFacet.new(facet_data, "research") }
      specify {
        expect(subject.query_params).to eq("facet_key" => "research")
      }
    end
  end

  describe "#options" do
    context 'valid value' do
      subject { ResearchAndStatisticsFacet.new(facet_data, "research") }
      it 'sets the options, selecting the correct value' do
        expect(subject.options).to eq([
                                        {
                                          value: 'upcoming_statistics',
                                          text: 'Statistics (upcoming)',
                                          checked: false,
                                        },
                                        {
                                          value: 'published_statistics',
                                          text: 'Statistics (published)',
                                          checked: false,
                                        },
                                        {
                                          value: 'research',
                                          text: 'Research',
                                          checked: true
                                        }
                                      ])
      end
    end
    context 'invalid value' do
      subject { ResearchAndStatisticsFacet.new(facet_data, "something") }
      it 'sets the options, selecting the default value' do
        expect(subject.options).to include(
          value: 'published_statistics',
          text: 'Statistics (published)',
          checked: true,
                                   )
      end
    end
  end
end
