# UniListView Playground API coverage

The Playground targets API declared by `TUniListView` and its directly exposed
data/configuration classes. Inherited FMX properties are outside this scope.

| Area | Coverage |
|---|---|
| View | `ViewMode`, `CardLayout`, Cards/List, `ActionVisibility` |
| Scrolling | All scroll, pan, scrollbar and content-flow modes; positions and navigation |
| Cards | All sizing modes, geometry, presets and `CardTemplate` properties |
| List | Header, rows, auto height, filter row, footer, frozen columns and grid |
| Columns | All published column properties, filters, roles, aggregates and `Assign` |
| Actions | All action properties, visibility modes, collection operations and `Assign` |
| Items | Add/clear/delete, typed fields, compatibility values, object/color fields, enumerator and both sort APIs |
| Selection | Selection navigation, selected text and scrolling |
| Tree | Fields, lazy loading, expand/collapse, levels, loaded-child state and event |
| Card Tree | Navigate, Hierarchy and Explorer modes; all properties, commands, state and events |
| MultiCheck | All modes, scopes, item/key/state APIs, enumerators, counts and events |
| Search | All options, next/previous/clear, running/match state and event |
| Filters | Column filter properties and `ClearFilters` |
| Navigation | Count, index mapping, page size and column display text |
| Color rules | All rule properties, collection operations and `Matches` |
| Colors | Every published component color plus presets |
| Themes | Built-in names, selection, YAML loading, variant and theme-definition information |
| Fonts | Family, body, title and detail sizes |
| Layout | JSON and file save/load |
| DataSource | Bind/unbind a live sample `TClientDataSet` |
| Design preview | All preview modes and row count |
| Performance | Reset, snapshot and report |
| Events | Item, action, check, search, lazy tree and every Card Tree event |
| Diagnostics | Read-only geometry, search, check, theme and Card Tree state |

Collection `OnChanged` callbacks are owned by `TUniListView`; collection changes
exercise them indirectly. Replacing those callbacks in Playground would break
the component's normal invalidation and synchronization.

