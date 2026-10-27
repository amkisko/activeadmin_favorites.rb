# Personalization menu stylesheet Propshaft wiring

## Participants

Andrei Makarov (@amkisko)

## Decisions

- Root cause is host install guidance that assumed Propshaft logical `@import` works inside a Tailwind CLI tmp build. The CSS content is fine; Propshaft precompile registration is fine.
- Fix is engine head link plus docs for override and optional absolute-path concatenate. No rewrite of gem paths inside host Tailwind builds.

## Effects

- Docs and engine wiring updated on branch `patch/personalization-menu-stylesheet-propshaft`.

## Next

- Review and merge.
- Cut a patch release so hosts can drop manual head workarounds.

## Source

- docs/changelogs/20261027113714_personalization-menu-stylesheet-propshaft.md
