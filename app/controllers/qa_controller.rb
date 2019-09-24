class QaController < ApplicationController
  layout "finder_layout"

  before_action do
    expires_in(5.minutes, public: true)
  end

  def show
    redirect_to_finder if finder_page?
    raw_finder
  end

private

  def qa_config
    @qa_config ||= YAML.load_file("lib/#{request.path.tr('-', '_')}.yaml")
  end

  def slug
    qa_config["finder_base_path"]
  end

  def raw_finder
    # FIXME: stop caching this once the app has migrated to AWS
    @raw_finder ||= begin
      item_hash = Services.cached_content_item(slug)

      item_hash.with_indifferent_access
    end
  end

  def facets
    @facets ||= begin
      valid_types = %w[text content_id]
      raw_facets.select do |facet|
        valid_types.include?(facet["type"]) && facet["filterable"] && qa_config["pages"][facet["key"]]["show_in_qa"]
      end
    end
  end

  def raw_facets
    @raw_facets ||= FacetExtractor.new(ContentItem.new(raw_finder)).extract
  end

  def page
    params.permit(:page)
    params[:page].to_i.clamp(1, facets.length + 1)
  end

  def question_type
    @question_type ||= qa_config["pages"][current_facet["facet"]["key"]]["question_type"]
  end

  def title
    qa_config["title"]
  end
  helper_method :title

  def breadcrumbs
    [{ title: "Home", url: "/" }]
  end
  helper_method :breadcrumbs

  def current_facet
    current_facet = facets[page - 1]
    current_facet_config = qa_config["pages"][current_facet["key"]]
    config = {
      "question" => current_facet_config["question"],
      "description" => current_facet_config["description"],
      "hint_title" => current_facet_config["hint_title"],
      "hint_text" => current_facet_config["hint_text"],
      "facet" => current_facet,
    }
    config.merge!("custom_options" => current_facet_config["custom_options"]) if current_facet_config["custom_options"].present?

    config
  end
  helper_method :current_facet

  def single_wrapped_question?
    question_type == "single_wrapped"
  end
  helper_method :single_wrapped_question?

  def multiple_grouped_question?
    question_type == "multiple_grouped"
  end
  helper_method :multiple_grouped_question?

  def multiple_question?
    question_type == "multiple"
  end
  helper_method :multiple_question?

  def facet_grouped_allowed_values
    @facet_grouped_allowed_values ||= current_facet["facet"]["allowed_values"].group_by { |filter| filter["value"] }
  end

  def custom_options?
    question_type == "single" && current_facet["custom_options"].present?
  end

  def options
    if custom_options?
      return current_facet["custom_options"].map do |option|
        { label: option["label"], text: option["label"], value: option["value"] }
      end
    end
    allowed_values = current_facet["facet"]["allowed_values"]
    allowed_values.map do |option|
      { label: option["label"], text: option["label"], value: option["value"] }
    end
  end
  helper_method :options

  def filter_groups
    @filter_groups ||= qa_config["pages"][current_facet["facet"]["key"]]["filter_groups"]
  end
  helper_method :filter_groups

  def nested_options(filter_group)
    filter_group["filters"].map do |filter|
      {
        label: facet_grouped_allowed_values[filter][0]["label"],
        value: filter,
      }
    end
  end
  helper_method :nested_options

  def next_page
    page + 1
  end
  helper_method :next_page

  def finder_page?
    page == facets.length + 1
  end

  def next_page_url
    qa_config["base_path"]
  end
  helper_method :next_page_url

  def redirect_to_finder
    redirect_to qa_config["finder_base_path"] + "?" + filtered_params.to_query
  end

  def skip_link_url
    page_number = { page: next_page }
    next_page_url + "?" + filtered_params.merge(page_number).to_query
  end
  helper_method :skip_link_url

  def filtered_params
    params = permitted_params

    facet_keys = facets.map { |facet| facet["key"] }

    rejected_keys = facet_keys.select do |facet_key|
      params["#{facet_key}-yesno"] == "no"
    end

    params.except(*rejected_keys)
  end
  helper_method :filtered_params

  def permitted_params
    permitted_yesnos = facets.map { |facet| :"#{facet["key"]}-yesno" }

    permitted_keys = facets.each_with_object({}) do |facet, keys|
      keys[facet["key"]] = []
    end

    params.permit(*permitted_yesnos, permitted_keys)
  end
end
