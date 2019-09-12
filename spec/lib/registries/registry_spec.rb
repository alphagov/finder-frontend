require "spec_helper"

RSpec.describe Registries::Registry do
  subject(:registry) { described_class.new }

  describe "#can_refresh_cache?" do
    it "returns false" do
      expect(registry.can_refresh_cache?).to be false
    end
  end
end
