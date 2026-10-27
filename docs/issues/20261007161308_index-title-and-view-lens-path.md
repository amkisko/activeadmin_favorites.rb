## Participants

Andrei Makarov (@amkisko)

## Decisions

Add active_admin.favorites.title in the gem locale. Change the view lens preferences page registration name so parameterize.underscore yields view_lens_preferences. Do not rely on register_page as: for path shape.

## Effects

Index heading no longer depends on a host locale override for title. Preferences actions live under /admin/view_lens_preferences.

## Next

Publish 0.1.2 via make release. See docs/changelogs/20261007162649_release-0-1-2.md.

## Source

- docs/changelogs/20261007161308_index-title-and-view-lens-path.md
