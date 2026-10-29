# View paths keep host html head ahead of favorites

## Participants

Andrei Makarov (@amkisko)

## Decisions

- Reorder favorites views to sit immediately before ActiveAdmin's path, not merely somewhere ahead of it.
- Treat Rails engine `prepend_view_path` as the reason favorites can land before host `app/views` after boot.
- Keep host overrides ahead of favorites for shared Active Admin templates.

## Effects

- Specs cover a prepended favorites path that ends immediately before ActiveAdmin.
- Superseded for `_html_head` by 0.1.8: sibling `activeadmin-*` detection fix and removal of the gem head template. See docs/changelogs/20261029153215_html-head-and-activeadmin-path-detection.md.

## Next

- None for this note. Later path and head work is in 0.1.8.

## Source

- lib/activeadmin/favorites/view_paths.rb
