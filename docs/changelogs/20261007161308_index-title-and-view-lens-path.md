## Participants

Andrei Makarov (@amkisko)

## Decisions

Ship gem locale title for the favorites index. Register the view lens preferences page under a spaced human name so ActiveAdmin builds an underscored path.

## Effects

active_admin.favorites.title is Favorites in the English gem locale. The preferences page name is View Lens Preferences. Route helpers are admin_view_lens_preferences_*. Request specs cover the index title and the underscored paths.

## Next

Publish 0.1.2 via make release after the release note and appraisal locks land. Hosts that overrode the old camel-case path helpers should switch to the underscored helpers after upgrade.

## Source

- lib/activeadmin/favorites/register_favorites.rb
- lib/activeadmin/favorites/register_view_lens_preferences.rb
- config/locales/activeadmin_favorites.en.yml
- app/views/active_admin/favorites/_personalization_trigger.html.erb
- spec/requests/admin_favorites_spec.rb
- spec/requests/view_lens_preferences_spec.rb
