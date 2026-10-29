# HTML head removal and Active Admin path detection

## Participants

Andrei Makarov (@amkisko)

## Decisions

- Resolve Active Admin views via `ActiveAdmin::Engine.root`, with a fallback regex that requires a digit after `activeadmin-` so sibling engines cannot match.
- Remove the gem `active_admin/_html_head` template. Hosts link `personalization_menu` themselves.
- Keep favorites views immediately before Active Admin for index/show catalog injection.

## Effects

- Reorder no longer short-circuits when an `activeadmin-*` sibling sits next to favorites.
- Stock Active Admin stylesheet name is no longer forced through a gem head copy.
- Dummy app head demonstrates the host stylesheet link for request coverage.

## Next

- Shipped as 0.1.8. See docs/changelogs/20261029153215_release-0-1-8.md.

## Source

- lib/activeadmin/favorites/view_paths.rb
- README.md Stylesheet section
- spec/lib/activeadmin/favorites/view_paths_spec.rb
