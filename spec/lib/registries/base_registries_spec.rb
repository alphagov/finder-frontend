require 'spec_helper'
require "gds_api/test_helpers/worldwide"

RSpec.describe Registries::BaseRegistries do
  include GdsApi::TestHelpers::Worldwide

  before do
    worldwide_api_has_selection_of_locations
  end

  let(:subject) { described_class.new }

  it "fetches all registries" do
    expect(subject.all).to have_key('world_locations')
  end

  it "provides world_locations registry" do
    expect(subject.all['world_locations']).to be_instance_of Registries::WorldLocationsRegistry
  end
end
