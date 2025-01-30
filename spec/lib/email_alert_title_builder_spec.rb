require "spec_helper"

describe EmailAlertTitleBuilder do
  include TaxonomySpecHelper
  include RegistrySpecHelper
  include FixturesHelper

  subject do
    described_class.call(
      filter:,
      subscription_list_title_prefix:,
      facets:,
    )
  end

  let(:content_id_one) { "magical-education" }
  let(:content_id_two) { "herbology" }
  let(:top_level_taxon_one_title) { "Magical Education" }
  let(:top_level_taxon_two_title) { "Herbology" }

  before do
    Rails.cache.clear
    topic_taxonomy_has_taxons([
      FactoryBot.build(:level_one_taxon_hash, content_id: content_id_one, title: top_level_taxon_one_title),
      FactoryBot.build(:level_one_taxon_hash, content_id: content_id_two, title: top_level_taxon_two_title),
    ])

    stub_people_registry_request
    stub_organisations_registry_request
  end

  context "when there are no facets" do
    let(:filter) { nil }
    let(:subscription_list_title_prefix) { "Prefix" }
    let(:facets) { [] }

    it { is_expected.to eq(subscription_list_title_prefix) }
  end

  context "when there is one facet with a string subscription_list_title_prefix" do
    let(:subscription_list_title_prefix) { "Prefix" }

    let(:facets) do
      [
        {
          "facet_id" => "facet_id",
          "facet_name" => "facet name",
          "facet_choices" => [
            {
              "key" => "key_one",
              "radio_button_name" => "radio button name one",
              "topic_name" => "topic name one",
              "prechecked" => false,
            },
            {
              "key" => "key_two",
              "radio_button_name" => "radio button name two",
              "topic_name" => "topic name two",
              "prechecked" => false,
            },
          ],
        },
      ]
    end

    context "when no choice is selected" do
      let(:filter) { {} }

      it { is_expected.to eq("Prefix") }
    end

    context "when one choice is selected" do
      let(:filter) { { "facet_id" => %w[key_one] } }

      it { is_expected.to eq("Prefix with topic name one") }
    end

    context "when two choices are selected" do
      let(:filter) { { "facet_id" => %w[key_one key_two] } }

      it { is_expected.to eq("Prefix with topic name one and topic name two") }
    end
  end

  context "when there are multiple facets" do
    let(:subscription_list_title_prefix) { "Prefix: " }
    let(:facets) do
      [
        {
          "facet_id" => "facet_id_one",
          "facet_name" => "facet name one",
          "facet_choices" => [
            {
              "key" => "key_one",
              "radio_button_name" => "radio button name one",
              "topic_name" => "topic name one",
              "prechecked" => false,
            },
            {
              "key" => "key_two",
              "radio_button_name" => "radio button name two",
              "topic_name" => "topic name two",
              "prechecked" => false,
            },
          ],
        },
        {
          "facet_id" => "facet_id_two",
          "facet_name" => "facet name two",
          "facet_choices" => [
            {
              "key" => "key_three",
              "radio_button_name" => "radio button name three",
              "topic_name" => "topic name three",
              "prechecked" => false,
            },
            {
              "key" => "key_four",
              "radio_button_name" => "radio button name four",
              "topic_name" => "topic name four",
              "prechecked" => false,
            },
          ],
        },
      ]
    end

    context "when no choice is selected" do
      let(:filter) { {} }

      it { is_expected.to eq("Prefix:") }
    end

    context "when one facet is selected" do
      context "when one choice is selected" do
        let(:filter) { { "facet_id_one" => %w[key_one] } }

        it { is_expected.to eq("Prefix: with facet name one of topic name one") }
      end

      context "when two choices are selected" do
        let(:filter) { { "facet_id_one" => %w[key_one key_two] } }

        it { is_expected.to eq("Prefix: with facet name one of topic name one and topic name two") }
      end
    end

    context "when one dynamic facet is selected" do
      let(:subscription_list_title_prefix) { "Prefix " }
      let(:facets) do
        [{ "facet_id" => "people", "facet_name" => "people" }]
      end
      let(:filter) do
        { "people" => %w[harry-potter ron-weasley] }
      end

      it { is_expected.to eq("Prefix with people of Harry Potter and Ron Weasley") }
    end

    context "when two facets are selected" do
      let(:filter) do
        {
          "facet_id_one" => %w[key_one key_two],
          "facet_id_two" => %w[key_three key_four],
        }
      end

      it { is_expected.to eq("Prefix: with facet name one of topic name one and topic name two and facet name two of topic name three and topic name four") }
    end
  end

  context "when there are multiple facets with the same filter_key" do
    let(:subscription_list_title_prefix) { "News and communicatons " }
    let(:facets) do
      [
        { "facet_id" => "politicians", "facet_name" => "people", "filter_key" => "people" },
        { "facet_id" => "people", "facet_name" => "people" },
        { "facet_id" => "persons_of_interest", "facet_name" => "people", "filter_key" => "people" },
        { "facet_id" => "organisations", "facet_name" => "organisations" },
        { "facet_id" => "departments_of_interest", "facet_name" => "departments of interest", "filter_key" => "organisations" },
        { "facet_id" => "world_locations", "facet_name" => "world locations" },
        { "facet_id" => "level_one_taxon", "filter_key" => "part_of_taxonomy_tree", "facet_name" => "topics" },
        { "facet_id" => "level_two_taxon", "filter_key" => "part_of_taxonomy_tree", "facet_name" => "topics" },
        { "facet_id" => "document_type", "facet_name" => "document types" },
      ]
    end
    let(:filter) do
      {
        "people" => %w[harry-potter ron-weasley albus-dumbledore cornelius-fudge rufus-scrimgeour],
        "organisations" => %w[ministry-of-magic gringots hogwarts],
        "part_of_taxonomy_tree" => %w[magical-education d6c2de5d-ef90-45d1-82d4-5f2438369eea herbology],
        "document_type" => %w[OWL NEWT],
      }
    end

    it {
      expect(subject).to eq("News and communicatons with people of Harry Potter, Ron Weasley, Albus Dumbledore, Cornelius Fudge, and Rufus Scrimgeour, organisations of Ministry of Magic, Gringots, and 1 other organisation, topics of Magical Education, Brexit, and Herbology, and 2 document types")
    }
  end

  context "when a facet_connector is provided" do
    let(:content_item) { research_and_stats_finder_signup_content_item }
    let(:filter) { { "content_store_document_type" => %w[statistics_published research] } }
    let(:subscription_list_title_prefix) { content_item.dig("details", "subscription_list_title_prefix") }
    let(:facets) { content_item["details"].fetch("email_filter_facets", []) }

    it {
      expect(subject).to eq("All documents filtered by Statistics (published) and Research")
    }
  end
end
