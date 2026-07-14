# CHANGELOG

## Unreleased

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
