require 'spec_helper'
require 'gds_api/test_helpers/content_store'

describe QaController, type: :controller do
  include GdsApi::TestHelpers::ContentStore
  include FixturesHelper
  include GovukContentSchemaExamples
  render_views
  ENV["FINDER_FRONTEND_ENABLE_QA"] = "true"

  describe "GET show" do
    let(:aaib_reports_finder)         { aaib_reports_content_item }
    let(:aaib_reports_qa_config_yaml) { aaib_reports_qa_config }
    let(:aaib_reports_finder_facets) do
      aaib_reports_finder["details"]["facets"].select do |facet|
        facet["type"] == "text" && facet["filterable"] && aaib_reports_qa_config_yaml["pages"][facet["key"]]["show_in_qa"]
      end
    end

    before { allow_any_instance_of(QaController).to receive(:qa_config).and_return(aaib_reports_qa_config_yaml) }

    describe "a finder content item exists" do
      let(:base_path)        { aaib_reports_qa_config_yaml["base_path"] }
      let(:finder_base_path) { aaib_reports_qa_config_yaml["finder_base_path"] }

      before do
        content_store_has_item(
          "/aaib-reports",
          aaib_reports_finder
        )
      end

      it "correctly renders a finder Q&A page" do
        get :show
        expect(response.status).to eq(200)
        expect(response).to render_template("qa/show")
      end

      context "on the first page" do
        before { get :show }

        it "renders the first facet's question" do
          expect(response.body).to include(aaib_reports_qa_config_yaml["pages"][aaib_reports_finder_facets.first["key"]]["question"])
        end

        it "renders the description" do
          expect(response.body).to include(aaib_reports_qa_config_yaml["pages"][aaib_reports_finder_facets.first["key"]]["description"])
        end

        it "renders the hint text" do
          expect(response.body).to include(aaib_reports_qa_config_yaml["pages"][aaib_reports_finder_facets.first["key"]]["hint_text"])
        end

        it "renders the correct nested filter options" do
          expect(response.body).to include(aaib_reports_qa_config_yaml["pages"][aaib_reports_finder_facets.first["key"]]["filter_groups"].last["name"])
          expect(response.body).to include(aaib_reports_qa_config_yaml["pages"][aaib_reports_finder_facets.first["key"]]["filter_groups"].last["filters"].first)
        end

        it "sets next_page_url to itself" do
          expect(response.body).to have_css("form#finder-qa-facet-filter-selection[action='#{base_path}']")
        end

        it "sets skips_url_link to page 2" do
          expect(response.body).to have_link("Skip this question", href: "#{base_path}?page=2")
        end
      end

      context "on the last page" do
        before { get:show, params: { page: aaib_reports_finder_facets.count } }

        it "renders the last facet's question" do
          expect(response.body).to include(aaib_reports_qa_config_yaml["pages"][aaib_reports_finder_facets.last["key"]]["question"])
        end

        it "does not render the description" do
          expect(response.body).not_to include(aaib_reports_qa_config_yaml["pages"][aaib_reports_finder_facets.first["key"]]["description"])
        end

        it "does not render the hint text" do
          expect(response.body).not_to include(aaib_reports_qa_config_yaml["pages"][aaib_reports_finder_facets.first["key"]]["hint_text"])
        end

        it "renders the yes and no radio buttons" do
          values = aaib_reports_finder_facets.last['allowed_values']
          first_value = values.first['value']
          last_value = values.last['value']
          expect(response.body).to have_css("form#finder-qa-facet-filter-selection input[type='radio'][value='#{first_value}']")
          expect(response.body).to have_css("form#finder-qa-facet-filter-selection input[type='radio'][value='#{last_value}']")
        end

        it "renders the correct filter options under the yes radio button" do
          within("div.govuk-radios__conditional") do
            expect(response.body).to include(aaib_reports_finder_facets.second["allowed_values"].first["label"])
          end
        end

        it "sets next_page_url to the parent finder" do
          expect(response.body).to have_css("form#finder-qa-facet-filter-selection[action='#{finder_base_path}']")
        end

        it "sets skips_url_link to the parent finder without a page param" do
          expect(response.body).to have_link("Skip this question", href: "#{finder_base_path}?")
        end
      end

      describe "previous selections" do
        let(:facet_key)     { aaib_reports_finder_facets.first["key"] }
        let(:filters)       { aaib_reports_finder_facets.first["allowed_values"] }
        let(:first_filter)  { filters.first["value"] }
        let(:last_filter)   { filters.last["value"] }
        let(:params)        { { page: aaib_reports_finder_facets.count, facet_key => [first_filter, last_filter] } }

        before do
          get :show, params: params
        end

        it "remembers previous selections on each page" do
          expect(response.body).to have_css("input[type='hidden'][name='#{facet_key}[]'][value='#{first_filter}']", visible: false)
          expect(response.body).to have_css("input[type='hidden'][name='#{facet_key}[]'][value='#{last_filter}']", visible: false)
        end

        it "sets the skip_url_link to the parent finder with the previous selections" do
          selection_params = "?#{facet_key}%5B%5D=#{first_filter}&#{facet_key}%5B%5D=#{last_filter}"
          expect(response.body).to have_link("Skip this question", href: finder_base_path + selection_params)
        end

        context "with a no radio button" do
          let(:yesno_facet_key) { aaib_reports_finder_facets.second["key"] }
          let(:params) do
            {
              page: aaib_reports_finder_facets.count,
              facet_key => [first_filter, last_filter],
              "#{yesno_facet_key}-yesno" => "no",
              yesno_facet_key => [first_filter, last_filter]
            }
          end

          it "doesn't include facets that are no" do
            expect(response.body).not_to have_css("input[type='hidden'][name='#{yesno_facet_key}[]'][value='#{first_filter}']", visible: false)
            expect(response.body).not_to have_css("input[type='hidden'][name='#{yesno_facet_key}[]'][value='#{last_filter}']", visible: false)
          end
        end
      end
    end

    describe "finder item doesn't exist" do
      before do
        content_store_does_not_have_item("/aaib-reports")
        get :show
      end

      it "returns a 404, rather than 5xx" do
        expect(response.status).to eq(404)
      end
    end
  end
end
