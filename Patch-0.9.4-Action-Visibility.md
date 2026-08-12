# Patch 0.9.4 — Action Visibility: Always / On Hover

## 1. Цель

Добавить в **UniListView** управляемый режим отображения иконок `Actions`.

Сейчас иконки действий отображаются постоянно. Необходимо добавить выбор:

- показывать всегда;
- показывать только при наведении мыши на соответствующую строку, карточку или узел дерева.

Патч должен быть небольшим, изолированным и не менять существующее поведение по умолчанию.

---

## 2. Базовые правила проекта

Соблюдать текущие правила кодовой базы:

- Delphi 12 Athens;
- FMX;
- Skia renderer;
- UTF-8 BOM;
- CRLF;
- не использовать `with`;
- использовать Guard Clauses;
- не использовать magic numbers;
- сохранять обратную совместимость;
- новые свойства должны быть доступны design-time;
- не добавлять `Winapi.*`;
- не добавлять `Vcl.*`;
- не использовать платформенно-зависимые API без условной компиляции;
- новые типы и свойства добавить в runtime package и demo;
- при изменении `UniList.Columns.pas` явно подключать:

```delphi
System.UITypes
```

---

## 3. Новый API

### 3.1. Новый enum

Добавить публичный тип:

```delphi
type
  TUniActionVisibility = (
    uavAlways,
    uavOnHover
  );
```

### 3.2. Новое свойство компонента

Добавить в основной компонент:

```delphi
property ActionVisibility: TUniActionVisibility
  read FActionVisibility
  write SetActionVisibility
  default uavAlways;
```

Поле:

```delphi
FActionVisibility: TUniActionVisibility;
```

Setter:

```delphi
procedure SetActionVisibility(const Value: TUniActionVisibility);
```

Требования к setter:

- Guard Clause, если значение не изменилось;
- обновить поле;
- инвалидировать layout только при необходимости;
- вызвать redraw;
- не пересоздавать данные;
- не сбрасывать selection, scroll, search или checkbox state.

---

## 4. Значение по умолчанию

Обязательно:

```delphi
FActionVisibility := uavAlways;
```

Это сохраняет текущее поведение старых проектов.

Старые `.fmx` должны открываться без изменений.

---

## 5. Поведение режимов

### 5.1. `uavAlways`

Иконки `Actions` отображаются постоянно, как сейчас.

Требования:

- текущее поведение не меняется;
- hit-test работает всегда;
- hover/pressed состояния работают как раньше;
- layout не должен отличаться от версии 0.9.3.

### 5.2. `uavOnHover`

Иконки `Actions` отображаются только у элемента, который сейчас находится под курсором мыши.

Под элементом понимается:

- строка в List Mode;
- карточка в Grid Cards;
- карточка в Full-Width Cards;
- узел дерева в Tree Mode;
- строка Tree в табличном представлении.

Требования:

- иконки показываются при входе курсора в границы элемента;
- иконки скрываются после ухода курсора;
- переход между элементами должен обновлять только старый и новый hover item;
- не выполнять полный тяжёлый rebuild данных;
- не менять selection;
- не менять checkbox state;
- не менять scroll position.

---

## 6. Layout и отсутствие “прыжков”

В режиме `uavOnHover` текст и содержимое строки/карточки не должны смещаться при появлении иконок.

То есть область под `Actions` должна резервироваться так же, как при `uavAlways`.

Ожидаемое поведение:

```text
Без hover:
| Title and fields                     [reserved area] |

С hover:
| Title and fields                     [edit] [delete] |
```

Запрещено:

- расширять текст при уходе мыши;
- сжимать текст при наведении;
- менять высоту строки или карточки;
- вызывать визуальное “дёргание”.

Если текущий renderer уже всегда резервирует область Actions, сохранить этот механизм.

---

## 7. Hit Testing

В режиме `uavOnHover` action hit-test должен быть активен только когда Actions визуально показаны.

Требования:

- скрытая action icon не должна реагировать на click;
- скрытая action icon не должна показывать tooltip;
- скрытая action icon не должна получать pressed/hover state;
- после появления icon hit-test должен работать сразу;
- уход курсора должен сбрасывать hovered/pressed action index.

Guard Clause:

```delphi
if not AreActionsVisibleForItem(AItemIndex) then
  Exit;
```

или эквивалентная логика.

---

## 8. Рекомендуемый вспомогательный метод

Добавить единый метод, чтобы не дублировать условия в разных renderer-путях:

```delphi
function AreActionsVisibleForItem(
  const AItemIndex: Integer
): Boolean;
```

Ожидаемая логика:

```delphi
case FActionVisibility of
  uavAlways:
    Result := True;

  uavOnHover:
    Result := AItemIndex = FHoverItemIndex;
else
  Result := True;
end;
```

Имя можно адаптировать к текущей архитектуре.

Важно:

- использовать один источник истины;
- renderer и hit-test должны использовать одинаковую проверку;
- не размножать `if ActionVisibility = ...` по всему проекту без необходимости.

---

## 9. Hover state

Использовать существующий hover item state, если он уже есть.

Если в разных режимах используются разные поля, привести к единому способу определения текущего визуального элемента.

Нужно проверить:

- hover row index;
- hover card index;
- hover tree node / visible index;
- прокрутку;
- выход мыши из компонента;
- изменение ViewMode;
- удаление hovered item;
- обновление данных.

При `MouseLeave`:

- очистить hover item;
- скрыть Actions;
- сбросить hovered action;
- выполнить redraw только нужной области, если архитектура это позволяет.

---

## 10. Совместимость с режимами

Патч должен работать одинаково в:

### 10.1. List Mode

- Actions справа в строке;
- показываются только у hovered row.

### 10.2. Grid Cards

- Actions показываются только у hovered card;
- остальные карточки не показывают иконки.

### 10.3. Full-Width Cards

- Actions показываются только у hovered full-width card;
- reserved area сохраняется;
- trailing-поля не перекрываются.

### 10.4. Tree Mode

- Actions показываются только у hovered visible tree item;
- expand toggle и checkbox продолжают работать;
- hit-area toggle не должна конфликтовать с Actions.

---

## 11. Совместимость с selection

В этом патче selected item не должен автоматически показывать Actions.

То есть:

```text
uavOnHover
```

означает именно hover, а не hover-or-selected.

Не добавлять сейчас дополнительные варианты:

- `uavOnSelected`;
- `uavOnHoverOrSelected`;
- `uavNever`.

Это можно сделать позже отдельным патчем при реальной необходимости.

---

## 12. Touch / Mobile

В этом патче не требуется отдельная мобильная логика.

Не добавлять автоматическое поведение по типу:

- показывать Actions у selected item на touch;
- long press;
- swipe actions.

Главная цель текущего патча:

- Windows mouse;
- Linux mouse.

Код не должен ломать Android/iOS build, но специальная UX-логика для touch не требуется.

---

## 13. Actions collection

Не менять существующую модель Actions.

Не изменять:

- action identifiers;
- callback API;
- icons;
- enabled state;
- visible state отдельных action;
- tooltip;
- order;
- command execution.

Новое свойство управляет только общей видимостью панели Actions.

Если отдельный Action имеет:

```delphi
Visible := False;
```

он должен оставаться скрытым в обоих режимах.

---

## 14. Disabled Actions

Disabled action:

- показывается согласно `ActionVisibility`;
- использует disabled appearance;
- не выполняет callback;
- hit-test может определять icon для tooltip, если так работает текущая архитектура;
- pressed state не должен запускать action.

Не менять существующую семантику disabled actions.

---

## 15. Search compatibility

Проверить совместимость с Incremental Search:

- hover Actions не должны сбрасывать search highlight;
- FindNext / FindPrevious продолжают работать;
- автопрокрутка к найденному элементу корректно обновляет hover state;
- скрытые Actions не влияют на вычисление search text;
- action tooltips не должны попадать в поиск.

---

## 16. Color Rules и Theme compatibility

Проверить:

- светлые темы;
- тёмные темы;
- hover background;
- selected background;
- Color Rules;
- card indicator;
- disabled actions;
- action hover color;
- action pressed color.

При появлении Actions на hover иконки должны использовать текущую тему, а не фиксированные цвета.

---

## 17. JSON Layout

Добавить сохранение свойства в существующий layout JSON.

Пример:

```json
{
  "actionVisibility": "onHover"
}
```

или в текущем стиле сериализации enum.

Требования:

- при отсутствии поля использовать `uavAlways`;
- старый JSON загружается без ошибок;
- неизвестное значение не вызывает exception;
- fallback — `uavAlways`.

---

## 18. Demo

Все UI-компоненты оставить в `.fmx`.

Не создавать visual controls программно.

Добавить в demo design-time control:

- `TComboBox` или `TSegmentedControl`;
- значения:
  - Always
  - On Hover

При изменении control:

```delphi
UniListView1.ActionVisibility := uavAlways;
```

или:

```delphi
UniListView1.ActionVisibility := uavOnHover;
```

Demo должно позволять проверить:

- List;
- Grid Cards;
- Full-Width Cards;
- Tree.

---

## 19. Изменяемые файлы

Минимально ожидаются:

- `UniList.Control.pas`;
- renderer unit'ы;
- action hit-test unit;
- layout JSON unit;
- `MainUnit.pas`;
- `MainUnit.fmx`;
- runtime package;
- demo project;
- smoke tests.

Не создавать новый unit без необходимости.

---

## 20. Производительность

В `uavOnHover` движение мыши не должно приводить к тяжёлому пересчёту всего layout.

Предпочтительно:

- запомнить previous hover item;
- запомнить new hover item;
- invalidate old rect;
- invalidate new rect.

Если текущий component поддерживает только общий `Repaint`, допустимо использовать его в этом патче, но:

- не пересобирать item cache;
- не пересчитывать row heights;
- не пересоздавать tree;
- не сбрасывать virtualization state.

---

## 21. Edge Cases

Проверить:

- список пуст;
- Actions collection пуст;
- одна action;
- много actions;
- action скрыта;
- action disabled;
- курсор покинул компонент;
- курсор находится над scrollbar;
- прокрутка колесом при hover;
- resize формы;
- смена темы;
- смена ViewMode;
- смена CardLayout;
- удаление hovered item;
- refresh данных;
- lazy tree load;
- collapsed tree node;
- выбранный item без hover;
- быстрый переход мыши между строками.

---

## 22. Acceptance Criteria

Патч готов, если:

- Win32/Win64 компилируются;
- Linux64 компилируется;
- default равен `uavAlways`;
- старое поведение не изменилось;
- `uavOnHover` показывает Actions только у hovered item;
- скрытые Actions не реагируют на click;
- reserved area предотвращает layout jump;
- List работает;
- Grid Cards работают;
- Full-Width Cards работают;
- Tree работает;
- checkbox не ломается;
- tree toggle не ломается;
- search highlight не ломается;
- themes не ломаются;
- Color Rules не ломаются;
- JSON сохраняется и загружается;
- demo обновлено через `.fmx`;
- property видна в Object Inspector;
- нет `Winapi.*`;
- нет `Vcl.*`;
- нет `with`;
- нет новых magic numbers.

---

## 23. Ручной тест-план

### Test 1 — Backward compatibility

```delphi
ActionVisibility := uavAlways;
```

Ожидание:

- Actions видны всегда;
- UI совпадает с 0.9.3.

### Test 2 — List hover

```delphi
ViewMode := uvmList;
ActionVisibility := uavOnHover;
```

Ожидание:

- Actions только у строки под мышью.

### Test 3 — Grid Cards hover

```delphi
ViewMode := uvmCards;
CardLayout := uclGrid;
ActionVisibility := uavOnHover;
```

Ожидание:

- Actions только у hovered card.

### Test 4 — Full-Width Cards hover

```delphi
ViewMode := uvmCards;
CardLayout := uclFullWidth;
ActionVisibility := uavOnHover;
```

Ожидание:

- Actions только у hovered card;
- текст не прыгает.

### Test 5 — Tree hover

```delphi
ViewMode := uvmTree;
ActionVisibility := uavOnHover;
```

Ожидание:

- Actions только у hovered node;
- checkbox и expand toggle работают.

### Test 6 — Hidden hit-test

Навести на item, затем убрать мышь и кликнуть в прежнее место action.

Ожидание:

- callback не вызывается.

### Test 7 — Fast mouse movement

Быстро перемещать курсор между элементами.

Ожидание:

- не остаются “зависшие” Actions;
- hover state корректный.

### Test 8 — Scroll

Навести на item и прокрутить список.

Ожидание:

- Actions не остаются на старой позиции;
- hover item обновляется или очищается.

### Test 9 — Theme switch

Переключать светлые и тёмные темы.

Ожидание:

- action icons сохраняют корректный контраст.

### Test 10 — JSON

Сохранить layout с `uavOnHover`, затем загрузить.

Ожидание:

- режим восстановлен.

---

## 24. Не реализовывать в этом патче

Не добавлять:

- `uavNever`;
- `uavOnSelected`;
- `uavOnHoverOrSelected`;
- touch-specific actions;
- swipe actions;
- action overflow menu;
- action animation;
- fade in/out;
- dropdown;
- lookup control;
- Tree Cards;
- drag-and-drop.

Текущий патч должен решать только одну задачу:

```text
Actions Visibility:
Always / On Hover
```

---

## 25. Definition of Done

- изменения внесены в реальные файлы проекта;
- runtime package обновлён;
- demo обновлено;
- `.fmx` остаётся design-time;
- layout JSON обновлён;
- smoke tests обновлены;
- Win64 build проходит;
- Linux64 build проходит либо документирована конкретная ошибка среды;
- итоговый diff кратко описан;
- все Acceptance Criteria проверены.
