require 'spec_helper'
require 'gds_api/test_helpers/content_store'
include GdsApi::TestHelpers::ContentStore
include FixturesHelper

describe FindersController do
  describe "GET show" do
    describe "finder item doesn't exist" do
      it 'returns a 404, rather than 5xx' do
        content_store_does_not_have_item('/does-not-exist')

        get :show, slug: 'does-not-exist'
        expect(response.status).to eq(404)
      end
    end
  end
end
