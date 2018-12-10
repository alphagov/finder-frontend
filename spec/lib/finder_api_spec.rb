require "spec_helper"

describe FinderApi do
  context "when merging and de-duplicating" do
    subject { described_class.new("/finder", {}).content_item_with_search_results }

    def result_item(id, title, score:)
      {
        "_id" => id,
        "title" => title,
        "es_score" => score,
      }
    end

    before do
      allow(Services.content_store).to receive(:content_item)
        .with("/finder")
        .and_return(
          "details" => {
            "facets" => []
          },
        )

      allow(Services.rummager).to receive(:batch_search)
        .and_return(
          "results" => [
            {
              "results" => [
                result_item("/register-to-vote", "Register to Vote", score: 1),
              ],
            },
            {
              "results" => [
                result_item("/hmrc", "HMRC", score: 10),
                result_item("/register-to-vote", "Register to Vote", score: 2),
              ],
            },
          ]
        )
    end

    it "de-duplicates the content" do
      results = subject.fetch("details").fetch("results")
      expect(results.first).to match(hash_including("_id" => "/hmrc"))
      expect(results.second).to match(hash_including("_id" => "/register-to-vote"))
    end
  end
end
