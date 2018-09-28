require 'spec_helper'

RSpec.describe TranslateContentPurposeFields do
  subject(:translator) { described_class.new(query) }

  let(:query) { { 'foo' => 'bar' } }

  describe '.call' do
    subject(:translated) { translator.call }

    it { is_expected.to_not include(:aggregate_content_purpose_subgroup) }
    it { is_expected.to_not include(:aggregate_content_purpose_supergroup) }
    it { is_expected.to_not include(:filter_content_purpose_subgroup) }
    it { is_expected.to_not include(:filter_content_purpose_supergroup) }
    it { is_expected.to_not include(:reject_content_purpose_subgroup) }
    it { is_expected.to_not include(:reject_content_purpose_supergroup) }

    it 'preserves original query fields' do
      is_expected.to include('foo' => 'bar')
    end

    context 'when it includes a aggregate content purpose field' do
      let(:query) { { 'aggregate_content_purpose_subgroup' => 'news', 'foo' => 'bar' } }

      it 'preserves original query fields' do
        is_expected.to include('foo' => 'bar')
      end

      it 'translates content purpose attributes to content store document type' do
        is_expected.to include('aggregate_content_store_document_type' =>
                                 %w(fatality_notice news_article news_story press_release
                                    world_location_news_article world_news_story))

        is_expected.to_not include('aggregate_content_purpose_subgroup')
      end
    end

    context 'when it includes a filter content purpose field' do
      let(:query) { { 'filter_content_purpose_subgroup' => 'transactions', 'foo' => 'bar' } }

      it 'preserves original query fields' do
        is_expected.to include('foo' => 'bar')
      end

      it 'translates content purpose attributes to content store document type' do
        is_expected.to include('filter_content_store_document_type' =>
                                 %w(answer calculator completed_transaction form guide licence
                                    local_transaction place simple_smart_answer smart_answer
                                    step_by_step_nav transaction))

        is_expected.to_not include('filter_content_purpose_subgroup')
      end
    end

    context 'when it includes a reject content purpose field' do
      let(:query) { { 'reject_content_purpose_subgroup' => 'regulation', 'foo' => 'bar' } }

      it 'preserves original query fields' do
        is_expected.to include('foo' => 'bar')
      end

      it 'translates content purpose attributes to content store document type' do
        is_expected.to include('reject_content_store_document_type' => %w(regulation statutory_instrument))

        is_expected.to_not include('reject_content_purpose_subgroup')
      end
    end

    context 'when it includes multiple content purpose values' do
      let(:query) do
        {
          'filter_content_purpose_subgroup' => %w(policy consultations),
          'foo' => 'bar',
        }
      end

      it 'preserves original query fields' do
        is_expected.to include('foo' => 'bar')
      end

      it 'translates content purpose attributes to content store document type' do
        is_expected.to include('filter_content_store_document_type' =>
                                 %w(case_study closed_consultation consultation_outcome impact_assessment
                                    open_consultation policy_paper))

        is_expected.to_not include('filter_content_purpose_subgroup')
      end
    end

    context 'when it includes content purpose subgroup and supergroup fields' do
      let(:query) do
        {
          'filter_content_purpose_subgroup' => 'policy',
          'filter_content_purpose_supergroup' => 'transparency',
          'foo' => 'bar',
        }
      end

      it 'preserves original query fields' do
        is_expected.to include('foo' => 'bar')
      end

      it 'translates content purpose subgroup attributes to content store document type' do
        is_expected.to include('filter_content_store_document_type' => %w(case_study impact_assessment policy_paper))

        is_expected.to_not include('filter_content_purpose_subgroup', 'filter_content_purpose_supergroup')
      end
    end
  end
end
