# Importmap: desk Stimulus pins on application map

## Decisions

- Pin Favorites Stimulus controllers only onto `ActiveAdmin.importmap`.
- Do not draw those pins onto `Rails.application.importmap`.
- Keep asset precompile and importmap cache sweepers unchanged.

## Effects

- Engine initializer `activeadmin_favorites.importmap` draws pins onto the Active Admin map only.
- Spec asserts the three controller keys are present on `ActiveAdmin.importmap` and absent from `Rails.application.importmap`.

## Next

- Tag and publish `0.2.1` with `make release`.
- Hosts that redraw the application importmap after boot to strip these pins can drop that favorites-specific rationale once they upgrade.

## Source

- `docs/changelogs/20261123140400_importmap-desk-only-and-blank-create-fields.md`
- `lib/activeadmin/favorites/engine.rb`
- `spec/lib/activeadmin/favorites/importmap_spec.rb`
