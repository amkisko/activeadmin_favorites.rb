## Participants

- amkisko

## Decisions

- Look up favorites on ActiveAdmin Resource entries during register and install.
- Cover reload with a dashboard page already registered before Favorite is registered.

## Effects

- RegisterFavorites.resource_registered? and Install.configure_favorites_resource! read resource_class only on Resource entries.
- Specs that unload then load ActiveAdmin with a dashboard page can install favorites again.

## Source

- lib/activeadmin/favorites/register_favorites.rb
- lib/activeadmin/favorites/install.rb
- spec/lib/activeadmin/favorites/page_safe_registration_spec.rb
