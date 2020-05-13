require "spec_helper"

describe Search::Query do
  def stub_search
    stub_request(:get, %r{#{Plek.find("search")}/search.json})
  end

  def stub_batch_search
    stub_request(:get, %r{#{Plek.find("search")}/batch_search.json})
  end

  let(:content_item) do
    ContentItem.new(
      "details" => {
        "facets" => facets,
      },
    )
  end

  let(:facets) do
    [
      {
        "key" => "alpha",
        "filterable" => true,
        "type" => "text",
      },
      {
        "key" => "beta",
        "filterable" => true,
        "type" => "text",
        "combine_mode" => "or",
      },
    ]
  end
  let(:filter_params) { { "alpha" => "foo" } }
  let(:batch_search_filter_params) { { "alpha" => "foo", "beta" => "bar" } }

  def result_item(id, title, score:, popularity:, updated:)
    {
      "_id" => id,
      "title" => title,
      "es_score" => score,
      "popularity" => popularity,
      "public_timestamp" => updated,
    }
  end

  context "when searching using a single query" do
    subject { described_class.new(content_item, filter_params).search_results }

    before :each do
      stub_search.to_return(body: {
        "results" => [
          result_item("/register-to-vote", "Register to Vote", score: nil, updated: "14-12-19", popularity: 3),
          result_item("/hmrc", "HMRC", score: nil, updated: "14-12-18", popularity: 2),
          result_item("/own-a-micro-pig", "Owning a micro-pig", score: nil, updated: "14-12-19", popularity: 1),
        ],
      }.to_json)
    end

    it "uses the standard search endpoint" do
      results = subject.fetch("results")
      expect(results.length).to eq(3)
      expect(results.first).to match(hash_including("_id" => "/register-to-vote"))
      expect(results.last).to match(hash_including("_id" => "/own-a-micro-pig"))
    end
  end

  context "when merging, de-duplicating and sorting" do
    shared_examples "sorts by other fields" do
      context "most-recent" do
        subject { described_class.new(content_item, batch_search_filter_params.merge("order" => "most-recent")).search_results }

        it "de-duplicates and sorts by public_updated descending" do
          results = subject.fetch("results")
          expect(results.first).to match(hash_including("_id" => "/register-to-vote"))
          expect(results.second).to match(hash_including("_id" => "/hmrc"))
        end
      end

      context "most-viewed" do
        subject { described_class.new(content_item, batch_search_filter_params.merge("order" => "most-viewed")).search_results }

        it "de-duplicates and sorts by popularity descending" do
          results = subject.fetch("results")
          expect(results.first).to match(hash_including("_id" => "/register-to-vote"))
          expect(results.second).to match(hash_including("_id" => "/hmrc"))
        end
      end

      context "a-to-z" do
        subject { described_class.new(content_item, batch_search_filter_params.merge("order" => "a-to-z")).search_results }

        it "de-duplicates and sorts by title descending" do
          results = subject.fetch("results")
          expect(results.first).to match(hash_including("title" => "HMRC"))
          expect(results.second).to match(hash_including("title" => "Register to Vote"))
        end
      end
    end

    context "when keywords are not used" do # Rummager returns nil for es_score
      before do
        stub_batch_search.to_return(body:
          {
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
            ],
          }.to_json)
      end

      it_behaves_like "sorts by other fields"

      context "default" do
        subject { described_class.new(content_item, batch_search_filter_params).search_results }

        it "de-duplicates and returns in the order rummager returns" do
          results = subject.fetch("results")
          expect(results.first).to match(hash_including("_id" => "/register-to-vote"))
          expect(results.second).to match(hash_including("_id" => "/hmrc"))
        end
      end

      context "most-relevant" do
        subject { described_class.new(content_item, batch_search_filter_params.merge("order" => "most-relevant")).search_results }

        it "de-duplicates and returns in the order rummager returns" do
          results = subject.fetch("results")
          expect(results.first).to match(hash_including("_id" => "/register-to-vote"))
          expect(results.second).to match(hash_including("_id" => "/hmrc"))
        end
      end
    end

    context "when keywords exist in search" do
      before do
        stub_batch_search.to_return(body:
        {
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
          ],
        }.to_json)
      end

      it_behaves_like "sorts by other fields"

      context "default" do
        subject { described_class.new(content_item, batch_search_filter_params).search_results }

        it "de-duplicates and sorts by es_score descending" do
          results = subject.fetch("results")
          expect(results.first).to match(hash_including("title" => "HMRC"))
          expect(results.second).to match(hash_including("title" => "Register to Vote"))
        end
      end

      context "most-relevant" do
        subject { described_class.new(content_item, batch_search_filter_params.merge("order" => "most-relevant")).search_results }

        it "de-duplicates and sorts by es_score descending" do
          results = subject.fetch("results")
          expect(results.first).to match(hash_including("title" => "HMRC"))
          expect(results.second).to match(hash_including("title" => "Register to Vote"))
        end
      end

      context "with valid date params" do
        let(:valid_date_params) { { public_timestamp: { to: "01/01/01", from: "01/02/01" } } }
        subject { described_class.new(content_item, valid_date_params) }

        it "has no errors" do
          expect(subject.valid?).to be true
          expect(subject.errors.messages).to be_empty
        end
      end

      context "with invalid date params" do
        let(:invalid_to_date_params) { { public_timestamp: { to: "99/99/99", from: "01/01/01" } } }
        let(:invalid_from_date_params) { { public_timestamp: { to: "01/01/01", from: "99/99/99" } } }

        it "stores an error for bad 'to date'" do
          query = described_class.new(content_item, invalid_to_date_params)
          expect(query.valid?).to be false
          expect(query.errors.messages).to eq(to_date: ["Enter a real date"])
        end

        it "stores an error for bad 'from date'" do
          query = described_class.new(content_item, invalid_from_date_params)
          expect(query.valid?).to be false
          expect(query.errors.messages).to eq(from_date: ["Enter a real date"])
        end
      end
    end
  end
end
