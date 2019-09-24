require "spec_helper"


describe FacetExtractor do
  let(:facets) { described_class.new(finder).extract }

  context "with facets in details" do
    let(:finder) { ContentItem.new(finder_hash) }
    let(:finder_hash) do
      {
        details: {
          facets: [
            { some: "facet details" },
            { some: "more facet details" },
          ],
        },
      }.deep_stringify_keys
    end

    it "returns the facets directly from the finder" do
      expect(facets).to eq([
        { "some" => "facet details" },
        { "some" => "more facet details" },
      ])
    end
  end

  context "with  facets under facet_group in links" do
    let(:sector_facet_values) do
      [
        {
          content_id: "ed94c9f5-22ea-4fa5-aee1-7ccea25d412e",
          details: {
            label: "Aerospace",
            value: "aerospace",
          },
        },
        {
          content_id: "b7c4eccf-a1e8-4a95-9988-4db6c5cd889e",
          details: {
            label: "Computer services",
            value: "computer-services",
          },
        },
      ]
    end
    let(:eu_citizen_facet_values) do
      [
        {
          content_id: "d09d441f-7cef-40f3-9767-8cd5a84fff72",
          details: {
            label: "EU Citizens",
            value: "yes",
          },
        },
        {
          content_id: "66fc5add-c79c-41ed-9286-ae2d150e5deb",
          details: {
            label: "No EU Citizens",
            value: "no",
          },
        },
      ]
    end
    let(:finder) { ContentItem.new(finder_hash) }
    let(:finder_hash) do
      {
        links: {
          facet_group: [{
            links: {
              facets: [
                {
                  details: {
                    name: "Sector / Business Area",
                    key: "sector_business_area",
                    filter_key: "any_facet_values",
                    display_as_result_metadata: true,
                    filterable: true,
                    combine_mode: "or",
                    preposition: "your business is in",
                    type: "content_id",
                  },
                  links: {
                    facet_values: sector_facet_values,
                  },
                },
                {
                  details: {
                    name: "Who you employ",
                    short_name: "Employing EU citizens",
                    key: "employ_eu_citizens",
                    filter_key: "any_facet_values",
                    filterable: true,
                    preposition: "you",
                    type: "content_id",
                  },
                  links: {
                    facet_values: eu_citizen_facet_values,
                  },
                },
              ],
            },
          }],
        },
      }.deep_stringify_keys
    end

    it "returns facets in the correct format" do
      expected_facets = [
        {
          name: "Sector / Business Area",
          key: "sector_business_area",
          display_as_result_metadata: true,
          filterable: true,
          filter_key: "any_facet_values",
          combine_mode: "or",
          preposition: "your business is in",
          type: "content_id",
          allowed_values: [
            {
              label: "Aerospace",
              value: "aerospace",
              content_id: "ed94c9f5-22ea-4fa5-aee1-7ccea25d412e",
            },
            {
              label: "Computer services",
              value: "computer-services",
              content_id: "b7c4eccf-a1e8-4a95-9988-4db6c5cd889e",
            },
          ],
        },
        {
          name: "Who you employ",
          short_name: "Employing EU citizens",
          key: "employ_eu_citizens",
          filterable: true,
          filter_key: "any_facet_values",
          combine_mode: "and", #defaults to `and`,
          preposition: "you",
          type: "content_id",
          allowed_values: [
            {
              label: "EU Citizens",
              value: "yes",
              content_id: "d09d441f-7cef-40f3-9767-8cd5a84fff72",
            },
            {
              label: "No EU Citizens",
              value: "no",
              content_id: "66fc5add-c79c-41ed-9286-ae2d150e5deb",
            },
          ],
        },
      ].map(&:deep_stringify_keys)

      expect(facets).to eq(expected_facets)
    end
  end
end
