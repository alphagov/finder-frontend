require 'rails_helper'

RSpec.describe EmailSignupPage do

  let(:schema_facets) { [] }
  let(:artefact_details_hash) {
    {
      'description' => 'Some description'
    }
  }
  let(:artefact) {
    double(:artefact,
      title: "My Title",
      details: artefact_details_hash
    )
  }

  subject(:signup_page) {
    EmailSignupPage.new(
      slug: double(:slug),
      artefact: artefact,
      schema_facets: schema_facets,
    )
  }

  it 'returns the artefact title as its own' do
    expect(signup_page.title).to eql('My Title')
  end

  it 'returns the artefact description detail as its body' do
    expect(signup_page.body).to eql('Some description')
  end

  it 'returns a facet collection as its facets' do
    expect(signup_page.facets).to be_a(FacetCollection)
  end
end
