require "spec_helper"

describe FinderApi do
  context "when merging, de-duplicating and sorting" do
    def result_item(id, title, score:, popularity:, updated:)
      {
        "_id" => id,
        "title" => title,
        "es_score" => score,
        "popularity" => popularity,
        "public_timestamp" => updated
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
    end

    shared_examples 'sorts by other fields' do
      context 'most-recent' do
        subject { described_class.new("/finder", 'order' => 'most-recent').content_item_with_search_results }

        it "de-duplicates and sorts by public_updated descending" do
          results = subject.fetch("details").fetch("results")
          expect(results.first).to match(hash_including("_id" => "/register-to-vote"))
          expect(results.second).to match(hash_including("_id" => "/hmrc"))
        end
      end

      context 'most-viewed' do
        subject { described_class.new("/finder", 'order' => 'most-viewed').content_item_with_search_results }

        it "de-duplicates and sorts by popularity descending" do
          results = subject.fetch("details").fetch("results")
          expect(results.first).to match(hash_including("_id" => "/register-to-vote"))
          expect(results.second).to match(hash_including("_id" => "/hmrc"))
        end
      end

      context 'a-to-z' do
        subject { described_class.new("/finder", 'order' => 'a-to-z').content_item_with_search_results }

        it "de-duplicates and sorts by title descending" do
          results = subject.fetch("details").fetch("results")
          expect(results.first).to match(hash_including("title" => "HMRC"))
          expect(results.second).to match(hash_including("title" => "Register to Vote"))
        end
      end
    end

    context 'when keywords are not used' do #Rummager returns nil for es_score
      before do
        allow(Services.rummager).to receive(:batch_search)
          .and_return(
            "results" => [
              {
                "results" => [
                  result_item("/register-to-vote", "Register to Vote", score: nil, updated: "14-12-19", popularity: 3),
                ],
              },
              {
                "results" => [
                  result_item("/hmrc", "HMRC", score: nil, updated: "14-12-18", popularity: 2),
                  result_item("/register-to-vote", "Register to Vote", score: nil, updated: "14-12-19", popularity: 3),
                ],
              },
            ]
        )
      end

      it_behaves_like 'sorts by other fields'

      context 'default' do
        subject { described_class.new("/finder", {}).content_item_with_search_results }

        it "de-duplicates and returns in the order rummager returns" do
          results = subject.fetch("details").fetch("results")
          expect(results.first).to match(hash_including("_id" => "/register-to-vote"))
          expect(results.second).to match(hash_including("_id" => "/hmrc"))
        end
      end

      context 'most-relevant' do
        subject { described_class.new("/finder", 'order' => 'most-relevant').content_item_with_search_results }

        it "de-duplicates and returns in the order rummager returns" do
          results = subject.fetch("details").fetch("results")
          expect(results.first).to match(hash_including("_id" => "/register-to-vote"))
          expect(results.second).to match(hash_including("_id" => "/hmrc"))
        end
      end
    end

    context 'when keywords exist in search' do
      before do
        allow(Services.rummager).to receive(:batch_search)
          .and_return(
            "results" => [
              {
                "results" => [
                  result_item("/register-to-vote", "Register to Vote", score: 1, updated: "14-12-19", popularity: 3),
                ],
              },
              {
                "results" => [
                  result_item("/hmrc", "HMRC", score: 10, updated: "14-12-18", popularity: 2),
                  result_item("/register-to-vote", "Register to Vote", score: 2, updated: "14-12-19", popularity: 3),
                ],
              },
            ]
        )
      end

      it_behaves_like 'sorts by other fields'

      context 'default' do
        subject { described_class.new("/finder", {}).content_item_with_search_results }

        it "de-duplicates and sorts by es_score descending" do
          results = subject.fetch("details").fetch("results")
          expect(results.first).to match(hash_including("title" => "HMRC"))
          expect(results.second).to match(hash_including("title" => "Register to Vote"))
        end
      end

      context 'most-relevant' do
        subject { described_class.new("/finder", 'order' => 'most-relevant').content_item_with_search_results }

        it "de-duplicates and sorts by es_score descending" do
          results = subject.fetch("details").fetch("results")
          expect(results.first).to match(hash_including("title" => "HMRC"))
          expect(results.second).to match(hash_including("title" => "Register to Vote"))
        end
      end
    end
  end
end
