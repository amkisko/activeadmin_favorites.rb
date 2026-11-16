# E2E Playwright and activeadmin-graphql coverage

## Decisions

- Add Capybara + capybara-playwright-driver system specs following the onni / Polyrun house pattern (skip when Playwright CLI is missing).
- Add activeadmin-graphql as a development dependency and enable `admin.graphql` in the dummy app so favorites data is exercised on `POST /admin/graphql`.
- Assign the current admin user in a `graphql resolve_create` hook so GraphQL create matches HTML ownership rules.
- Hosts opt out with `config.graphql = false` (explicit `graphql.enabled = false`; skipping the block alone leaves the namespace default enabled).

## Effects

- Spec support: `spec/support/playwright_env.rb`, `spec/support/capybara_playwright.rb`, `spec/support/graphql_request_helper.rb`
- Request contract: `spec/requests/favorites_graphql_spec.rb`
- Browser e2e: `spec/system/filter_favorite_quick_create_spec.rb` (form fallback), `spec/system/favorites_hub_spec.rb`
- CI installs Chromium via `npx playwright install chromium --with-deps`
- Observed: `PLAYWRIGHT_BROWSERS_PATH="$HOME/Library/Caches/ms-playwright" bundle exec rspec spec/requests spec/system` -> 31 examples, 0 failures; RuboCop on touched files clean

## Next

- Confirm Chromium install path in CI once the workflow runs on the branch
- Wire Stimulus in the dummy app (ActiveAdmin 4 default importmap has no Stimulus) so system specs can cover one-click star save, not only the form fallback
- Consider a personalization cog system spec once lens catalog fixtures are stable in the dummy articles resource
- Tag and publish 0.2.0 after commit

## Source

- onni.rb `spec/support/capybara_playwright.rb` / `spec/system/admin_features_spec.rb`
- polyrun.rb examples `simple_demo` Playwright setup
- activeadmin-graphql `docs/graphql-api.md` (`resolve_create`)
