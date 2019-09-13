require 'spec_helper'

RSpec.describe Healthchecks::ContentItemsCache do
  include ContentStoreServiceHelper

  subject(:check) { described_class.new }

  context "when search api is unavailable" do
    it "has a warning status" do
      search_api_isnt_available
      expect(check.status).to eq :warning
      expect(check.message).to include 'A GdsApi::HTTPUnavailable error occurred'
    end
  end

  context "when content items aren't cached" do
    it "has a warning status" do
      search_api_has_finders
      expect(check.status).to eq :warning
      message = <<~WARNING
        Content items aren't cached. Searches may be slower. Is content store unavailable?
        These content items are uncached:
        #{finder_content_items.map { |item| item[:link] }.to_sentence}
      WARNING

      expect(check.message).to eq message
    end
  end

  context "when content items are cached" do
    before do
      search_api_has_finders
      content_items_are_already_cached
    end

    it "has an OK status" do
      expect(check.status).to eq :ok
      expect(check.message).to eq "OK"
    end
  end
end
