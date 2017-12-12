require "spec_helper"

RSpec.describe SearchResultsPresenter do
  let(:view_content) { double(:view_content, render: 'pagination_html') }

  def search_params(params)
    SearchParameters.new(ActionController::Parameters.new(params))
  end

  it "return an appropriate hash" do
    results = SearchResultsPresenter.new({
      "total" => 1,
      "results" => [{ "index" => "mainstream" }],
      "facets" => {}
    }, search_params(q: 'my-query'), view_content)

    expect(results.to_hash[:query]).to eq('my-query')
    expect(results.to_hash[:result_count]).to eq(1)
    expect(results.to_hash[:result_count_string]).to eq('1 result')
    expect(results.to_hash[:results_any?]).to eq(true)
  end

  it "return an entry for a facet" do
    results = SearchResultsPresenter.new({
      "results" => [],
      "facets" => {
        "organisations" => {
          "options" => [{
            "value" => {
              "link" => "/government/organisations/department-for-education",
              "title" => "Department for Education"
            },
            "documents" => 114
          }]
        }
      }
    }, search_params(q: 'my-query'), view_content)

    expect(results.to_hash[:filter_fields].length).to eq(1)
    expect(results.to_hash[:filter_fields][0][:field]).to eq("organisations")
    expect(results.to_hash[:filter_fields][0][:field_title]).to eq("Organisations")
    expect(results.to_hash[:filter_fields][0][:options][:options].length).to eq(1)
    expect(results.to_hash[:filter_fields][0][:options][:options][0][:title]).to eq("Department for Education")
  end

  context 'pagination' do
    it 'build a link to the next page' do
      expect(view_content).to receive(:render).with(
        "govuk_component/previous_and_next_navigation",
        next_page: { url: "/search?count=50&q=my-query&start=50", title: "Next page", label: "2 of 4" },
      )

      response = { 'total' => 200 }
      params = search_params(q: 'my-query',
        count: 50,
        start: 0)
      presenter = SearchResultsPresenter.new(response, params, view_content)

      presenter.next_and_prev_links
    end

    it 'not have a next page when start + count >= total' do
      expect(view_content).to receive(:render).with(
        "govuk_component/previous_and_next_navigation",
        previous_page: { url: "/search?count=50&start=100", title: "Previous page", label: "3 of 4" },
      )

      response = { 'total' => 200 }
      params = search_params(count: 50,
        start: 150)
      presenter = SearchResultsPresenter.new(response, params, view_content)

      presenter.next_and_prev_links
    end

    it 'build a link to the previous page' do
      expect(view_content).to receive(:render).with(
        "govuk_component/previous_and_next_navigation",
        previous_page: { url: "/search?count=50&q=my-query&start=50", title: "Previous page", label: "2 of 4" },
        next_page: { url: "/search?count=50&q=my-query&start=150", title: "Next page", label: "4 of 4" }
      )

      response = { 'total' => 200 }
      params = search_params(q: 'my-query',
        count: 50,
        start: 100)
      presenter = SearchResultsPresenter.new(response, params, view_content)

      presenter.next_and_prev_links
    end

    it 'not have a previous page when start = 0' do
      expect(view_content).to receive(:render).with(
        "govuk_component/previous_and_next_navigation",
        next_page: { url: "/search?count=50&start=50", title: "Next page", label: "2 of 4" }
      )

      response = { 'total' => 200 }
      params = search_params(count: 50,
        start: 0)
      presenter = SearchResultsPresenter.new(response, params, view_content)

      presenter.next_and_prev_links
    end

    it 'link to a start_at value of 0 when less than zero' do
      expect(view_content).to receive(:render).with(
        "govuk_component/previous_and_next_navigation",
        previous_page: { url: "/search?count=50&q=my-query", title: "Previous page", label: "1 of 4" },
        next_page: { url: "/search?count=50&q=my-query&start=75", title: "Next page", label: "3 of 4" }
      )

      response = { 'total' => 200 }
      params = search_params(q: 'my-query',
        count: 50,
        start: 25)
      presenter = SearchResultsPresenter.new(response, params, view_content)

      presenter.next_and_prev_links
    end

    it 'not have a previous or next page when there are no results' do
      expect(view_content).not_to receive(:render)

      response = { 'total' => 0 }
      params = search_params(count: 50,
        start: 0)
      presenter = SearchResultsPresenter.new(response, params, view_content)

      presenter.next_and_prev_links
    end

    it 'not have a previous or next page when there are not enough results' do
      expect(view_content).not_to receive(:render)

      response = { 'total' => 25 }
      params = search_params(count: 50,
        start: 0)
      presenter = SearchResultsPresenter.new(response, params, view_content)

      presenter.next_and_prev_links
    end

    it 'include the count parameter in the url when not set to the default' do
      expect(view_content).to receive(:render).with(
        "govuk_component/previous_and_next_navigation",
        next_page: { url: "/search?count=88&q=my-query&start=88", title: "Next page", label: "2 of 3" }
      )

      response = { 'total' => 200 }
      params = search_params(q: 'my-query',
        count: 88,
        start: 0)
      presenter = SearchResultsPresenter.new(response, params, view_content)

      presenter.next_and_prev_links
    end
  end

  context 'grouping' do
    it "not have metadata for group results" do
      results = SearchResultsPresenter.new({
        "total" => 1,
        "results" => [{ "document_type" => "group" }],
        "facets" => {}
      }, search_params(q: 'my-query'), view_content)
      rlist = results.to_hash[:results]
      expect(rlist.size).to eq(1)
      expect(rlist[0][:metadata]).to be_nil
      expect(rlist[0][:metadata_any?]).to be_falsy
    end
  end
end
