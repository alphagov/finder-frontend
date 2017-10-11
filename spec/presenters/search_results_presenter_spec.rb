require "spec_helper"

RSpec.describe SearchResultsPresenter do
  it "return an appropriate hash" do
    results = SearchResultsPresenter.new({
      "total" => 1,
      "results" => [{ "index" => "mainstream" }],
      "facets" => {}
    }, SearchParameters.new(q: 'my-query'))

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
    }, SearchParameters.new(q: 'my-query'))

    expect(results.to_hash[:filter_fields].length).to eq(1)
    expect(results.to_hash[:filter_fields][0][:field]).to eq("organisations")
    expect(results.to_hash[:filter_fields][0][:field_title]).to eq("Organisations")
    expect(results.to_hash[:filter_fields][0][:options][:options].length).to eq(1)
    expect(results.to_hash[:filter_fields][0][:options][:options][0][:title]).to eq("Department for Education")
  end

  context 'pagination' do
    it 'build a link to the next page' do
      response = { 'total' => 200 }
      params = SearchParameters.new(q: 'my-query',
        count: 50,
        start: 0)
      presenter = SearchResultsPresenter.new(response, params)

      expect(presenter).to have_next_page
      expect(presenter.next_page_link).to eq('/search?count=50&q=my-query&start=50')
      expect(presenter.next_page_label).to eq('2 of 4')
    end

    it 'not have a next page when start + count >= total' do
      response = { 'total' => 200 }
      params = SearchParameters.new(count: 50,
        start: 150)
      presenter = SearchResultsPresenter.new(response, params)

      expect(presenter).not_to have_next_page
      expect(presenter.next_page_link).to be_nil
    end

    it 'build a link to the previous page' do
      response = { 'total' => 200 }
      params = SearchParameters.new(q: 'my-query',
        count: 50,
        start: 100)
      presenter = SearchResultsPresenter.new(response, params)

      expect(presenter).to have_previous_page
      expect(presenter.previous_page_link).to eq('/search?count=50&q=my-query&start=50')
      expect(presenter.previous_page_label).to eq('2 of 4')
    end

    it 'not have a previous page when start = 0' do
      response = { 'total' => 200 }
      params = SearchParameters.new(count: 50,
        start: 0)
      presenter = SearchResultsPresenter.new(response, params)

      expect(presenter).not_to have_previous_page
      expect(presenter.previous_page_link).to be_nil
      expect(presenter).to have_next_page
      expect(presenter.next_page_link).to eq('/search?count=50&start=50')
      expect(presenter.next_page_label).to eq('2 of 4')
    end

    it 'link to a start_at value of 0 when less than zero' do
      response = { 'total' => 200 }
      params = SearchParameters.new(q: 'my-query',
        count: 50,
        start: 25)
      presenter = SearchResultsPresenter.new(response, params)

      # with a start value of 25 and a count of 50, this could incorrectly
      # calculate 25-50 and link to 'start=-25'. here, we assert that start=0
      # (so no start parameter is used).
      expect(presenter).to have_previous_page
      expect(presenter.previous_page_link).to eq('/search?count=50&q=my-query')
      expect(presenter.previous_page_label).to eq('1 of 4')
    end

    it 'not have a previous or next page when there are no results' do
      response = { 'total' => 0 }
      params = SearchParameters.new(count: 50,
        start: 0)
      presenter = SearchResultsPresenter.new(response, params)

      expect(presenter).not_to have_previous_page
      expect(presenter).not_to have_next_page

      expect(presenter.previous_page_link).to be_nil
      expect(presenter.next_page_link).to be_nil
    end

    it 'not have a previous or next page when there are not enough results' do
      response = { 'total' => 25 }
      params = SearchParameters.new(count: 50,
        start: 0)
      presenter = SearchResultsPresenter.new(response, params)

      expect(presenter).not_to have_previous_page
      expect(presenter).not_to have_next_page

      expect(presenter.previous_page_link).to be_nil
      expect(presenter.next_page_link).to be_nil
    end

    it 'include the count parameter in the url when not set to the default' do
      response = { 'total' => 200 }
      params = SearchParameters.new(q: 'my-query',
        count: 88,
        start: 0)
      presenter = SearchResultsPresenter.new(response, params)

      expect(presenter).to have_next_page
      expect(presenter.next_page_link).to eq('/search?count=88&q=my-query&start=88')
    end
  end

  context 'grouping' do
    it "not have metadata for group results" do
      results = SearchResultsPresenter.new({
        "total" => 1,
        "results" => [{ "document_type" => "group" }],
        "facets" => {}
      }, SearchParameters.new(q: 'my-query'))
      rlist = results.to_hash[:results]
      expect(rlist.size).to eq(1)
      expect(rlist[0][:metadata]).to be_nil
      expect(rlist[0][:metadata_any?]).to be_falsy
    end
  end
end
