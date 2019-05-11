# The PublishingComponentsHelper module is responsible for rendering
# ERB partials (particularly govuk_publishing_components) as HTML for use
# in both JSON and HTML responses. It's a bit of glue code we can remove
# with the introduction of a show.json.erb template file.
module PublishingComponentsHelper
  def component_to_html(component:, locals: {})
    return unless can_render_component_html?

    render_to_string(partial: component, locals: locals, formats: %w[html])
  end

private

  def can_render_component_html?
    %w(html json).include? request.format
  end
end
