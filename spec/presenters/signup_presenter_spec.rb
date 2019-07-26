require "spec_helper"

describe SignupPresenter do
  include FixturesHelper

  describe '#choices' do
    it 'returns an empty array when there are no facets to choose from' do
      content_item = {
        "details" => {
          "email_signup_choice" => [],
        }
      }
      expect(SignupPresenter.new(content_item, {}).choices).to eq([])
    end
  end
end
