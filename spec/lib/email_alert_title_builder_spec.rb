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
      { 'singular' => 'Prefix: ', 'plural' => 'Prefixes: ' }
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

      it { is_expected.to eq('Prefixes: ') }
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

      it { is_expected.to eq('Prefix: ') }
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
end
