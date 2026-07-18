# activeadmin_favorites

[![Gem Version](https://badge.fury.io/rb/activeadmin_favorites.svg)](https://badge.fury.io/rb/activeadmin_favorites) [![Test Status](https://github.com/amkisko/activeadmin_favorites.rb/actions/workflows/test.yml/badge.svg)](https://github.com/amkisko/activeadmin_favorites.rb/actions/workflows/test.yml)

Saved filter favorites, per-resource view lens defaults, and a cogwheel personalization UI for ActiveAdmin 4 index and show pages.

## Requirements

- Ruby 3.2+ (CI matrix: Ruby 3.4, 4.0, and TruffleRuby)
- Rails 7.2+ (Rails 7.2 and 8.1 tested in CI)
- ActiveAdmin 4.0.0.beta13+
- PostgreSQL for production migrations (`jsonb` columns and concurrent index helpers)

## Install

Add the gem to your Gemfile:

```ruby
gem "activeadmin_favorites"
```

Run the install generator:

```bash
bin/rails generate activeadmin_favorites:install
bin/rails db:migrate
```

Or copy migrations manually:

```bash
bin/rails activeadmin_favorites:install:migrations
bin/rails db:migrate
```

Greenfield apps pick up engine migrations automatically when no matching version exists in `db/migrate/`.

Configure the host app (the generator writes `config/initializers/activeadmin_favorites.rb` with neutral defaults):

```ruby
ActiveAdmin::Favorites.configure do |config|
  config.user_class = "User"
  config.user_foreign_key = :user_id
  config.user_association_name = :user
  config.user_label_method = :email
  config.current_user_method = :current_user
end
```

Add `ActiveAdmin::Favorites::FavoritePolicy` in the host app (the generator copies a template). Point `has_many :favorites` on your user model at `ActiveAdmin::Favorites::Favorite`.

Configure the table name when needed:

```ruby
ActiveAdmin::Favorites.configure do |config|
  config.table_name = "admin_favorites"
end
```

When using ActionPolicy, add `save_lens_favorite?` and `reset?` to `ActiveAdmin::PagePolicy` (or equivalent) so the view lens preference page actions authorize correctly.

### Locales

English ships with the gem. Copy `config/locales/activeadmin_favorites.host.yml.example` into your locale files and translate `active_admin.favorites` keys.

## Favorite kinds

| Kind | Stores |
|------|--------|
| `filters` | scope, sort, ransack query, macros |
| `lens` | hidden columns, filters, panels, rows, action items |
| `combined` | filters and layout together |

## View lens layout schema

```json
{
  "version": 1,
  "hidden": {
    "columns": ["created_at"],
    "filters": ["status"],
    "action_items": ["new"],
    "panels": ["details"],
    "show_rows": ["author"]
  }
}
```

Version 1 supports show/hide only. Column reorder is deferred.

Catalog entries are discovered at render time from ActiveAdmin columns, filters, panels, and show rows. Use `lens_id:` on custom columns or panels when auto ids are unstable. Block columns without a title receive stable `block_column_N` ids automatically. Personalization catalog data is injected on every index layout, not only table indexes.

## Personalization UI

The gem installs:

- **Add to favorites** on index pages (saved filters)
- **Personalize page** cogwheel on index and show pages
- **Favorites** hub with type tabs (all, filters, lens, combined)

Defaults are stored in `active_admin_view_lens_defaults`. Named lens favorites and combined favorites use `admin_favorites.layout`.

## Development

```bash
bundle install
bundle exec appraisal install
make lint
make test
```

See `spec/README.md` for focused runs and coverage notes.

If native extensions fail to load after switching Ruby installs (for example mise vs rbenv with the same version), wipe and reinstall both bundle trees with one active Ruby:

```bash
rm -rf vendor/bundle
bundle install

rm -rf gemfiles/vendor/bundle
bundle exec appraisal install
```

## Links

- [GitHub](https://github.com/amkisko/activeadmin_favorites.rb)
- [GitLab](https://gitlab.com/amkisko/activeadmin_favorites.rb)
- [RubyGems](https://rubygems.org/gems/activeadmin_favorites)
- [libraries.io](https://libraries.io/rubygems/activeadmin_favorites)
- [Deps.dev](https://deps.dev/rubygems/activeadmin_favorites)
- [SonarCloud](https://sonarcloud.io/project/overview?id=amkisko_activeadmin_favorites.rb)
- [Snyk](https://snyk.io/test/github/amkisko/activeadmin_favorites.rb)
- [Codecov](https://app.codecov.io/github/amkisko/activeadmin_favorites.rb)
- [OpenSSF Scorecard](https://scorecard.dev/viewer/?uri=github.com/amkisko/activeadmin_favorites.rb)

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Sponsors

Sponsored by [Kisko Labs](https://www.kiskolabs.com).

<a href="https://www.kiskolabs.com">
  <img src="kisko.svg" width="200" alt="Sponsored by Kisko Labs" />
</a>
