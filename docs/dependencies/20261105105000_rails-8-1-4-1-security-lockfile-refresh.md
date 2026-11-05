# Rails 8.1.4.1 security lockfile refresh

## Participants

Andrei Makarov (@amkisko)

## Dependency

- rails / actionpack / actionview / activestorage / actionmailbox / activesupport (was 8.1.3.1 on root and rails8 appraisals, now 8.1.4.1)
- rails on rails72 appraisal (was 7.2.3.2, now 7.2.4; last 7.2 release, still past security support)
- Lockfiles: Gemfile.lock and gemfiles/*.gemfile.lock
- Appraisals floors: rails8 `>= 8.1.4.1`, rails72 `>= 7.2.4`

## Symptom

`make release` failed on `BUNDLE_GEMFILE=gemfiles/rails72.gemfile bundle exec bundler-audit check --update` after ruby-advisory-db commit 516ea475 (2026-11-04). Root and rails8 locks also matched the same advisory set at 8.1.3.1.

## Evidence

- bundler-audit reported Rails framework GHSAs against 8.1.3.1 with solution `>= 8.1.4.1` (and `~> 8.0.5, >= 8.0.5.2` where applicable), including GHSA-f3w6-w445-fwh9, GHSA-v924-7rp8-4mxh, GHSA-wm3x-v3qw-4jh3, GHSA-8474-xrp6-wh69, and related actionpack / actionview / activestorage / actionmailbox entries from the 2026-11-04 release set
- rails72 lock at 7.2.3.2 matched the same advisory range (`< 8.0.5.2`) for eighteen GHSAs; Rails published fixes only for 8.0.5.2 and 8.1.4.1
- Rails 7.2.4 (2026-09-24) is the last 7.2 release; security support for 7.2 ended earlier; the maintenance policy lists only 8.0.x and 8.1.x for security fixes

## Suggested fix

Upgrade root and rails8 appraisal locks to rails 8.1.4.1. Raise Appraisals floors accordingly. Keep rails72 for compatibility tests at 7.2.4; ignore the November 2026 GHSAs that have no 7.2 patch when auditing that lockfile in `usr/bin/release.rb` and `.github/workflows/dependency-audit.yml`. Hosts still on 7.2 must upgrade Rails themselves.

## Trigger

bundler-audit scanner match during `make release`.

## Assessment target

- CI and test graphs: Gemfile.lock and gemfiles/*.gemfile.lock
- Published gem runtime: does not ship Rails; host apps resolve their own Rails version against gemspec `rails >= 7.2`

## Advisory

See Evidence and Source for GHSA ids. Vendor fixed releases: 8.1.4.1 and 8.0.5.2.

## Status

- CI and test graphs for rails8 / root: fixed after lockfiles pin rails 8.1.4.1
- CI and test graph for rails72: affected with accepted risk (EOL series; ignores scoped to that lockfile only)
- Published gem runtime: not_affected for Rails itself (component not present in the gem package); host apps on 8.1.3.1 or 7.2 remain responsible for their own upgrades

## Applicability

- Dummy-app and appraisal graphs only for the lockfile refresh
- Host apps that mount this engine inherit exposure from their own Rails version

## Priority

- CI graph: high because bundler-audit fails the release gate
- rails72 compatibility matrix: accepted until the appraisal is dropped

## Disposition

Upgrade 8.1 locks. Document rails72 EOL ignores. Re-run bundler-audit on all four locks.

## Effects

- Root Gemfile.lock and rails8 appraisal locks pin rails 8.1.4.1
- rails72 appraisal lock pins rails 7.2.4
- `bundle exec bundler-audit check --no-update` on Gemfile.lock: No vulnerabilities found
- `bundler-audit check` on rails8ruby34 and rails8ruby4 locks: No vulnerabilities found
- `bundler-audit check` on rails72 lock with the documented `--ignore` list: No vulnerabilities found

## Next

- Revisit dropping the rails72 appraisal once hosts no longer need a 7.2 CI signal

## Source

- https://rubyonrails.org/2026/11/4/Rails-8.0.5.2-and-8.1.4.1-have-been-released
- https://rubyonrails.org/2026/9/24/Rails-Version-7-2-4-has-been-released
- https://rubyonrails.org/maintenance
- https://github.com/rails/rails/security/advisories/GHSA-f3w6-w445-fwh9
- https://github.com/rails/rails/security/advisories/GHSA-v924-7rp8-4mxh
- https://github.com/rails/rails/security/advisories/GHSA-wm3x-v3qw-4jh3
- https://github.com/rails/rails/security/advisories/GHSA-8474-xrp6-wh69
