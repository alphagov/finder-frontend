# typed: true
# This class currently supports only one question
# If there is a need for multiple questions, this class needs to be modified

class QaToContentController < ApplicationController
  layout "finder_layout"

  def show
    return redirect_to content_url if redirect_to_content?

    render "qa_to_content/show"
  end

private

  def qa_config
    @qa_config ||= YAML.load_file("lib/#{request.path.tr('-', '_')}.yaml")
  end

  def title
    qa_config["title"]
  end
  helper_method :title

  def breadcrumbs
    [{ title: "Home", url: "/" }]
  end
  helper_method :breadcrumbs

  def question
    @question ||= qa_config["questions"].first
  end
  helper_method :question

  def content_url
    @content_url ||= params[question["id"]]
  end

  def format_options(options)
    options.map do |option|
      return option if option.is_a? String

      { text: option["text"], value: option["value"] }
    end
  end
  helper_method :format_options

  def content_url_valid?
    question["options"].any? do |option|
      option["value"] == content_url
    end
  end

  def redirect_to_content?
    content_url.present? && content_url_valid?
  end
end
