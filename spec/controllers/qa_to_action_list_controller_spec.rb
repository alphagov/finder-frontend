require 'spec_helper'

describe QaToActionListController, type: :controller do
  include FixturesHelper
  render_views

  describe "GET show" do
    let(:prepare_everyone_uk_leaving_eu_yaml) { prepare_everyone_uk_leaving_eu_config }
    let(:questions)                           { prepare_everyone_uk_leaving_eu_yaml["questions"] }
    let(:current_question)                    { questions.first }
    let(:params)                              { {} }

    before do
      allow_any_instance_of(QaToActionListController).to receive(:qa_config).and_return(prepare_everyone_uk_leaving_eu_yaml)
      get :show, params: params
    end

    describe "Q&A page" do
      let(:base_path)        { prepare_everyone_uk_leaving_eu_yaml["base_path"] }
      let(:result_base_path) { prepare_everyone_uk_leaving_eu_yaml["result_base_path"] }

      it "correctly renders a Q&A page" do
        get :show
        expect(response.status).to eq(200)
      end

      context "on the first page" do
        before { get :show }

        it "sets a robots no-index metatag" do
          expect(response.body).to include('<meta name="robots" content="noindex">')
        end

        it "renders the first facet's question" do
          expect(response.body).to include(current_question["question"])
        end

        it "renders the description" do
          expect(response.body).to include(current_question["description"])
        end

        it "renders the hint text" do
          expect(response.body).to include(current_question["hint_text"])
        end

        it "sets next_page_url to itself" do
          expect(response.body).to have_css("form#finder-qa-facet-filter-selection[action='#{base_path}']")
        end

        it "sets skips_url_link to page 2" do
          expect(response.body).to have_link("Skip this question", href: "#{base_path}?page=2")
        end
      end
    end
  end
end
