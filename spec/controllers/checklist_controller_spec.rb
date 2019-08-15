require 'spec_helper'

describe ChecklistController, type: :controller do
  include FixturesHelper
  render_views

  describe "GET show" do
    let(:find_brexit_guidance_yaml) { find_brexit_guidance_config }
    let(:questions)                 { find_brexit_guidance_yaml["questions"] }
    let(:current_question)          { questions.first }
    let(:params)                    { {} }
    let(:base_path)                 { find_brexit_guidance_path }
    let(:results_page_base_path)    { find_brexit_guidance_results_path }

    before do
      allow_any_instance_of(ChecklistController).to receive(:qa_config).and_return(find_brexit_guidance_yaml)
      get :show, params: params
    end

    describe "Q&A page" do
      it "correctly renders a Q&A page" do
        get :show
        expect(response.status).to eq(200)
      end

      context "on a question page" do
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

        it "sets next_page_url to itself" do
          expect(response.body).to have_css("form#finder-qa-facet-filter-selection[action='#{base_path}']")
        end

        it "sets skips_url_link to page 2" do
          expect(response.body).to have_link("Skip this question", href: "#{base_path}?page=2")
        end
      end

      context "submitting final selections to the Q&A" do
        let(:params) { { page: questions.count + 1, last_facet_key: %w(first_filter last_filter) } }

        it "redirects to the results page" do
          expected_params = params.except(:page).to_query
          expect(response).to redirect_to("#{results_page_base_path}?#{expected_params}")
        end
      end
    end
  end
end
