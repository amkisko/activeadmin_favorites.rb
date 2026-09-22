Test CI ran bundler-audit on every matrix gemfile. Quality was not the blocker.

## Participants

- amkisko

## Decisions

- Drop the security job from test.yml so tests no longer wait on advisory freshness.
- Add dependency-audit.yml with workflow_dispatch only.

## Effects

- Test CI runs lint and specs without an advisory gate.
- On-demand bundler-audit of every Gemfile.lock is available through workflow_dispatch.

## Next

- Run dependency audit on demand when a release or a known advisory needs it.
- Do not reintroduce advisory scanners into test.yml.

## Source

- GitHub Actions test workflow on 2026-09-17
