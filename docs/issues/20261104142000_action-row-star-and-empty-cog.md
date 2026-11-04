# Shared action-row defaults: star favorite and empty cog hide

## Participants

Andrei Makarov

## Decisions

- Upstream star icon as the default filter-favorite action item; no text-vs-star config flag.
- Upstream empty lens-catalog hide for the personalization cog; start hidden and reveal only when the deferred catalog is non-empty.
- Keep product-only host config (user class, table name, association keys) out of the gem.

## Effects

- Implemented on branch `feature/action-row-star-and-empty-cog` for release `0.1.9`.
- Request specs cover star add/edit accessible names and `data-favorited`, plus personalization hide wiring.
- Engineering draft: `docs/changelogs/20261104141735_action-row-star-and-empty-cog.md`.

## Next

- Publish `0.1.9`.
- Consumers drop star and personalization shadows plus Install remove/re-add and importmap re-pin; `bundle update activeadmin_favorites`.
- Re-check an index action row after upgrade: one star, cog only when the catalog has entries.

## Source

- `docs/changelogs/20261104141735_action-row-star-and-empty-cog.md`
- `docs/changelogs/20261104141736_release-0-1-9.md`
