# typed: false
def finder_content_item
  @finder_content_item ||= JSON.parse(File.read(
                                        Rails.root.join("features", "fixtures", "advanced-search.json")
  ))
end

Given(/^a collection of tagged documents(.*?)$/) do |categorisation|
  @tagged_to_taxon = {
    "title" => "tagged-to-taxon",
    "link" => "/tagged-to-taxon",
    "content_store_document_type" => "guidance",
    "content_purpose_supergroup" => "news_and_communications",
  }
  @guide_tagged_to_taxon = {
    "title" => "guide-tagged-to-taxon",
    "link" => "/guide-tagged-to-taxon",
    "content_store_document_type" => "guide",
    "content_purpose_supergroup" => "news_and_communications",
  }
  @results = [@tagged_to_taxon, @guide_tagged_to_taxon]
  search_params = base_search_params.merge(
    "count" => 20,
    "facet_content_purpose_subgroup" => "1500,order:value.title",
    "fields" => %w(
      title link description public_timestamp popularity
      content_purpose_supergroup content_store_document_type format
      is_historic government_name
      organisations content_purpose_subgroup part_of_taxonomy_tree
    ).join(","),
    "order" => "-public_timestamp",
    "reject_content_store_document_type" => %w[browse],
  )

  case categorisation.strip
  when /^with dates in supergroup '(\w+)'$/
    search_params["filter_content_purpose_supergroup"] = $1
    search_params["filter_public_timestamp"] = "from:2005-01-01,to:2025-01-01"
  when /^in supergroup '(\w+)'$/
    search_params["filter_content_purpose_supergroup"] = $1
  when /^in supergroup '(\w+)' and subgroups '([\w,]+)'$/
    search_params["filter_content_purpose_supergroup"] = $1
    search_params["filter_content_purpose_subgroup"] = $2.split(",")
  end

  rummager_advanced_search_url = rummager_url(search_params)

  stub_request(:get, rummager_advanced_search_url).to_return(
    body: {
      results: @results,
      total: 200,
      start: 0,
      facets: {},
      suggested_queries: []
    }.to_json
  )
  content_store_has_item("/search/advanced", finder_content_item)
  content_store_has_item("/taxon",
                         schema: "special_route",
                         base_path: "/taxon",
                         title: "Taxon")
  stub_taxonomy_api_request
end

When(/^I filter by taxon alone$/) do
  visit "/search/advanced?topic=/taxon"
end

When(/^I filter by content purpose supergroup alone$/) do
  visit "/search/advanced?group=news_and_communications"
end

When(/^I filter by taxon and by supergroup$/) do
  visit "/search/advanced?topic=/taxon&group=news_and_communications"
end

When(/^I filter by taxon, supergroup and dates$/) do
  visit "/search/advanced?topic=/taxon&group=news_and_communications&public_timestamp%5Bfrom%5D=2005&public_timestamp%5Bto%5D=2025"
end

When(/^I filter by taxon, supergroup and subgroups$/) do
  visit "/search/advanced?topic=/taxon&group=news_and_communications&subgroup[]=news&subgroup[]=updates_and_alerts"
end

Then(/^I only see documents tagged to the taxon tree within the supergroup$/) do
  @results.each do |result|
    expect(page).to have_title("News and communications - GOV.UK")
    expect(page).to have_link("Taxon", href: "/taxon")
    expect(page).to have_text("200 results")
    expect(page).to have_link(result["title_with_highlighting"], href: result["link"])
  end
end

Then(/^I only see documents tagged to the taxon tree within the supergroup and subgroups$/) do
  @results.each do |result|
    expect(page).to have_title("News and communications - GOV.UK")
    expect(page).to have_link("Taxon", href: "/taxon")
    expect(page).to have_text("200 results")
    expect(page).to have_link(result["title_with_highlighting"], href: result["link"])
  end
end

Then(/^The correct metadata is displayed for the search results$/) do
  expect(page).to have_css(".document-metadata__value", text: "Guidance")
  expect(page).not_to have_css(".document-metadata__value", text: "Guide")
end

And(/^the correct metadata is displayed for the dates$/) do
  within(".result-info") do
    expect(page).to have_content("200 results")
    expect(page).to have_content("1 January 2005")
    expect(page).to have_content("1 January 2025")
  end
end

Then(/^The page is not found$/) do
  expect(page.status_code).to eq(404)
end

And(/^I enter a search query$/) do
  within '#keywords' do
    fill_in("Search", with: "harry potter")
  end
end

Then(/^the pagination links have been updated correctly$/) do
  within("#js-pagination") do
    expect(page).to have_link("Next page", href: "/search/advanced?group=news_and_communications&page=2&topic=%2Ftaxon")
  end
end
