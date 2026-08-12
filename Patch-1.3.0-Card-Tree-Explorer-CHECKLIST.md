# Patch 1.3.0 Card Tree Explorer Checklist

## Architecture
- [x] Reuse the existing item and tree model
- [x] Build persistent O(N) tree indexes outside Paint
- [x] Build navigate visible set in O(children)
- [x] Build hierarchy visible sequence in O(visible nodes)

## Public API
- [x] Add Card Tree enum and published properties
- [x] Add read-only runtime state
- [x] Add navigation and hierarchy methods
- [x] Add Card Tree events

## Navigate Mode
- [x] Root and child-level visible sets
- [x] Navigation, parent navigation, and state restoration

## Breadcrumbs
- [x] Cached breadcrumb path and captions
- [x] Clickable segments and overflow
- [x] Root and back controls

## Hierarchy Mode
- [x] Full-width parent layout
- [x] Indented leaf grids
- [x] Expand/collapse using existing expanded state

## Rendering
- [x] Parent visual state
- [x] Navigation and expand/collapse vector icons
- [x] Visible-card-only paint

## Hit Testing
- [x] Dedicated Card Tree icon hits
- [x] Breadcrumb and back hits
- [x] Preserve action, checkbox, card, and scrollbar priority

## Keyboard
- [x] Navigate mode Right, Left, and Backspace
- [x] Hierarchy mode Right and Left

## Search and Filter
- [x] Search-compatible Card Tree visible set
- [x] Filter-compatible current node and hierarchy

## Sorting
- [x] Preserve sibling grouping and sorted order

## Selection
- [x] Keep selection inside the visible set
- [x] Repair selection after navigation and collapse

## Checked State
- [x] Preserve checks during navigation and expansion

## Theme
- [x] Theme-derived default Card Tree colors
- [x] Theme changes avoid tree rebuild

## Performance
- [x] No tree rebuild on navigation or expansion
- [x] No O(N) child lookup in Paint
- [x] No layout invalidation on hover
- [x] No idle timer or repaint

## Design-Time
- [x] Published properties serialize in FMX resources
- [x] Design preview has no navigation side effects

## Packages
- [x] Runtime package builds
- [x] Design-time package builds

## Demo
- [x] Add Card Tree Explorer page
- [x] Add 4+ levels and 50+ nodes
- [ ] Cover modes, navigation, search, filter, sorting, checks, popup, and resize

## Windows Validation
- [x] Runtime and demo compile for Windows
- [ ] Windows interaction scenarios executed

## Linux Validation
- [x] Runtime and demo compile for Linux
- [ ] Linux interaction scenarios executed

## Regression
- [x] Existing List and Cards behavior preserved when disabled
- [x] Existing Tree, Lookup, DropDown, Popup, Search, Filter, and MultiCheck compile
