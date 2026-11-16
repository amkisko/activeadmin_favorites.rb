# E2E Playwright and activeadmin-graphql coverage

## Decisions

Ship browser system specs with Capybara Playwright and request specs against activeadmin-graphql so favorites HTML UX and GraphQL data stay covered together.

## Effects

- Playwright system specs for star quick-create and the favorites hub
- GraphQL request specs for schema surface, list/read, and owned create
- Dummy admin namespace enables GraphQL; create assigns the current user via `resolve_create`
- `config.graphql` (default true) gates registration; false sets `graphql.enabled = false`
- CI installs Playwright Chromium before the test matrix

## Source

- docs/issues/20261116094117_e2e-playwright-graphql.md
- docs/changelogs/20261116143300_release-0-2-0.md
