# Patch 0.9.7.1 — Popup Content Width Fix + Resizable Popup

## 1. Цель

Исправить поведение `upwContent` и добавить возможность изменять размер popup мышкой.

Текущий popup в режиме:

```delphi
WidthMode := upwContent;
```

может становиться уже anchor-контрола, что выглядит неудобно и ломает содержимое.

Также необходимо добавить опциональный resize popup пользователем.

---

## 2. Исправление `upwContent`

Новое правило:

```text
PopupWidth = Max(Anchor.Width, Content.Width)
```

После этого применить ограничения доступной области формы.

Итоговая логика:

```text
RequestedWidth =
  Max(
    Anchor.Width,
    Content.Width
  )

PopupWidth =
  Clamp(
    RequestedWidth,
    MinPopupWidth,
    AvailableWidth
  )
```

Требования:

- popup в `upwContent` не должен быть уже anchor;
- popup не должен выходить за границы формы;
- `upwAnchor` не менять;
- `upwFixed` не менять;
- старые проекты не ломать.

---

## 3. Новые свойства resize

Добавить в `TUniPopupHost`:

```delphi
property Resizable: Boolean
  read FResizable
  write FResizable
  default False;

property MinPopupWidth: Single
  read FMinPopupWidth
  write SetMinPopupWidth;

property MinPopupHeight: Single
  read FMinPopupHeight
  write SetMinPopupHeight;

property MaxPopupWidth: Single
  read FMaxPopupWidth
  write SetMaxPopupWidth;

property MaxPopupHeight: Single
  read FMaxPopupHeight
  write SetMaxPopupHeight;

property RememberUserSize: Boolean
  read FRememberUserSize
  write FRememberUserSize
  default True;
```

Значения по умолчанию подобрать разумно и вынести в константы.

---

## 4. Resize handle

В первом варианте достаточно resize через правый нижний угол popup.

Ориентировочно:

```text
┌──────────────────────────┐
│                          │
│                       ◢  │
└──────────────────────────┘
```

Требования:

- resize handle показывается только при `Resizable = True`;
- отдельная hit area;
- менять курсор на resize;
- drag мышкой изменяет width и height;
- не использовать Unicode-символ как handle;
- handle рисовать векторно;
- не использовать bitmap;
- работать через FMX, без Windows API.

---

## 5. Ограничения resize

Во время drag:

```text
Width >= MinPopupWidth
Height >= MinPopupHeight
Width <= MaxPopupWidth
Height <= MaxPopupHeight
```

Также:

- popup не должен выходить за клиентскую область формы;
- учитывать текущую позицию popup;
- учитывать screen margin;
- не менять anchor;
- не менять placement;
- не закрывать popup во время resize;
- click outside не должен срабатывать при drag handle;
- popup content должен получать новые размеры сразу.

---

## 6. `RememberUserSize`

### `True`

После ручного resize:

- сохранить пользовательские width/height;
- использовать их при следующем открытии;
- применять ограничения min/max;
- сохранять только в памяти компонента;
- не добавлять JSON serialization в этом патче.

### `False`

При каждом открытии:

- заново вычислять размеры по WidthMode и MaxPopupHeight;
- предыдущий пользовательский размер не учитывать.

---

## 7. Приоритет размеров

При открытии popup:

### Если пользователь ещё не менял размер

Использовать обычную логику:

```text
WidthMode
Placement
PopupWidth
MaxPopupHeight
```

### Если `RememberUserSize = True` и пользовательский размер есть

Использовать сохранённый размер, затем применить:

- MinPopupWidth;
- MinPopupHeight;
- MaxPopupWidth;
- MaxPopupHeight;
- доступную область формы.

---

## 8. Resize и WidthMode

После ручного resize:

- текущий popup использует пользовательский размер;
- значение `WidthMode` не менять;
- при следующем открытии:
  - использовать сохранённый размер, если `RememberUserSize = True`;
  - иначе снова вычислить по `WidthMode`.

Не добавлять новый enum `upwResizable`.

Resize должен быть отдельным свойством, а не режимом ширины.

---

## 9. Resize и placement

При `uppBelow`:

- popup растёт вправо и вниз;
- если снизу места нет — ограничить высоту.

При `uppAbove`:

- popup визуально должен оставаться привязанным к anchor;
- изменение height не должно отрывать popup от anchor;
- верхняя граница должна пересчитываться так, чтобы нижний край оставался у anchor.

При `uppAuto`:

- не менять выбранную сторону во время drag;
- только ограничивать размер доступной областью.

---

## 10. Mouse state

Добавить внутренние состояния:

```delphi
FIsResizing: Boolean;
FResizeStartPoint: TPointF;
FResizeStartSize: TSizeF;
```

или эквивалент.

Требования:

- Guard Clauses;
- сбрасывать resize state при mouse up;
- сбрасывать при close;
- сбрасывать при destroy;
- не оставлять component в состоянии resize после потери capture;
- не вызывать popup close во время resize.

---

## 11. Курсор

При наведении на resize handle:

```text
SizeNWSE
```

или FMX-эквивалент.

Не использовать Windows cursor API.

После ухода вернуть стандартный cursor.

---

## 12. Theme integration

Resize handle должен использовать текущую тему:

- обычный цвет;
- hover color;
- pressed color;
- disabled color.

Не использовать фиксированные цвета.

---

## 13. TUniDropDown proxy properties

Добавить в `TUniDropDown` прокси-свойства:

```delphi
property Resizable;
property MinPopupWidth;
property MinPopupHeight;
property MaxPopupWidth;
property MaxPopupHeight;
property RememberUserSize;
```

Они должны делегировать значения внутреннему `TUniPopupHost`.

Не дублировать resize-логику в `TUniDropDown`.

---

## 14. TUniLookup compatibility

Будущий `TUniLookup` должен получить resize автоматически через `TUniDropDown`.

Не добавлять lookup-specific resize code.

---

## 15. Design-Time

В design-time:

- свойства должны быть видны в Object Inspector;
- popup не открывать;
- resize handle не нужен в Designer;
- компонент должен компилироваться без runtime popup.

---

## 16. Linux compatibility

Обязательно:

- без `Winapi.*`;
- без `Vcl.*`;
- без HWND;
- без native window resize;
- mouse handling только через FMX;
- cursor только через FMX;
- Linux64 build должен проходить.

---

## 17. Edge Cases

Проверить:

- content меньше anchor;
- content больше anchor;
- popup около правого края формы;
- popup около нижнего края;
- popup сверху anchor;
- очень маленький popup;
- очень большой popup;
- Min > requested;
- Max < requested;
- resize до минимума;
- resize до границы формы;
- click outside во время resize;
- Escape во время resize;
- закрытие popup во время resize;
- destroy owner во время resize;
- повторное открытие;
- `RememberUserSize = False`;
- `Resizable = False`.

---

## 18. Acceptance Criteria

Патч готов, если:

- `upwContent` больше не создаёт popup уже anchor;
- `upwAnchor` работает как раньше;
- `upwFixed` работает как раньше;
- добавлен `Resizable`;
- resize работает за правый нижний угол;
- min/max ограничения работают;
- popup не выходит за форму;
- resize не закрывает popup;
- content меняет размер вместе с popup;
- `RememberUserSize` работает;
- proxy properties в `TUniDropDown` работают;
- theme работает;
- Win32/Win64 компилируются;
- Linux64 компилируется;
- нет `Winapi.*`;
- нет `Vcl.*`;
- нет `with`;
- нет magic numbers.

---

## 19. Не реализовывать

Не добавлять:

- resize за все стороны;
- resize за углы кроме правого нижнего;
- snap;
- docking;
- animation;
- fade;
- сохранение размера в JSON;
- lookup-specific behavior;
- auto layout content;
- native popup window.

---

## 20. Definition of Done

- `TUniPopupHost` обновлён;
- `TUniDropDown` proxy properties добавлены;
- demo обновлено;
- smoke tests добавлены;
- Win64 build проходит;
- Linux64 build проходит либо документирована конкретная ошибка среды;
- `upwContent` исправлен;
- resize протестирован;
- итоговый diff кратко описан.
