# Engineering audit: action-row star and empty cog

## Participants

Andrei Makarov

## Decisions

- Scope: filter-favorite action item default and personalization empty-catalog hide for `0.1.9`.
- Modes run: core pipeline, product-surface, client-surface, resource and budget, trace and identification, security (client markup), contracts (testid and accessible name).
- Modes skipped: boundary and control (no external plant), privacy (no new personal-data collection), observability (library), learned systems (none), lineage (unchanged storage), cloud deployment (none).

## Effects

Findings fixed in this pass:

1. Text filter-favorite button as default. Severity high for desk chrome. Fix: gem partial plus Install render. Evidence: request specs for add and owned edit.
2. Empty personalization cog stayed in the action row. Severity high for empty catalog pages. Fix: start `hidden`, reveal when deferred catalog length is non-zero after DOM parse / turbo load. Evidence: markup contract `class="relative hidden"` and `data-testid="page-personalization"`.
3. Dual emptyFooter unreachable under wrapper hide. Severity low. Fix: remove emptyFooter and footerActions targets; hide only the wrapper.
4. Redundant trigger target with wrapper hide. Severity low. Fix: remove trigger target.
5. Weak owned-state assertion via SVG fill attribute. Severity low. Fix: `data-favorited` on the star control.

Residual (accepted):

1. Empty-catalog hide is Stimulus behavior; request specs prove markup wiring, not that the class toggles in a browser. No browser driver in this tree. Category: missing coverage. Severity medium. Measure next: system example when a JS runner exists.
2. Cold gem size and RSS not re-measured this pass. Prior release audit had local ceilings. Category: resource and budget. Severity low.

Visual surface assessed (index action row): star and cog are icon buttons with accessible names; star outline versus filled by owned state; cog absent from the row until a non-empty catalog is confirmed. Narrow viewport, keyboard focus order, and contrast were not measured on a rendered browser.

Validation observed:

- `bundle exec rubocop` -> 81 files, no offenses
- `bundle exec rbs validate` -> exit 0
- `bundle exec polyrun parallel-rspec --workers 5 --merge-failures` -> exit 0

No confirmed correction remains in the reviewed delta.

## Next

- Publish `0.1.9` when ready.
- Optional later: browser-level example for empty versus non-empty catalog hide.

## Source

- `docs/changelogs/20261104141735_action-row-star-and-empty-cog.md`
- `docs/issues/20261104142000_action-row-star-and-empty-cog.md`
- `.agents/skills/engineering-audit/SKILL.md`
