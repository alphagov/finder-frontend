require 'spec_helper'
require 'gds_api/test_helpers/content_store'
require 'gds_api/test_helpers/search'

describe Services::ContentStore do
  include GdsApi::TestHelpers::ContentStore
  include GdsApi::TestHelpers::Search
  include ContentStoreServiceHelper

  subject(:service) { described_class.new }
  let(:search_path) { '/search/all' }

  describe ".cached_content_item" do
    subject { described_class.new.cached_content_item(search_path) }

    context "when content store is unavailable" do
      it "will raise an error" do
        content_store_isnt_available
        expect { subject }.to raise_error GdsApi::HTTPServerError
      end
    end

    it "will return a content item hash" do
      stub_content_store_has_item(search_path)
      expect(subject['base_path']).to eq(search_path)
    end

    it "will cache a returned content item" do
      item = content_item_for_base_path(search_path)
      stub_content_store_has_item(search_path, item)
      expect { subject }.to(change { cached_item(search_path) }.from(nil).to(item))
    end

    context "when an item is already cached" do
      it "won't fetch a fresh one from the content store" do
        content_store_isnt_available
        content_items_are_already_cached
        expect(subject['base_path']).to eq(search_path)
      end
    end
  end

  describe ".soft_refresh_cache" do
    subject { service.soft_refresh_cache }

    context "when cache is empty" do
      it "will cache all finder content items" do
        search_api_has_finders
        stub_content_store_has_finders
        subject
        finder_content_items.each { |item|
          expect_item_to_be_in_cache(item[:link])
        }
      end
    end

    context "when cache is not empty" do
      it "WILL NOT overwrite already cached finder content items" do
        search_api_has_finders
        content_store_isnt_available
        content_items_are_already_cached
        subject
        finder_content_items.each { |item|
          expect_item_to_be_in_cache(item[:link])
        }
      end
    end

    context "when content store is unavailable" do
      it "will raise an error" do
        search_api_has_finders
        content_store_isnt_available
        expect { subject }.to raise_error GdsApi::HTTPServerError
      end
    end

    context "when search-api is unavailable" do
      it "will raise an error" do
        search_api_isnt_available
        expect { service.soft_refresh_cache }.to raise_error GdsApi::HTTPServerError
      end
    end
  end

  describe ".hard_refresh_cache" do
    subject { service.hard_refresh_cache }

    context "when cache is empty" do
      it "will cache all finder content items" do
        search_api_has_finders
        stub_content_store_has_finders
        subject
        finder_content_items.each { |item|
          expect_item_to_be_in_cache(item[:link])
        }
      end
    end

    context "when cache is not empty" do
      it "WILL overwrite already cached finder content items" do
        search_api_has_finders
        item = content_item(search_path)
        to_date = item['public_updated_at']
        from_date = "2001-01-01T12:01:00+00:00"
        item['public_updated_at'] = from_date
        Rails.cache.write("finder-frontend_content_items#{search_path}", item)
        stub_content_store_has_finders
        expect { subject }.to(
          change {
            cached_item(search_path)['public_updated_at']
          }.to(to_date).from(from_date)
        )
      end
    end

    context "when content store is unavailable" do
      it "will raise an error" do
        search_api_has_finders
        content_store_isnt_available
        expect { subject }.to raise_error GdsApi::HTTPServerError
      end
    end

    context "when search-api is unavailable" do
      it "will raise an error" do
        search_api_isnt_available
        expect { subject }.to raise_error GdsApi::HTTPServerError
      end
    end
  end
end
