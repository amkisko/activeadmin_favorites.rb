# Form UX: quick save, published asterisk, macros JSON toggle

## Participants

Andrei Makarov

## Decisions

- Prefer star quick-create with suggested name over a name prompt (lens still prompts). Keep the full form for Edit favorite and as the no-JS fallback href on the star.
- Make "Published for everyone" optional in the form; normalize nil to false; drop the inclusion validator.
- Toggle JSON visibility and disable templates when "Edit macros as JSON" is checked.
- Omit Dynamic filters and Advanced macros on create when no date ranges are detected.
- Call `assign_new_favorite_defaults` from `build_resource` so star fallback params populate the form.

## Effects

Reproduction before fix:

1. Star on a filtered index always opened the full new form; note, publish, and macros were required desk steps for a private save.
2. "Published for everyone" showed Formtastic `*` because `validates :published, inclusion: {in: [true, false]}` marks the field required.
3. "Edit macros as JSON" changed only submit behavior; the JSON textarea stayed visible, so the checkbox looked broken.
4. New form with path and query string params did not receive defaults via `build_resource`, so the star fallback form could lose filter context.

After fix:

- Star POST to `quick_create` builds a private `FiltersFavorite` with `Favorite.suggested_name`, then redirects to the filtered index.
- Published checkbox is optional in the form; model normalizes nil to false; inclusion validator removed.
- Macro JSON field starts hidden/disabled; advanced checkbox reveals it and disables template controls.
- Create with no detected ranges omits Dynamic filters and Advanced macros panels.
- `build_resource` calls `assign_new_favorite_defaults` before form attributes.

## Next

- Tag and publish `0.1.10` with `make release`.
- Host adopt steps: `docs/issues/20261104154500_form-ux-quick-save-macros-published.md`.

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
