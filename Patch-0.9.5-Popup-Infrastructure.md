# Patch 0.9.5 — Popup Infrastructure

## 1. Цель

Добавить в **UniListView** базовую инфраструктуру popup-контейнера, пригодную для дальнейшего построения:

- popup list;
- lookup control;
- dropdown;
- фильтров;
- выбора темы;
- выбора цвета;
- других всплывающих UI-элементов.

Текущий патч не должен реализовывать lookup-компонент или логику выбора данных.

Главная задача — создать стабильный универсальный popup host.

---

## 2. Базовые правила проекта

Соблюдать текущие правила кодовой базы:

- Delphi 12 Athens;
- FMX;
- Skia-compatible;
- UTF-8 BOM;
- CRLF;
- не использовать `with`;
- использовать Guard Clauses;
- не использовать magic numbers;
- сохранять обратную совместимость;
- design-time friendliness;
- не добавлять `Winapi.*`;
- не добавлять `Vcl.*`;
- не использовать платформенно-зависимые API без условной компиляции;
- новые unit'ы добавить в runtime package, demo и соответствующие project files;
- не ломать Win32/Win64/Linux64;
- код должен корректно компилироваться как минимум под Windows и Linux.

---

## 3. Новый unit

Добавить новый unit:

```text
UniList.Popup.pas
```

Unit должен содержать универсальный popup host.

---

## 4. Новый класс

Добавить:

```delphi
type
  TUniPopupHost = class(TComponent)
  end;
```

Допускается другой базовый FMX-класс, если это необходимо архитектуре, но popup host не должен быть обычным визуальным контролом, который пользователь обязан вручную размещать на форме.

Основной сценарий:

```delphi
PopupHost.ShowPopup(
  AnchorControl,
  PopupContent
);
```

---

## 5. Новый enum позиционирования

Добавить:

```delphi
type
  TUniPopupPlacement = (
    uppAuto,
    uppBelow,
    uppAbove
  );
```

### Семантика

#### `uppAuto`

- сначала попытаться открыть popup ниже anchor;
- если места недостаточно — открыть выше;
- если popup полностью не помещается ни сверху, ни снизу — ограничить его высоту доступной областью.

#### `uppBelow`

- открывать ниже anchor;
- при нехватке места ограничить высоту;
- не менять сторону автоматически.

#### `uppAbove`

- открывать выше anchor;
- при нехватке места ограничить высоту;
- не менять сторону автоматически.

---

## 6. Новый enum ширины

Добавить:

```delphi
type
  TUniPopupWidthMode = (
    upwAnchor,
    upwContent,
    upwFixed
  );
```

### Семантика

#### `upwAnchor`

Ширина popup равна ширине anchor control.

#### `upwContent`

Ширина определяется popup content, но ограничивается доступной областью формы/экрана.

#### `upwFixed`

Используется значение `PopupWidth`.

---

## 7. Публичный API

Минимально ожидаемый API:

```delphi
type
  TUniPopupHost = class(TComponent)
  private
    FPlacement: TUniPopupPlacement;
    FWidthMode: TUniPopupWidthMode;
    FPopupWidth: Single;
    FMaxPopupHeight: Single;
    FCloseOnEscape: Boolean;
    FCloseOnOutsideClick: Boolean;
    FIsOpen: Boolean;
  public
    procedure ShowPopup(
      const AAnchor: TControl;
      const AContent: TControl
    );

    procedure ClosePopup;

    property IsOpen: Boolean read FIsOpen;
  published
    property Placement: TUniPopupPlacement
      read FPlacement
      write FPlacement
      default uppAuto;

    property WidthMode: TUniPopupWidthMode
      read FWidthMode
      write FWidthMode
      default upwAnchor;

    property PopupWidth: Single
      read FPopupWidth
      write FPopupWidth;

    property MaxPopupHeight: Single
      read FMaxPopupHeight
      write FMaxPopupHeight;

    property CloseOnEscape: Boolean
      read FCloseOnEscape
      write FCloseOnEscape
      default True;

    property CloseOnOutsideClick: Boolean
      read FCloseOnOutsideClick
      write FCloseOnOutsideClick
      default True;
  end;
```

Имена можно адаптировать к текущему стилю проекта.

---

## 8. События

Добавить:

```delphi
type
  TUniPopupCloseReason = (
    upcrProgrammatic,
    upcrEscape,
    upcrOutsideClick,
    upcrOwnerHidden,
    upcrOwnerDestroyed
  );
```

События:

```delphi
property OnPopupShown: TNotifyEvent;
property OnPopupClosed: TUniPopupClosedEvent;
```

Где:

```delphi
TUniPopupClosedEvent = procedure(
  Sender: TObject;
  const AReason: TUniPopupCloseReason
) of object;
```

Требования:

- `OnPopupShown` вызывается один раз после фактического показа;
- `OnPopupClosed` вызывается один раз после закрытия;
- повторный `ClosePopup` не должен повторно вызывать событие;
- причина закрытия должна быть корректной.

---

## 9. Поведение ShowPopup

Метод должен:

- проверить `AAnchor <> nil`;
- проверить `AContent <> nil`;
- убедиться, что anchor принадлежит активной форме;
- закрыть уже открытый popup перед показом нового;
- сохранить текущего parent у content при необходимости;
- разместить content внутри popup container;
- вычислить позицию;
- вычислить размеры;
- показать popup;
- установить `FIsOpen := True`;
- корректно обработать focus;
- вызвать `OnPopupShown`.

Guard Clauses обязательны.

---

## 10. Поведение ClosePopup

Метод должен:

- безопасно работать, если popup уже закрыт;
- скрыть popup container;
- отсоединить content;
- восстановить parent content при необходимости;
- очистить references;
- сбросить hover/pressed state popup;
- установить `FIsOpen := False`;
- вызвать `OnPopupClosed`.

Нельзя оставлять dangling references.

---

## 11. Popup container

Popup должен:

- отображаться поверх остальных FMX controls;
- иметь собственную surface/background;
- иметь border;
- иметь corner radius;
- иметь shadow, если это возможно кроссплатформенно;
- использовать текущую тему проекта;
- не зависеть от Windows API;
- не создавать отдельное native window без крайней необходимости.

Предпочтительно использовать FMX overlay/layer на текущей форме.

---

## 12. Overlay

Для `CloseOnOutsideClick = True` использовать прозрачный overlay:

```text
Form
├── Existing UI
├── Popup Overlay
│   └── Popup Container
```

Overlay должен:

- занимать всю клиентскую область формы;
- перехватывать click вне popup;
- не закрывать popup при click внутри;
- не мешать popup content получать mouse events;
- быть удалён или скрыт после закрытия popup;
- не оставаться в visual tree после destroy host.

---

## 13. Закрытие по Escape

При:

```delphi
CloseOnEscape := True;
```

нажатие `Esc` должно закрывать popup.

Требования:

- `Esc` обрабатывается только когда popup открыт;
- popup content может сначала обработать `Esc`, если архитектура это поддерживает;
- если content не обработал, popup закрывается;
- причина закрытия: `upcrEscape`;
- key handling должно работать на Windows и Linux.

---

## 14. Закрытие по клику вне popup

При:

```delphi
CloseOnOutsideClick := True;
```

click вне popup container закрывает popup.

Требования:

- click внутри popup не закрывает popup;
- click по anchor не должен приводить к двойному открытию/закрытию;
- click по scrollbar popup content считается click внутри;
- причина закрытия: `upcrOutsideClick`.

---

## 15. Anchor lifecycle

Popup должен автоматически закрываться, если:

- anchor уничтожен;
- anchor скрыт;
- форма закрывается;
- owner form уничтожается;
- popup host уничтожается.

Использовать `Notification` и безопасные проверки ссылок.

Причины:

- `upcrOwnerHidden`;
- `upcrOwnerDestroyed`.

---

## 16. Позиционирование

Не использовать magic numbers.

Добавить именованные константы:

```delphi
const
  CPopupDefaultGap = 4.0;
  CPopupDefaultMaxHeight = 320.0;
  CPopupDefaultWidth = 240.0;
  CPopupScreenMargin = 8.0;
  CPopupCornerRadius = 6.0;
```

Точные значения можно адаптировать к существующей теме.

Позиция должна учитывать:

- координаты anchor относительно формы;
- scale;
- HiDPI;
- доступную клиентскую область;
- нижнюю и верхнюю границы;
- левую и правую границы;
- возможный scrollbar;
- resize формы.

---

## 17. Ограничение размеров

Popup не должен выходить за клиентскую область формы.

При необходимости:

- уменьшить высоту;
- ограничить ширину;
- скорректировать X;
- скорректировать Y.

Минимальная ширина не должна быть меньше разумного значения, если используется `upwContent`.

---

## 18. Focus behavior

При показе:

- сохранить текущий focused control;
- перевести focus в popup content, если content может получать focus;
- не вызывать exception, если focus не удаётся установить.

При закрытии:

- попытаться вернуть focus anchor control;
- если anchor уже уничтожен или недоступен — не выполнять возврат focus;
- не ломать Tab navigation.

---

## 19. Повторное открытие

Проверить:

- ShowPopup при уже открытом popup;
- ShowPopup с тем же content;
- ShowPopup с другим content;
- ClosePopup после повторного ShowPopup;
- быстрое открытие/закрытие.

Ожидаемое поведение:

- старый popup корректно закрывается;
- references очищаются;
- новый popup показывается без визуальных артефактов.

---

## 20. Scroll compatibility

Popup container должен позволять content самостоятельно управлять scroll.

Popup host не должен:

- перехватывать wheel внутри content;
- менять scroll offset content;
- ломать touch scrolling;
- принудительно создавать собственный scrollbox.

---

## 21. Theme compatibility

Popup surface должна использовать текущую тему UniListView.

Нужно предусмотреть публичные свойства либо внутренний способ получить:

- background color;
- border color;
- shadow color;
- corner radius;
- text contrast.

Не использовать фиксированные светлые/тёмные цвета.

Если popup content — `TUniListView`, он должен визуально совпадать с текущей темой.

---

## 22. Linux compatibility

Обязательно проверить:

- отсутствие `Winapi.*`;
- отсутствие `Vcl.*`;
- отсутствие HWND;
- отсутствие `GetCursorPos`;
- отсутствие `SetWindowPos`;
- отсутствие Windows message hook;
- keyboard handling через FMX;
- mouse handling через FMX;
- popup работает в Linux64 build.

---

## 23. Demo

Добавить в demo design-time:

- кнопку `Open Popup`;
- anchor control;
- popup content panel;
- несколько controls внутри popup content;
- переключатель placement:
  - Auto
  - Below
  - Above
- переключатель width mode:
  - Anchor
  - Content
  - Fixed
- checkbox:
  - Close On Escape
  - Close On Outside Click

Все визуальные компоненты должны оставаться в `.fmx`.

Не создавать demo UI программно.

---

## 24. Demo сценарий

При нажатии:

```delphi
btnOpenPopupClick
```

вызвать:

```delphi
UniPopupHost1.ShowPopup(
  edtPopupAnchor,
  layPopupContent
);
```

В popup content можно временно разместить:

- label;
- edit;
- button;
- небольшой `TUniListView`.

Главная цель demo — проверить инфраструктуру, а не lookup.

---

## 25. Изменяемые файлы

Минимально ожидаются:

- новый `UniList.Popup.pas`;
- runtime package;
- demo `.dproj`;
- demo `.pas`;
- demo `.fmx`;
- smoke tests;
- возможно theme-related unit.

Не изменять основной UniListView без необходимости.

---

## 26. Tests

Добавить smoke tests:

- создание `TUniPopupHost`;
- default values;
- ShowPopup;
- ClosePopup;
- повторный ClosePopup;
- повторный ShowPopup;
- close reason;
- destroy anchor;
- destroy owner form;
- placement calculation;
- width mode;
- max height;
- outside click;
- escape.

---

## 27. Acceptance Criteria

Патч готов, если:

- Win32/Win64 компилируются;
- Linux64 компилируется;
- popup открывается;
- popup закрывается программно;
- popup закрывается по Escape;
- popup закрывается по click outside;
- click внутри не закрывает popup;
- `uppAuto` выбирает сторону корректно;
- `uppBelow` работает;
- `uppAbove` работает;
- width modes работают;
- popup не выходит за границы формы;
- resize формы не ломает popup;
- focus возвращается anchor;
- destroy anchor не вызывает AV;
- destroy form не вызывает AV;
- события вызываются один раз;
- demo находится в `.fmx`;
- runtime package обновлён;
- нет `Winapi.*`;
- нет `Vcl.*`;
- нет `with`;
- нет magic numbers.

---

## 28. Ручной тест-план

### Test 1 — Open / Close

Открыть popup и закрыть программно.

Ожидание:

- popup показывается;
- popup закрывается;
- focus возвращается.

### Test 2 — Escape

Открыть popup и нажать `Esc`.

Ожидание:

- popup закрывается;
- reason = `upcrEscape`.

### Test 3 — Outside Click

Открыть popup и кликнуть вне него.

Ожидание:

- popup закрывается;
- reason = `upcrOutsideClick`.

### Test 4 — Inside Click

Кликнуть по control внутри popup.

Ожидание:

- popup остаётся открытым.

### Test 5 — Auto Placement

Разместить anchor внизу формы.

Ожидание:

- popup открывается сверху.

### Test 6 — Below

Выбрать:

```delphi
Placement := uppBelow;
```

Ожидание:

- popup открывается ниже;
- высота ограничивается при нехватке места.

### Test 7 — Above

Выбрать:

```delphi
Placement := uppAbove;
```

Ожидание:

- popup открывается выше.

### Test 8 — Width Modes

Проверить:

- `upwAnchor`;
- `upwContent`;
- `upwFixed`.

### Test 9 — Resize

Открыть popup и изменить размер формы.

Ожидание:

- popup остаётся в доступной области или корректно перепозиционируется.

### Test 10 — Destroy Anchor

Открыть popup и уничтожить anchor.

Ожидание:

- popup закрывается;
- AV нет.

### Test 11 — Linux

Собрать Linux64 и проверить:

- positioning;
- focus;
- keyboard;
- mouse;
- outside click;
- theme rendering.

---

## 29. Не реализовывать в этом патче

Не добавлять:

- lookup control;
- popup list;
- data binding;
- item selection;
- multi-select;
- filtering;
- incremental search integration;
- animation;
- fade;
- slide;
- native window popup;
- Tree Cards;
- drag-and-drop.

Текущий патч решает только фундаментальную задачу:

```text
Universal FMX Popup Host
```

---

## 30. Definition of Done

- новый unit добавлен;
- runtime package обновлён;
- demo обновлено;
- `.fmx` остаётся design-time;
- smoke tests добавлены;
- Win64 build проходит;
- Linux64 build проходит либо документирована конкретная ошибка среды;
- все Acceptance Criteria проверены;
- итоговый diff кратко описан.
