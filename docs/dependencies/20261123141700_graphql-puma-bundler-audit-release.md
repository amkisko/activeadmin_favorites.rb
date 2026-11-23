# GraphQL and Puma bundler-audit release refresh

## Dependency

- graphql (was 2.6.15, target >= 2.6.16); development gemspec floor raised to >= 2.6.16, < 3
- puma (was 8.1.1, target >= 8.1.2); development dependency remains >= 5.0 with lockfiles refreshed
- Lockfiles: Gemfile.lock and gemfiles/*.gemfile.lock

## Symptom

`make release` for 0.2.1 failed on `BUNDLE_GEMFILE=gemfiles/rails72.gemfile bundle exec bundler-audit check --update`.

## Evidence

- bundler-audit reported graphql GHSA-492h-6x29-69mq, GHSA-5f8h-c2xc-j37j, GHSA-wqwf-8p4q-mwqj against 2.6.15; solution >= 2.6.16
- bundler-audit reported puma GHSA-4v6q-hvv7-49h9 and GHSA-rhww-p99c-hgj9 against 8.1.1; solution >= 8.1.2 (also ~> 7.2.3 / ~> 8.0.4)

## Suggested fix

Upgrade. Named `bundle update graphql puma` on the root and appraisal Gemfiles. Raise the graphql development gemspec floor to >= 2.6.16.

## Trigger

bundler-audit scanner match during `make release` for 0.2.1.

## Assessment target

- CI and test graphs: Gemfile.lock and gemfiles/*.gemfile.lock
- Published gem runtime: graphql and puma are development dependencies for the dummy app and GraphQL specs; hosts resolve their own locks

## Advisory

See Evidence for GHSA ids and vendor solution floors.

## Status

- CI and test graphs: fixed after lockfiles pin graphql 2.6.16 and puma 8.1.2; gemspec graphql floor >= 2.6.16
- Published gem runtime for graphql / puma: not_affected as direct runtime dependencies of the published gem; host apps that use GraphQL or Puma must refresh their own locks

## Applicability

- graphql: dummy-app GraphQL request specs and activeadmin-graphql development stack
- puma: dummy-app / test server only in this repository

## Priority

- CI graph: high because bundler-audit fails the release gate on version match
- Published gem runtime: none for these as gem runtime deps

## Next

- Re-run `make release` for 0.2.1

## Source

- Terminal output from `make release` bundler-audit step (2026-11-23)
- https://github.com/rmosolgo/graphql-ruby/security/advisories/GHSA-492h-6x29-69mq
- https://github.com/rmosolgo/graphql-ruby/security/advisories/GHSA-5f8h-c2xc-j37j
- https://github.com/rmosolgo/graphql-ruby/security/advisories/GHSA-wqwf-8p4q-mwqj
- https://github.com/puma/puma/security/advisories/GHSA-4v6q-hvv7-49h9
- https://github.com/puma/puma/security/advisories/GHSA-rhww-p99c-hgj9
