## Dependency

- loofah (was 2.25.1, now 2.25.2) via rails-html-sanitizer / Action View
- rails-html-sanitizer (was 1.7.0, now 1.7.1)
- Lockfiles: Gemfile.lock and gemfiles/*.gemfile.lock

## Symptom

GitHub Actions security jobs failed bundler-audit on main after the first push of activeadmin_favorites.rb.

## Evidence

- bundler-audit reported GHSA-5qhf-9phg-95m2, GHSA-8whx-365g-h9vv, GHSA-9wjq-cp2p-hrgf for loofah 2.25.1
- bundler-audit reported GHSA-cj75-f6xr-r4g7 for rails-html-sanitizer 1.7.0
- Run: https://github.com/amkisko/activeadmin_favorites.rb/actions/runs/29638677295

## Suggested fix

Relock appraisal and root graphs so loofah is >= 2.25.2 and rails-html-sanitizer is >= 1.7.1. Done on patch/ci-latest-deps.

## Next

- Confirm security jobs pass on the patch branch CI run.

## Source

- https://github.com/flavorjones/loofah/security/advisories/GHSA-5qhf-9phg-95m2
- https://github.com/flavorjones/loofah/security/advisories/GHSA-8whx-365g-h9vv
- https://github.com/flavorjones/loofah/security/advisories/GHSA-9wjq-cp2p-hrgf
- https://github.com/rails/rails-html-sanitizer/security/advisories/GHSA-cj75-f6xr-r4g7
