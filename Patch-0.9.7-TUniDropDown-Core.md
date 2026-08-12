# Patch 0.9.7 — TUniDropDown Core

## 1. Цель

Добавить универсальный FMX-компонент:

```delphi
TUniDropDown
```

Компонент должен быть простой оболочкой над существующим `TUniPopupHost`.

Он отвечает только за:

- отображение текста;
- отображение кнопки раскрытия;
- открытие и закрытие popup;
- базовые состояния мыши, клавиатуры и фокуса.

`TUniDropDown` не должен содержать lookup-логику и не должен знать, что находится внутри popup.

## 2. Главный архитектурный принцип

```text
TUniDropDown ничего не знает о содержимом PopupContent.
```

`PopupContent` может быть любым FMX-контролом:

- `TLayout`;
- `TFrame`;
- `TPanel`;
- `TUniListView`;
- календарь;
- цветовая палитра;
- пользовательский control.

Запрещено добавлять проверки или логику, предполагающую, что внутри находится список.

## 3. Базовые правила проекта

Соблюдать:

- Delphi 12 Athens;
- FMX;
- UTF-8 BOM;
- CRLF;
- не использовать `with`;
- использовать Guard Clauses;
- не использовать magic numbers;
- design-time friendliness;
- Win32 / Win64 / Linux64;
- не использовать `Winapi.*`;
- не использовать `Vcl.*`;
- не использовать HWND;
- не создавать native popup window;
- использовать существующий `TUniPopupHost`;
- новые unit'ы добавить в runtime package, design-time package и demo.

## 4. Новый unit

Добавить:

```text
UniList.DropDown.pas
```

## 5. Новый компонент

Добавить:

```delphi
type
  TUniDropDown = class(TControl)
  end;
```

Не наследовать от `TEdit`.

Компонент должен быть доступен в Tool Palette.

## 6. Внешний вид

Компонент должен выглядеть как компактное поле:

```text
┌───────────────────────────────┐
│ DisplayText               ▼  │
└───────────────────────────────┘
```

Поддержать состояния:

- normal;
- hover;
- focused;
- pressed;
- disabled;
- opened.

## 7. Публичный API

Минимально ожидаемый API:

```delphi
type
  TUniDropDown = class(TControl)
  private
    FPopupHost: TUniPopupHost;
    FPopupContent: TControl;
    FText: string;
    FPromptText: string;
    FOpenOnFieldClick: Boolean;
    FIsDropDownOpen: Boolean;
  public
    procedure OpenDropDown;
    procedure CloseDropDown;
    procedure ToggleDropDown;

    property IsDropDownOpen: Boolean
      read FIsDropDownOpen;
  published
    property Text: string
      read FText
      write SetText;

    property PromptText: string
      read FPromptText
      write SetPromptText;

    property PopupContent: TControl
      read FPopupContent
      write SetPopupContent;

    property OpenOnFieldClick: Boolean
      read FOpenOnFieldClick
      write FOpenOnFieldClick
      default True;
  end;
```

Имена можно адаптировать к текущему стилю проекта.

## 8. PopupHost

`TUniDropDown` должен самостоятельно создавать внутренний `TUniPopupHost`.

Предпочтительно:

```delphi
FPopupHost := TUniPopupHost.Create(Self);
```

Пользователь не должен вручную размещать `TUniPopupHost` на форме.

Использовать текущие настройки popup host:

- placement;
- width mode;
- max height;
- close on escape;
- close on outside click.

Допускается опубликовать прокси-свойства:

```delphi
DropDownPlacement
DropDownWidthMode
DropDownWidth
DropDownMaxHeight
CloseOnEscape
CloseOnOutsideClick
```

Не дублировать логику popup host.

## 9. PopupContent

Добавить:

```delphi
property PopupContent: TControl;
```

Требования:

- использовать `FreeNotification`;
- корректно обрабатывать destroy content;
- не уничтожать внешний content;
- запрещать `PopupContent = Self`;
- запрещать циклическую parent-связь;
- не менять owner content;
- parent content может временно меняться только через `TUniPopupHost`.

## 10. Методы управления

### `OpenDropDown`

Должен:

- выйти, если `Enabled = False`;
- выйти, если `PopupContent = nil`;
- выйти, если popup уже открыт;
- вызвать cancelable событие `OnOpening`;
- открыть popup через `TUniPopupHost`;
- установить opened state;
- перерисовать компонент;
- вызвать `OnOpened`.

### `CloseDropDown`

Должен:

- безопасно работать, если popup уже закрыт;
- закрыть popup через `TUniPopupHost`;
- сбросить opened state;
- перерисовать компонент;
- вызвать `OnClosed` один раз.

### `ToggleDropDown`

```delphi
if IsDropDownOpen then
  CloseDropDown
else
  OpenDropDown;
```

## 11. События

Добавить:

```delphi
type
  TUniDropDownOpeningEvent = procedure(
    Sender: TObject;
    var AAllow: Boolean
  ) of object;
```

Свойства:

```delphi
property OnOpening: TUniDropDownOpeningEvent;
property OnOpened: TNotifyEvent;
property OnClosed: TUniPopupClosedEvent;
```

Не добавлять отдельное событие выбора значения.

## 12. Кнопка раскрытия

Кнопка должна:

- находиться справа;
- иметь отдельную hit area;
- использовать векторный chevron;
- не использовать Unicode-символ;
- не использовать bitmap;
- смотреть вниз, когда dropdown закрыт;
- смотреть вверх, когда открыт;
- поддерживать hover и pressed state;
- использовать цвета текущей темы.

## 13. Mouse behavior

### Click по кнопке

Вызывает:

```delphi
ToggleDropDown;
```

### Click по полю

Если:

```delphi
OpenOnFieldClick = True
```

вызывает:

```delphi
ToggleDropDown;
```

Если `False`, открытие возможно только кнопкой и клавиатурой.

Не добавлять логику выбора текста.

## 14. Keyboard behavior

Поддержать:

### Открытие

```text
Alt + Down
F4
Space
Enter
```

### Закрытие

```text
Escape
Alt + Up
F4
```

Условия:

- control имеет focus;
- `Enabled = True`.

Не добавлять навигацию по элементам popup.

## 15. Focus

Компонент должен:

- быть focusable;
- поддерживать `TabStop`;
- рисовать focused state;
- не открываться автоматически при получении focus;
- передавать focus popup content через `TUniPopupHost`;
- возвращать focus после закрытия popup.

## 16. Text и PromptText

### `Text`

Показывается как основной текст.

### `PromptText`

Показывается только если:

```delphi
Text = ''
```

Prompt должен:

- использовать менее заметный цвет;
- не считаться выбранным значением;
- не иметь отдельной логики.

Длинный текст должен обрезаться ellipsis и не перекрывать кнопку.

## 17. Disabled state

При:

```delphi
Enabled := False;
```

- dropdown не открывается;
- если открыт — закрывается;
- text и chevron рисуются disabled;
- mouse и keyboard игнорируются.

## 18. Theme integration

Использовать существующий Theme Engine.

Нужны цвета:

- background;
- border;
- hover background;
- focused border;
- opened border;
- text;
- prompt text;
- chevron;
- disabled text;
- disabled background.

Не использовать фиксированные цвета.

## 19. Геометрия

Использовать именованные константы:

```delphi
const
  CDropDownDefaultHeight = 36.0;
  CDropDownHorizontalPadding = 10.0;
  CDropDownButtonWidth = 34.0;
  CDropDownCornerRadius = 6.0;
  CDropDownBorderThickness = 1.0;
  CDropDownChevronSize = 12.0;
```

Точные значения можно адаптировать к существующей теме.

Не использовать magic numbers в paint/layout.

## 20. Design-Time

В Form Designer компонент должен:

- отображать `Text`;
- показывать `PromptText`, если `Text = ''`;
- показывать chevron;
- отображать текущую тему;
- корректно реагировать на resize;
- позволять назначить `PopupContent` через Object Inspector;
- не открывать popup автоматически.

Не требуется design-time раскрытие popup.

## 21. Lifecycle

При destroy:

- закрыть popup;
- убрать notifications;
- не уничтожать внешний `PopupContent`;
- не оставлять overlay;
- не вызывать события после начала destroy;
- не оставлять dangling references.

## 22. Popup synchronization

Если popup закрывается через:

- Escape;
- click outside;
- owner hidden;
- owner destroyed;
- programmatically;

dropdown обязан:

- сбросить `IsDropDownOpen`;
- вернуть chevron вниз;
- вызвать repaint;
- вызвать `OnClosed` один раз.

Не допускать состояния:

```text
PopupHost.IsOpen = False
TUniDropDown.IsDropDownOpen = True
```

## 23. Demo

Добавить на существующую demo-форму:

- `TUniDropDown`;
- `TLayout` или `TFrame` как `PopupContent`;
- несколько обычных FMX controls внутри popup content;
- кнопку программного открытия;
- кнопку программного закрытия;
- переключатель `OpenOnFieldClick`.

В demo не использовать `TUniListView` как обязательное содержимое popup.

Главная цель — показать универсальность.

## 24. Acceptance Criteria

Патч готов, если:

- добавлен `TUniDropDown`;
- компонент доступен в Tool Palette;
- отображает Text;
- отображает PromptText;
- chevron меняет направление;
- click по кнопке открывает и закрывает popup;
- click по полю учитывает `OpenOnFieldClick`;
- keyboard работает;
- Escape закрывает popup;
- click outside закрывает popup;
- PopupContent может быть любым FMX control;
- dropdown не знает о списках и данных;
- focus работает;
- disabled state работает;
- theme работает;
- design-time работает;
- Win32/Win64 компилируются;
- Linux64 компилируется;
- нет `Winapi.*`;
- нет `Vcl.*`;
- нет `with`;
- нет magic numbers.

## 25. Не реализовывать

Не добавлять:

```delphi
SelectedItem
SelectedValue
SelectedIndex
ItemIndex
KeyField
DisplayField
ValueField
DataSource
SearchText
AutoComplete
IncrementalSearch
```

Не добавлять:

- встроенный `TUniListView`;
- встроенный список;
- data binding;
- выбор записи;
- редактирование текста;
- caret;
- IME;
- autocomplete;
- multi-select;
- Tree Cards;
- drag-and-drop.

## 26. Definition of Done

- новый unit добавлен;
- runtime package обновлён;
- design-time package обновлён;
- demo обновлено;
- smoke tests добавлены;
- Win64 build проходит;
- Linux64 build проходит либо документирована конкретная ошибка среды;
- `PopupContent` остаётся полностью универсальным;
- итоговый diff кратко описан.
