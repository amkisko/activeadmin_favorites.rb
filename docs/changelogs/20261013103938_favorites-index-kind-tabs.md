## Decisions

Render favorites index kind navigation with Arbre `a` tags and an explicit `href`. Do not call `link_to` inside the ActiveAdmin/Arbre index block; that returned an array of HTML strings and printed Favorite::KINDS as page text.

## Effects

Kind tabs on /admin/favorites render as All, Filters, Lens, and Combined links. The raw `["filters", "lens", "combined"]` dump no longer appears. Request specs assert tab hrefs and reject the escaped KINDS inspect string.

## Next

Publish 0.1.3 via make release. See docs/changelogs/20261013104000_release-0-1-3.md.

## Source

- lib/activeadmin/favorites/register_favorites.rb
- spec/requests/admin_favorites_spec.rb
