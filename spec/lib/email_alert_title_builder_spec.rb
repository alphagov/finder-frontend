require 'spec_helper'
require 'email_alert_title_builder'
require "helpers/taxonomy_spec_helper"
require "helpers/registry_spec_helper"

describe EmailAlertTitleBuilder do
  include TaxonomySpecHelper
  include RegistrySpecHelper

  subject do
    described_class.call(
      filter: filter,
      subscription_list_title_prefix: subscription_list_title_prefix,
      facets: facets,
    )
  end

  let(:content_id_one) { "magical-education" }
  let(:content_id_two) { "herbology" }
  let(:top_level_taxon_one_title) { "Magical Education" }
  let(:top_level_taxon_two_title) { "Herbology" }

  before :each do
    topic_taxonomy_has_taxons([
      {
        content_id: content_id_one,
        title: top_level_taxon_one_title
      },
      {
        content_id: content_id_two,
        title: top_level_taxon_two_title
      }
    ])

    stub_people_registry_request
    stub_organisations_registry_request
  end

  context 'when there are no facets' do
    let(:filter) { nil }
    let(:subscription_list_title_prefix) { 'Prefix' }
    let(:facets) { [] }

    it { is_expected.to eq(subscription_list_title_prefix) }
  end

  context 'when there is one facet' do
    let(:subscription_list_title_prefix) do
      { 'singular' => 'Prefix:', 'plural' => 'Prefixes:' }
    end
    let(:facets) do
      [
        {
          'facet_id' => 'facet_id',
          'facet_name' => 'facet name',
          'facet_choices' => [
            {
              'key' => 'key_one',
              'radio_button_name' => 'radio button name one',
              'topic_name' => 'topic name one',
              'prechecked' => false
            },
            {
              'key' => 'key_two',
              'radio_button_name' => 'radio button name two',
              'topic_name' => 'topic name two',
              'prechecked' => false
            }
          ],
        }
      ]
    end

    context 'when no choice is selected' do
      let(:filter) { {} }

      it { is_expected.to eq('Prefixes:') }
    end

    context 'when one choice is selected' do
      let(:filter) { { 'facet_id' => %w(key_one) } }

      it { is_expected.to eq('Prefix: topic name one') }
    end

    context 'when two choices are selected' do
      let(:filter) { { 'facet_id' => %w(key_one key_two) } }

      it { is_expected.to eq('Prefixes: topic name one and topic name two') }
    end
  end

  context 'when there are multiple facets' do
    let(:subscription_list_title_prefix) { 'Prefix: ' }
    let(:facets) do
      [
        {
          'facet_id' => 'facet_id_one',
          'facet_name' => 'facet name one',
          'facet_choices' => [
            {
              'key' => 'key_one',
              'radio_button_name' => 'radio button name one',
              'topic_name' => 'topic name one',
              'prechecked' => false
            },
            {
              'key' => 'key_two',
              'radio_button_name' => 'radio button name two',
              'topic_name' => 'topic name two',
              'prechecked' => false
            }
          ],
        },
        {
          'facet_id' => 'facet_id_two',
          'facet_name' => 'facet name two',
          'facet_choices' => [
            {
              'key' => 'key_three',
              'radio_button_name' => 'radio button name three',
              'topic_name' => 'topic name three',
              'prechecked' => false
            },
            {
              'key' => 'key_four',
              'radio_button_name' => 'radio button name four',
              'topic_name' => 'topic name four',
              'prechecked' => false
            }
          ],
        }
      ]
    end

    context 'when no choice is selected' do
      let(:filter) { {} }

      it { is_expected.to eq('Prefix:') }
    end

    context 'when one facet is selected' do
      context 'when one choice is selected' do
        let(:filter) { { 'facet_id_one' => %w(key_one) } }

        it { is_expected.to eq('Prefix: with facet name one of topic name one') }
      end

      context 'when two choices are selected' do
        let(:filter) { { 'facet_id_one' => %w(key_one key_two) } }

        it { is_expected.to eq('Prefix: with facet name one of topic name one and topic name two') }
      end
    end

    context 'when one dynamic facet is selected' do
      let(:subscription_list_title_prefix) { 'Prefix ' }
      let(:facets) do
        [{ "facet_id" => "people", "facet_name" => "people" }]
      end
      let(:filter) do
        { 'people' => %w(harry-potter ron-weasley) }
      end

      it { is_expected.to eq('Prefix with people of Harry Potter and Ron Weasley') }
    end


    context 'when two facets are selected' do
      let(:filter) do
        {
          'facet_id_one' => %w(key_one key_two),
          'facet_id_two' => %w(key_three key_four),
        }
      end

      it { is_expected.to eq('Prefix: with facet name one of topic name one and topic name two and facet name two of topic name three and topic name four') }
    end
  end

  context "when there are multiple facets with the same filter_key" do
    let(:subscription_list_title_prefix) { 'News and communicatons ' }
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
        { "facet_id" => "related_to_brexit", "filter_key" => "part_of_taxonomy_tree", "filter_value" => "d6c2de5d-ef90-45d1-82d4-5f2438369eea", "facet_name" => "topics" },
        { "facet_id" => "document_type", "facet_name" => "document types" },
    ]
    end
    let(:filter) do
      {
        'people' => %w(harry-potter ron-weasley albus-dumbledore cornelius-fudge rufus-scrimgeour),
        'organisations' => %w(ministry-of-magic gringots hogwarts),
        'part_of_taxonomy_tree' => %w(magical-education d6c2de5d-ef90-45d1-82d4-5f2438369eea herbology),
        'document_type' => %w(OWL NEWT),
      }
    end

    it {
      is_expected.to eq('News and communicatons with people of Harry Potter, Ron Weasley, Albus Dumbledore, Cornelius Fudge, and Rufus Scrimgeour, organisations of Ministry of Magic, Gringots, and 1 other organisation, topics of Magical Education, Brexit, and Herbology, and 2 document types')
    }
  end

  context "business finder specific snowflakey test" do
    # TODO - import these fixtures from features/fixtures/business_readiness_email_signup.json

    let(:subscription_list_title_prefix) { 'Find EU Exit guidance for your business ' }
    let(:facets) do
      [
        {
          "facet_id" => "sector_business_area",
          "facet_name"=> "Sector / Business Area",
          "facet_choices"=> [
            {
              "key"=> "banking-market-infrastructure",
              "radio_button_name"=> "Banking, markets and infrastructure",
              "topic_name"=> "Banking, markets and infrastructure",
              "prechecked"=> false
            },
            {
              "key"=> "electronics",
              "radio_button_name"=> "Electronics",
              "topic_name"=> "Electronics",
              "prechecked"=> false
            },
            {
              "key"=> "imports",
              "radio_button_name"=> "Imports",
              "topic_name"=> "Imports",
              "prechecked"=> false
            },
            {
              "key" => "retail",
              "radio_button_name" => "Retail",
              "topic_name" => "Retail",
              "prechecked" => false
            },
          ]
        },
        {
            "facet_id"=> "business_activity",
            "facet_name"=> "Business activity",
            "facet_choices" => [
                {
                    "key"=> "sell-uk",
                    "radio_button_name"=> "I sell products or goods in the UK",
                    "topic_name"=> "I sell products or goods in the UK",
                    "prechecked"=> false
                },
                {
                    "key"=> "buying",
                    "radio_button_name"=> "I buy products or goods from abroad",
                    "topic_name"=> "I buy products or goods from abroad",
                    "prechecked"=> false
                },
                {
                    "key"=> "selling",
                    "radio_button_name"=> "I sell products or goods abroad",
                    "topic_name"=> "I sell products or goods abroad",
                    "prechecked"=> false
                },
            ]
        },
        {
          "facet_id"=> "employ_eu_citizens",
          "facet_name"=> "Employ EU citizens",
          "facet_choices"=> [
            {
              "key"=> "no",
              "radio_button_name"=> "No",
              "topic_name"=> "No",
              "prechecked"=> false
            },
          ]
        },
        {
          "facet_id"=> "intellectual_property",
          "facet_name"=> "Intellectual property",
          "facet_choices"=> [
            {
              "key"=> "trademarks",
              "radio_button_name"=> "Trade marks",
              "topic_name"=> "Trade marks",
              "prechecked"=> false
            },
          ]
        },

      ]
    end

    let(:filter) do
      {
        'sector_business_area' => %w(banking-market-infrastructure electronics imports retail),
        'business_activity' => %w(sell-uk buying selling),
        'employ_eu_citizens' => %w(no),
        'intellectual_property' => %w(trademarks)
      }
    end

    subject do
      described_class.call(
          filter: filter,
          subscription_list_title_prefix: subscription_list_title_prefix,
          facets: facets,
          join_facets_with: "or"
          )
    end

    it {
      # TODO - get this test passing, as this is what we're expecting at the moment.
      # Then rewrite the test to assert against the value we WANT - talk to a content designer
      # to find out what that is.
      expected_val = 'Find EU Exit guidance for your business with Sector / Business Area of Banking, markets and infrastructure, Electronics, Imports, and Retail, Business activity of I sell products or goods in the UK, I buy products or goods from abroad, and I sell products or goods abroad, Employ EU citizens of No, and Intellectual property of Trade marks'
      puts ""
      puts "EXPECTED #{expected_val}"
      puts "ACTUAL #{subject}"
      is_expected.to eq(expected_val)
    }
  end
end
