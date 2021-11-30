require "spec_helper"

RSpec.describe "Redirecting", type: :request do
  context "retiring the Brexit checker" do
    get_paths = %w[
      /transition-check/results
      /transition-check/questions
      /transition-check/email-signup
      /transition-check/save-your-results
      /transition-check/save-your-results/confirm
      /transition-check/saved-results
      /transition-check/edit-saved-results
    ]

    get_paths.each do |path|
      it "redirects a get of #{path} to the Brexit landing page" do
        get path
        expect(response).to redirect_to("/brexit")
      end
    end

    post_paths = %w[
      /transition-check/save-your-results/sign-up
      /transition-check/save-your-results/confirm
      /transition-check/email-signup
    ]

    post_paths.each do |path|
      it "redirects a post to #{path} to the Brexit landing page" do
        post path
        expect(response).to redirect_to("/brexit")
      end
    end
  end
end
