## Participants

- amkisko

## Decisions

- Relock json to 2.21.2 in Gemfile.lock and every appraisal gemfile.lock.
- Relock sqlite3 to 2.9.6 and raise the development gemspec floor to >= 2.9.6.
- Keep json on the 2.x line because rubocop declares json ~> 2.3.
- Leave Dependabot bundler at directory /. Appraisal lockfiles stay on the CI security matrix.

## Effects

- Root and appraisal lockfiles pin json 2.21.2 and sqlite3 2.9.6.
- Dummy-app sqlite3 now has a patched floor in the gemspec.
- bundler-audit check --update on Gemfile.lock and --no-update on the three appraisal locks reported no vulnerabilities. ruby-advisory-db commit e7179ad, last updated 2026-09-05.
- make test exited 0: rubocop 70 files no offenses, rbs validate, polyrun parallel-rspec 5 workers exit 0.

## Source

- usr/docs/issues/20260907125500_engineering-and-dependency-audit.md
- usr/docs/dependencies/20260907125500_json-cve-2026-71847.md
- usr/docs/dependencies/20260907125500_sqlite3-ghsa-mwm8-39rw-8826.md
