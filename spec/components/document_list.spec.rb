require "spec_helper"

describe "Document list", type: :view do
  def component_name
    "document_list"
  end

  def render_component(component_arguments)
    render partial: "components/#{component_name}", locals: component_arguments
  end

  def default
    {
      items: [
        {
          link: {
            text: "School behaviour and attendance: parental responsibility measures",
            path: "/government/publications/parental-responsibility-measures-for-behaviour-and-attendance",
          },
        },
      ],
    }
  end

  def with_parts
    {
      items: [
        {
          link: {
            text: "Item title",
            path: "/link",
          },
          parts: [
            {
              link: {
                text: "Part title",
                path: "part-link",
                description: "Part description",
              },
            },
          ],
        },
      ],
    }
  end

  def with_parts_no_link
    {
      items: [
        {
          link: {
            text: "Item title",
            path: "/link",
          },
          parts: [
            {
              link: {
                text: "Part title without link",
                description: "Part description",
              },
            },
          ],
        },
      ],
    }
  end

  it "does not render parts if they are not available" do
    render_component(default)
    expect(rendered).not_to have_selector(".gem-c-document-list__children")
  end

  it "renders parts if they are available" do
    render_component(with_parts)
    expect(rendered).to have_selector(".gem-c-document-list__children")
  end

  it "part contains a title" do
    render_component(with_parts)
    expect(rendered).to have_selector(".gem-c-document-list-child__link", text: "Part title")
  end

  it "part link contains a valid url" do
    render_component(with_parts)
    expect(rendered).to have_link "Part title", href: "/link/part-link"
  end

  it "part contains a description" do
    render_component(with_parts)
    expect(rendered).to have_selector(".gem-c-document-list-child__description", text: "Part description")
  end

  it "part renders a heading span if no link is provided" do
    render_component(with_parts_no_link)
    expect(rendered).to have_selector(".gem-c-document-list-child__heading", text: "Part title without link")
    expect(rendered).not_to have_selector(".gem-c-document-list-child__link")
  end
end
