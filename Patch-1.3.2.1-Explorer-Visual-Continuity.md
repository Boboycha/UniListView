# Patch 1.3.2.1 — Explorer Visual Continuity

## 1. Цель Patch

Исправить визуальное поведение `ctmExplorer` при переходе на дочерний уровень.

Сейчас:

```text
Explorer root
    ↓
Navigate visible set
    ↓
Navigate layout/renderer
```

Должно быть:

```text
Explorer root
    ↓
Navigate visible set
    ↓
Explorer layout/renderer
```

В `ctmExplorer` переход по уровням должен менять только набор отображаемых элементов, breadcrumb, current node, selection и scroll state. Внешний вид карточек должен оставаться одинаковым на любой глубине дерева.

## 2. Обязательные правила проекта

- UTF-8 BOM;
- CRLF;
- без `with`;
- guard clauses;
- без magic numbers;
- design-time friendly;
- Linux compatible;
- без `Winapi.*` и `Vcl.*`;
- новые units добавить в runtime/design packages;
- не выполнять посторонний рефакторинг;
- не менять публичный API без необходимости.

При изменении `UniList.Columns.pas` сохранить `System.UITypes`.

## 3. Обязательный checklist

Создать:

```text
Patch-1.3.2.1-Explorer-Visual-Continuity-CHECKLIST.md
```

Разделы:

- Current Behavior Analysis
- Architecture
- Visible Set Separation
- Renderer Selection
- Layout Reuse
- Breadcrumb Integration
- Selection
- Scroll State
- Hit Testing
- Check Engine Regression
- Search and Filter
- Theme
- Resize
- Performance
- Windows Validation
- Linux Validation
- Demo
- Regression

Отмечать `[x]` только после реализации и проверки.

## 4. Главный архитектурный принцип

Необходимо строго разделить:

```text
что отображать
```

и:

```text
как отображать
```

То есть разделить `Visible Set Strategy` и `Card Layout / Renderer Strategy`.

Navigation state не должен автоматически выбирать Navigate renderer. Configured mode должен определять renderer.

## 5. Требуемая модель

Внутренне должны быть независимые понятия:

```delphi
FCardTreeMode: TUniCardTreeMode;
FCardTreeNavigationActive: Boolean;
FCardTreeCurrentNodeId: <existing id type>;
```

Допустимо добавить внутренний enum:

```delphi
type
  TUniCardRendererKind = (
    crkExplorer,
    crkNavigate,
    crkHierarchy
  );
```

Renderer kind вычисляется только из `CardTreeMode`:

```text
ctmExplorer  → crkExplorer
ctmNavigate  → crkNavigate
ctmHierarchy → crkHierarchy
```

`CardTreeNavigationActive` не должен менять renderer kind.

## 6. Исправление выбора renderer

Предположительно сейчас используется логика, аналогичная:

```delphi
if FCardTreeNavigationActive then
  UseNavigateLayout
else
  UseExplorerLayout;
```

Это неправильно.

Нужно:

```delphi
case FCardTreeMode of
  ctmExplorer:
    UseExplorerLayout;
  ctmNavigate:
    UseNavigateLayout;
  ctmHierarchy:
    UseHierarchyLayout;
end;
```

Visible set внутри `ctmExplorer` может быть flat Explorer set или children текущего node, но layout всегда остаётся Explorer layout.

## 7. Поведение `ctmExplorer`

### 7.1 Root level

При:

```text
CardTreeMode = ctmExplorer
CardTreeNavigationActive = False
```

использовать Explorer visible set, Explorer card width/height, Explorer grid, Explorer content layout, actions, badges, checkbox и navigation icon placement.

### 7.2 Внутренний уровень

При:

```text
CardTreeMode = ctmExplorer
CardTreeNavigationActive = True
```

использовать visible set непосредственных children текущего node и breadcrumb, но сохранять Explorer card width/height, Explorer grid, Explorer content layout, actions, badges, checkbox и navigation icon placement.

Не использовать Navigate-specific geometry.

## 8. Визуальная непрерывность

На всех уровнях Explorer должны оставаться одинаковыми:

- ширина карточки;
- минимальная высота карточки;
- auto-height policy;
- corner radius;
- padding;
- grid spacing;
- row spacing;
- column count calculation;
- checkbox rect;
- leading icon rect;
- title/subtitle/status/footer rects;
- badge rect;
- action rects;
- navigation icon rect;
- selected/hot/pressed states;
- parent emphasis.

Допустимое различие только одно: breadcrumb занимает верхнюю область viewport.

## 9. Размеры карточек

### 9.1 Card width

На дочернем уровне нельзя:

- растягивать карточки на всю ширину;
- переключать в full-width;
- использовать hierarchy width;
- использовать Navigate-specific width;
- менять minimum card width.

Количество колонок рассчитывается тем же алгоритмом, что и на Explorer root.

### 9.2 Card height

Нельзя менять fixed height, auto card height, text measurement policy, footer reservation и content row spacing.

## 10. Breadcrumb area

Breadcrumb занимает отдельную верхнюю область:

```text
BreadcrumbRect
CardsViewportRect
```

Layout карточек рассчитывается внутри `CardsViewportRect`.

Breadcrumb не должен менять CardWidth, CardHeight, renderer, indentation, card padding или grid policy.

## 11. Parent card behavior

Внутри Explorer navigation parent cards продолжают:

- слегка выделяться;
- показывать navigation icon;
- показывать child count, если включено;
- использовать Explorer parent emphasis;
- открывать следующий уровень.

Не применять Navigate-specific styling.

## 12. Hit Testing

Hit testing использует rects Explorer layout:

- checkbox;
- actions;
- parent navigation icon;
- child-count badge;
- card body;
- breadcrumb;
- back button;
- scrollbar.

Нельзя использовать Navigate hit geometry для Explorer-rendered карточек.

## 13. Mouse behavior

На любом уровне `ctmExplorer`:

- checkbox click меняет check state;
- action click запускает action;
- navigation icon открывает child level;
- card body сохраняет Explorer semantics;
- hover не меняет layout;
- breadcrumb меняет visible set, но не layout style.

## 14. Keyboard

На любом уровне `ctmExplorer`:

- стрелки перемещают selection по Explorer grid;
- Right Arrow на parent открывает child level;
- Left Arrow/Backspace возвращает на parent level;
- на верхнем navigation level возвращает в flat Explorer;
- Space работает через Tree Check Engine;
- Enter сохраняет Explorer item activation semantics.

## 15. Selection

При входе:

- сохранить selected parent;
- сохранить scroll текущего уровня;
- восстановить previous child-level selection, если есть;
- иначе выбрать первый visible child либо очистить selection.

При возврате:

- выбрать parent card, из которой был выполнен вход;
- восстановить Explorer grid navigation;
- не оставлять selected item вне visible set.

## 16. Scroll state

Для каждого уровня можно сохранять:

```text
NodeId
ScrollOffset
SelectedItemId
```

Root Explorer flat state хранится отдельно.

## 17. Search и Filter

Search/filter меняют visible set, но не renderer.

В `ctmExplorer` независимо от root, child level, search results или filter используется Explorer layout.

После очистки Search/Filter восстановить current node, breadcrumb, Explorer renderer, selection и scroll.

## 18. Check Engine regression

`Patch 1.3.1 — Three-Mode Tree Check Engine` должен работать без изменений.

На любом уровне Explorer:

- checkbox остаётся в том же месте;
- `tcmIndependent` работает;
- `tcmCascadeDown` работает;
- `tcmCascadeFull` работает;
- cascade не вызывает layout switch;
- tri-state renderer остаётся Explorer renderer.

## 19. Theme

На root и child levels использовать одинаковые Theme-derived значения для card background, parent emphasis, selection, hot, pressed, checkbox, actions, badge и navigation icon.

Theme change:

- один visual cache invalidation;
- один repaint;
- без visible set rebuild;
- без renderer switch;
- без tree rebuild.

## 20. Resize

При resize на любом уровне Explorer:

- использовать Explorer column calculation;
- не переключаться в full-width;
- не переключаться на Navigate layout;
- не rebuild tree;
- не rebuild breadcrumb path;
- не rebuild visible set;
- пересчитать только geometry;
- text layout пересчитывать только при изменении effective width.

## 21. Производительность

### 21.1 Enter level

```text
Build child visible set
Build breadcrumb
Recalculate Explorer geometry
One repaint
```

### 21.2 Back

```text
Restore visible set
Restore breadcrumb/state
Recalculate Explorer geometry
One repaint
```

### 21.3 Запрещено

- rebuild tree;
- rebuild filter без изменения filter;
- rebuild search без изменения query;
- пересоздавать Theme;
- пересоздавать card renderer;
- пересоздавать text layouts всех items;
- создавать timer;
- делать duplicate layout passes;
- repaint на каждый item.

### 21.4 Complexity

```text
Enter level: O(children + depth)
Back: O(children restored level + depth)
Layout: O(visible cards)
Paint: O(visible cards)
Hover: O(1)
```

### 21.5 Diagnostics

Использовать counters:

```text
TreeRebuildCount
VisibleSetBuildCount
BreadcrumbBuildCount
ExplorerLayoutRecalculateCount
NavigateLayoutRecalculateCount
HierarchyLayoutRecalculateCount
PaintCount
TextLayoutCreateCount
```

При navigation внутри Explorer `NavigateLayoutRecalculateCount` не должен увеличиваться.

## 22. Demo

Обновить `Card Tree Explorer` demo.

Показать минимум три уровня:

```text
Company
  Division
    Department
      Team
```

На каждом уровне:

- одинаковая ширина карточек;
- одинаковая height policy;
- одинаковое количество колонок при той же ширине viewport;
- одинаковое внутреннее расположение;
- одинаковые checkbox/actions/badge/navigation icon;
- breadcrumb сверху.

## 23. Validation

### Visual

- root и child cards имеют одинаковую width policy;
- root и child cards имеют одинаковую height policy;
- child level не становится full-width;
- internal content layout не меняется;
- checkbox/icon/title/subtitle/status/badge/actions/navigation icon не меняют zone policy;
- parent emphasis одинаков;
- breadcrumb — единственное новое визуальное отличие.

### Functional

- navigation;
- back;
- breadcrumb;
- selection;
- checkbox;
- actions;
- child count;
- Search;
- Filter;
- Theme;
- Resize.

### Performance

Проверить 100, 1 000 и 10 000 items:

- enter;
- nested enter;
- back;
- root;
- resize;
- theme switch;
- hover;
- checkbox cascade;
- search/filter;
- idle.

## 24. Regression

Не сломать:

- Explorer flat root;
- ctmNavigate;
- ctmHierarchy;
- ordinary Cards;
- FullWidth Cards;
- ordinary Tree;
- Three-Mode Tree Check Engine;
- Search;
- Filter;
- Sorting;
- Selection;
- MultiSelect;
- Actions;
- Badges;
- Popup;
- Lookup;
- DropDown;
- Windows;
- Linux.

Важно: `ctmNavigate` может сохранить собственную layout policy. Patch касается только `ctmExplorer`.

## 25. Acceptance Criteria

- [ ] Explorer child level использует Explorer renderer;
- [ ] Explorer child level использует Explorer layout;
- [ ] navigation state не выбирает renderer;
- [ ] configured mode определяет renderer;
- [ ] root и child cards имеют одинаковую width policy;
- [ ] root и child cards имеют одинаковую height policy;
- [ ] child level не full-width;
- [ ] content zones одинаковы;
- [ ] checkbox/action/badge/navigation icon geometry одинакова;
- [ ] parent emphasis одинаков;
- [ ] breadcrumb не влияет на card style;
- [ ] hit-test использует Explorer rects;
- [ ] keyboard использует Explorer grid semantics;
- [ ] selection/scroll корректны;
- [ ] Search/Filter не переключают renderer;
- [ ] Check Engine regression отсутствует;
- [ ] Theme regression отсутствует;
- [ ] Resize не rebuild tree;
- [ ] Navigate layout counter не растёт внутри Explorer;
- [ ] один transition — один layout и один repaint;
- [ ] idle activity отсутствует;
- [ ] Windows validation;
- [ ] Linux validation;
- [ ] demo обновлён;
- [ ] checklist обновлён;
- [ ] remaining/deferred указаны.

## 26. Что не входит в Patch

Не реализовывать:

- новый Card Content Layout Engine;
- исправление плавающих внутренних элементов карточки;
- новые card templates;
- animations;
- изменение `ctmNavigate`;
- изменение `ctmHierarchy`;
- новый Search Engine;
- новый Filter Engine;
- Data Provider API;
- editing fields.

Проблема плавающих элементов карточки решается отдельным Patch `Stable Card Content Layout`.

## 27. Порядок реализации

1. Создать checklist.
2. Найти место выбора card layout/renderer.
3. Найти зависимость renderer от navigation active.
4. Разделить visible set и renderer selection.
5. Закрепить renderer selection за `CardTreeMode`.
6. Подключить Explorer layout для navigation state.
7. Проверить breadcrumb viewport offset.
8. Проверить card width/height policy.
9. Проверить hit-test rects.
10. Проверить keyboard.
11. Проверить selection/scroll.
12. Проверить Search/Filter.
13. Проверить Check Engine.
14. Проверить Theme.
15. Проверить Resize.
16. Добавить diagnostics.
17. Обновить demo.
18. Windows validation.
19. Linux validation.
20. Regression.
21. Обновить checklist.
22. Подготовить итоговый отчёт.

## 28. Формат итогового отчёта Codex

```text
Implemented:
- ...

Root cause:
- ...

Architecture:
- Visible set:
- Renderer selection:
- Layout selection:

Explorer continuity:
- Root:
- Child levels:
- Breadcrumb:

Performance:
- Layout counts:
- Paint counts:
- Tree rebuilds:

Files changed:
- ...

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

## 29. Итог

`ctmExplorer` должен выглядеть одинаково на любой глубине дерева.

Пользователь должен видеть:

```text
те же карточки
+
другой набор данных
+
breadcrumb
```

а не переключение на другой визуальный режим.
