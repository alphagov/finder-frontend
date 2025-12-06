require "spec_helper"
require "support/taxonomy_helper"

describe TopicFinderHelper, type: :helper do
  include TaxonomySpecHelper

  describe "#topic_finder?" do
    before do
      topic_taxonomy_has_taxons([FactoryBot.build(:level_one_taxon_hash, content_id: "existing_content_id")])
    end

    let(:has_topic) { topic_finder?("topic" => "/education/education-of-disadvantaged-children") }

    it "returns true because there is a topic parameter that exists" do
      expect(topic_finder?("topic" => "d2005b89-352f-4896-aced-1d17504330e6")).to be_truthy
    end

    it "returns false because there is a topic parameter that does not exist" do
      expect(topic_finder?("topic" => "non_existing_content_id")).to be_falsey
    end

    it "returns false because there is no topic parameter" do
      expect(topic_finder?({})).to be_falsey
    end
  end
end
