# View paths keep host html head ahead of favorites

## Participants

Andrei Makarov (@amkisko)

## Decisions

- Reorder favorites views to sit immediately before ActiveAdmin's path, not merely somewhere ahead of it.
- Treat Rails engine `prepend_view_path` as the reason favorites can land before host `app/views` after boot.
- Keep the engine `_html_head` for hosts that do not override it; host overrides must continue to win.

## Effects

- Hosts that override `active_admin/_html_head` with a custom stylesheet name keep their partial; the gem head that calls `stylesheet_link_tag "active_admin"` no longer wins via prepended engine paths.
- Specs cover a prepended favorites path that starts before the host and ends immediately before ActiveAdmin.

## Next

- Shipped as 0.1.7. See docs/changelogs/20261029151805_release-0-1-7.md.

## Source

- lib/activeadmin/favorites/view_paths.rb
- app/views/active_admin/_html_head.html.erb
