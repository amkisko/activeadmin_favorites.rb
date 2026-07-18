# CHANGELOG

## Unreleased

- CI: run Rails 7.2 appraisal on Ruby 3.4; refresh lockfiles for current advisories (`loofah` 2.25.2, `rails-html-sanitizer` 1.7.1) and development gems (`rbs` ~> 4).

## 0.1.0 (2026-07-13)

- Initial public release: saved filter favorites and view lens personalization for ActiveAdmin 4.
- STI storage on configurable `admin_favorites` (`FiltersFavorite`, `LensFavorite`, `CombinedFavorite`).
- ActiveAdmin resource at `/admin/favorites`.
- Request-scoped `ViewLens::Applicator` state via `ActiveSupport::CurrentAttributes`.
- Deferred catalog JSON for cogwheel column and panel toggles after table render.
- Configurable user association via `UserRecord` (`user_id` defaults).
- Engine migration append with host-version deduplication.
- `rails activeadmin_favorites:install` generator and `activeadmin_favorites:install:migrations` rake task.
- English locale; host locale template for copy into additional languages.
