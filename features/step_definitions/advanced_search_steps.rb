def finder_content_item
  @finder_content_item ||= JSON.parse(File.read(
    Rails.root.join("features", "fixtures", "advanced-search.json")
  ))
end

Given(/^a collection of tagged documents(.*?)$/) do |categorisation|
  @tagged_to_taxon = { "title" => "tagged-to-taxon", "link" => "/tagged-to-taxon" }
  @results = [@tagged_to_taxon]
  search_params = base_search_params.merge(
    "count" => 20,
    "facet_content_purpose_subgroup" => "1000,order:value.title",
    "fields" => %w(title link description public_timestamp content_purpose_subgroup
      taxons content_purpose_supergroup).join(","),
    "order" => "-public_timestamp",
    "reject_content_store_document_type" => ["browse"],
  )

  case categorisation.strip
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
      total: 1,
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
end

When(/^I search by taxon$/) do
  visit "/search/advanced?taxons=/taxon"
end

When(/^I search by taxon and by supergroup$/) do
  visit "/search/advanced?taxons=/taxon&content_purpose_supergroup=news_and_communications"
end

When(/^I search by taxon, supergroup and subgroups$/) do
  visit "/search/advanced?taxons=/taxon&content_purpose_supergroup=news_and_communications&content_purpose_subgroup[]=news&content_purpose_subgroup[]=updates_and_alerts"
end

Then(/^I only see documents tagged to the taxon$/) do
  @results.each do |result|
    expect(page).to have_title("Taxon - GOV.UK")
    expect(page).to have_link("Taxon", "/taxon")
    expect(page).to have_link(result["title_with_highlighting"], href: result["link"])
  end
end

Then(/^I only see documents tagged to the taxon within the supergroup$/) do
  @results.each do |result|
    expect(page).to have_title("News and communications - GOV.UK")
    expect(page).to have_link("Taxon", "/taxon")
    expect(page).to have_text("1 result in updates and alerts, news, and speeches and statements")
    expect(page).to have_link(result["title_with_highlighting"], href: result["link"])
  end
end

Then(/^I only see documents tagged to the taxon within the supergroup and subgroups$/) do
  @results.each do |result|
    expect(page).to have_title("News and communications - GOV.UK")
    expect(page).to have_link("Taxon", "/taxon")
    expect(page).to have_text("1 result in updates and alerts or news")
    expect(page).to have_link(result["title_with_highlighting"], href: result["link"])
  end
end
