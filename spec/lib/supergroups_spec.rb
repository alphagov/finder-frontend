# typed: false
require "spec_helper"

describe Supergroups do
  describe ".lookup" do
    it "instantiates a supergroup for the key passed" do
      groups = Supergroups.lookup("news_and_communications")
      expect(groups.first.label).to eq("News and communications")
    end

    it "can look up multiple groups" do
      groups = Supergroups.lookup(%w(news_and_communications services))
      expect(groups.first.label).to eq("News and communications")
      expect(groups.last.label).to eq("Services")
    end

    it "raises Supergroup::NotFound when keys are empty" do
      expect {
        Supergroups.lookup(nil)
      }.to raise_error(Supergroups::NotFound)
    end

    it "raises Supergroup::NotFound when a group isn't found" do
      expect {
        Supergroups.lookup("foo")
      }.to raise_error(Supergroups::NotFound)
    end

    it "can expose subgroups as a hash" do
      expect(Supergroups.lookup("services").first.to_h).to eq(
        "label" => "Services",
        "value" => "services",
        "subgroups" => [
          { "label" => "Transactions", "value" => "transactions" }
        ]
      )
    end
  end
end
