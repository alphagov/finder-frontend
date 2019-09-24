require "spec_helper"
require "gds_api/test_helpers/content_store"

describe QaToContentController, type: :controller do
  include FixturesHelper
  render_views

  describe "GET show" do
    let(:uk_nationals_in_eu_yaml) { uk_nationals_in_eu_config }
    let(:question)                { uk_nationals_in_eu_yaml["questions"].first }
    let(:params)                  { {} }

    before do
      allow_any_instance_of(QaController).to receive(:qa_config).and_return(uk_nationals_in_eu_yaml)
      get :show, params: params
    end

    describe "viewing the question" do
      it "correctly renders a QA to Content page" do
        expect(response.status).to eq(200)
        expect(response).to render_template("qa_to_content/show")
      end

      it "renders the title" do
        expect(response.body).to include(uk_nationals_in_eu_yaml["title"])
      end

      it "renders the first question" do
        expect(response.body).to include(question["question"])
      end

      it "renders the first question hint" do
        expect(response.body).to include(question["hint"])
      end

      it "renders the options as radio buttons" do
        first_option = question["options"].first
        last_option = question["options"].last
        expect(response.body).to have_css(".govuk-radios__input[type='radio'][value='#{first_option['value']}']")
        expect(response.body).to have_css(".govuk-radios__input[type='radio'][value='#{last_option['value']}']")
      end
    end

    describe "submitting an option" do
      context "when the option is valid" do
        let(:params) { { question["id"] => question["options"].first["value"] } }

        it "redirects to the chosen option's URL" do
          expect(response).to redirect_to(question["options"].first["value"])
        end
      end

      context "when the option is invalid" do
        let(:params) { { question["id"] => "/non-matching-url" } }

        it "renders the question" do
          expect(response).to render_template("qa_to_content/show")
        end
      end
    end
  end
end
