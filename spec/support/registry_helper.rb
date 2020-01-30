module RegistrySpecHelper
  def stub_people_registry_request
    stub_request(:get, "http://search.dev.gov.uk/search.json")
        .with(query: {
            count: 0,
            facet_people: "1500,examples:0,order:value.title",
        })
        .to_return(body: {
            results: [],
            facets: {
                people: {
                    options: [
                        {
                            value: {
                                title: "Albus Dumbledore",
                                slug: "albus-dumbledore",
                                _id: "a field that we're not using",
                                content_id: "content_id_for_albus-dumbledore",
                            },
                        },
                        {
                            value: {
                                title: "Cornelius Fudge",
                                slug: "cornelius-fudge",
                                _id: "a field that we're not using",
                                content_id: "content_id_for_cornelius-fudge",

                            },
                        },
                        {
                            value: {
                                title: "Harry Potter",
                                slug: "harry-potter",
                                _id: "a field that we're not using",
                                content_id: "content_id_for_harry-potter",
                            },
                        },
                        {
                            value: {
                                title: "Ron Weasley",
                                slug: "ron-weasley",
                                _id: "a field that we're not using",
                                content_id: "content_id_for_ron-weasley",
                            },
                        },
                        {
                            value: {
                                title: "Rufus Scrimgeour",
                                slug: "rufus-scrimgeour",
                                _id: "/government/people/rufus-scrimgeour",
                                content_id: "content_id_for_rufus-scrimgeour",
                            },
                        },
                    ],
                },
            },
        }.to_json)
  end

  def stub_roles_registry_request
    stub_request(:get, "http://search.dev.gov.uk/search.json")
        .with(query: {
            count: 0,
            facet_roles: "1500,examples:0,order:value.title",
        })
        .to_return(body: {
            results: [],
            facets: {
                roles: {
                    options: [
                        {
                            value: {
                                title: "Prime Minister",
                                slug: "prime-minister",
                                _id: "a field that we're not using",
                                content_id: "content_id_for_prime-minister",
                            },
                        },
                    ],
                },
            },
        }.to_json)
  end

  def stub_organisations_registry_request
    stub_request(:get, "http://search.dev.gov.uk/search.json")
    .with(query: {
      count: 1500,
      fields: %w(slug title acronym content_id),
      filter_format: %(organisation),
      order: "title",
    })
    .to_return(body: { results: [
      {
        "title": "Closed organisation: Death Eaters",
        "slug": "death-eaters",
        "_id": "/government/organisations/death-eaters",
        "content_id": "content_id_for_death-eaters",
      },
      {
        "title": "Department of Mysteries",
        "slug": "department-of-mysteries",
        "_id": "/government/organisations/department-of-mysteries",
        "content_id": "content_id_for_department-of-mysteries",
      },
      {
        "title": "Gringots",
        "acronym": "GRI",
        "slug": "gringots",
        "_id": "/government/organisations/gringots",
        "content_id": "content_id_for_gringots",
      },
      {
        "title": "Ministry of Magic",
        "slug": "ministry-of-magic",
        "acronym": "MOM",
        "_id": "a field that we're not using",
        "content_id": "content_id_for_ministry-of-magic",
      },
    ] }.to_json)
  end

  def stub_manuals_registry_request
    stub_request(:get, "http://search.dev.gov.uk/search.json")
      .with(query: {
          filter_document_type: %w(manual service_manual_homepage service_manual_guide),
          fields: %w(title),
          count: 1500,
      })
      .to_return(body: {
        results: [
          {
              title: "Replacing bristles in your Nimbus 2000",
              _id: "/guidance/care-and-use-of-a-nimbus-2000",
          },
          {
              title: "Upgrading the baud rate on the Floo Network",
              _id: "upgrading-baud-rate-on-the-floo-network",
          },
          {
            title: "How to be a Wizard",
            _id: "how-to-be-a-wizard",
          },
        ],
      }.to_json)
  end
end
