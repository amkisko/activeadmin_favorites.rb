# Personalization menu stylesheet via Propshaft

## Participants

Andrei Makarov (@amkisko)

## Decisions

- Treat `personalization_menu.css` as a Propshaft stylesheet, not a Tailwind entry.
- Stop telling hosts to bare-`@import` the Propshaft logical path into the Active Admin CSS entrypoint. That fails when Tailwind CLI compiles a generated tmp input and resolves imports from the input directory.
- Link the stylesheet from the engine `active_admin/_html_head` partial. Hosts that override that partial must add `stylesheet_link_tag` themselves.
- Expose `ActiveAdmin::Favorites.personalization_menu_stylesheet_path` for hosts that concatenate the absolute file into a Tailwind CLI entry.

## Effects

- README Stylesheet section no longer documents the bare `@import` as the install path.
- Admin pages that use the gem head include `activeadmin_favorites/personalization_menu`.
- Request and path specs cover the link and absolute file contract.

## Next

- Publish 0.1.6 via `make release`. See docs/changelogs/20261027114820_release-0-1-6.md.
- Hosts that already load the sheet with `stylesheet_link_tag` can drop duplicate tags once they upgrade.

## Source

- README.md Stylesheet section
- app/views/active_admin/_html_head.html.erb
- lib/activeadmin/favorites.rb
- CHANGELOG.md Unreleased
