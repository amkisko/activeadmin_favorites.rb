# frozen_string_literal: true

require "rails_helper"

RSpec.describe "active_admin/favorites/lens_catalog_data" do
  let(:resource_config) do
    instance_double(
      ActiveAdmin::Resource,
      resource_name: double(route_key: "articles")
    )
  end

  let(:catalog_payload) do
    [
      {id: "title", label: "Title with </script>", group: "columns"},
      {id: "details", label: "Details", group: "panels"}
    ]
  end

  def render_catalog_partial
    allow(ActiveAdmin::Favorites::ViewLens::Applicator).to receive(:catalog_payload)
      .and_return(catalog_payload)

    view = ActionView::Base.with_empty_template_cache.with_view_paths(
      [ActiveAdmin::Favorites::Engine.root.join("app/views")],
      {}
    )
    view.extend(ActionView::Helpers::OutputSafetyHelper)
    view.extend(ActionView::Helpers::JavaScriptHelper)
    config = resource_config
    view.define_singleton_method(:active_admin_config) { config }

    view.render(
      partial: "active_admin/favorites/lens_catalog_data",
      locals: {action_name: "show", render_context: nil}
    )
  end

  it "emits script JSON that JSON.parse accepts without HTML entity decoding", :aggregate_failures do
    html = render_catalog_partial
    match = html.match(
      %r{id="favorites-lens-catalog-articles-show"[^>]*>(.*?)</script>}m
    )

    expect(match).to be_present, "expected catalog script in #{html.inspect}"
    script_body = match[1]
    expect(script_body).not_to include("&quot;")

    catalog = JSON.parse(script_body)
    expect(catalog).to eq(
      [
        {"id" => "title", "label" => "Title with </script>", "group" => "columns"},
        {"id" => "details", "label" => "Details", "group" => "panels"}
      ]
    )
    expect(script_body).to include('\u003c/script\u003e')
  end
end
