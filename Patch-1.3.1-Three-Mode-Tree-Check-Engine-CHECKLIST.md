# Patch 1.3.1 Three-Mode Tree Check Engine Checklist

## Architecture
- [ ] Keep check state in the item/data model
- [ ] Use one check engine for all renderers
- [ ] Reuse existing tree indexes

## Public API
- [ ] Add TreeCheckMode and tri-state API
- [ ] Add public check methods
- [ ] Add check propagation events

## Check State Model
- [ ] Preserve Boolean Checked compatibility
- [ ] Store and expose Indeterminate state

## Independent Mode
- [ ] Keep items independent

## Cascade Down
- [ ] Propagate parent state to all descendants
- [ ] Do not aggregate ancestors

## Cascade Full
- [ ] Propagate state downward
- [ ] Aggregate state upward

## Downward Propagation
- [ ] Use iterative cycle-safe traversal

## Upward Aggregation
- [ ] Aggregate immediate children to root

## Indeterminate Rendering
- [ ] Render one shared horizontal-line glyph

## Hit Testing
- [ ] Keep checkbox hit separate from tree controls

## Keyboard
- [ ] Toggle focused item with Space

## Selection Independence
- [ ] Checkbox operations do not change selection

## Search and Filter
- [ ] Include hidden descendants in propagation and aggregation

## Sorting
- [ ] Keep propagation independent from visual order

## Card Tree Integration
- [ ] Use shared engine in Navigate and Hierarchy

## Regular Tree Integration
- [ ] Use shared engine in List/Tree

## Data Adapter Compatibility
- [ ] Preserve Boolean checked loading

## Performance
- [ ] Leaf Independent is O(1)
- [ ] Downward cascade is O(descendants)
- [ ] Full upward aggregation is O(depth)
- [ ] One repaint and no layout/tree rebuild per operation

## Design-Time
- [ ] TreeCheckMode serializes in FMX resources

## Packages
- [ ] Runtime package builds
- [ ] Design package builds

## Demo
- [ ] Add Tree Check Engine section
- [ ] Cover the three modes and required operations

## Windows Validation
- [ ] Runtime, design package, and demo compile
- [ ] Interaction scenarios executed

## Linux Validation
- [ ] Runtime and demo compile
- [ ] Interaction scenarios executed

## Regression
- [ ] Existing Boolean API compiles
- [ ] Tree, Card Tree, Lookup, DropDown, Popup, and JSON compile
