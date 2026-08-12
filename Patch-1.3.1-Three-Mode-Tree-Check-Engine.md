# Patch 1.3.1 — Three-Mode Tree Check Engine for TUniListView

## 1. Цель Patch

Добавить в `TUniListView` единый движок отметки древовидных элементов с тремя режимами поведения:

```delphi
type
  TUniTreeCheckMode = (
    tcmIndependent,
    tcmCascadeDown,
    tcmCascadeFull
  );
```

Движок должен одинаково работать во всех представлениях дерева:

- обычный Tree/List mode;
- Card Tree Navigate;
- Card Tree Explorer;
- Card Tree Hierarchy;
- после Search;
- после Filter;
- после Sorting;
- при загрузке через `TUniJsonDataAdapter`;
- в popup/lookup, если там разрешены checkboxes.

Не создавать отдельную реализацию каскада специально для Card Tree.

---

## 2. Обязательные правила проекта

Все новые и изменённые файлы:

- UTF-8 BOM;
- CRLF;
- без `with`;
- использовать guard clauses;
- не использовать magic numbers;
- design-time friendly;
- Linux compatible;
- без `Winapi.*` и `Vcl.*`;
- новые units добавить в runtime/design packages и проекты;
- не выполнять косметический рефакторинг вне Patch;
- не менять существующий API без необходимости.

При изменении `UniList.Columns.pas` сохранить `System.UITypes` в `uses`.

---

## 3. Обязательный checklist

Codex обязан создать:

```text
Patch-1.3.1-Three-Mode-Tree-Check-Engine-CHECKLIST.md
```

Checklist должен обновляться по мере работы.

Разделы:

- Architecture
- Public API
- Check State Model
- Independent Mode
- Cascade Down
- Cascade Full
- Downward Propagation
- Upward Aggregation
- Indeterminate Rendering
- Hit Testing
- Keyboard
- Selection Independence
- Search and Filter
- Sorting
- Card Tree Integration
- Regular Tree Integration
- Data Adapter Compatibility
- Performance
- Design-Time
- Packages
- Demo
- Windows Validation
- Linux Validation
- Regression

Пункт отмечается `[x]` только после реализации и проверки.

---

# 4. Главный архитектурный принцип

Check state должен принадлежать item/data model, а не renderer.

Renderer только отображает:

```text
Unchecked
Checked
Indeterminate
```

Операции каскада должны выполняться единым internal Check Engine.

Запрещено:

- отдельная логика для обычного Tree;
- отдельная логика для Card Tree;
- вычисление состояния parent только визуально;
- повторный полный проход дерева на каждом Paint;
- изменение selection при изменении checkbox;
- хранение Indeterminate только во временном layout record.

---

# 5. Публичный API

## 5.1 Режимы

Добавить:

```delphi
type
  TUniTreeCheckMode = (
    tcmIndependent,
    tcmCascadeDown,
    tcmCascadeFull
  );
```

Published property:

```delphi
property TreeCheckMode: TUniTreeCheckMode
  read FTreeCheckMode
  write SetTreeCheckMode
  default tcmIndependent;
```

Default обязательно `tcmIndependent`, чтобы сохранить обратную совместимость.

## 5.2 Состояние checkbox

Если текущая модель поддерживает только Boolean, расширить её до tri-state.

Предпочтительно:

```delphi
type
  TUniCheckState = (
    ucsUnchecked,
    ucsChecked,
    ucsIndeterminate
  );
```

Если в проекте уже есть аналогичный enum, переиспользовать его.

Нельзя создавать второй несовместимый тип.

## 5.3 Public methods

Добавить или расширить:

```delphi
procedure SetItemCheckState(
  const AItemId: <existing id type>;
  const AState: TUniCheckState
);

function GetItemCheckState(
  const AItemId: <existing id type>
): TUniCheckState;

procedure CheckItem(
  const AItemId: <existing id type>;
  const AChecked: Boolean
);

procedure CheckAll;
procedure UncheckAll;
procedure RecalculateTreeCheckStates;
```

Дополнительно допустимо:

```delphi
procedure BeginCheckUpdate;
procedure EndCheckUpdate;
```

если в проекте уже есть update batching pattern.

## 5.4 Events

Добавить либо расширить события:

```text
OnItemCheckChanging
OnItemCheckChanged
OnTreeCheckPropagationCompleted
```

Рекомендуемый cancellable event:

```delphi
type
  TUniItemCheckChangingEvent = procedure(
    Sender: TObject;
    const AItemId: <id type>;
    const AOldState: TUniCheckState;
    const ANewState: TUniCheckState;
    var AAllow: Boolean
  ) of object;
```

Completed event должен срабатывать один раз на пользовательскую операцию, а не на каждый descendant.

---

# 6. Семантика трёх режимов

## 6.1 `tcmIndependent`

Каждый item независим.

```text
☑ Platform
   ☐ API Gateway
   ☐ Worker Pool
```

Изменение parent:

- не меняет children;
- не меняет ancestors;
- не создаёт Indeterminate.

Изменение child не меняет parent.

Это текущее поведение и default mode.

## 6.2 `tcmCascadeDown`

Изменение parent распространяется на всех descendants.

```text
☑ Platform
   ☑ API Gateway
   ☑ Worker Pool
```

При снятии parent:

```text
☐ Platform
   ☐ API Gateway
   ☐ Worker Pool
```

Но изменение child не пересчитывает parent.

Допустимое состояние:

```text
☑ Platform
   ☐ API Gateway
   ☑ Worker Pool
```

`Indeterminate` автоматически не вычисляется.

## 6.3 `tcmCascadeFull`

Полная двусторонняя каскадная модель.

Правила:

- изменение parent распространяется вниз на всех descendants;
- изменение child пересчитывает всех ancestors;
- parent становится Checked, если все relevant descendants checked;
- parent становится Unchecked, если все relevant descendants unchecked;
- parent становится Indeterminate, если descendants имеют смешанные состояния.

```text
◩ Platform
   ☑ API Gateway
   ☐ Worker Pool
```

где `◩` — Indeterminate.

---

# 7. Downward propagation

## 7.1 Область

В `tcmCascadeDown` и `tcmCascadeFull` установка parent в `Checked` или `Unchecked` применяется ко всем descendants любого уровня.

```text
Data
└── PostgreSQL
    ├── Primary
    └── Replica
```

Check `Data` должен изменить `Data`, `PostgreSQL`, `Primary` и `Replica`, а не только непосредственных children.

## 7.2 Indeterminate click

Рекомендуемая toggle-семантика:

```text
Unchecked → Checked
Checked → Unchecked
Indeterminate → Checked
```

Использовать одинаково во всех renderer.

## 7.3 Traversal

Использовать существующий индекс:

```text
ParentId → ChildIndexes
```

Предпочтительно iterative traversal со stack/buffer.

Не выполнять рекурсивные вызовы с риском stack overflow на глубоком дереве и не создавать новый `TList` для каждого node.

---

# 8. Upward aggregation

Только для `tcmCascadeFull`.

После изменения child пересчитать parent, затем grandparent и далее до root.

## 8.1 Правила агрегации

Для непосредственных children parent:

```text
All Checked       → Parent Checked
All Unchecked     → Parent Unchecked
Mixed             → Parent Indeterminate
Any Indeterminate → Parent Indeterminate
```

Parent state определяется по непосредственным children, поскольку их состояния уже агрегируют descendants.

## 8.2 Leaf node

Leaf node не должен автоматически становиться Indeterminate.

Для leaf допустимы только `Unchecked` и `Checked`.

Если external data содержит Indeterminate leaf, предпочтительно нормализовать его в `Unchecked` при rebuild.

## 8.3 Parent own state

В `tcmCascadeFull` state parent является агрегированным состоянием ветки. После загрузки данных выполнить normalization/recalculation.

---

# 9. Инициализация и загрузка данных

## `tcmIndependent`

Сохранять состояния как загружены.

## `tcmCascadeDown`

Сохранять состояния как загружены. Автоматический пересчёт parents не нужен.

## `tcmCascadeFull`

После загрузки items, JSON, изменения ParentID, bulk update или tree rebuild выполнить один bottom-up recalculation parents.

Не выполнять recalculation после добавления каждого item при bulk load. Использовать batching/update lock.

---

# 10. Переключение `TreeCheckMode`

## В `tcmIndependent`

Сохранить Checked/Unchecked. Indeterminate нормализовать в `Unchecked`.

## В `tcmCascadeDown`

Сохранить Checked/Unchecked. Indeterminate нормализовать аналогично.

## В `tcmCascadeFull`

Выполнить один bottom-up recalculation всего дерева.

Не выполнять каскад вниз при самом переключении режима.

---

# 11. Rendering tri-state

Обычный Tree и Card Tree должны использовать единый checkbox renderer.

Состояния:

```text
Unchecked
Checked
Indeterminate
Disabled Unchecked
Disabled Checked
Disabled Indeterminate
Hot
Pressed
```

Indeterminate glyph — горизонтальная линия внутри checkbox.

Не использовать emoji и платформенные glyph resources. Цвет, stroke и background получать из Theme Engine.

Checkbox size и glyph metrics должны использовать существующие constants/theme metrics, без magic numbers.

---

# 12. Hit Testing и input

Checkbox остаётся отдельной hit area.

Click по checkbox:

- меняет check state;
- не запускает navigation icon;
- не запускает expand/collapse;
- не вызывает обычный card action;
- не меняет selection, если текущая логика так устроена.

Приоритет hit-test должен исключить конфликт checkbox с Card Tree icons и card body.

---

# 13. Keyboard

`Space` переключает checkbox focused item.

Семантика:

```text
Unchecked → Checked
Checked → Unchecked
Indeterminate → Checked
```

Не ломать Enter, arrow navigation, Card Tree Right/Left и Backspace navigation.

---

# 14. Selection independence

Check state и selection независимы.

Checkbox click не должен автоматически:

- очищать multi-selection;
- выбирать descendants;
- генерировать selection events для descendants;
- прокручивать список;
- переходить внутрь Card Tree.

---

# 15. Events и batching

Один click parent может изменить тысячи descendants.

Нельзя вызывать внешний event и repaint для каждого descendant.

Рекомендуемая модель:

1. `OnItemCheckChanging` для origin item;
2. internal batch update;
3. descendants update;
4. ancestors update;
5. один `OnItemCheckChanged` для origin item;
6. один `OnTreeCheckPropagationCompleted`;
7. один repaint.

Одна операция не должна вызывать layout invalidation, tree rebuild или text-layout rebuild, если geometry не меняется.

---

# 16. Search и Filter

Check state принадлежит полному underlying tree.

Изменение visible parent действует и на hidden descendants.

В `tcmCascadeFull` parent state определяется по всем реальным children, а не только по visible после filter/search.

После очистки filter/search состояния отображаются без дополнительной коррекции.

---

# 17. Sorting

Sorting не влияет на check state.

Каскад использует tree relation, а не visual order.

После sort состояния, checked collections и parent aggregation сохраняются.

---

# 18. Card Tree integration

Все Card Tree modes используют один Check Engine.

## `ctmNavigate`

Check parent на текущем уровне изменяет descendants, включая невидимые deeper levels. После входа внутрь children уже имеют обновлённое состояние.

## `ctmExplorer`

То же поведение независимо от перехода в Navigate.

## `ctmHierarchy`

Checkbox parent и expand/collapse icon — разные hit zones. Collapse не влияет на checks. Hidden descendants участвуют в aggregation.

---

# 19. Regular Tree integration

Обычный Tree/List mode должен использовать тот же API и propagation logic.

Найти central check mutation method и направить через него:

- mouse;
- keyboard;
- public API;
- JSON/data load normalization;
- CheckAll;
- UncheckAll.

Не оставлять старый Boolean click path отдельно.

---

# 20. Checked collections и counts

Если существуют `CheckedItems`, `CheckedCount`, `GetCheckedItems`:

- `CheckedCount` считает только `Checked`;
- `Indeterminate` не считается checked;
- `GetCheckedItems` не возвращает Indeterminate по умолчанию;
- отдельный `IndeterminateCount` добавлять только при реальной пользе.

Counts обновлять инкрементально либо одним batch recalculation.

---

# 21. Disabled и read-only items

Рекомендуемая политика:

```text
disabled/read-only items участвуют в propagation и aggregation,
но недоступны прямому user click
```

Если проект уже имеет другую семантику, сохранить её и явно документировать.

---

# 22. Orphan и malformed nodes

Обработать:

- ParentID отсутствует;
- parent не найден;
- cycle;
- duplicate ID.

Check Engine не должен зависать. При cycle detection traversal прекращается с использованием существующей диагностики tree model.

---

# 23. Производительность

## 23.1 Целевые сложности

```text
Check leaf in Independent: O(1)
Check parent CascadeDown: O(descendants)
Check leaf CascadeFull: O(depth)
Check parent CascadeFull: O(descendants + depth)
Full recalculation: O(N)
Paint: O(visible items)
```

Недопустимо:

```text
Check one leaf: O(N)
Parent state on Paint: O(children)
Cascade operation: O(N²)
```

## 23.2 Кэши

Переиспользовать:

```text
NodeId → ItemIndex
ParentId → ChildIndexes
NodeId → ParentId
```

## 23.3 Bulk operations

`CheckAll`, `UncheckAll`, data load и mode switch:

- BeginUpdate;
- один проход;
- один count rebuild;
- один repaint;
- один completed event.

## 23.4 Paint

Paint только читает готовый state. Запрещено вычислять Indeterminate в renderer.

## 23.5 Idle

В idle:

- нет timer;
- нет recalculation;
- нет tree traversal;
- нет repaint.

---

# 24. Public API compatibility

Существующие Boolean properties/methods должны продолжить работать.

```delphi
Item.Checked := True;
```

должно направляться через Check Engine либо безопасно синхронизироваться.

```text
Checked=True  → ucsChecked
Checked=False → ucsUnchecked
```

При чтении Boolean `Checked` для `Indeterminate` рекомендуется возвращать `False`. Документировать это.

---

# 25. Serialization

- сохранить backward compatibility с Boolean;
- старые данные должны загружаться;
- Indeterminate для `tcmCascadeFull` предпочтительно не сохранять, поскольку это derived state;
- не дублировать вычисляемое состояние без необходимости.

---

# 26. Data Adapter compatibility

`TUniJsonDataAdapter` должен продолжить загружать Boolean checked state.

Опционально поддержать:

```json
"checkState": "checked"
"checkState": "unchecked"
"checkState": "indeterminate"
```

только если adapter уже поддерживает enum mapping. Не превращать Patch в переработку adapter.

---

# 27. Design-Time

В Object Inspector должно быть доступно `TreeCheckMode`.

Design-time:

- enum корректно сериализуется;
- нет event storm;
- нет runtime-only traversal без данных;
- preview tri-state работает;
- IDE не зависает при bulk changes.

---

# 28. Demo

Добавить секцию:

```text
Tree Check Engine
```

Показать одну структуру в трёх режимах:

```text
Independent
Cascade Down
Cascade Full
```

Controls:

- mode selector;
- Check Root;
- Uncheck Root;
- Check Leaf;
- Uncheck Leaf;
- Check All;
- Uncheck All;
- Recalculate;
- Toggle Filter;
- Toggle Card Tree Mode;
- Expand/Collapse.

Показывать counters `Checked`, `Unchecked`, `Indeterminate`, если доступны.

---

# 29. Тестовая структура

```text
Platform
├── API Gateway
└── Worker Pool

Data
├── PostgreSQL
│   ├── Primary
│   └── Replica
└── Redis
```

Использовать эту или эквивалентную структуру для визуальной проверки.

---

# 30. Validation scenarios

## Independent

- check root;
- children unchanged;
- check child;
- parent unchanged;
- no Indeterminate.

## Cascade Down

- check root;
- all descendants checked;
- uncheck nested parent;
- nested descendants unchecked;
- ancestor unchanged;
- leaf change does not update parent.

## Cascade Full

- check root;
- all descendants checked;
- uncheck one leaf;
- parent Indeterminate;
- all ancestors Indeterminate;
- check leaf again;
- ancestors Checked;
- uncheck all children;
- parent Unchecked;
- click Indeterminate parent;
- all descendants Checked.

## Search/filter

- hide one checked child;
- parent state still based on all children;
- change parent under filter;
- hidden descendants updated;
- clear filter;
- states correct.

## Card Tree

- check parent in Explorer;
- enter Navigate;
- child states correct;
- hierarchy collapse;
- states preserved;
- hidden descendants aggregate correctly.

## Performance

Проверить:

```text
100
1,000
10,000
100,000 nodes
```

Для каждого:

- check leaf;
- check root;
- uncheck root;
- check deep parent;
- change one leaf in full cascade;
- filter active;
- Card Tree Navigate;
- Card Tree Hierarchy;
- idle.

Проверять сложность и отсутствие лишних rebuild/event storm.

---

# 31. Regression

Не сломать:

- ordinary list;
- ordinary tree;
- Card Tree Navigate;
- Card Tree Explorer;
- Card Tree Hierarchy;
- selection;
- multi-select;
- search;
- filter;
- sorting;
- checked collections;
- theme;
- popup;
- lookup;
- dropdown;
- resize;
- Windows;
- Linux.

---

# 32. Acceptance Criteria

- [ ] `TUniTreeCheckMode` добавлен;
- [ ] default `tcmIndependent`;
- [ ] tri-state model добавлен/reused;
- [ ] Independent работает;
- [ ] CascadeDown работает;
- [ ] CascadeFull работает;
- [ ] downward propagation идёт на все levels;
- [ ] upward aggregation идёт до root;
- [ ] Indeterminate корректен;
- [ ] Indeterminate renderer одинаковый Windows/Linux;
- [ ] Space toggles checkbox;
- [ ] checkbox hit не конфликтует с Card Tree icons;
- [ ] selection независим;
- [ ] hidden filtered children участвуют;
- [ ] sorting не влияет;
- [ ] обычный Tree использует общий engine;
- [ ] все Card Tree modes используют общий engine;
- [ ] один click не создаёт event storm;
- [ ] один click вызывает один repaint;
- [ ] нет layout rebuild;
- [ ] нет tree rebuild;
- [ ] leaf full cascade update O(depth);
- [ ] parent cascade O(descendants);
- [ ] Paint не вычисляет state;
- [ ] idle activity отсутствует;
- [ ] Boolean API совместим;
- [ ] serialization совместима;
- [ ] runtime package собирается;
- [ ] design package собирается;
- [ ] Windows validation;
- [ ] Linux validation;
- [ ] demo обновлён;
- [ ] checklist обновлён;
- [ ] remaining/deferred указаны.

---

# 33. Что не входит в Patch

Не реализовывать:

- permissions inheritance;
- custom per-node cascade policies;
- async propagation;
- database persistence;
- REST synchronization;
- drag-and-drop;
- lazy loading descendants;
- checkbox animations;
- отдельный Check Designer;
- новую Search Engine;
- новую Filter Engine.

---

# 34. Порядок реализации

1. Создать checklist.
2. Найти central mutation path текущего `Checked`.
3. Зафиксировать существующий item/tree API.
4. Добавить enum mode.
5. Добавить/reuse tri-state enum.
6. Реализовать internal Check Engine.
7. Реализовать downward traversal.
8. Реализовать upward aggregation.
9. Подключить mouse.
10. Подключить keyboard.
11. Подключить public API.
12. Подключить обычный Tree renderer.
13. Подключить Card Tree renderers.
14. Добавить Indeterminate glyph.
15. Интегрировать search/filter.
16. Интегрировать counts/collections.
17. Интегрировать serialization/data adapter.
18. Добавить batching/events.
19. Добавить demo.
20. Добавить diagnostics.
21. Проверить performance.
22. Windows validation.
23. Linux validation.
24. Regression.
25. Обновить checklist.
26. Итоговый отчёт.

---

# 35. Формат итогового отчёта Codex

```text
Implemented:
- ...

Check Engine:
- ...

Modes:
- Independent:
- CascadeDown:
- CascadeFull:

Tri-State:
- ...

Integration:
- Regular Tree:
- Card Tree:
- Search/Filter:
- Data Adapter:

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

Итог Patch:

```text
Единый Three-Mode Tree Check Engine
```

для всех древовидных представлений `TUniListView`, с полной tri-state поддержкой и без регрессии производительности.
