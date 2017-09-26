require 'spec_helper'

describe 'components/_date-filter.html.erb', type: :view do
  it "returns nothing when no key or name provided" do
    render
    expect(rendered).to eql('')
  end

  it "returns two text fields with associated labels when key and name provided" do
    render partial: 'components/date-filter', locals: { key: 'key', name: 'name' }

    expect(rendered).to have_selector(".app-c-date-filter")

    expect(rendered).to have_selector("input[name='key\[to\]']")
    expect(rendered).to have_selector("input[name='key\[from\]']")

    expect(rendered).to have_selector("label[for='key\[to\]']", text: 'name before')
    expect(rendered).to have_selector("label[for='key\[from\]']", text: 'name after')
  end

  it "adds aria-controls data attributes when specified" do
    render partial: 'components/date-filter', locals: { aria_controls_id: 'controls', key: 'key', name: 'name' }

    expect(rendered).to have_selector(".app-c-date-filter[data-module='enable-aria-controls']")
    expect(rendered).to have_selector("[data-aria-controls='controls']", count: 2)
  end

  it "prefills user values" do
    render partial: 'components/date-filter', locals: { from_value: 'user from', to_value: 'user to', key: 'key', name: 'name' }

    expect(rendered).to have_selector("input[name='key\[to\]'][value='user to']")
    expect(rendered).to have_selector("input[name='key\[from\]'][value='user from']")
  end

  it "includes help text with unique ID based on key" do
    render partial: 'components/date-filter', locals: { key: 'key', name: 'name' }

    expect(rendered).to have_selector("#date-help-text-key")
    expect(rendered).to have_selector("[aria-describedby='date-help-text-key']")
  end
end
