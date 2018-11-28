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
      title link description public_timestamp
      content_purpose_supergroup
      content_store_document_type organisations
      content_purpose_subgroup part_of_taxonomy_tree
    ).join(","),
    "order" => "-public_timestamp",
    "reject_content_store_document_type" => %w[browse],
  )

  case categorisation.strip
  when /^in supergroup '(\w+)'$/
    search_params["filter_content_store_document_type"] = GovukDocumentTypes.supergroup_document_types($1)
  when /^in supergroup '(\w+)' and subgroups '([\w,]+)'$/
    search_params["filter_content_store_document_type"] = GovukDocumentTypes.subgroup_document_types(*$2.split(","))
  end

  rummager_advanced_search_url = rummager_url(search_params)

  stub_request(:get, rummager_advanced_search_url).to_return(
    body: {
      results: @results,
      total: 2,
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

When(/^I filter by taxon alone$/) do
  visit "/search/advanced?topic=/taxon"
end

When(/^I filter by content purpose supergroup alone$/) do
  visit "/search/advanced?group=news_and_communications"
end

When(/^I filter by taxon and by supergroup$/) do
  visit "/search/advanced?topic=/taxon&group=news_and_communications"
end

When(/^I filter by taxon, supergroup and subgroups$/) do
  visit "/search/advanced?topic=/taxon&group=news_and_communications&subgroup[]=news&subgroup[]=updates_and_alerts"
end

Then(/^I only see documents tagged to the taxon tree within the supergroup$/) do
  @results.each do |result|
    expect(page).to have_title("News and communications - GOV.UK")
    expect(page).to have_link("Taxon", href: "/taxon")
    expect(page).to have_text("2 results")
    # expect(page).to have_text("2 results in updates and alerts, news, speeches and statements, and decisions")
    expect(page).to have_link(result["title_with_highlighting"], href: result["link"])
  end
end

Then(/^I only see documents tagged to the taxon tree within the supergroup and subgroups$/) do
  @results.each do |result|
    all_facet_tags = page.all(:css, "facet-tag")
    expect(page).to have_title("News and communications - GOV.UK")
    expect(page).to have_link("Taxon", href: "/taxon")
    expect(page).to have_text("2 results")
    # expect(page).to have_text("2 results in updates and alerts or news")
    expect(page).to have_link(result["title_with_highlighting"], href: result["link"])
  end
end

Then(/^The correct metadata is displayed for the search results$/) do
  expect(page).to have_css(".gem-c-document-list__attribute", text: "Guidance")
  expect(page).not_to have_css(".gem-c-document-list__attribute", text: "Guide")
end

Then(/^The page is not found$/) do
  expect(page.status_code).to eq(404)
end
