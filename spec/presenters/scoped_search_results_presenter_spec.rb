require "spec_helper"

RSpec.describe ScopedSearchResultsPresenter do
  before do
    @scope_title = double
    @unscoped_result_count = double

    @scoped_results = [
      { "title_with_highlighting" => "scoped_result_1" },
      { "title_with_highlighting" => "scoped_result_2" },
      { "title_with_highlighting" => "scoped_result_3" },
      { "title_with_highlighting" => "scoped_result_4" },
    ]

    @unscoped_results = [
      { "title_with_highlighting" => "unscoped_result_1" },
      { "title_with_highlighting" => "unscoped_result_2" },
      { "title_with_highlighting" => "unscoped_result_3" },
    ]

    @search_response =  {
      "result_count" => "50",
      "results" => @scoped_results,
      "scope" => {
        "title" => @scope_title,
      },
      "unscoped_results" => {
        "total" => @unscoped_result_count,
        "results" => @unscoped_results,
      },
    }

    @search_parameters = double(
      :params,
      search_term: 'words',
      debug_score: 1,
      start: 1,
      count: 1,
      build_link: 1,
    )
  end

  it "return a hash that has is_scoped set to true" do
    results = ScopedSearchResultsPresenter.new(@search_response, @search_parameters)
    expect(results.to_hash[:is_scoped?]).to eq(true)
  end

  it "return a hash with the scope_title set to the scope title from the @search_response" do
    results = ScopedSearchResultsPresenter.new(@search_response, @search_parameters)
    expect(results.to_hash[:scope_title]).to eq(@scope_title)
  end

  it "return a hash result count set to the scope title from the @search_response" do
    results = ScopedSearchResultsPresenter.new(@search_response, @search_parameters)
    expect(results.to_hash[:unscoped_result_count]).to eq("#{@unscoped_result_count} results")
  end

  context "presentable result list" do
    it "return all scoped results with unscoped results inserted at position 4" do
      results = ScopedSearchResultsPresenter.new(@search_response, @search_parameters).to_hash

      ##
      # This test is asserting that the format of `presentable_list` is:
      # [result, result, result, {results: list_of_results, is_multiple_results: true}, result ...]
      # Where list_of_results are the top three results from an unscoped request to rummager
      # and a flag `is_multiple_results` set to true.
      ##

      simplified_expected_results_list = [
        { "title_with_highlighting" => "scoped_result_1" },
        { "title_with_highlighting" => "scoped_result_2" },
        { "title_with_highlighting" => "scoped_result_3" },
        {
          "is_multiple_results" => true,
          "results" => [
            { "title_with_highlighting" => "unscoped_result_1" },
            { "title_with_highlighting" => "unscoped_result_2" },
            { "title_with_highlighting" => "unscoped_result_3" },
          ]
        },
        { "title_with_highlighting" => "scoped_result_4" },
      ]

      # Scoped results
      simplified_expected_results_list[0..2].each_with_index do |result, i|
        expect(results[:results][i][:title_with_highlighting]).to eq(result["title_with_highlighting"])
      end

      # Check un-scoped sub-list has flag
      expect(results[:results][3][:is_multiple_results]).to eq(true)

      # iterate unscoped sublist of results
      simplified_expected_results_list[3]["results"].each_with_index do |result, i|
        expect(results[:results][3][:results][i][:title_with_highlighting]).to eq(result["title_with_highlighting"])
      end

      # check remaining result
      expect(results[:results][4][:title_with_highlighting]).to eq(simplified_expected_results_list[4]["title_with_highlighting"])
    end
  end

  context "no scoped results returned" do
    before do
      @no_results = []
      @search_response["unscoped_results"]["results"] = @no_results
    end

    it "not not include unscoped results in the presentable_list if there aren't any" do
      results = ScopedSearchResultsPresenter.new(@search_response, @search_parameters).to_hash

      @scoped_results.each_with_index do |result, i|
        expect(results[:results][i][:title_with_highlighting]).to eq(result["title_with_highlighting"])
      end
    end

    it "not set unscoped_results_any? to false" do
      results = ScopedSearchResultsPresenter.new(@search_response, @search_parameters).to_hash
      expect(results.to_hash[:unscoped_results_any?]).to be_falsy
    end
  end
end
