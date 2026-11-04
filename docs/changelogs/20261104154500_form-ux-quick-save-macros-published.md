# Form UX: quick save, published asterisk, macros JSON toggle

## Participants

Andrei Makarov

## Decisions

- Fix three desk frictions on filter-favorite create/edit after the star opens the form flow in `0.1.9`.
- Prefer star quick-create with suggested name over a name prompt (lens still prompts). Keep full form for Edit favorite and as no-JS fallback href on the star.
- Prefer checkbox (a): toggle JSON visibility and disable templates when "Edit macros as JSON" is checked.

## Effects

Reproduction before fix:

1. Star on a filtered index always opened the full new form; note, publish, and macros were required desk steps for a private save.
2. "Published for everyone" showed Formtastic `*` because `validates :published, inclusion: {in: [true, false]}` marks the field required.
3. "Edit macros as JSON" changed only submit behavior; the JSON textarea stayed visible, so the checkbox looked broken.
4. New form with path/query query params did not receive defaults via `build_resource`, so the star fallback form could lose filter context.

After fix:

- Star POST `quick_create` builds a private `FiltersFavorite` with `Favorite.suggested_name`, redirects to the filtered index.
- Published checkbox is optional in the form; model normalizes nil to false; inclusion validator removed.
- Macro JSON field starts hidden/disabled; advanced checkbox reveals it and disables template controls.
- Create with no detected ranges omits Dynamic filters and Advanced macros panels.
- `build_resource` calls `assign_new_favorite_defaults` before form attributes.

## Next

- Tag and publish `0.1.10` with `make release`.
- Host adopt after publish.

## Source

- `lib/activeadmin/favorites/register_favorites.rb`
- `lib/activeadmin/favorites/install.rb`
- `app/views/active_admin/favorites/_macro_fields.html.erb`
- `app/views/active_admin/favorites/_filter_favorite_button.html.erb`
- `app/assets/controllers/activeadmin_favorites/filter_favorite_controller.js`
- `app/assets/controllers/activeadmin_favorites/macro_fields_controller.js`
- `app/models/active_admin/favorites/favorite.rb`
- `spec/requests/favorite_form_ux_spec.rb`
- `spec/requests/filter_favorite_quick_create_spec.rb`
