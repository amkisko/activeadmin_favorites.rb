# Bundler-audit release lockfile refresh

## Participants

Andrei Makarov (@amkisko)

## Dependency

- loofah (was 2.25.2, now 2.25.3) via rails-html-sanitizer / Action View
- nokogiri (was 1.19.4, now 1.19.7)
- rack (was 3.2.6, now 3.2.8)
- rails-html-sanitizer (was 1.7.1, now 1.7.2)
- sqlite3 (was 2.9.6, now 2.10.2); development gemspec floor raised to >= 2.10.2
- Lockfiles: Gemfile.lock and gemfiles/*.gemfile.lock

## Symptom

`make release` failed on `BUNDLE_GEMFILE=gemfiles/rails72.gemfile bundle exec bundler-audit check --update` after ruby-advisory-db commit ea31421.

## Evidence

- bundler-audit reported six loofah GHSAs against 2.25.2 (GHSA-345x-3rq2-jfrm, GHSA-h6v6-rg66-fqj4, GHSA-jcff-cj73-4w4f, GHSA-m3x9-938q-5767, GHSA-mf2j-8f84-cc9q, GHSA-p9wj-w8xq-vjx6); solution >= 2.25.3
- bundler-audit reported three nokogiri GHSAs against 1.19.4 (GHSA-3w22-6jfg-527w, GHSA-4p39-36wj-23h4, GHSA-v995-44v6-5fqm); solution >= 1.19.5
- bundler-audit reported four rack GHSAs against 3.2.6 (GHSA-2j8w-xcrc-x985, GHSA-5v64-555j-wjxm, GHSA-p8x9-v4hv-2w4g, GHSA-wvg4-6p58-3gh3); solution >= 3.2.8
- bundler-audit reported two rails-html-sanitizer GHSAs against 1.7.1 (GHSA-cpgf-5mjf-73p7, GHSA-h7wh-q2qr-458c); solution >= 1.7.2
- bundler-audit reported sqlite3 GHSA-4fqr-96q8-xrfx against 2.9.6; solution >= 2.10.2
- ransack GHSA-58rx-96gf-w92x landed in the same advisory-db update; lockfiles already pin ransack 4.4.4 which matches patched_versions `~> 4.4.4`

## Suggested fix

Upgrade. Named `bundle update` of the five packages on the root and appraisal Gemfiles. Raise the sqlite3 development gemspec floor to >= 2.10.2. Done on main before re-running release.

## Trigger

bundler-audit scanner match during `make release` for 0.1.9.

## Assessment target

- CI and test graphs: Gemfile.lock and gemfiles/*.gemfile.lock
- Published gem runtime: transitive Action View / Rack stack when a host mounts the engine; sqlite3 remains development-only

## Advisory

See Evidence for GHSA ids and vendor solution floors.

## Status

- CI and test graphs: fixed after lockfiles pin loofah 2.25.3, nokogiri 1.19.7, rack 3.2.8, rails-html-sanitizer 1.7.2, sqlite3 2.10.2
- Published gem runtime for sqlite3: not_affected (component not present)
- Published gem runtime for loofah / nokogiri / rack / rails-html-sanitizer: fixed in consumer graphs that resolve through these lockfiles; host apps must refresh their own locks

## Applicability

- sqlite3: dummy-app and test graph only
- HTML sanitizer and Rack packages: present in the Rails test app and in any host that renders Active Admin through this gem's engine

## Priority

- CI graph: high because bundler-audit fails the release gate on version match
- sqlite3 published runtime: none

## Disposition

Upgrade lockfiles and raise the sqlite3 development floor. Re-run bundler-audit on all four locks.

## Effects

- `BUNDLE_GEMFILE=gemfiles/rails72.gemfile bundle exec bundler-audit check --update` reported No vulnerabilities found (ruby-advisory-db ea31421)
- The three other appraisal locks and Gemfile.lock also reported No vulnerabilities found with `--no-update`

## Source

- https://github.com/flavorjones/loofah/security/advisories/GHSA-345x-3rq2-jfrm
- https://github.com/sparklemotion/nokogiri/security/advisories/GHSA-3w22-6jfg-527w
- https://github.com/rack/rack/security/advisories/GHSA-5v64-555j-wjxm
- https://github.com/rails/rails-html-sanitizer/security/advisories/GHSA-cpgf-5mjf-73p7
- https://github.com/sparklemotion/sqlite3-ruby/security/advisories/GHSA-4fqr-96q8-xrfx
- https://github.com/activerecord-hackery/ransack/security/advisories/GHSA-58rx-96gf-w92x
