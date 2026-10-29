# CHANGELOG

## Unreleased

- Place engine views immediately before ActiveAdmin's view path so host `app/views` stays ahead of favorites. Rails engines prepend view paths; the previous reorder left favorites first whenever it was already ahead of ActiveAdmin, which made the gem `_html_head` shadow host heads that use a custom Active Admin stylesheet name.

## 0.1.6 (2026-10-27)

- Link the personalization menu stylesheet from Active Admin's HTML head so hosts no longer need a Tailwind `@import` of the Propshaft path.
- Document `ActiveAdmin::Favorites.personalization_menu_stylesheet_path` for hosts that concatenate the plain CSS into a Tailwind CLI entry.

## 0.1.5 (2026-10-26)

- Keep personalization menu actions in view while a long catalog scrolls.
- Add `activeadmin_favorites/personalization_menu.css` for hosts to import into the ActiveAdmin stylesheet.

## 0.1.4 (2026-10-26)

- Fix column and panel personalization so the lens catalog on index and show pages parses in the browser.

## 0.1.3 (2026-10-13)

- Fix favorites index kind tabs so they render as links instead of raw kind list text.

## 0.1.2 (2026-10-07)

- Show Favorites as the favorites index heading from the gem locale.
- Mount view lens preference actions at `/admin/view_lens_preferences`.

## 0.1.1 (2026-09-07)

- Keep favorites registration working after ActiveAdmin reload when a custom page is already registered.
- Keep JSON and CSV collection downloads working on ActiveAdmin resources that only expose the index action.
- CI: run Rails 7.2 appraisal on Ruby 3.4; refresh lockfiles for current advisories (`loofah` 2.25.2, `rails-html-sanitizer` 1.7.1, `json` 2.21.2, `sqlite3` 2.9.6) and development gems (`rbs` ~> 4).

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
