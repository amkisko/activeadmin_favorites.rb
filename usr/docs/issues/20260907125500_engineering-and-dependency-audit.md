Recorded 2026-09-07. Library gem for ActiveAdmin 4 favorites. Pipeline is authenticated admin request in, resource register and install, models and view-lens application, HTML and JSON out. No own product UI, queue, or worker.

## Participants

- amkisko

## Decisions

- Keep the page-safe favorites registration that already landed: look up favorites on ActiveAdmin Resource entries only, then cover reload with a dashboard page already registered.
- Distill CHANGELOG Unreleased to the operator outcome. Keep engineering names in usr/docs/changelogs.
- Bump json to 2.21.2 and sqlite3 to 2.9.6 in Gemfile.lock and every appraisal lockfile. Raise the sqlite3 development gemspec floor to >= 2.9.6.
- Keep json on 2.x. rubocop declares json ~> 2.3. json 3.0.0 is out of that constraint.
- Leave Dependabot bundler at directory /. Appraisal *.gemfile names are not a working Dependabot directory. The CI security matrix remains the gate for those locks.
- Treat CVE-2026-71847 as not_affected for this gem's execute path. The advisory names JSON::ResumableParser#partial_value. This tree uses JSON.parse on admin-authenticated layout and macro input.
- Treat GHSA-mwm8-39rw-8826 as not_affected for the published gem runtime. sqlite3 is development-only and this tree never calls the multi-arg aggregate APIs. Still bump the test graph so bundler-audit can pass.

Modes run: resource and budget, trace and identification, boundary with ActiveAdmin as the external framework, security, contracts, performance as unmeasured boot scan. Modes skipped: product-surface, this gem has no own presentation surface in the delta. Privacy, no new personal-data collection. Observability, library with no own runtime or SLO. Learned systems, none.

## Effects

- lib/activeadmin/favorites/register_favorites.rb and lib/activeadmin/favorites/install.rb already guard resource_class behind an ActiveAdmin::Resource check.
- Root and appraisal lockfiles pin json 2.21.2 and sqlite3 2.9.6.
- CHANGELOG Unreleased names the reload outcome and the advisory lockfile versions.
- Dependency records live under usr/docs/dependencies for json CVE-2026-71847 and sqlite3 GHSA-mwm8-39rw-8826.
- bundler-audit check --update on Gemfile.lock and --no-update on the three appraisal locks reported no vulnerabilities. ruby-advisory-db commit e7179ad, last updated 2026-09-05.
- make test exited 0: rubocop 70 files no offenses, rbs validate, polyrun parallel-rspec 5 workers exit 0.

Resource and budget: favorites register walks the ActiveAdmin namespace at boot and reload. Cheaper alternatives stay inference until a boot bench exists. Trace and identification: layout JSON is request params on an authenticated admin resource. Identifiers that appear are the same favorite and user ids the admin already sees. Boundary: after unload then load, a Page listed first has no resource_class. The Resource predicate is the alarm at that split. Security: JSON.parse of layout is rescued ParserError. The json advisory execute path is absent. Contracts: public install and register still attach favorites to Resource entries. Performance of the namespace scan was not measured this session.

## Next

- Appraisal lockfiles stay outside Dependabot directory /. Keep CI bundler-audit as the gate unless a later pass finds a supported Dependabot layout for those files.

## Source

- engineering-audit, dependency-audit, and claims-audit skills under .agents/skills
- CHANGELOG.md Unreleased
- usr/docs/changelogs/20260907124700_page-safe-favorites-registration.md
- usr/docs/changelogs/20260907125500_advisory-lockfile-refresh.md
- usr/docs/dependencies/20260907125500_json-cve-2026-71847.md
- usr/docs/dependencies/20260907125500_sqlite3-ghsa-mwm8-39rw-8826.md
- https://github.com/ruby/json/security/advisories/GHSA-9hj4-r449-hfvc
- https://github.com/sparklemotion/sqlite3-ruby/security/advisories/GHSA-mwm8-39rw-8826
- .github/dependabot.yml
- Gemfile.lock and gemfiles/*.gemfile.lock
