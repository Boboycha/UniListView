# Patch 1.3.0 — Card Tree Explorer for TUniListView

## 1. Цель

Добавить в `TUniListView` два способа отображения древовидных данных в режиме карточек:

```delphi
type
  TUniCardTreeMode = (
    ctmNavigate,
    ctmHierarchy
  );
```

`ctmNavigate` — карточный explorer: показывается только текущий уровень, переход внутрь ветки выполняется по отдельной иконке, сверху отображаются кликабельные хлебные крошки.

`ctmHierarchy` — родительская карточка с детьми занимает всю ширину, дочерние карточки отображаются ниже с отступом и поддерживают expand/collapse.

Оба режима обязаны использовать существующую внутреннюю модель дерева `TUniListView`. Отдельную модель данных для карточек не создавать.

---

## 2. Обязательные правила

Все новые и изменённые файлы:

- UTF-8 BOM;
- CRLF;
- без `with`;
- guard clauses;
- без magic numbers;
- design-time friendly;
- Linux compatible;
- без `Winapi.*` и `Vcl.*`;
- новые units добавить в runtime/design packages и проекты;
- не выполнять рефакторинг вне Patch;
- не менять существующий API без необходимости.

При изменении `UniList.Columns.pas` сохранить `System.UITypes` в `uses`.

---

## 3. Обязательный checklist

В начале работы создать:

```text
Patch-1.3.0-Card-Tree-Explorer-CHECKLIST.md
```

Checklist обязан содержать Markdown checkbox-пункты и обновляться по мере выполнения.

Разделы:

- Architecture
- Public API
- Navigate Mode
- Breadcrumbs
- Hierarchy Mode
- Rendering
- Hit Testing
- Keyboard
- Search and Filter
- Sorting
- Selection
- Checked State
- Theme
- Performance
- Design-Time
- Packages
- Demo
- Windows Validation
- Linux Validation
- Regression

Отмечать `[x]` только реально реализованные, собранные и проверенные пункты. Невыполненные и отложенные пункты не скрывать.

---

# 4. Архитектура

## 4.1 Единая модель данных

Не создавать отдельное дерево для Card Tree.

Переиспользовать существующие:

- item ID;
- parent ID;
- tree rebuild;
- filtered items;
- sorted items;
- selection;
- checked state;
- search;
- current internal item model.

Card Tree — только новый механизм формирования visible set, layout, rendering и navigation state.

## 4.2 Индексы дерева

Для быстрых операций использовать существующие индексы либо построить кэш:

```text
NodeId → ItemIndex
ParentId → ChildIndexes
NodeId → ParentId
NodeId → HasChildren
NodeId → Depth
```

Кэши перестраивать вместе с существующим tree rebuild.

Запрещено:

- искать детей полным проходом на каждом Paint;
- строить словари на каждом Paint;
- выполнять O(N) `HasChildren` для каждой карточки;
- перестраивать дерево при hover, navigation или expand/collapse.

Целевые сложности:

```text
Tree rebuild: O(N)
Navigate visible set: O(children current node)
Breadcrumb build: O(depth)
Hierarchy visible sequence: O(visible nodes)
Paint: O(visible cards)
```

---

# 5. Публичный API

## 5.1 Свойства

Добавить published-свойства:

```delphi
property CardTreeEnabled: Boolean default False;
property CardTreeMode: TUniCardTreeMode default ctmNavigate;

property CardTreeShowBreadcrumbs: Boolean default True;
property CardTreeShowRootBreadcrumb: Boolean default True;
property CardTreeRootCaption: string;
property CardTreeShowBackButton: Boolean default True;

property CardTreeParentBackgroundColor: TAlphaColor;
property CardTreeNavigationIconColor: TAlphaColor;
property CardTreeNavigationIconSize: Single;

property CardTreeHierarchyIndent: Single;
property CardTreeHierarchySpacing: Single;

property CardTreeBreadcrumbHeight: Single;
property CardTreeBreadcrumbSpacing: Single;
property CardTreeBreadcrumbTextColor: TAlphaColor;
property CardTreeBreadcrumbHotColor: TAlphaColor;
property CardTreeBreadcrumbSeparator: string;
```

Рекомендуемые default values:

```text
CardTreeEnabled=False
CardTreeMode=ctmNavigate
CardTreeShowBreadcrumbs=True
CardTreeShowRootBreadcrumb=True
CardTreeRootCaption=Root
CardTreeShowBackButton=True
CardTreeNavigationIconSize=18
CardTreeHierarchyIndent=24
CardTreeHierarchySpacing=8
CardTreeBreadcrumbHeight=36
CardTreeBreadcrumbSpacing=8
CardTreeBreadcrumbSeparator=›
```

Цвета по умолчанию получать из Theme Engine.

## 5.2 Runtime state

Добавить read-only public-свойства:

```delphi
property CardTreeCurrentNodeId: <existing node id type> read ...;
property CardTreeCurrentDepth: Integer read ...;
property CardTreeCanNavigateBack: Boolean read ...;
```

Тип ID должен соответствовать существующему типу идентификатора items.

## 5.3 Методы Navigate

```delphi
procedure CardTreeNavigateToRoot;
procedure CardTreeNavigateToParent;
procedure CardTreeNavigateToNode(const ANodeId: <existing id type>);
function CardTreeTryNavigateToNode(
  const ANodeId: <existing id type>
): Boolean;
procedure CardTreeRefresh;
```

Навигация к отсутствующему узлу или листу не должна приводить к AV или пустому некорректному состоянию.

## 5.4 Методы Hierarchy

```delphi
procedure CardTreeExpandAll;
procedure CardTreeCollapseAll;
procedure CardTreeExpandNode(const ANodeId: <existing id type>);
procedure CardTreeCollapseNode(const ANodeId: <existing id type>);
function CardTreeIsNodeExpanded(
  const ANodeId: <existing id type>
): Boolean;
```

Переиспользовать существующий expanded state дерева, если он есть.

## 5.5 События

Добавить события:

```text
OnCardTreeNavigating
OnCardTreeNavigated
OnCardTreeLevelChanged
OnCardTreeNodeExpand
OnCardTreeNodeCollapse
OnCardTreeBreadcrumbClick
```

`OnCardTreeNavigating` должен быть cancellable, если это соответствует текущему стилю событий проекта.

Не менять существующий порядок click/selection events.

---

# 6. Условия активации

Card Tree действует только при:

```text
CardTreeEnabled=True
```

и карточном режиме отображения.

В List mode:

- Card Tree не влияет на renderer;
- navigation/expanded state сохраняется;
- при возврате в Cards режим восстанавливается.

Если дерево отсутствует:

- обычные карточки работают как раньше;
- navigation icons не отображаются;
- breadcrumbs показывают только Root либо скрываются.

---

# 7. Режим `ctmNavigate`

## 7.1 Visible set

На root уровне отображать только root nodes.

После перехода внутрь parent node отображать только его непосредственных детей.

Не включать grandchildren, siblings parent и сам parent как обычную карточку.

## 7.2 Иконка перехода

Карточка с детьми получает отдельную navigation/tree icon в правом верхнем углу.

Требования:

- отдельный hit rect;
- не перекрывать checkbox, actions, badges и текст;
- не использовать emoji;
- использовать существующий icon renderer, vector path или icon font;
- одинаковая работа Windows/Linux.

Добавить отдельный hit kind, например:

```delphi
uhiCardTreeNavigate
```

или эквивалент в существующем enum.

Нажатие по иконке:

- не вызывает обычный `OnItemClick`;
- не переключает checkbox;
- не запускает card action;
- выполняет navigation.

## 7.3 Переход внутрь

Одна операция navigation должна:

1. проверить `HasChildren`;
2. вызвать cancellable `OnCardTreeNavigating`;
3. изменить current node;
4. сформировать visible set детей;
5. сбросить invalid hover;
6. исправить selection;
7. сбросить или восстановить scroll текущего уровня;
8. выполнить один layout invalidation;
9. выполнить один repaint;
10. вызвать `OnCardTreeNavigated`;
11. вызвать `OnCardTreeLevelChanged`.

Не выполнять:

- `RebuildTree`;
- `RebuildFilter`;
- повторную сортировку всего data set;
- повторный checked count.

## 7.4 Back navigation

Поддержать:

- Backspace;
- Left Arrow при допустимом контексте;
- Back button;
- breadcrumb click;
- public method.

Предпочтительно хранить per-level state:

```text
NodeId
ScrollOffset
SelectedItemId
```

При возврате желательно выбрать parent card, из которой пользователь входил.

---

# 8. Хлебные крошки

## 8.1 Вид

Пример:

```text
Root › Company › Engineering › Backend
```

Каждый segment содержит:

```text
NodeId
Caption
MeasuredWidth
Rect
Hot state
```

Сегменты кликабельны и возвращают непосредственно на выбранный уровень.

## 8.2 Caption

Caption получать в порядке:

1. специально назначенное tree caption field;
2. primary/display field карточки;
3. ID;
4. пустая строка.

Не выполнять поиск caption по items при каждом Paint. Кэшировать path captions.

## 8.3 Root

При `CardTreeShowRootBreadcrumb=True` отображать root segment с `CardTreeRootCaption`.

Root segment возвращает на корневой уровень.

## 8.4 Overflow

Если path не помещается:

```text
Root › … › Parent › Current
```

Сохранять:

- Root, если включён;
- Current всегда;
- ближайший Parent, если хватает места.

Ellipsis в Patch 1.3.0 может быть некликабельным.

Не делать горизонтальный scroll и popup menu скрытых сегментов.

## 8.5 Renderer

Breadcrumb рисовать owner-draw средствами текущего renderer.

Запрещено создавать `TLabel`, `TButton` или другие FMX controls на каждый segment.

Hover breadcrumb:

- вызывает repaint только при смене target;
- не вызывает layout invalidation;
- не измеряет весь path заново.

---

# 9. Цвет parent card

Карточка с детьми должна немного отличаться фоном.

Интегрировать с Theme Engine и текущими color rules.

Codex обязан изучить существующий порядок visual states и сохранить его. Рекомендуемый приоритет:

```text
Disabled
Selected
Pressed
Hot
Explicit item/color rule
CardTree parent background
Normal card background
```

При смене темы:

- не перестраивать tree;
- не перестраивать visible set;
- сбросить только visual caches;
- один repaint.

---

# 10. Режим `ctmHierarchy`

## 10.1 Представление

Parent с детьми отображается full-width.

Дети располагаются ниже с indent.

Leaf children одного уровня могут формировать card grid.

Пример:

```text
[ Parent A — full width ]
    [ Child 1 ] [ Child 2 ] [ Child 3 ]

    [ Parent B — full width ]
        [ Grandchild 1 ] [ Grandchild 2 ]
```

## 10.2 Layout

Для уровня:

```text
AvailableWidth =
  ClientWidth
  - LeftPadding
  - RightPadding
  - EffectiveIndent
```

Parent с детьми:

```text
Width=AvailableWidth
```

Leaf cards:

- используют существующий card grid algorithm;
- количество колонок рассчитывается внутри `AvailableWidth`;
- не выходят за границы viewport;
- при малой ширине переходят в одну колонку.

## 10.3 Ограничение indent

Большая глубина не должна уничтожать ширину карточки.

```text
EffectiveIndent =
  Min(Depth * CardTreeHierarchyIndent, MaxAllowedIndent)
```

`MaxAllowedIndent` вычислять относительно viewport и минимальной ширины карточки, без magic numbers.

## 10.4 Expand/collapse

Parent card получает отдельную expand/collapse icon.

Нажатие:

- меняет expanded state;
- обновляет hierarchy visible sequence;
- выполняет один layout invalidation;
- выполняет один repaint;
- вызывает event.

Не выполнять tree rebuild, filter rebuild, checked count или search reconfiguration.

## 10.5 Expanded state

Состояние должно сохраняться при:

- repaint;
- resize;
- theme change;
- List ↔ Cards;
- смене CardTreeMode.

После tree rebuild удалить state несуществующих nodes.

Если selected descendant скрывается collapse, selection переводится на parent.

---

# 11. Layout Engine

## 11.1 Owner-draw

Не создавать FMX-control на каждую карточку.

Использовать internal layout record, например:

```delphi
TUniCardTreeLayoutItem = record
  ItemIndex: Integer;
  NodeId: <id type>;
  Depth: Integer;
  Bounds: TRectF;
  ContentRect: TRectF;
  NavigationIconRect: TRectF;
  ExpandIconRect: TRectF;
  HasChildren: Boolean;
  IsExpanded: Boolean;
  IsFullWidthParent: Boolean;
end;
```

Можно расширить существующий layout record вместо создания дубликата.

## 11.2 Navigate layout

Использовать существующий card grid, но:

- зарезервировать место под breadcrumb;
- использовать visible set текущего уровня;
- рассчитать navigation icon rect;
- не рассчитывать descendants.

## 11.3 Hierarchy layout

Строить по visible hierarchy sequence.

Предпочтительно iterative traversal или уже существующий flattened tree.

Не создавать `TList`, dictionary или динамический массив для каждого node.

Переиспользовать buffers.

## 11.4 Invalidation

Разделить причины invalidation, если архитектура позволяет:

```text
NavigationChanged
ExpansionChanged
BreadcrumbChanged
GeometryChanged
VisualStateChanged
```

Не сбрасывать text layouts при:

- hover icon;
- hover breadcrumb;
- change selected breadcrumb segment;
- expand/collapse, если effective text widths не изменились.

---

# 12. Rendering

## 12.1 Navigate order

1. background;
2. breadcrumb background;
3. breadcrumbs;
4. cards;
5. card content;
6. navigation icons;
7. overlays;
8. scrollbar;
9. focus.

## 12.2 Hierarchy order

1. background;
2. parent/leaf cards;
3. card content;
4. expand/collapse icons;
5. overlays;
6. scrollbar;
7. focus.

Connecting tree lines не обязательны и не должны добавляться в Patch 1.3.0.

## 12.3 Paint allocations

Запрещено создавать для каждой карточки на каждом Paint:

- новые `TUniTextLayout`;
- новые fonts;
- новые paths;
- новые dictionaries;
- новые lists;
- новые динамические buffers, если их можно переиспользовать.

Breadcrumb cache инвалидировать только при изменении:

- current path;
- caption;
- font/theme;
- component width.

---

# 13. Hit Testing

Поддержать hit targets:

```text
Breadcrumb segment
Breadcrumb root
Back button
Card action
Checkbox
Card tree navigate icon
Card expand/collapse icon
Card body
Scrollbar
Background
```

Приоритеты согласовать с текущей архитектурой, исключив конфликты.

Tree icon и expand icon должны быть отдельными hits.

Hover target change вызывает только repaint.

---

# 14. Keyboard

## 14.1 Navigate

Поддержать:

- Right Arrow на parent card — открыть детей;
- Left Arrow или Backspace — parent level;
- breadcrumb/back mouse;
- public methods.

Не ломать обычную navigation selection стрелками.

`Enter` оставить с текущей семантикой item activation, если отдельное поведение не требуется.

## 14.2 Hierarchy

- Right Arrow — expand;
- Left Arrow — collapse;
- Left Arrow на collapsed node — перейти к parent selection, если совместимо;
- Enter — обычный item action.

---

# 15. Selection

## 15.1 Navigate

Selected item всегда должен принадлежать текущему visible set.

При входе:

- восстановить selection уровня, если сохранено;
- иначе выбрать первый child либо очистить selection.

При возврате:

- выбрать parent card, из которой был выполнен вход, если она видима.

## 15.2 Hierarchy

Если collapse скрывает selected descendant, selection переводится на parent.

Не оставлять визуально активный hidden selected item.

---

# 16. Checked state

Navigation и expand/collapse не должны:

- сбрасывать checks;
- пересчитывать checked count полным проходом без необходимости;
- менять parent-child propagation semantics.

---

# 17. Search

Не создавать новую Search Engine.

Codex обязан изучить существующую реализацию и выбрать минимально совместимое поведение.

Предпочтительная семантика:

## Navigate mode

- global search по data set;
- временный плоский набор результатов;
- breadcrumb показывает специальное состояние `Search Results`;
- после очистки search восстановить current node, scroll и selection.

Если глобальный поиск потребует крупного рефакторинга, допустим поиск только в текущем уровне, но это ограничение явно описать.

## Hierarchy mode

Предпочтительно:

- показывать matching nodes;
- показывать ancestor chain для контекста;
- временно раскрывать только нужные branches;
- после очистки search восстановить expanded state.

Допустим временный flat result set, если это единственный безопасный способ без переписывания Search Engine.

---

# 18. Filter

Filter применяется до Card Tree visible set.

Требования:

- parent-child relation не изменяется;
- ancestor может показываться для контекста descendant match;
- current node, исчезнувший после filter, переводится к ближайшему доступному ancestor либо root;
- пустой уровень не приводит к битому состоянию;
- использовать существующие `RebuildFilter` и `RebuildTree`;
- не выполнять дополнительные полные проходы в Paint.

---

# 19. Sorting

Sorting должен работать внутри sibling group.

Требования:

- siblings сортируются;
- разные levels не смешиваются;
- parent-child relation сохраняется;
- navigate показывает sorted children current node;
- hierarchy строит sorted child groups.

---

# 20. Empty state

Корректно обработать:

- пустой root;
- текущий node без visible children;
- filter no results;
- search no results;
- current node удалён;
- malformed parent reference.

Использовать существующий empty-state renderer.

---

# 21. Производительность

## 21.1 Запрещённые регрессии

Card Tree не должен возвращать проблемы, устранённые предыдущими patches:

- лишние layout при resize;
- постоянный timer;
- repeated SetBounds;
- repeated Repaint;
- full text-layout rebuild при hover;
- tree rebuild при navigation;
- full paint невидимых items.

## 21.2 Navigate operation

Одна navigation:

- не rebuild tree;
- не rebuild filter;
- не full sort;
- формирует только children visible set;
- один layout invalidation;
- один repaint.

## 21.3 Expand/collapse

Одна операция:

- обновляет expanded state;
- перестраивает только visible hierarchy sequence;
- один layout invalidation;
- один repaint.

## 21.4 Resize

Resize:

- не rebuild tree;
- не rebuild visible set;
- не rebuild breadcrumbs;
- пересчитывает geometry;
- text layout invalidируется только при изменении effective width;
- не создаёт heap object на node;
- один resize event не порождает duplicate invalidations.

## 21.5 Idle

В idle:

- нет timer;
- нет repaint;
- нет layout;
- нет breadcrumb recalculation;
- нет tree traversal.

## 21.6 Diagnostics

Добавить временные пассивные counters, при необходимости под conditional compilation:

```text
TreeRebuildCount
NavigateVisibleSetBuildCount
HierarchyVisibleSetBuildCount
BreadcrumbBuildCount
LayoutRecalculateCount
TextLayoutCreateCount
PaintCount
NavigationCount
ExpandCollapseCount
```

Не добавлять их в published API.

---

# 22. Theme и Design-Time

## Theme

Card Tree colors получать из существующей темы.

Theme change:

- один visual cache invalidation;
- один repaint;
- без tree rebuild и visible set rebuild.

## Design-Time

- properties видны в Object Inspector;
- `.fmx` сериализация корректна;
- никаких runtime navigation side effects;
- никаких timers;
- корректный preview при design-time items;
- отсутствие данных не вызывает ошибок.

---

# 23. Data Adapter compatibility

Patch не реализует Data Provider API.

Card Tree должен работать после загрузки через `TUniJsonDataAdapter`, если internal items имеют ID и ParentID.

Нельзя привязывать Card Tree к JSON, RTTI, dataset или REST.

---

# 24. Demo

Добавить страницу/секцию:

```text
Card Tree Explorer
```

Demo включает:

- 4+ levels;
- 50+ nodes;
- Navigate mode;
- Hierarchy mode;
- mode switch;
- breadcrumbs;
- back;
- expand/collapse;
- search;
- filter;
- sorting;
- checked items;
- selection;
- theme switch;
- continuous resize;
- popup with Card Tree;
- JSON-loaded example, если adapter уже реализован.

Тестовые данные должны содержать видимые и скрытые поля для будущего editing Patch.

---

# 25. Тестовые данные

Рекомендуемая структура:

```text
Company
├── Administration
│   ├── Management
│   └── Finance
├── Engineering
│   ├── Backend
│   │   ├── API Team
│   │   └── Data Team
│   ├── Frontend
│   └── QA
└── Operations
    ├── DevOps
    ├── Support
    └── Security
```

Поля node:

```text
id
parent_id
title
subtitle
status
code (hidden)
internal_id (hidden)
numeric value
checked state
```

---

# 26. Validation scenarios

## Navigate

- root;
- enter children;
- breadcrumb current;
- breadcrumb middle;
- root breadcrumb;
- Backspace;
- Left Arrow;
- back button;
- public methods;
- selection restore;
- scroll restore;
- current node deletion;
- empty child level;
- filter;
- search;
- sorting;
- theme;
- resize;
- popup.

## Hierarchy

- parent full width;
- leaf grid;
- nested parent;
- expand;
- collapse;
- expand all;
- collapse all;
- selection in collapsed branch;
- checked state;
- search;
- filter;
- sorting;
- deep hierarchy;
- narrow width;
- resize;
- popup.

## Performance

Проверить:

```text
100
1,000
10,000 items
```

Для каждого:

- initial tree build;
- first paint;
- navigate;
- back;
- expand;
- collapse;
- continuous resize;
- icon hover;
- breadcrumb click;
- search;
- filter;
- popup open;
- idle.

Windows и Linux.

Сравнивать counters и отсутствие лишних rebuild, а не абсолютные ms конкретной машины.

---

# 27. Regression

Не сломать:

- List;
- Cards;
- FullWidth Cards;
- existing Tree;
- Search;
- Filter;
- Sorting;
- Selection;
- MultiSelect;
- Checked items;
- Columns;
- Footer;
- Card actions;
- Color rules;
- Theme;
- Lookup;
- DropDown;
- Popup;
- Resize;
- Windows;
- Linux.

---

# 28. Acceptance Criteria

Patch завершён, если:

- [ ] enum добавлен;
- [ ] default behavior не изменён при `CardTreeEnabled=False`;
- [ ] Navigate mode работает;
- [ ] Hierarchy mode работает;
- [ ] navigation icon и отдельный hit-test работают;
- [ ] parent background интегрирован с Theme;
- [ ] breadcrumbs кликабельны;
- [ ] breadcrumb overflow работает;
- [ ] back navigation работает;
- [ ] public methods работают;
- [ ] hierarchy parent full-width;
- [ ] children indent;
- [ ] leaf grid;
- [ ] expand/collapse;
- [ ] expanded state сохраняется;
- [ ] selection валиден;
- [ ] checked state сохраняется;
- [ ] search не ломает tree;
- [ ] filter не ломает tree;
- [ ] sorting sibling-based;
- [ ] resize не rebuild tree;
- [ ] hover не вызывает layout;
- [ ] Paint обрабатывает visible cards;
- [ ] HasChildren не O(N) на карточку;
- [ ] нет нового постоянного timer;
- [ ] idle activity отсутствует;
- [ ] Popup regression отсутствует;
- [ ] Windows build;
- [ ] Linux build;
- [ ] runtime package;
- [ ] design-time package;
- [ ] demo;
- [ ] Object Inspector serialization;
- [ ] UTF-8 BOM + CRLF;
- [ ] no `with`;
- [ ] no magic numbers;
- [ ] guard clauses;
- [ ] checklist создан и обновлён;
- [ ] remaining/deferred пункты указаны.

---

# 29. Не входит в Patch

Не реализовывать:

- Data Provider API;
- editing visible/hidden fields;
- inline editor;
- form editor;
- REST/HTTP;
- async paging;
- virtual provider;
- drag-and-drop tree;
- animated transitions;
- breadcrumb popup menu;
- connecting lines;
- lazy network loading;
- новый Search Engine;
- новый Filter Engine;
- новый Theme Engine.

---

# 30. Порядок реализации

1. Создать checklist.
2. Изучить текущую tree model и ID types.
3. Добавить enum/properties/method signatures.
4. Реализовать/reuse tree indexes.
5. Реализовать Navigate visible set.
6. Реализовать breadcrumb model/cache.
7. Реализовать Navigate layout.
8. Реализовать Navigate renderer.
9. Реализовать Navigate hit-test.
10. Реализовать methods/events/keyboard.
11. Реализовать Hierarchy visible sequence.
12. Реализовать expanded state.
13. Реализовать Hierarchy layout.
14. Реализовать Hierarchy renderer/hit-test.
15. Интегрировать selection/checks.
16. Интегрировать Search/Filter/Sorting.
17. Интегрировать Theme.
18. Добавить demo.
19. Добавить diagnostics.
20. Проверить performance.
21. Проверить Windows.
22. Проверить Linux.
23. Regression.
24. Обновить checklist.
25. Итоговый отчёт.

Не начинать renderer до проверки visible-set architecture.

---

# 31. Итоговый отчёт Codex

```text
Implemented:
- ...

Architecture:
- ...

Public API:
- ...

Navigate Mode:
- ...

Breadcrumbs:
- ...

Hierarchy Mode:
- ...

Performance:
- ...

Files added:
- ...

Files changed:
- ...

Packages:
- runtime: ...
- design-time: ...

Validation:
- Windows: ...
- Linux: ...
- Demo: ...
- Regression: ...

Checklist:
- completed: ...
- remaining: ...
- deferred: ...

Known limitations:
- ...
```

Не вставлять полные исходники.

Главный результат:

```text
TUniListView Card Tree Explorer
```

с режимами:

```text
ctmNavigate
ctmHierarchy
```

на единой модели данных, с хлебными крошками, hierarchy layout и без регрессии производительности.
