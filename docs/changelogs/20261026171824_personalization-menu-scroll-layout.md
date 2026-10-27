## Participants

Andrei Makarov (@amkisko)

## Decisions

Ship the compact personalization dropdown markup with a scrollable catalog region and pinned action buttons. Match Stimulus catalog markup to the same BEM classes. Publish `activeadmin_favorites/personalization_menu.css` for hosts to import into the ActiveAdmin stylesheet entrypoint.

## Effects

Personalize page menu keeps Save, Reset, and Save lens actions in view while long catalogs scroll. Hosts that already overrode the trigger partial and controller for this layout can drop those overrides after upgrading and importing the stylesheet.

## Next

Publish 0.1.5 via make release. See docs/changelogs/20261026172252_release-0-1-5.md.

## Source

- app/views/active_admin/favorites/_personalization_trigger.html.erb
- app/assets/controllers/activeadmin_favorites/personalization_controller.js
- app/assets/stylesheets/activeadmin_favorites/personalization_menu.css
- lib/activeadmin/favorites/engine.rb
- README.md
- spec/requests/personalization_menu_spec.rb
