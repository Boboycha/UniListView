# UniListView Development History

Detailed patch specifications were consolidated into this index. Git history retains their full text.

## 0.x Foundation

- Added virtualized card rendering, adaptive layouts and vector actions.
- Added named fields, list columns, header resizing/reordering and layout persistence.
- Added incremental search, full-width cards and hover-only actions.
- Added popup infrastructure, design-time preview, `TUniDropDown` and `TUniLookup`.
- Added JSON data adapter and stress-test demo.

## 1.0 And 1.1

- Prepared the Showcase demonstration architecture and verification workflow.
- Added multi-check behavior.
- Investigated Linux FMX presentation performance with dedicated profilers and benchmarks.
- Added popup performance diagnostics and automatic regression scenarios.

## 1.2

- Reduced unnecessary resize/layout work and stabilized rendering during window changes.

## 1.3

- Added card-tree explorer mode.
- Added three-mode tree check state.
- Added three-mode card-tree projection.
- Fixed explorer visual continuity.
- Fixed collapsed-tree projection so descendants are not duplicated as roots.

## Supporting Tools

- `demo`: primary interactive demo.
- `playground`: API coverage and exploratory scenarios.
- `FMXBaselineBenchmark`: comparison protocol for FMX rendering.
- `UniPopupPerformanceLab`: isolated popup performance measurements.
