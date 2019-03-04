require 'spec_helper'

describe RedirectionController, type: :controller do
  it "redirects to the news-and-comms page" do
    get :announcements
    expect(response).to redirect_to finder_path('news-and-communications')
  end
  it 'passes on keywords params' do
    get :announcements, params: { keywords: %w[one two] }
    expect(response).to redirect_to finder_path('news-and-communications', params: { keywords: %w[one two] })
  end
  it 'converts taxons to level_one_taxon and converts array to string' do
    get :announcements, params: { taxons: %w[one] }
    expect(response).to redirect_to finder_path('news-and-communications', params: { level_one_taxon: 'one' })
  end
  it 'converts subtaxons to level_two_taxon and converts array to string' do
    get :announcements, params: { subtaxons: %w[two] }
    expect(response).to redirect_to finder_path('news-and-communications', params: { level_two_taxon: 'two' })
  end
  it 'passes on people params' do
    get :announcements, params: { people: %w[one two] }
    expect(response).to redirect_to finder_path('news-and-communications', params: { people: %w[one two] })
  end
  it 'converts departments into organisations' do
    get :announcements, params: { departments: %w[one two] }
    expect(response).to redirect_to finder_path('news-and-communications', params: { organisations: %w[one two] })
  end
  it 'passes on world_locations' do
    get :announcements, params: { world_locations: %w[one two] }
    expect(response).to redirect_to finder_path('news-and-communications', params: { world_locations: %w[one two] })
  end
  it 'converts from_date to public_timestamp[from]' do
    get :announcements, params: { from_date: '01/01/2014' }
    expect(response).to redirect_to finder_path('news-and-communications', params: { public_timestamp: { from: '01/01/2014' } })
  end
  it 'converts to_date to public_timestamp[to]' do
    get :announcements, params: { to_date: '01/01/2014' }
    expect(response).to redirect_to finder_path('news-and-communications', params: { public_timestamp: { to: '01/01/2014' } })
  end
end
