# Patch 0.9.3 — Full-Width Card Layout

## 1. Цель

Добавить в **UniListView** новый вариант карточного режима, при котором каждая карточка занимает всю доступную ширину viewport и располагается отдельной строкой.

Этот режим станет фундаментом для будущего компонента выпадающего списка / lookup-контрола.

---

## 2. Базовые требования проекта

Соблюдать существующие правила кодовой базы:

- Delphi 12 Athens
- FMX
- Skia renderer
- UTF-8 BOM
- CRLF
- не использовать `with`
- предпочитать Guard Clauses
- не использовать magic numbers
- сохранять обратную совместимость
- не ломать существующий `uclGrid`
- новые типы и свойства должны быть доступны design-time
- новые unit'ы обязательно добавлять в:
  - runtime package
  - demo project
  - соответствующие `.dproj` / `.dpk`
- при использовании `TTextAlign`, `TAlphaColor`, `TFontStyle` и аналогичных типов явно подключать `System.UITypes`
- Linux compatibility:
  - не добавлять `Winapi.*`
  - не добавлять `Vcl.*`
  - не использовать платформенно-зависимые API без условной компиляции

---

## 3. Новый API

### 3.1. Новый enum

Добавить тип:

```delphi
type
  TUniCardLayout = (
    uclGrid,
    uclFullWidth
  );
```

### 3.2. Новое свойство компонента

```delphi
property CardLayout: TUniCardLayout
  read FCardLayout
  write SetCardLayout
  default uclGrid;
```

Значение по умолчанию должно сохранить текущее поведение:

```delphi
uclGrid
```

---

## 4. Поведение `uclFullWidth`

В режиме:

```delphi
ViewMode := uvmCards;
CardLayout := uclFullWidth;
```

каждая карточка должна:

- занимать всю доступную ширину viewport;
- располагаться отдельной строкой;
- не создавать горизонтальный скролл;
- учитывать внутренние отступы компонента;
- учитывать вертикальный scrollbar;
- работать с текущей виртуализацией;
- поддерживать фиксированную и автоматическую высоту;
- корректно перерасчитываться при resize формы;
- корректно работать на HiDPI;
- сохранять текущую тему;
- сохранять Color Rules;
- сохранять checkbox;
- сохранять hover / selection;
- сохранять search highlight;
- сохранять card rule indicator;
- сохранять текущую модель данных.

---

## 5. Отображение выбранных свойств

Для будущего dropdown/lookup режима необходимо уметь управлять тем, какие колонки отображаются в карточках.

### 5.1. Новое свойство колонки

В `TUniListColumn` добавить:

```delphi
property VisibleInCards: Boolean
  read FVisibleInCards
  write SetVisibleInCards
  default True;
```

Важно:

- свойство не должно влиять на `Visible` в List Mode;
- `Visible = False` не обязательно должно автоматически скрывать колонку в карточках;
- `VisibleInCards = False` скрывает только карточное представление;
- изменение свойства должно вызывать `Changed` / `Redraw`.

### 5.2. Новый enum роли поля в карточке

Добавить:

```delphi
type
  TUniCardRole = (
    ucrAuto,
    ucrTitle,
    ucrSubtitle,
    ucrDetail,
    ucrTrailing,
    ucrHidden
  );
```

### 5.3. Новое свойство колонки

```delphi
property CardRole: TUniCardRole
  read FCardRole
  write SetCardRole
  default ucrAuto;
```

### 5.4. Семантика ролей

#### `ucrAuto`

Использовать текущую карточную раскладку.

#### `ucrTitle`

Главное поле карточки.

Требования:

- более заметный шрифт;
- максимум одна строка по умолчанию;
- ellipsis при нехватке ширины;
- одна колонка `ucrTitle` считается основной;
- если таких колонок несколько, использовать первую по порядку.

#### `ucrSubtitle`

Вторичный текст под title.

#### `ucrDetail`

Обычные дополнительные свойства.

#### `ucrTrailing`

Поле справа.

Типичный пример:

- Status
- Code
- Amount
- Date
- Badge

В `uclFullWidth` trailing-часть должна располагаться справа и не перекрывать title/subtitle.

#### `ucrHidden`

Полностью скрыто в карточках независимо от `VisibleInCards`.

---

## 6. Рекомендуемая раскладка full-width карточки

Ориентировочная структура:

```text
┌────────────────────────────────────────────────────────────┐
│ [checkbox] [icon] Title                         Trailing    │
│                   Subtitle                                  │
│                   Detail 1   Detail 2   Detail 3            │
└────────────────────────────────────────────────────────────┘
```

Нужно учитывать:

- checkbox слева;
- card rule indicator;
- optional icon;
- trailing field справа;
- перенос текста;
- auto row/card height;
- padding;
- search highlight;
- long strings;
- пустые значения.

---

## 7. Константы layout

Все размеры вынести в именованные константы.

Пример:

```delphi
const
  CFullWidthCardHorizontalPadding = 12.0;
  CFullWidthCardVerticalPadding = 10.0;
  CFullWidthCardGap = 8.0;
  CFullWidthCardTitleGap = 4.0;
  CFullWidthCardTrailingMinWidth = 80.0;
```

Точные значения можно адаптировать к текущему renderer, но не использовать числовые литералы прямо в paint-методах.

---

## 8. Виртуализация

`uclFullWidth` должен использовать существующий механизм виртуализации.

Требования:

- не создавать отдельный FMX-control на каждую карточку;
- рендерить только видимый диапазон;
- корректно рассчитывать:
  - total content height;
  - first visible card;
  - last visible card;
  - scroll offset;
- при auto height использовать существующий cache;
- resize должен инвалидировать только нужные layout caches;
- смена `CardLayout` должна перестраивать размеры и вызывать redraw.

---

## 9. Search Engine compatibility

Проверить совместимость с `UniList.Search.pas`.

В `uclFullWidth` должны работать:

- `SearchText`;
- подсветка совпадений;
- `FindNext`;
- `FindPrevious`;
- автопрокрутка к найденной карточке;
- поиск только по колонкам, которые участвуют в поиске;
- скрытые через `ucrHidden` поля не должны визуально подсвечиваться.

Не ломать текущий поиск в `uclGrid`, List и Tree.

---

## 10. Color Rules compatibility

Проверить:

- row-scope rule;
- cell-scope rule;
- theme-aware colors;
- card rule indicator;
- selected state;
- hover state.

В `uclFullWidth` row-scope background rule не должен полностью ломать поверхность карточки.

Текущая логика индикатора слева должна сохраниться.

---

## 11. Checkbox compatibility

В `uclFullWidth` checkbox должен:

- находиться слева;
- иметь достаточную hit area;
- использовать текущую тему;
- сохранять отметку между:
  - Grid Cards
  - Full-Width Cards
  - List
  - Tree
- не смещать title при отключённом `ShowCheckBoxes`.

---

## 12. Сохранение layout JSON

Добавить сохранение:

```json
{
  "cardLayout": "fullWidth"
}
```

или эквивалентное enum-значение в существующем стиле проекта.

Сохранить обратную совместимость:

- если поле отсутствует, использовать `uclGrid`;
- старые layout JSON должны загружаться без ошибок.

Также сохранить по колонкам:

```json
{
  "visibleInCards": true,
  "cardRole": "title"
}
```

---

## 13. Demo

Все визуальные компоненты должны оставаться в `.fmx`.

Не создавать UI программно.

### 13.1. Добавить design-time controls

Добавить в demo:

- `TComboBox` или `TSwitch` для выбора layout:
  - Grid
  - Full Width
- подпись текущего режима;
- существующий `TUniListView` оставить design-time.

### 13.2. Настроить роли колонок

Рекомендуемая демонстрационная настройка:

```text
name / display_name   -> ucrTitle
description           -> ucrSubtitle
address               -> ucrDetail
version               -> ucrDetail
latency_ms            -> ucrDetail
status                -> ucrTrailing
id                     -> ucrHidden
parent_id              -> ucrHidden
has_children           -> ucrHidden
```

### 13.3. Проверить темы

Demo должно позволять переключать темы и сразу видеть full-width cards.

---

## 14. Изменяемые файлы

Минимально ожидаются изменения:

- `UniList.Control.pas`
- `UniList.Columns.pas`
- возможно renderer unit'ы карточек
- `MainUnit.pas`
- `MainUnit.fmx`
- runtime package
- demo project
- smoke tests
- stress tests

Важно:

В `UniList.Columns.pas` явно добавить:

```delphi
System.UITypes
```

---

## 15. Обратная совместимость

Обязательно:

- существующий `uclGrid` визуально и функционально не должен измениться;
- текущие проекты без нового свойства должны работать как раньше;
- старые `.fmx` должны открываться;
- старые layout JSON должны загружаться;
- существующие публичные API не переименовывать;
- не удалять deprecated alias в этом патче.

---

## 16. Acceptance Criteria

Патч считается готовым, если:

- проект компилируется Win32/Win64;
- проект компилируется Linux64;
- `uclGrid` работает без регрессий;
- `uclFullWidth` показывает одну карточку на строку;
- карточка занимает ширину viewport;
- горизонтальный scroll не появляется;
- resize работает корректно;
- auto height работает;
- checkbox работает;
- themes работают;
- Color Rules работают;
- search highlight работает;
- selection и hover работают;
- layout JSON сохраняет `CardLayout`;
- `VisibleInCards` работает;
- `CardRole` работает;
- demo остаётся design-time;
- нет `Winapi.*`;
- нет `Vcl.*`;
- нет `with`;
- нет magic numbers в renderer;
- новые enum/property видны в Object Inspector.

---

## 17. Ручной тест-план

### Test 1 — Grid regression

```delphi
ViewMode := uvmCards;
CardLayout := uclGrid;
```

Ожидание: поведение полностью совпадает с предыдущей версией.

### Test 2 — Full width

```delphi
ViewMode := uvmCards;
CardLayout := uclFullWidth;
```

Ожидание: одна карточка на строку.

### Test 3 — Resize

Изменять ширину формы.

Ожидание:

- карточка растягивается;
- текст перераспределяется;
- scrollbar не ломается.

### Test 4 — Selected properties

Отключить:

```delphi
Column.VisibleInCards := False;
```

Ожидание: поле исчезает только из карточек.

### Test 5 — Roles

Настроить:

```delphi
NameColumn.CardRole := ucrTitle;
StatusColumn.CardRole := ucrTrailing;
```

Ожидание:

- Name слева;
- Status справа.

### Test 6 — Checkbox

Отметить записи в Full Width, переключиться в List и обратно.

Ожидание: отметки сохраняются.

### Test 7 — Search

Найти текст в subtitle/detail.

Ожидание:

- карточка прокручивается в viewport;
- найденный текст подсвечивается.

### Test 8 — Themes

Переключить несколько светлых и тёмных тем.

Ожидание: layout и контраст остаются корректными.

### Test 9 — Linux

Собрать Linux64 и проверить:

- шрифты;
- размеры;
- scroll;
- keyboard;
- mouse;
- rendering.

---

## 18. Не реализовывать в этом патче

Не добавлять:

- dropdown popup;
- lookup control;
- dataset lookup binding;
- Tree Cards;
- drag-and-drop;
- inline editing;
- multi-select popup;
- remote data loading.

Этот патч должен создать только стабильный фундамент:

```text
Full-Width Card Layout
+
Selected Card Properties
+
Card Roles
```

---

## 19. Definition of Done

- код внесён в реальные файлы проекта;
- новые типы и свойства добавлены в design-time;
- demo обновлено через `.fmx`;
- runtime package обновлён;
- tests обновлены;
- Win64 build проходит;
- Linux64 build проходит либо документированы конкретные ошибки среды;
- все acceptance criteria проверены;
- итоговый diff кратко описан в отчёте Codex.
