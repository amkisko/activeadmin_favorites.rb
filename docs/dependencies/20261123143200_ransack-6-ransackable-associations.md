# Ransack 6 requires ransackable_associations on dummy Article

## Dependency

- ransack (appraisal locks: rails72 `6.0.1`, rails8* `6.1.2`; root Gemfile.lock still `4.4.4` via Active Admin)
- Pulled transitively by Active Admin on appraisal Gemfiles during `make release`

## Symptom

`make release` polyrun on `gemfiles/rails72.gemfile` fails when rendering `/admin/articles` filters: `Ransack needs Article associations explicitly allowlisted as searchable`.

## Evidence

- Failures: `filter_favorite_quick_create_spec`, `favorites_hub_spec`, `admin_favorites_spec` (GET articles index)
- Stack: `ransack-6.0.1` `deprecated_ransackable_list` raise while Formtastic/Active Admin builds string filters
- Dummy `Article` already defined `ransackable_attributes` but not `ransackable_associations`

## Suggested fix

Add `Article.ransackable_associations` returning `[]` in the dummy app (no associations to search). Keep root lock on ransack 4.x until Active Admin there resolves higher; appraisal graphs already on 6.x need the allowlist.

## Next

- Re-run rails72 polyrun / `make release`

## Source

- Terminal `make release` rails72 polyrun output (2026-11-23)
- `spec/dummy/app/models/article.rb`
