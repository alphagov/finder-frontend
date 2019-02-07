require 'spec_helper'
require 'email_alert_title_builder'

describe EmailAlertTitleBuilder do
  subject do
    described_class.call(
      filter: filter,
      subscription_list_title_prefix: subscription_list_title_prefix,
      facets: facets
    )
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
        { 'people' => %w(harry_potter ron_weasley) }
      end

      it { is_expected.to eq('Prefix with 2 people') }
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
        { "facet_id" => "document_type", "facet_name" => "document types" },
        { "facet_id" => "world_locations", "facet_name" => "world locations" },
        { "facet_id" => "level_one_taxon", "filter_key" => "part_of_taxonomy_tree", "facet_name" => "topics" },
        { "facet_id" => "level_two_taxon", "filter_key" => "part_of_taxonomy_tree", "facet_name" => "topics" },
        { "facet_id" => "related_to_brexit", "filter_key" => "part_of_taxonomy_tree", "filter_value" => "d6c2de5d-ef90-45d1-82d4-5f2438369eea", "facet_name" => "topics" },
    ]
    end
    let(:filter) do
      {
        'people' => %w(harry_potter ron_weasley dumbledore cornelius_fudge rufus_scrimgeour),
        'organisations' => %w(ministry_of_magic gringots hogwarts),
        'part_of_taxonomy_tree' => %w(magical_education brexit education),
      }
    end

    it {
      is_expected.to eq('News and communicatons with 5 people, 3 organisations, and 3 topics')
    }
  end
end
