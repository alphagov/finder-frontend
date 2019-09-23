require "spec_helper"

describe FacetTagPresenter do
  context "taxonomy tags" do
    it "hides the taxonomy tags when requested from a topic page" do
      presenter = described_class.new(
        fragment,
        false,
        i_am_a_topic_page_finder: true,
      )

      expect(presenter.present.map { |value| value[:data_facet] }).to eq(expected_keys(true))
    end

    it "shows the taxonomy tags when requested from any other page" do
      presenter = described_class.new(
        fragment,
        false,
        i_am_a_topic_page_finder: false,
      )

      expect(presenter.present.map { |value| value[:data_facet] }).to eq(expected_keys(false))
    end

    def fragment
      {
        "preposition" => "about",
        "word_connectors" => { words_connector: "and" },
        "values" => [
          { "label" => "foo", "name" => "bar", "value" => "baz", "parameter_key" => "level_one_taxon" },
          { "label" => "foo", "name" => "bar", "value" => "baz", "parameter_key" => "level_two_taxon" },
          { "label" => "foo", "name" => "bar", "value" => "baz", "parameter_key" => "organisation" },
          { "label" => "foo", "name" => "bar", "value" => "baz", "parameter_key" => "magic" },
        ],
      }
    end

    def expected_keys(i_am_a_topic_page_finder)
      keys = fragment["values"].map do |value|
        if !i_am_a_topic_page_finder || !(%w[level_one_taxon level_two_taxon].include? value["parameter_key"])
          value["parameter_key"]
        end
      end
      keys.compact
    end
  end
end
