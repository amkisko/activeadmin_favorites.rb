# Personalization menu stylesheet Propshaft wiring

## Participants

Andrei Makarov (@amkisko)

## Decisions

- Root cause is host install guidance that assumed Propshaft logical `@import` works inside a Tailwind CLI tmp build. The CSS content is fine; Propshaft precompile registration is fine.
- Fix is engine head link plus docs for override and optional absolute-path concatenate. No rewrite of gem paths inside host Tailwind builds.

## Effects

- Docs and engine wiring updated on branch `patch/personalization-menu-stylesheet-propshaft`.

## Next

- Commit and push the 0.1.6 release prep on main.
- Run `make release` from a clean tree when ready to publish to RubyGems.

## Source

- docs/changelogs/20261027113714_personalization-menu-stylesheet-propshaft.md
