# Favorites create: hidden required destination fields

## Decisions

- Root cause: create form always rendered `path` and `resource_key` as hidden inputs, so a blank `new` page could not supply values required by presence validation.
- When both `path` and `resource_key` are present (star / contextual create), keep them hidden.
- When either is missing, show editable `path`, optional `query_string`, and `resource_key`; keep `kind` and `action` as hidden defaults.
- Do not refuse the blank URL; make the form completable on that place.
- Contextual star handoff and `quick_create` stay the preferred happy path.

## Effects

- Form branch in `register_favorites.rb` switches hidden vs editable destination fields from record values.
- Request specs cover blank `new`, contextual hidden prefills, successful create from supplied destination fields, and 422 redisplay when destination is still blank.

## Next

- Tag and publish `0.2.1` with `make release`.
- Hosts: `bundle update --conservative activeadmin_favorites` after that release.

## Source

- `docs/changelogs/20261123140400_importmap-desk-only-and-blank-create-fields.md`
- `lib/activeadmin/favorites/register_favorites.rb`
- `spec/requests/favorite_blank_create_spec.rb`
