## Participants

- amkisko

## Decisions

- Apply and clear the view lens with if: on action_name for index and show.
- Cover JSON and CSV collection actions on a resource that declares actions :index only.

## Effects

- ViewLens::ControllerMethods no longer lists show in only:. Rails ActionFilter no longer requires show to be an available action for the current format.
- Index-only resources keep HTML index, JSON collection, and CSV collection on 200.

## Source

- lib/activeadmin/favorites/view_lens/resource_dsl.rb
- spec/requests/index_only_resource_formats_spec.rb
- spec/dummy/app/admin/index_only_articles.rb
