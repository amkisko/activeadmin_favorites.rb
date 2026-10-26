# ransack GHSA-vxc9-rm8f-p56j

## Dependency

- ransack (was 4.4.1, now 4.4.4)
- Constraint in this repo: none in the gemspec. Transitive via activeadmin 4.0.0.beta22 (ransack >= 4.0).
- Lockfiles: Gemfile.lock, gemfiles/rails72.gemfile.lock, gemfiles/rails8ruby34.gemfile.lock, gemfiles/rails8ruby4.gemfile.lock

## Symptom

bundler-audit matches ransack 4.4.1 against GHSA-vxc9-rm8f-p56j. make release stops on gemfiles/rails72.gemfile while that pin remains.

## Evidence

- Advisory: Search#collapse_multiparameter_attributes! uses an unbounded position from a query key such as q[created_at(1000000000i)] as an array index. Affected < 4.4.2, and >= 5.0.0, < 5.0.1. Patched 4.4.2 and 5.0.1. Published 2026-09-22. Severity on the advisory page: High, CVSS 3.1 7.5, CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:H. The page did not list a CVE ID.
- ActiveAdmin::ResourceController::DataAccess calls chain.ransack(params[:q] || {}, auth_object: active_admin_authorization) on index.
- This gem's Favorite.ransackable_attributes_for reads the allowlist. It does not build a Ransack::Search.
- Installed ransack 4.4.4 drops a position outside 0...16 (MULTIPARAMETER_POSITION_LIMIT) and names this advisory in the comment.

## Suggested fix

Upgrade lockfiles to ransack 4.4.4, which is past the 4.4.2 floor. Stay on the 4.4 line. An update without --patch resolved 6.0.1 because activeadmin allows >= 4.0. Leave ransack off the gemspec. A floor of >= 4.4.2 would still allow vulnerable 5.0.0.

## Trigger

- bundler-audit scanner match during make release on 2026-10-26. ruby-advisory-db commit 04bbdaed29a22b4539f899ac1d6863ddaa326074, last updated 2026-10-26 09:56:27 -0400.

## Assessment target

- CI and test graphs: dummy ActiveAdmin index plus Gemfile.lock and gemfiles/*.gemfile.lock.
- Published gem payload: ransack is not a gemspec dependency. Host apps are not assessed here.

## Advisory

- GHSA-vxc9-rm8f-p56j
- Severity on the advisory page: High, CVSS 3.1 7.5
- The advisory page did not list a CVE ID when fetched on 2026-10-26, so a KEV lookup by CVE was not available from that page.

## Status

- CI and test graphs: fixed after lockfiles pin ransack 4.4.4. The installed gem contains the position cap. bundler-audit check --update reported no vulnerabilities on Gemfile.lock and the three appraisal locks.
- Published gem payload: component not present. Host resolution stays on the host lockfile.

## Applicability

- Vulnerable component was present at 4.4.1.
- Exploit conditions are a Ransack search built from an attacker-controlled q key with a huge multiparameter position. The dummy index reaches that through ActiveAdmin's chain.ransack(params[:q]). Allowlisting attributes does not stop the allocation, per the advisory.

## Priority

- CI graph: high because bundler-audit fails make release, and the dummy index builds a Ransack search from request params.
- Published gem payload: the library file is not in this gem. Host exposure is outside this assessment.

## Disposition

- Upgrade. bundle lock --update=ransack --patch --conservative on the root Gemfile and each appraisal gemfile. Resolved 4.4.4. Rejected 6.0.1 for this release.

## Next

- Keep the test graph on ransack 4.4 until a matrix run covers 6.x. A later bundle update without --patch can resolve ransack 6.0.1 because activeadmin's constraint is >= 4.0.
- A host that serves ActiveAdmin filters updates its own lock to ransack 4.4.2 or newer on the 4.4 line, 5.0.1 or newer on the 5.0 line, or 6.0.0 or newer.

## Source

- https://github.com/activerecord-hackery/ransack/security/advisories/GHSA-vxc9-rm8f-p56j
- activeadmin 4.0.0.beta22 app/controllers/active_admin/resource_controller/data_access.rb
- app/models/active_admin/favorites/favorite.rb ransackable_attributes_for
- ransack 4.4.4 lib/ransack/search.rb MULTIPARAMETER_POSITION_LIMIT
- docs/dependencies/20261026174520_ransack-ghsa-j3f8-w227-4hh8.md
- docs/changelogs/20261026173208_release-0-1-4.md
