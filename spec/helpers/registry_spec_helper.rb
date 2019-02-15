module RegistrySpecHelper
  def stub_people_registry_request
    stub_request(:get, "http://search.dev.gov.uk/search.json")
    .with(query: {
        count: 1500,
        start: 0,
        fields: %w(slug title),
        filter_format: %(person),
    })
    .to_return(body: { results: [
        {
          "title": "Harry Potter",
          "slug": "harry-potter",
          "_id": "a field that we're not using"
        },
        {
          "title": "Albus Dumbledore",
          "slug": "albus-dumbledore",
          "_id": "a field that we're not using"
        },
        {
          "title": "Ron Weasley",
          "slug": "ron-weasley",
          "_id": "a field that we're not using"
        },
        {
          "title": "Cornelius Fudge",
          "slug": "cornelius-fudge",
          "_id": "a field that we're not using"
        },
        {
          "title": "Rufus Scrimgeour",
          "slug": "rufus-scrimgeour",
          "_id": "/government/people/rufus-scrimgeour"
        }
    ] }.to_json)
  end

  def stub_organisations_registry_request
    stub_request(:get, "http://search.dev.gov.uk/search.json")
    .with(query: {
      count: 1500,
      fields: %w(slug title acronym),
      filter_format: %(organisation),
    })
    .to_return(body: { results: [
        {
          "title": "Ministry of Magic",
          "slug": "ministry-of-magic",
          "acronym": "MOM",
          "_id": "a field that we're not using"
        },
        {
          "title": "Gringots",
          "acronym": "GRI",
          "slug": "gringots",
          "_id": "/government/organisations/gringots"
        },
        {
          "title": "Department of Mysteries",
          "slug": "department-of-mysteries",
          "_id": "/government/organisations/department-of-mysteries"
        }
    ] }.to_json)
  end
end
