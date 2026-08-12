# Patch 1.3.2 — Three-Mode Card Tree for TUniListView

## 1. Цель Patch

Расширить `TUniListView Card Tree Explorer` и окончательно закрепить три режима представления дерева карточками:

```delphi
type
  TUniCardTreeMode = (
    ctmExplorer,
    ctmNavigate,
    ctmHierarchy
  );
```

Режимы должны использовать:

- одну модель дерева;
- один набор tree indexes;
- один Check Engine;
- общие правила selection;
- общий Search/Filter pipeline;
- общий Theme Engine;
- общий owner-draw renderer;
- общую систему hit-test;
- общие performance caches.

Нельзя создавать три независимые реализации дерева.

---

# 2. Смысл режимов

## 2.1 `ctmExplorer`

Стартовый смешанный режим.

На экране отображаются **все элементы текущего обычного карточного набора плоско**, без раскрытия дерева и без визуального indentation.

Карточки, имеющие дочерние элементы:

- слегка отличаются фоном;
- имеют отдельную navigation/tree icon;
- могут показывать количество непосредственных детей;
- остаются обычными карточками для selection, checkbox и actions.

Нажатие на navigation icon parent-карточки:

- переводит компонент во внутреннее навигационное состояние;
- отображает непосредственных детей выбранного parent;
- включает breadcrumb;
- дальнейшее поведение соответствует `ctmNavigate`.

Важно: публичное свойство `CardTreeMode` остаётся `ctmExplorer`. Компонент не должен самовольно менять его на `ctmNavigate`.

То есть `ctmNavigate` внутри Explorer используется как **navigation presentation state**, а не как изменение published mode.

---

## 2.2 `ctmNavigate`

Чистый навигационный режим.

На root отображаются только root nodes.

После входа в parent отображаются только его непосредственные children.

Всегда действует логика:

```text
Root → Current level → Child level
```

с breadcrumb и back navigation.

---

## 2.3 `ctmHierarchy`

Полное дерево отображается в одном viewport.

Parent-карточки:

- занимают всю доступную ширину;
- имеют expand/collapse icon;
- children располагаются ниже;
- children получают indentation;
- leaf-карточки одного уровня могут формировать grid.

---

# 3. Обязательные правила проекта

Все новые и изменённые файлы:

- UTF-8 BOM;
- CRLF;
- без `with`;
- guard clauses;
- без magic numbers;
- design-time friendly;
- Linux compatible;
- без `Winapi.*` и `Vcl.*`;
- новые units добавить в runtime и design packages;
- не выполнять посторонний рефакторинг;
- сохранять backward compatibility.

При изменении `UniList.Columns.pas` обязательно сохранить:

```delphi
System.UITypes
```

---

# 4. Обязательный checklist

Codex обязан создать:

```text
Patch-1.3.2-Three-Mode-Card-Tree-CHECKLIST.md
```

Разделы checklist:

- Architecture Review
- Existing Card Tree Regression
- Public API
- Explorer Visible Set
- Explorer Parent Detection
- Explorer Rendering
- Explorer Navigation
- Navigate State Reuse
- Breadcrumbs
- Hierarchy Regression
- Hit Testing
- Mouse
- Keyboard
- Selection
- Check Engine Integration
- Search
- Filter
- Sorting
- Theme
- Performance
- Design-Time
- Packages
- Demo
- Windows Validation
- Linux Validation
- Regression

Отмечать `[x]` только после реализации и проверки.

---

# 5. Публичный API

## 5.1 Enum

Итоговый enum:

```delphi
type
  TUniCardTreeMode = (
    ctmExplorer,
    ctmNavigate,
    ctmHierarchy
  );
```

Если enum уже опубликован в `.fmx`, важно учитывать ordinal compatibility.

Если прежний enum был:

```delphi
ctmNavigate = 0
ctmHierarchy = 1
```

нельзя просто вставить `ctmExplorer` первым и бездумно изменить ordinal values сохранённых форм.

Безопасный вариант:

```delphi
type
  TUniCardTreeMode = (
    ctmNavigate,
    ctmHierarchy,
    ctmExplorer
  );
```

но published-порядок будет не таким, как желаемый логический порядок.

Предпочтительное решение Codex должен выбрать после проверки существующей сериализации:

1. сохранить ordinal compatibility;
2. либо добавить migration/read compatibility;
3. не ломать старые `.fmx`.

В исходниках и документации логический порядок режимов остаётся:

```text
Explorer
Navigate
Hierarchy
```

---

## 5.2 Default mode

Для новых компонентов рекомендуется:

```delphi
CardTreeMode := ctmExplorer;
```

Но если изменение default сломает существующие формы или тесты, сохранить прежний default и явно указать это в отчёте.

Обратная совместимость важнее косметического default.

---

## 5.3 Explorer properties

Добавить или переиспользовать:

```delphi
property CardTreeExplorerShowChildCount: Boolean
  read ...
  write ...
  default True;

property CardTreeExplorerNavigateOnCardClick: Boolean
  read ...
  write ...
  default False;

property CardTreeExplorerParentEmphasis: Single
  read ...
  write ...;

property CardTreeExplorerKeepFlatOrder: Boolean
  read ...
  write ...
  default True;
```

### Семантика

`CardTreeExplorerShowChildCount`

- показывает количество непосредственных детей;
- не количество всех descendants;
- count берётся из tree index;
- не вычисляется полным проходом в Paint.

`CardTreeExplorerNavigateOnCardClick`

- `False`: переход только по navigation icon;
- `True`: click по body parent-card также открывает ветку;
- checkbox/actions сохраняют более высокий hit priority.

`CardTreeExplorerParentEmphasis`

- управляет степенью визуального отличия parent-card;
- должен влиять на Theme-derived color;
- не должен требовать пользовательского ручного цвета.

`CardTreeExplorerKeepFlatOrder`

- `True`: отображается обычный текущий flat/sorted/filtered набор;
- tree relation используется только для определения parent cards;
- descendants не скрываются на стартовом Explorer screen.

---

## 5.4 Runtime state

Добавить read-only state:

```delphi
property CardTreeNavigationActive: Boolean read ...;
property CardTreeCurrentNodeId: <existing id type> read ...;
property CardTreeCurrentDepth: Integer read ...;
property CardTreeCanNavigateBack: Boolean read ...;
```

Значения:

### Explorer root screen

```text
CardTreeMode = ctmExplorer
CardTreeNavigationActive = False
CurrentNodeId = empty/root
CurrentDepth = 0
```

### Explorer after opening parent

```text
CardTreeMode = ctmExplorer
CardTreeNavigationActive = True
CurrentNodeId = opened parent
CurrentDepth >= 1
```

### Navigate mode

```text
CardTreeMode = ctmNavigate
CardTreeNavigationActive = True
```

даже на root level, поскольку сам presentation mode навигационный.

### Hierarchy mode

```text
CardTreeNavigationActive = False
```

---

## 5.5 Public methods

Существующие navigation methods должны работать и в Explorer:

```delphi
procedure CardTreeNavigateToRoot;
procedure CardTreeNavigateToParent;
procedure CardTreeNavigateToNode(const ANodeId: <id type>);
function CardTreeTryNavigateToNode(
  const ANodeId: <id type>
): Boolean;
```

Добавить:

```delphi
procedure CardTreeExitNavigation;
```

Семантика:

- в `ctmExplorer` возвращает на flat Explorer screen;
- в `ctmNavigate` эквивалентна переходу на root;
- в `ctmHierarchy` ничего не делает.

Допустимо добавить:

```delphi
procedure CardTreeEnterExplorerNode(
  const ANodeId: <id type>
);
```

только если это не дублирует `CardTreeNavigateToNode`.

---

# 6. Архитектура состояния

Не путать:

```text
Configured mode
Presentation state
Current node
```

Нужно иметь минимум:

```delphi
FCardTreeMode: TUniCardTreeMode;
FCardTreeNavigationActive: Boolean;
FCardTreeCurrentNodeId: <id type>;
```

Не использовать изменение `FCardTreeMode` как способ входа внутрь Explorer.

Иначе возникнут проблемы:

- Object Inspector внезапно изменит режим;
- mode switch event вызовется ошибочно;
- пользователь не сможет вернуться именно в Explorer;
- `.fmx` state станет непредсказуемым;
- demo будет показывать неверный режим.

---

# 7. Explorer visible set

## 7.1 Стартовый экран

При:

```text
CardTreeMode=ctmExplorer
CardTreeNavigationActive=False
```

использовать обычный flat visible set текущего Cards mode после:

1. source items;
2. filter;
3. search;
4. sorting;
5. visibility rules.

Не ограничивать его root nodes.

Не скрывать children.

Не добавлять indentation.

Не перестраивать отдельную hierarchy sequence.

---

## 7.2 Parent detection

Для каждого visible item определить:

```text
HasChildren
DirectChildCount
```

через существующий tree index.

Недопустимо:

```text
HasChildren = полный проход по items
```

на каждую visible card.

---

## 7.3 Вход в navigation state

При click navigation icon parent-card:

1. убедиться, что node существует;
2. убедиться, что имеет children;
3. вызвать cancellable `OnCardTreeNavigating`;
4. сохранить Explorer flat state:
   - scroll offset;
   - selected item;
   - hot item при необходимости;
5. установить `CardTreeNavigationActive=True`;
6. установить current node;
7. построить visible set непосредственных children;
8. построить breadcrumb;
9. скорректировать selection;
10. выполнить один geometry/layout invalidation;
11. выполнить один repaint;
12. вызвать navigation events.

Не менять `CardTreeMode`.

---

## 7.4 Выход из navigation state

В `ctmExplorer` click Root breadcrumb либо `CardTreeExitNavigation`:

1. установить `CardTreeNavigationActive=False`;
2. очистить current node/path;
3. вернуть flat Explorer visible set;
4. восстановить Explorer scroll;
5. восстановить Explorer selection, если item ещё существует и видим;
6. выполнить один layout invalidation;
7. выполнить один repaint.

На промежуточных breadcrumb segments navigation остаётся active.

---

# 8. Explorer rendering

## 8.1 Обычные карточки

Leaf cards отображаются точно как обычные Cards.

Patch не должен менять их:

- background;
- padding;
- content;
- checkbox;
- selection;
- actions;
- footer;
- badges.

---

## 8.2 Parent cards

Parent cards получают:

- слегка изменённый background;
- navigation icon;
- optional child-count badge;
- hot state navigation icon;
- tooltip/accessibility text, если инфраструктура уже есть.

Visual emphasis не должен превращать parent в header.

Parent остаётся обычной карточкой в grid.

---

## 8.3 Child-count badge

Если включён:

```text
3
12
99+
```

Рекомендуется отображать непосредственное количество детей.

Правила:

- значение берётся из кэша;
- badge не является отдельным FMX control;
- badge не должен конфликтовать с actions;
- overflow format определяется существующей badge architecture;
- не добавлять locale-dependent строку в Paint.

---

## 8.4 Breadcrumb

На flat Explorer screen breadcrumb не показывать.

После входа:

```text
Root › Parent › Child
```

Breadcrumb использует уже реализованную логику `ctmNavigate`.

Root breadcrumb в Explorer означает:

```text
выйти из navigation state и вернуться к flat Explorer
```

В чистом `ctmNavigate` Root означает:

```text
показать root nodes
```

Это различие должно быть явно реализовано.

---

# 9. Hit Testing

Добавить/переиспользовать hit kinds:

```text
Card body
Checkbox
Card action
Explorer navigation icon
Explorer child-count badge
Breadcrumb
Back button
Hierarchy expand/collapse
Scrollbar
```

Child-count badge:

- по умолчанию не отдельное действие;
- может входить в navigation icon hit zone;
- не должен перехватывать checkbox/actions.

Приоритет:

1. scrollbar/resize;
2. breadcrumb/back;
3. checkbox;
4. card actions;
5. hierarchy expand;
6. Explorer/navigation icon;
7. card body;
8. background.

Уточнить по существующей архитектуре, но конфликты исключить.

---

# 10. Mouse behavior

## 10.1 Explorer leaf

Click body:

- обычный item click;
- обычная selection;
- никакой navigation.

## 10.2 Explorer parent

При `CardTreeExplorerNavigateOnCardClick=False`:

- body click — обычный item click;
- navigation icon click — вход внутрь.

При `True`:

- body click parent — вход внутрь;
- checkbox/action hit сохраняет приоритет;
- обычный item activation event не должен дублироваться.

## 10.3 Hover

Hover navigation icon:

- repaint только при смене target;
- без layout invalidation;
- без tree traversal;
- без повторного child count;
- без text layout rebuild.

---

# 11. Keyboard

## Explorer flat screen

- стрелки — обычная card selection;
- Right Arrow на parent — открыть ветку;
- Enter — существующий item action;
- Space — checkbox через общий Tree Check Engine.

## Explorer navigation state

- Left Arrow/Backspace — parent level;
- на top navigation level Backspace/Left Arrow — выйти в flat Explorer;
- Right Arrow на parent — открыть child level;
- Escape допустимо использовать для выхода в flat Explorer, если не конфликтует с popup.

## Navigate

Сохранить существующее поведение.

## Hierarchy

Сохранить expand/collapse keyboard behavior.

---

# 12. Selection

## Explorer flat

Selection работает по flat visible set.

## Вход внутрь

Сохранить:

```text
ExplorerSelectedItemId
ExplorerScrollOffset
```

В child level:

- восстановить level state, если уже посещался;
- иначе выбрать первый child либо очистить selection.

## Выход

Восстановить selected parent/previous flat item, если он существует и проходит filter/search.

Не оставлять selected item, отсутствующий в active visible set.

---

# 13. Check Engine integration

Patch должен использовать `Patch 1.3.1 — Three-Mode Tree Check Engine`.

Во всех режимах:

```text
tcmIndependent
tcmCascadeDown
tcmCascadeFull
```

работают одинаково.

Explorer flat screen показывает одновременно parent и descendants, поэтому после cascade:

- обновить все visible affected cards;
- выполнить один repaint;
- не перестраивать layout;
- не перестраивать tree.

Click checkbox parent не должен открывать navigation.

---

# 14. Search

## 14.1 Explorer flat state

Search работает как обычный Cards search по flat set.

Parent emphasis и icon определяются по underlying tree, даже если дети не вошли в search results.

## 14.2 Explorer navigation state

Использовать уже выбранную семантику Patch 1.3.0:

- global flat Search Results либо current-level search;
- не создавать новую Search Engine.

После очистки search восстановить:

- navigation active;
- current node;
- breadcrumb;
- level scroll;
- selection.

## 14.3 Search result parent

Если result имеет children в underlying tree, navigation icon сохраняется.

Нажатие открывает ветку согласно обычной navigation logic.

---

# 15. Filter

Explorer flat set строится после filter.

`HasChildren` определяется по underlying tree, а не только по visible filtered items.

Но navigation icon должен быть доступен только если после filter у parent есть хотя бы один доступный child, либо component должен показать корректный empty state.

Codex обязан выбрать и документировать один вариант:

### Предпочтительно

```text
HasNavigableChildren = filtered accessible child count > 0
```

При этом parent может оставаться визуально parent, но icon disabled/hidden при отсутствии доступных детей.

Не открывать пустой уровень.

---

# 16. Sorting

Explorer flat screen сохраняет обычный текущий flat sorting.

Не применять sibling-only sorting на flat Explorer screen, если это изменит существующий card order.

В navigation state использовать sibling sorting children current node.

Hierarchy сохраняет sibling sorting.

---

# 17. Mode switching

## Explorer → Navigate

- выйти из Explorer internal navigation;
- `CardTreeMode=ctmNavigate`;
- показать Navigate root либо сохранить current node только если политика явно определена.

Предпочтительно сохранить current node, если navigation уже active.

## Explorer → Hierarchy

- завершить navigation presentation;
- построить hierarchy visible sequence;
- сохранить navigation state отдельно, чтобы при возврате в Explorer его можно было восстановить либо безопасно сбросить.

Предпочтительно сбрасывать Explorer navigation при explicit mode switch для предсказуемости.

## Navigate → Explorer

- установить Explorer flat state;
- `CardTreeNavigationActive=False`;
- не оставлять Navigate root-only visible set.

## Hierarchy → Explorer

- flat set;
- без indentation;
- без expanded sequence.

Каждый explicit mode switch:

- один visible-set rebuild;
- один layout invalidation;
- один repaint;
- без tree rebuild.

---

# 18. Theme

Добавить Theme-derived значения:

```text
Explorer parent background
Explorer parent hot background
Explorer navigation icon
Explorer child-count badge
Explorer navigation icon hot
```

Использовать `CardTreeExplorerParentEmphasis` для смешивания normal card background и parent background.

Не применять жёстко заданный цвет.

Theme change:

- сброс visual caches;
- один repaint;
- без visible-set rebuild;
- без breadcrumb path rebuild;
- без tree rebuild.

---

# 19. Performance

## 19.1 Target complexity

```text
Explorer flat visible set: existing complexity
Parent detection: O(1) per visible item
Child count: O(1) per visible item
Enter node: O(children + depth)
Exit navigation: O(flat visible count only if required)
Breadcrumb: O(depth)
Paint: O(visible cards)
Hover: O(1) state change
```

Недопустимо:

```text
Paint O(N²)
HasChildren O(N) per card
ChildCount O(N) per card
Tree rebuild при enter/exit
Search rebuild при hover
Layout rebuild при icon hover
```

---

## 19.2 Reuse Patch 1.3.0 caches

Переиспользовать:

```text
NodeId → ItemIndex
ParentId → ChildIndexes
NodeId → ParentId
Current breadcrumb
Navigate visible indexes
Hierarchy visible indexes
Layout rects
Per-level navigation state
```

Добавить только:

```text
Explorer flat scroll state
Explorer flat selected item
Explorer navigation active flag
```

Не дублировать existing caches.

---

## 19.3 Paint allocations

Explorer Paint не должен создавать:

- dictionary;
- child list;
- breadcrumb list;
- new text layouts;
- per-card dynamic array;
- FMX control.

Child count badge metrics кэшировать либо рассчитывать существующим дешёвым text path.

---

## 19.4 Idle

В idle:

- никаких timers;
- никаких tree traversal;
- никаких breadcrumb updates;
- никаких repaint;
- никаких state polling.

---

## 19.5 Resize

Resize:

- не меняет configured mode;
- не меняет navigation active;
- не rebuild tree;
- не rebuild child indexes;
- пересчитывает только geometry;
- text layout сбрасывается только при effective width change;
- один resize cycle не должен вызывать duplicate layout passes.

---

# 20. Design-Time

Object Inspector должен показывать:

```text
CardTreeMode
CardTreeExplorerShowChildCount
CardTreeExplorerNavigateOnCardClick
CardTreeExplorerParentEmphasis
CardTreeExplorerKeepFlatOrder
```

Design-time preview:

- parent cards выделены;
- icons отображаются;
- runtime navigation не запускается;
- никаких timers;
- `.fmx` сохраняется;
- старые `.fmx` загружаются.

Особенно проверить enum ordinal compatibility.

---

# 21. Demo

Обновить страницу `Card Tree Explorer`.

Добавить selector:

```text
Explorer
Navigate
Hierarchy
```

Explorer demo обязан показывать:

- flat cards из разных levels;
- leaf cards;
- parent cards;
- parent emphasis;
- child count;
- icon-only navigation;
- optional navigate-on-card-click;
- breadcrumb после входа;
- возврат Root → flat Explorer;
- Tree Check Engine modes;
- Search;
- Filter;
- Sorting;
- Theme switch;
- continuous resize;
- popup.

---

# 22. Validation scenarios

## Explorer

1. Все flat cards видимы.
2. Children не скрыты.
3. Indentation отсутствует.
4. Parent cards выделены.
5. Leaf cards не выделены.
6. Child count корректен.
7. Navigation icon только у parent.
8. Icon click открывает immediate children.
9. `CardTreeMode` остаётся `ctmExplorer`.
10. `CardTreeNavigationActive=True`.
11. Breadcrumb появляется.
12. Root breadcrumb возвращает flat Explorer.
13. Scroll восстанавливается.
14. Selection восстанавливается.
15. Checkbox не открывает ветку.
16. Action button не открывает ветку.
17. Search result parent navigable.
18. Filter не открывает empty level.
19. Sorting flat order сохраняется.
20. Theme change не rebuild tree.
21. Resize не rebuild tree.
22. Idle без активности.

## Navigate

Повторить regression Patch 1.3.0.

## Hierarchy

Повторить regression Patch 1.3.0.

## Check Engine

Проверить три режима Patch 1.3.1 во всех трёх Card Tree modes.

---

# 23. Performance validation

Данные:

```text
100
1,000
10,000
100,000 items
```

Проверить:

- first Explorer paint;
- hover parent icon;
- enter parent;
- enter nested parent;
- back;
- Root → Explorer flat;
- mode switch;
- search;
- filter;
- check cascade;
- resize;
- popup;
- idle.

Диагностические counters:

```text
TreeRebuildCount
ExplorerVisibleSetBuildCount
NavigateVisibleSetBuildCount
HierarchyVisibleSetBuildCount
BreadcrumbBuildCount
LayoutRecalculateCount
PaintCount
TextLayoutCreateCount
```

Не устанавливать жёсткие ms для конкретной машины.

Критерий — отсутствие лишних rebuild и правильная алгоритмическая сложность.

---

# 24. Regression

Не сломать:

- ordinary List;
- ordinary Cards;
- FullWidth Cards;
- existing Tree;
- ctmNavigate;
- ctmHierarchy;
- Three-Mode Tree Check Engine;
- selection;
- multi-select;
- actions;
- checkboxes;
- search;
- filter;
- sorting;
- themes;
- popup;
- lookup;
- dropdown;
- Windows;
- Linux.

---

# 25. Acceptance Criteria

Patch завершён, если:

- [ ] `ctmExplorer` добавлен безопасно для `.fmx`;
- [ ] Explorer показывает flat cards;
- [ ] descendants не скрываются на flat screen;
- [ ] parent cards визуально выделены;
- [ ] child count работает;
- [ ] navigation icon работает;
- [ ] icon имеет отдельный hit-test;
- [ ] checkbox не запускает navigation;
- [ ] action не запускает navigation;
- [ ] переход не меняет `CardTreeMode`;
- [ ] используется `CardTreeNavigationActive`;
- [ ] breadcrumb появляется после входа;
- [ ] Root breadcrumb возвращает flat Explorer;
- [ ] selection корректен;
- [ ] scroll state корректен;
- [ ] Navigate regression отсутствует;
- [ ] Hierarchy regression отсутствует;
- [ ] Check Engine работает во всех режимах;
- [ ] Search работает;
- [ ] Filter работает;
- [ ] Sorting работает;
- [ ] Theme работает;
- [ ] Object Inspector работает;
- [ ] старые `.fmx` загружаются;
- [ ] no tree rebuild при enter/exit;
- [ ] no layout rebuild при hover;
- [ ] HasChildren/ChildCount O(1);
- [ ] Paint только visible cards;
- [ ] idle activity отсутствует;
- [ ] Windows build;
- [ ] Linux build;
- [ ] runtime package;
- [ ] design package;
- [ ] demo;
- [ ] checklist обновлён;
- [ ] remaining/deferred указаны.

---

# 26. Что не входит в Patch

Не реализовывать:

- animated page transitions;
- lazy network loading;
- breadcrumb popup menu;
- drag-and-drop;
- separate Explorer data provider;
- custom parent templates;
- per-node mode override;
- новый Search Engine;
- новый Filter Engine;
- новый Theme Engine;
- editing fields;
- REST;
- async virtual paging.

---

# 27. Порядок реализации

1. Создать checklist.
2. Проверить текущий enum и `.fmx` ordinal compatibility.
3. Изучить Patch 1.3.0 implementation.
4. Добавить `ctmExplorer`.
5. Разделить configured mode и navigation state.
6. Реализовать Explorer flat visible set.
7. Подключить O(1) parent/child count.
8. Реализовать Explorer rendering.
9. Реализовать child-count badge.
10. Реализовать Explorer hit-test.
11. Подключить navigation engine Patch 1.3.0.
12. Реализовать Root → flat Explorer semantics.
13. Подключить mouse/keyboard.
14. Интегрировать selection/scroll state.
15. Интегрировать Tree Check Engine.
16. Интегрировать Search/Filter/Sorting.
17. Интегрировать Theme.
18. Проверить mode switching.
19. Обновить demo.
20. Добавить diagnostics.
21. Проверить performance.
22. Windows validation.
23. Linux validation.
24. Regression.
25. Обновить checklist.
26. Итоговый отчёт.

---

# 28. Итоговый отчёт Codex

```text
Implemented:
- ...

Enum compatibility:
- ...

Explorer:
- Flat visible set:
- Parent emphasis:
- Child count:
- Navigation:

Navigate reuse:
- ...

Hierarchy regression:
- ...

Check Engine integration:
- ...

Search/Filter/Sorting:
- ...

Performance:
- ...

Files added:
- ...

Files changed:
- ...

Packages:
- runtime:
- design-time:

Validation:
- Windows:
- Linux:
- Demo:
- Regression:

Checklist:
- completed:
- remaining:
- deferred:

Known limitations:
- ...
```

---

# 29. Итоговая модель

```text
ctmExplorer
    Flat Cards
        ↓ click parent navigation icon
    Navigate Presentation
        ↓ Root breadcrumb / ExitNavigation
    Flat Cards

ctmNavigate
    Root Nodes
        ↓
    Child Levels

ctmHierarchy
    Full Tree in One Viewport
```

Все три режима используют одну модель данных и один tree engine.

`ctmExplorer` является главным пользовательским режимом: обычные карточки остаются обычными, а дерево проявляется только там, где у карточки действительно есть дочерние элементы.
