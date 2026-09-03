# UniListView Agent Guidelines

## Role

This public repository owns reusable virtualized Delphi FMX list, card, tree, lookup and popup controls.

## Boundaries

- Keep domain-specific server, Hub and application behavior out of the package.
- Expose reusable fields, events, actions and templates instead of host-specific assumptions.
- Preserve design-time streaming compatibility for published properties.
- Avoid adding dependencies on sibling workspace projects.
- Do not include private endpoints, credentials or proprietary data examples.

## Performance Invariants

- Work must scale with visible items where virtualization is expected.
- Batch mutations through `BeginUpdate`/`EndUpdate` and avoid per-item event floods.
- Resize, hover, filtering and selection must not rebuild unrelated controls.
- Fixed-format cards and rows must not shift size because of icons or transient state.
- Tree filtering and collapse must project every source item at most once.

## Interaction Invariants

- Keyboard, mouse and touch paths must preserve selection semantics.
- Clipboard replacement must remove the selected text before insertion.
- Popup controls must handle focus, search, resizing and teardown without stale references.
- Check state must remain consistent across flat, tree and filtered projections.

## Verification

Build runtime and design packages under `packages`. Use focused smoke projects under `tests`, `demo`, `playground`, `FMXBaselineBenchmark` and `UniPopupPerformanceLab` according to the changed behavior.

Performance claims require measurements or profiler evidence. Visual changes require runtime inspection at representative sizes.

## Git

The canonical public branch is `main`. Keep public and mirror remotes synchronized only when explicitly requested. After pushing, update the parent workspace submodule pointer.
