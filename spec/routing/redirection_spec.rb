require "spec_helper"

RSpec.describe "Redirecting", type: :routing do
  context "coronavirus topical event searches" do
    it "sends coronavirus topical event to a redirect (array params)" do
      expect(
        get: "/any-old-finder?topical_events[]=coronavirus-covid-19-uk-government-response",
      ).to route_to(
        controller: "redirection",
        action: "redirect_covid",
        slug: "any-old-finder",
        topical_events: %w[coronavirus-covid-19-uk-government-response],
      )
    end

    it "sends coronavirus topical event to a redirect (string params)" do
      expect(
        get: "/any-old-finder?topical_events=coronavirus-covid-19-uk-government-response",
      ).to route_to(
        controller: "redirection",
        action: "redirect_covid",
        slug: "any-old-finder",
        topical_events: "coronavirus-covid-19-uk-government-response",
      )
    end

    it "ignores other topical events" do
      expect(
        get: "/any-old-finder?topical_events[]=talk-like-a-pirate-day",
      ).to route_to(
        controller: "finders",
        action: "show",
        slug: "any-old-finder",
        topical_events: ["talk-like-a-pirate-day"],
      )
    end

    it "includes other params too" do
      expect(
        get: "/any-old-finder?keywords=bernard&topical_events[]=coronavirus-covid-19-uk-government-response&organisations[]=ministry-of-pirates",
      ).to route_to(
        controller: "redirection",
        action: "redirect_covid",
        slug: "any-old-finder",
        keywords: "bernard",
        organisations: %w[ministry-of-pirates],
        topical_events: %w[coronavirus-covid-19-uk-government-response],
      )
    end

    it "ignores atom feeds" do
      expect(
        get: "/any-old-finder.atom?keywords=bernard&topical_events[]=coronavirus-covid-19-uk-government-response&organisations[]=ministry-of-pirates",
      ).to route_to(
        format: "atom",
        controller: "finders",
        action: "show",
        slug: "any-old-finder",
        keywords: "bernard",
        organisations: %w[ministry-of-pirates],
        topical_events: %w[coronavirus-covid-19-uk-government-response],
      )
    end
  end
end
