# Patch 1.1.0 — MultiCheck Core

## 1. Цель

Добавить в `TUniListView` независимый механизм множественных отметок элементов — `MultiCheck`.

Нужно строго разделять:

```text
Current/Focused item
Selected item
Checked items
```

`Checked` не является синонимом `Selected`.

Отметки должны сохраняться при сортировке, фильтрации, поиске, виртуализации, переключении List/Cards и изменении порядка элементов.

---

## 2. Правила проекта

Все новые и изменённые файлы:

- UTF-8 BOM;
- CRLF;
- без `with`;
- guard clauses;
- без magic numbers;
- Design-Time friendly;
- Linux compatible;
- без `Winapi.*` и `Vcl.*`;
- без крупного рефакторинга вне Patch.

При изменении `UniList.Columns.pas` обязательно сохранить:

```delphi
System.UITypes
```

---

## 3. Область Patch

Входит:

- Checked state в item model;
- публичный API;
- события;
- `CheckAll`, `UncheckAll`, `InvertChecks`;
- scope `AllItems` и `VisibleItems`;
- `for..in` по всем элементам;
- `for..in` по отмеченным элементам;
- renderer checkbox для List и Cards;
- mouse и keyboard;
- Design-Time;
- Showcase demo;
- тест на 50 000 элементов.

Не входит:

- Tree cascade parent/children;
- `Mixed` state;
- tri-state;
- MultiLookup;
- JSON mapping Checked;
- shift-range checking.

---

## 4. Хранение состояния

Добавить в существующий item model:

```delphi
property Checked: Boolean read ... write ...;
```

Требования:

- состояние хранится в самом item;
- не хранить только в renderer;
- не хранить по visible/filter/screen index;
- не создавать параллельную коллекцию индексов;
- после сортировки Checked остаётся у того же item;
- новые items по умолчанию `Checked := False`.

Setter должен корректно уведомлять owner:

- обновить `CheckedCount`;
- выполнить repaint;
- вызвать события;
- не делать ничего при повторной установке того же значения.

---

## 5. Published свойства TUniListView

Добавить:

```delphi
property MultiCheck: Boolean read ... write ... default False;
property ShowCheckBoxes: Boolean read ... write ... default True;
```

Поведение:

- `MultiCheck = False` — UI не позволяет менять Checked;
- `MultiCheck = True` — checkbox доступен;
- выключение MultiCheck не очищает отметки;
- `ShowCheckBoxes = False` скрывает checkbox, но сохраняет Checked state.

Если `ShowCheckBoxes` объективно дублирует существующую архитектуру, допускается оставить только `MultiCheck`, но решение описать в отчёте.

Добавить read-only:

```delphi
property CheckedCount: Integer read ...;
```

`CheckedCount` желательно поддерживать инкрементально, а не пересчитывать весь список при каждом чтении.

---

## 6. Scope массовых операций

Добавить:

```delphi
type
  TUniCheckScope = (
    ucsAllItems,
    ucsVisibleItems
  );
```

Добавить методы:

```delphi
procedure CheckAll; overload;
procedure CheckAll(const AScope: TUniCheckScope); overload;

procedure UncheckAll; overload;
procedure UncheckAll(const AScope: TUniCheckScope); overload;

procedure InvertChecks; overload;
procedure InvertChecks(const AScope: TUniCheckScope); overload;
```

Методы без параметра используют:

```delphi
ucsAllItems
```

`ucsVisibleItems` означает текущий результат search/filter.

Пример:

```text
Search "PostgreSQL"
CheckAll(ucsVisibleItems)
Clear search
```

Только найденные элементы должны стать Checked.

---

## 7. API по индексу

Добавить:

```delphi
function IsItemChecked(const AIndex: Integer): Boolean;
procedure SetItemChecked(const AIndex: Integer; const AChecked: Boolean);
procedure ToggleItemChecked(const AIndex: Integer);
```

Индекс относится к полному текущему порядку item model, не к экранному row index.

При неверном индексе использовать единый стиль ошибки, предпочтительно:

```delphi
EArgumentOutOfRangeException
```

---

## 8. Цикл по всем элементам

Обязательный API:

```delphi
for LItem in UniListView.Items do
begin
  ...
end;
```

Если `Items` уже enumerable — переиспользовать его.

Если нет — добавить enumerator к существующей коллекции.

Требования:

- проходит по всем items;
- filtered/search-hidden items тоже входят;
- порядок соответствует текущему model order;
- не создаёт копию;
- ownership не передаётся вызывающему коду.

Пример:

```delphi
for LItem in UniListView1.Items do
  LItem.Checked := True;
```

---

## 9. Цикл по отмеченным элементам

Обязательный API:

```delphi
for LItem in UniListView.CheckedItems do
begin
  ...
end;
```

`CheckedItems` должен быть lightweight enumerable view.

Требования:

- не создавать список-копию при каждом вызове;
- не владеть items;
- пропускать unchecked items;
- включать отмеченные items, скрытые search/filter;
- возвращать items в текущем model order;
- корректно работать при `CheckedCount = 0`.

Пример:

```delphi
for LItem in UniListView1.CheckedItems do
  ProcessItem(LItem);
```

Дополнительно добавить:

```delphi
function FirstCheckedItem: TUniListItem;
function LastCheckedItem: TUniListItem;
```

При отсутствии отмеченных — `nil`.

Использовать реальное имя существующего item type вместо `TUniListItem`, если оно отличается.

---

## 10. События

Добавить event type:

```delphi
TUniItemCheckChangedEvent = procedure(
  Sender: TObject;
  AItem: TUniListItem;
  AChecked: Boolean
) of object;
```

Добавить published events:

```delphi
property OnItemCheckChanged: TUniItemCheckChangedEvent read ... write ...;
property OnCheckedChanged: TNotifyEvent read ... write ...;
```

Семантика:

- `OnItemCheckChanged` — одиночное изменение;
- `OnCheckedChanged` — изменение набора отметок;
- массовая операция вызывает `OnCheckedChanged` один раз;
- не вызывать события при установке прежнего значения.

Не генерировать десятки тысяч repaint/event при `CheckAll`.

---

## 11. Batch update

`CheckAll`, `UncheckAll`, `InvertChecks` должны:

- использовать существующий `BeginUpdate/EndUpdate` или аналог;
- вызывать `EndUpdate` через `try..finally`;
- делать один итоговый repaint;
- поддерживать корректный `CheckedCount`;
- не выполнять rebuild после каждого item.

---

## 12. List renderer

В List mode checkbox рисуется в служебной области слева:

- до frozen columns;
- не как пользовательская data column;
- theme-aware;
- states: unchecked, checked, hover, pressed, disabled;
- одинаковая геометрия для строк;
- учитывает scale.

Не создавать `TCheckBox` для каждой строки.

Использовать renderer + hit testing.

Checkbox area не должна ломать:

- columns resize;
- frozen columns;
- row selection;
- sorting;
- footer;
- filter row.

---

## 13. Cards renderer

В Cards mode checkbox рисуется внутри карточки:

- предпочтительно Top Left;
- не перекрывает icon/title/actions;
- учитывает card padding;
- работает в responsive cards;
- работает в Full Width Cards;
- theme-aware;
- масштабируется вместе с root layout.

Не создавать FMX controls на каждую карточку.

---

## 14. Mouse

При `MultiCheck = True`:

- click по checkbox переключает Checked;
- click по остальной строке сохраняет существующее selection behavior;
- click по checkbox не запускает row action;
- не запускает double-click action;
- hover checkbox не ломает hover item;
- работает в List и Cards.

---

## 15. Keyboard

При фокусе на `TUniListView`:

```text
Space
```

переключает Checked у current/focused item.

Требования:

- selection не теряется;
- search edit получает обычный пробел;
- popup/search input не должен ошибочно переключать item;
- repaint и events работают.

Не назначать `Ctrl+A` на CheckAll автоматически.

---

## 16. Search, Filter, Sort

Проверить:

- Checked сохраняется при search;
- Checked сохраняется при filter;
- Checked сохраняется при sort/multisort;
- Checked сохраняется при List ↔ Cards;
- `CheckedCount` не меняется от отображения;
- `CheckedItems` выдаёт текущий model order;
- `ucsVisibleItems` работает по current visible result.

---

## 17. Удаление и Clear

При удалении Checked item:

- `CheckedCount` уменьшается;
- item исчезает из `CheckedItems`;
- нет dangling references;
- события корректны.

После `Clear`:

```delphi
CheckedCount = 0;
```

---

## 18. JSON Adapter

`TUniJsonDataAdapter` должен работать без специальной логики Checked.

При `ClearBeforeLoad = True` старые items и их state удаляются.

При `ClearBeforeLoad = False` существующие items сохраняют Checked.

Новые items создаются unchecked.

Не добавлять JSON field mapping Checked в этом Patch.

---

## 19. Design-Time

В Object Inspector должны быть доступны:

```text
MultiCheck
ShowCheckBoxes
OnItemCheckChanged
OnCheckedChanged
```

Требования:

- checkbox preview на design-time sample rows;
- изменение свойства сразу обновляет preview;
- `.fmx` сохраняется;
- reopen Designer работает;
- нет AV;
- удаление компонента безопасно.

---

## 20. Showcase Demo

Добавить отдельную страницу:

```text
MultiCheck
```

Предпочтительный frame:

```text
Demo.MultiCheck.Frame.pas
Demo.MultiCheck.Frame.fmx
```

Все визуальные компоненты разместить через Designer.

Все команды через `TActionList`.

Actions:

```text
actMultiCheckLoad
actMultiCheckCheckAll
actMultiCheckCheckVisible
actMultiCheckUncheckAll
actMultiCheckUncheckVisible
actMultiCheckInvertAll
actMultiCheckInvertVisible
actMultiCheckIterateAll
actMultiCheckIterateChecked
actMultiCheckToggleCards
actMultiCheckSearch
actMultiCheckClearSearch
```

Показывать:

- CheckedCount;
- List mode;
- Cards mode;
- search;
- all-items scope;
- visible-items scope;
- цикл по всем;
- цикл по checked.

---

## 21. Демонстрация циклов

Кнопка `Iterate all` обязана использовать публичный API:

```delphi
for LItem in UniListView1.Items do
begin
  ...
end;
```

Кнопка `Iterate checked` обязана использовать:

```delphi
for LItem in UniListView1.CheckedItems do
begin
  ...
end;
```

Результат вывести в read-only memo/log:

- количество;
- id/key;
- title/name;
- checked state.

Demo не должна обращаться к private/internal collections.

---

## 22. Производительность

Проверить минимум на:

```text
50 000 items
```

Операции:

- CheckAll;
- UncheckAll;
- InvertChecks;
- Iterate all;
- Iterate checked;
- search + visible scope.

Требования:

- без создания checkbox controls;
- без полной копии CheckedItems;
- один batch update;
- стабильный CheckedCount;
- UI не должен выполнять 50 000 отдельных repaint.

---

## 23. Tree

Tree mode не должен ломаться.

В текущем Patch допустимо отображать независимый checkbox каждого tree item без каскада.

Не реализовывать:

- parent → children propagation;
- children → parent propagation;
- Mixed state;
- tri-state.

В отчёте явно указать:

```text
Tree cascade and Mixed state are planned for the next Patch.
```

---

## 24. Что не делать

Не реализовывать:

- `TUniMultiLookup`;
- Tree cascade;
- tri-state;
- JSON Checked mapping;
- database binding;
- selection rewrite;
- shift range;
- drag checking;
- async;
- новый renderer framework;
- отдельную item model.

---

## 25. Критерии приёмки

1. `MultiCheck` добавлен.
2. Checked хранится в item model.
3. Checked независим от Selected.
4. Checkbox работает в List.
5. Checkbox работает в Cards.
6. Mouse toggle работает.
7. Space toggle работает.
8. `CheckedCount` корректен.
9. `CheckAll` работает.
10. `UncheckAll` работает.
11. `InvertChecks` работает.
12. `ucsAllItems` работает.
13. `ucsVisibleItems` работает.
14. Search/filter не теряет state.
15. Sort не теряет state.
16. List/Cards не теряет state.
17. `for..in Items` работает.
18. `for..in CheckedItems` работает.
19. `CheckedItems` не создаёт владеющую копию.
20. Events работают.
21. Массовые операции batch-based.
22. Delete/Clear корректируют count.
23. Design-Time работает.
24. Showcase содержит MultiCheck frame.
25. 50 000 items проходят тест.
26. Runtime package собирается.
27. Design-time package собирается.
28. Showcase собирается.
29. Linux compatibility сохранена.
30. Все файлы UTF-8 BOM + CRLF.

---

## 26. Проверки перед завершением

Проверить:

- empty list;
- one item;
- 10 items;
- 50 000 items;
- no checked;
- all checked;
- CheckAll;
- UncheckAll;
- InvertChecks;
- all scope;
- visible scope;
- search;
- filter;
- sort;
- multisort;
- List;
- Cards;
- Full Width Cards;
- delete checked item;
- Clear;
- JSON reload;
- iterate all;
- iterate checked;
- mouse;
- Space;
- Designer open/save/reopen.

---

## 27. Итоговый отчёт

```text
Implemented:
- ...

API added:
- ...

Files added:
- ...

Files changed:
- ...

Validation:
- List:
- Cards:
- Search/filter:
- Sort:
- Iterate Items:
- Iterate CheckedItems:
- 50 000 items:
- Design-Time:
- Runtime package:
- Design-time package:
- Showcase:

Known limitations:
- Tree cascade and Mixed state are planned for the next Patch.

Notes:
- ...
```

Не вставлять полные исходники в отчёт.

---

## 28. Эффективность

- изучить существующую item model;
- переиспользовать текущие collections/enumerators;
- не анализировать весь repository повторно;
- не создавать параллельную модель;
- не переписывать selection;
- не создавать FMX checkbox на каждый item;
- переиспользовать renderer, hit testing, theme engine и batch update;
- не делать Tree cascade сейчас;
- минимально менять существующие units.

Главная цель:

> быстрый независимый MultiCheck с естественным `for..in` обходом всех и отмеченных элементов.
