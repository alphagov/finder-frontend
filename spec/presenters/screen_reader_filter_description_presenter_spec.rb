require "spec_helper"

RSpec.describe ScreenReaderFilterDescriptionPresenter do
  subject(:presenter) { ScreenReaderFilterDescriptionPresenter.new([a_facet, a_facet_without_facet_tags], sort_option) }

  let(:sort_option) { { "key" => "updated-newest", "name" => "Updated (newest)" } }
  let(:a_facet) do
    double(
      OptionSelectFacet,
      key: "key_1",
      selected_values: [
          {
              "value" => "ca98-and-civil-cartels",
              "label" => "CA98 and civil cartels",
          },
          {
              "value" => "mergers",
              "label" => "Mergers",
          },
      ],
      allowed_values: [
          {
              "value" => "ca98-and-civil-cartels",
              "label" => "CA98 and civil cartels",
          },
          {
              "value" => "mergers",
              "label" => "Mergers",
          },
      ],
      sentence_fragment: {
          "key" => "key_1",
          "type" => "text",
          "preposition" => "Of Type",
          "values" => [
              {
                  "label" => "CA98 and civil cartels",
              },
              {
                  "label" => "Mergers",
              },
          ],
          "word_connectors" => { words_connector: "or" },
      },
      has_filters?: true,
      labels: %W(ca98-and-civil-cartels mergers),
      value: %W(ca98-and-civil-cartels mergers),
      hide_facet_tag?: false,
    )
  end

  let(:a_facet_without_facet_tags) do
    double(
      RadioFacet,
      key: "key_3",
      preposition: "that are",
      allowed_values: [
          {
              "value" => "statistics_published",
              "label" => "Statistics (published)",
              "default" => true,
          },
          {
              "value" => "statistics_upcoming",
              "label" => "Statistics (upcoming)",
          },
          {
              "value" => "research",
              "label" => "Research",
          },
      ],
      has_filters?: true,
      hide_facet_tag?: true,
      value: "something",
      sort: [
          {
              "value" => "most-viewed",
              "name" => "Most viewed",
          },
      ],
    )
  end
  describe "#hidden_text" do
    it "creates appropriate hidden text for the facet without a facet tag for a default value" do
      expect(presenter.present).to eql("that are Statistics (published), sorted by Updated (newest)")
    end

    it "creates appropriate hidden text for the facet without a facet tag for a non default value" do
      allow(a_facet_without_facet_tags).to receive(:value).and_return("research")
      expect(presenter.present).to eql("that are Research, sorted by Updated (newest)")
    end

    it "will not include a facet without a facet tag if there is no selected value or default value" do
      allow(a_facet_without_facet_tags).to receive(:value).and_return("")
      allow(a_facet_without_facet_tags).to receive(:allowed_values).and_return(
        [
          {
              "value" => "statistics_published",
              "label" => "Statistics (published)",
          },
          {
              "value" => "statistics_upcoming",
              "label" => "Statistics (upcoming)",
          },
          {
              "value" => "research",
              "label" => "Research",
          },
        ],
      )

      expect(presenter.present).to eql("sorted by Updated (newest)")
    end
  end
end
