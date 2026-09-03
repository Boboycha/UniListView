# UniListView Features

## Core List

- Virtualized FMX rendering for large item collections.
- Card grid, full-width list and horizontal-strip layouts.
- Mouse wheel, touch/pointer panning and draggable scrollbars.
- Stable resize behavior with batched layout and update controls.
- Named item fields with string, Boolean, integer and date/time accessors.

## Cards And Actions

- Design-time `CardTemplate` configuration.
- Configurable icon, title, text, detail and action regions.
- Vector action icons with normal, hover, pressed and disabled states.
- Action visibility can be always-on or hover-only.
- Card sizing can follow fixed dimensions or title/content constraints.

## List Columns

- Design-time `Columns` collection.
- Sorting from headers, column reorder and resize.
- Double-click AutoFit based on header and data.
- Column visibility menu.
- JSON/file layout persistence keyed by `LayoutID` with `FieldName` fallback.

## Search And Selection

- Incremental search without mutating source data.
- Normal text selection, clipboard replacement and multi-click selection behavior.
- Single selection and multi-check workflows.
- Three-state tree checking with explicit, inherited and partial state.

## Trees

- Hierarchical card/tree projection.
- Collapsed descendants remain hidden and are not duplicated as root nodes.
- Filtering retains ancestor context while projecting each node once.
- Explorer-style visual continuity and indentation.

## Popup Controls

- Reusable popup infrastructure with content-width measurement and resizing.
- `TUniDropDown` and searchable `TUniLookup` controls.
- Design-time preview and popup diagnostics hooks.

## Data Adapters

- JSON adapter for loading structured records into named fields.
- Batched updates for stress workloads and large datasets.

See `README.md` for installation and examples. Historical patch specifications are available through Git history.
