# Form UX: quick save, published asterisk, macros JSON toggle

## Participants

Andrei Makarov

## Decisions

- Star on a filtered index quick-creates a private filter favorite with a suggested name and returns to the index. Full form stays the no-JS fallback and the edit path for note, publish, and macros.
- Drop the `published` inclusion validator that Formtastic treats as required. Normalize nil to false before validation. Mark the boolean input `required: false`.
- Advanced macros checkbox toggles JSON field visibility and disables template rows while checked. Hint states JSON replaces templates on save.
- On first create with no detected date ranges and advanced mode off, omit Dynamic filters and Advanced macros so the default form is name, note, and publish only.
- Apply `assign_new_favorite_defaults` from `build_resource` so query params from the star fallback form still populate path, query string, and suggested name.
- Patch release target: `0.1.10`. Skip RFC: change stays within existing create/edit desk flow, not a new product contract.

## Effects

- `collection_action :quick_create` on favorites; star Stimulus posts create then redirects to the filtered index.
- `_macro_fields` hides JSON until advanced is checked; empty-range create omits macro panels.
- Request specs: published optional, JSON hidden wiring, empty-range omit, quick create success and duplicate reject.

## Next

- Tag and publish `0.1.10` with `make release`.
- Hosts: `bundle update --conservative activeadmin_favorites`; refresh locale copy if `use_advanced_macros_hint` is mirrored under host locales.

## Source

- `docs/changelogs/20261104154500_form-ux-quick-save-macros-published.md`
- `docs/reviews/20261104154501_engineering-audit-form-ux.md`
- Upstream registry: https://rubygems.org/gems/activeadmin_favorites
