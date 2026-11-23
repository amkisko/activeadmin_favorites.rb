# Importmap desk-only pins and blank create destination fields

## Decisions

- Stop dual-pinning Favorites Stimulus controllers onto `Rails.application.importmap`; pin only `ActiveAdmin.importmap`.
- Fix blank Favorites create by exposing editable `path` and `resource_key` when those values are not prefilled; keep hidden prefills for the star contextual path.

## Effects

- `engine.rb` importmap initializer draws the three controller pins onto Active Admin only.
- `register_favorites.rb` form: if `new_record?` and both `path` and `resource_key` present, hidden destination fields; otherwise editable path, query string, and resource key with hidden kind/action defaults.
- Specs: `spec/lib/activeadmin/favorites/importmap_spec.rb`, `spec/requests/favorite_blank_create_spec.rb`.
- `CHANGELOG.md` Unreleased bullets for both outcomes.

## Next

- Publish `0.2.1` with `make release` (see `docs/changelogs/20261123141400_release-0-2-1.md`).
- Hosts upgrade and may drop favorites-specific application importmap redraw once on `0.2.1`.

## Source

- `docs/issues/20261123140400_application-importmap-desk-pins.md`
- `docs/issues/20261123140401_favorites-blank-create-required-fields.md`
