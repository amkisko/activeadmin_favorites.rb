# Engineering audit: form UX quick save, published, macros

## Participants

Andrei Makarov

## Decisions

- Scope: filter-favorite star create path and favorites create/edit form after consumer symptom report against gem `0.1.9`.
- Modes run: core pipeline, product-surface, client-surface, resource and budget, trace and identification, security (create ownership), contracts (testid and form markup).
- Modes skipped: boundary and control (no external plant), privacy (no new personal-data fields), observability (library), learned systems (none), lineage (storage shape unchanged), cloud deployment (none).

## Effects

Fact check of the consumer note (observed in this tree at `0.1.9` tip before this patch):

1. Star destination was `new` / `edit` only. Confirmed in `Install#install_filter_favorite_action_item!`. Kind: observed. Confidence high.
2. Published inclusion validator drove Formtastic required. Confirmed in `Favorite` validations and Formtastic `inputs/base/validations.rb` inclusion branch; boolean input skips only the global required default. Kind: observed. Confidence high.
3. Schema `published boolean null: false, default: false`. Confirmed in create migration. Kind: observed. Confidence high.
4. Macros JSON always rendered; `use_advanced_macros` read only on submit. Confirmed in `_macro_fields.html.erb` and `assign_macros_from_form!`. Kind: observed. Confidence high.
5. Lens save uses `window.prompt` then POST. Confirmed in `personalization_controller.js` and `save_lens_favorite` page action. Kind: observed. Confidence high.
6. Extra finding while fixing: `build_resource` skipped `assign_new_favorite_defaults`, so star query params did not populate the new form. Kind: observed. Confidence high.

Findings fixed in this pass:

1. Star not quick. Severity high for desk chrome. Fix: `quick_create` collection action plus filter-favorite Stimulus; href to new remains fallback. Evidence: request specs for wiring, create, duplicate.
2. Published asterisk. Severity medium for form honesty. Fix: `required: false`, drop inclusion validator, `normalize_published`. Evidence: new-form request spec, no `required` / `<abbr` on published input.
3. Advanced macros checkbox inert visually. Severity medium for form honesty. Fix: hide/disable JSON until checked; disable templates when advanced; hint locale. Evidence: request markup for hidden JSON and toggle action.
4. Macro panels on empty-range create. Severity low. Fix: omit panels when new, no rows, advanced off. Evidence: request spec.
5. New-form defaults lost. Severity medium for fallback form. Fix: call `assign_new_favorite_defaults` in `build_resource`. Evidence: range-backed form now renders macro rows in the advanced-mode spec.

Residual (accepted):

1. Quick-create and macros toggle are Stimulus; request specs prove markup and HTTP create, not browser click. No browser driver in this tree. Category: missing coverage. Severity medium.
2. Cold gem size and RSS not re-measured. Category: resource and budget. Severity low.
3. `register_favorites.rb` remains a large ActiveAdmin register block. Split deferred unless AbcSize or ownership forces it. Category: organization. Severity low.

Visual surface assessed (index star; favorites new/edit form). Star stays icon-only with accessible name. Add path quick-saves without a form when JS runs. Form published label no longer shows a required marker. Advanced macros checkbox reveals JSON and states that JSON replaces templates. Empty-range create shows name, note, publish (and include layout) only. Narrow viewport, keyboard focus order, and contrast were not measured on a rendered browser.

Validation observed:

- `bundle exec rubocop` -> 83 files, no offenses
- `bundle exec rbs validate` -> exit 0
- `bundle exec polyrun parallel-rspec --workers 5 --merge-failures` -> exit 0

No confirmed finding remains unfixed in the reviewed delta.

## Next

- Tag and publish `0.1.10` with `make release`.
- Optional later: browser-level example for star click and macros toggle.

## Source

- `docs/issues/20261104154500_form-ux-quick-save-macros-published.md`
- `docs/changelogs/20261104154500_form-ux-quick-save-macros-published.md`
- `.agents/skills/engineering-audit/SKILL.md`
