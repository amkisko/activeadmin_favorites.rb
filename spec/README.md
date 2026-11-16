# Testing

## Commands

Full suite (matches CI: parallel shards via Polyrun):

```bash
make test
```

Lint (RuboCop and RBS):

```bash
make lint
```

Focused runs:

```bash
bundle exec rspec spec/
bundle exec rspec spec/system
bundle exec rspec spec/requests/favorites_graphql_spec.rb
```

See `polyrun.yml`. `make test` runs `hooks.before_suite` before specs.

## Playwright (system specs)

System specs use Capybara with `capybara-playwright-driver`. They skip when the Playwright CLI is missing.

```bash
export PLAYWRIGHT_CLI_VERSION=$(bundle exec ruby -e 'require "playwright"; puts Playwright::COMPATIBLE_PLAYWRIGHT_VERSION.strip')
npm install playwright@${PLAYWRIGHT_CLI_VERSION}
npx playwright install chromium
```

CI installs Chromium with `npx --yes playwright install chromium --with-deps`.

## Layout

- `spec/` — unit, request, and system specs for lib, app models, view lens, GraphQL, and browser UX
- `spec/dummy/` — minimal Rails + ActiveAdmin app (GraphQL enabled for `activeadmin-graphql`)
- `spec/system/` — Playwright browser e2e
- `spec/requests/favorites_graphql_spec.rb` — favorites data on `POST /admin/graphql`

## Guidelines

- Test macro resolution, layout schema, view lens catalog behavior, GraphQL surface, and browser flows in this repo.
- Add or update specs before bugfixes; run `make lint && make test` before a PR.
- Coverage threshold: `config/polyrun_coverage.yml`; CI runs a separate `coverage` job with `POLYRUN_COVERAGE=1`.
