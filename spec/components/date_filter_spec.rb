require "spec_helper"

describe "components/_date_filter", type: :view do
  it "returns nothing when no key or name provided" do
    render
    expect(rendered).to eql("")
  end

  it "returns two text fields with associated labels when key and name provided" do
    render partial: "components/date_filter", locals: { key: "key", name: "name" }

    expect(rendered).to have_css("#key")

    expect(rendered).to have_field("key\[to\]")
    expect(rendered).to have_field("key\[from\]")

    expect(rendered).to have_css("label[for='key\[to\]']", text: "name before")
    expect(rendered).to have_css("label[for='key\[from\]']", text: "name after")
  end

  it "prefills user values" do
    render partial: "components/date_filter", locals: { from_value: "user from", to_value: "user to", key: "key", name: "name" }

    expect(rendered).to have_css("input[name='key\[to\]'][value='user to']")
    expect(rendered).to have_css("input[name='key\[from\]'][value='user from']")
  end

  it "displays an error if it's passed an error message" do
    render partial: "components/date_filter",
           locals: {
             from_value: "user from",
             to_value: "user to",
             key: "key",
             name: "name",
             date_errors_from: "error message",
           }
    expect(rendered).to have_css(".gem-c-error-message")
  end

  it "does not display error if it isn't passed an error message" do
    render partial: "components/date_filter",
           locals: {
             from_value: "user from",
             to_value: "user to",
             key: "key",
             name: "name",
             date_errors_from: nil,
           }
    expect(rendered).to have_no_css(".gem-c-error-message")
  end
end
