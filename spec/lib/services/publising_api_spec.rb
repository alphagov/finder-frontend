require "spec_helper"
require "gds_api/publishing_api"
require "gds_api/test_helpers/publishing_api"

describe Services do
  include GdsApi::TestHelpers::PublishingApi

  describe "#unpublish" do
    subject(:service) do
      Services.publishing_api.unpublish(content_item_id, unpublish_options)
    end

    let(:content_item_id) { "f3dd33bd-e88a-400a-8dbc-50e673e42a7a" }

    let(:unpublish_options) do
      {
        "type" => "redirect",
        "alternative_path" => "/transition",
      }.symbolize_keys
    end

    it "unpublishes the item" do
      stub_any_publishing_api_unpublish
      expect(subject.code).to eq(200)
    end
  end
end
