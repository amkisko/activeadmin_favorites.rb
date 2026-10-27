## Participants

Andrei Makarov (@amkisko)

## Decisions

Embed lens catalog JSON with `raw json_escape(catalog_payload.to_json)` inside the `application/json` script tag so `JSON.parse(element.textContent)` receives real JSON. Reorder engine view paths so this gem's resource index/show templates override ActiveAdmin's and still inject the catalog after the table render, while host `app/views` stays first.

## Effects

Personalize page catalog entries parse in the browser again. Index and show pages emit `favorites-lens-catalog-*` script tags under the default ActiveAdmin view path order. Labels that contain `</script>` stay escaped as JSON unicode escapes.

## Next

Publish 0.1.4 via make release. See docs/changelogs/20261026173208_release-0-1-4.md.

## Source

- app/views/active_admin/favorites/_lens_catalog_data.html.erb
- lib/activeadmin/favorites/view_paths.rb
- lib/activeadmin/favorites/engine.rb
- spec/requests/lens_catalog_data_spec.rb
- spec/views/active_admin/favorites/lens_catalog_data_spec.rb
- spec/lib/activeadmin/favorites/view_paths_spec.rb
