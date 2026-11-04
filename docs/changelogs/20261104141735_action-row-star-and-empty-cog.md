# Action row star favorite and empty personalization cog

## Participants

Andrei Makarov

## Decisions

- Ship `_filter_favorite_button` as the default filter-favorite action item body: Heroicons outline/solid star, accessible name from existing i18n, `data-testid="filter-favorite"`.
- Change `Install#install_filter_favorite_action_item!` to render that partial instead of a text `link_to`.
- Hide the personalization cog when the deferred lens catalog has zero entries; wait for `DOMContentLoaded` / `turbo:load` because the catalog script is rendered after the action row.
- Keep the scrollable BEM personalization menu markup and `data-testid="page-personalization"`; render the control `hidden` until Stimulus confirms a non-empty deferred catalog (avoids empty-cog flash; no dual empty footer; favorites hub stays at `/admin/favorites`).
- Expose `data-favorited` on the star control for owned vs add state.
- No config flag for text vs star or always-visible empty cog.
- Patch release `0.1.9`. Skip RFC: default chrome for existing controls, not a new product contract.

## Effects

- Index action rows render the star control from the gem without a host Install monkey-patch or remove/re-add loop.
- Empty lens catalogs no longer leave a dead cog in the action row.
- Request specs cover star add/edit markup and empty-catalog hide wiring.
- README Personalization UI documents star, empty-cog hide, and `/admin/favorites`.

## Next

- Publish `0.1.9`.
- Consumers drop shadowed star partial, Install `to_prepare` override, personalization view/controller shadows, and importmap re-pin; keep configure block only; `bundle update activeadmin_favorites`.

## Source

- `lib/activeadmin/favorites/install.rb`
- `app/views/active_admin/favorites/_filter_favorite_button.html.erb`
- `app/views/active_admin/favorites/_personalization_trigger.html.erb`
- `app/assets/controllers/activeadmin_favorites/personalization_controller.js`
- `spec/requests/filter_favorite_button_spec.rb`
- `spec/requests/personalization_menu_spec.rb`
