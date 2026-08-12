# Техническое задание
# UniListView Playground

**Проект:** UniListView  
**Назначение:** единый ручной стенд для проверки всех возможностей `TUniListView`  
**Основа:** `UniListView v0.6.0` с изменениями `patch10`  
**Среда:** Delphi 12, FireMonkey, Skia4Delphi  
**Тип проекта:** FMX desktop application  
**Главное ограничение:** во всём приложении должен существовать **ровно один экземпляр `TUniListView`**

---

## 1. Цель проекта

Создать компактное FMX-приложение, позволяющее вручную проверять все доступные возможности текущего компонента `TUniListView`.

Приложение не является пользовательским Demo, библиотекой демонстрационных сцен, системой плагинов или отдельным фреймворком. Это простой рабочий стенд разработчика.

Все настройки, команды и тесты должны применяться к одному и тому же экземпляру:

```pascal
UniListView1: TUniListView;
```

Компонент не должен пересоздаваться при переключении режимов, генерации данных или изменении настроек.

---

## 2. Жёсткие ограничения

### 2.1. Только один `TUniListView`

Во всём проекте допускается только один экземпляр `TUniListView`.

Запрещено:

- создавать второй `TUniListView` в коде;
- размещать второй `TUniListView` на другой форме или фрейме;
- использовать скрытый экземпляр;
- создавать временный экземпляр для тестов;
- создавать отдельные окна для режимов Cards и List;
- делать набор демонстрационных сцен;
- создавать отдельный экземпляр для benchmark;
- использовать `TUniListView` внутри диалогов.

Все проверки выполняются на `UniListView1`.

### 2.2. Одна главная форма

Проект должен содержать одну рабочую форму:

```pascal
TMainForm
```

Допускаются стандартные диалоги выбора и сохранения файла, но не дополнительные демонстрационные формы.

### 2.3. Без лишней архитектуры

Не создавать:

- Scene Registry;
- Scene Host;
- Demo Packages;
- плагины;
- фабрики сцен;
- маршрутизаторы;
- DI-контейнер;
- отдельную подсистему навигации;
- сложную модель команд;
- универсальный Property Inspector;
- собственный UI-фреймворк поверх FMX.

Обработчик кнопки может напрямую менять свойство `UniListView1`. Для данного проекта это правильная архитектура.

Пример:

```pascal
procedure TMainForm.GridLinesSwitchClick(Sender: TObject);
begin
  UniListView1.ListGridLines := GridLinesSwitch.IsChecked;
end;
```

### 2.4. Не изменять библиотеку без необходимости

Основная задача — создать Playground на существующем API.

Файлы библиотеки изменять только тогда, когда:

- проект не компилируется из-за реальной ошибки;
- существующее публичное свойство не вызывает перерисовку и это мешает проверке;
- обнаружен воспроизводимый дефект компонента.

Любое изменение библиотеки должно быть минимальным и отдельно перечислено в отчёте.

---

## 3. Исходные модули

Playground должен использовать текущие модули:

```pascal
UniList.Control
UniList.Types
UniList.Items
UniList.Columns
UniList.Vector
UniList.Text
```

Все необходимые модули должны быть явно добавлены в секцию `contains` файла проекта.

Особое обязательное правило:

```pascal
UniList.Vector in '..\src\UniList.Vector.pas'
```

необходимо явно включить в `.dpr`, даже если модуль косвенно используется через `UniList.Control`.

При изменении `UniList.Columns.pas` обязательно сохранить:

```pascal
System.UITypes
```

в секции `uses`.

---

## 4. Рекомендуемая структура проекта

```text
playground/
├── UniListPlayground.dpr
├── MainUnit.pas
├── MainUnit.fmx
└── data/
    └── sample-layout.json
```

Не создавать лишние модули, если логика помещается в `MainUnit.pas`.

Допускается один дополнительный модуль только для генерации больших тестовых данных, если `MainUnit.pas` становится чрезмерно большим:

```text
Playground.DataGenerator.pas
```

Но сам `TUniListView` всё равно остаётся только на `TMainForm`.

---

## 5. Компоновка главной формы

На форме должен быть корневой `TLayout`, внутри которого размещаются все визуальные элементы.

```text
TMainForm
└── RootLayout
    ├── TopToolBar
    ├── MainLayout
    │   ├── ControlPanel
    │   ├── Splitter
    │   └── UniListView1
    └── BottomPanel
```

### 5.1. RootLayout

Все контролы формы должны находиться внутри одного корневого `TLayout`.

Это позволит при необходимости масштабировать весь UI через:

```pascal
RootLayout.Scale.X := ScaleValue;
RootLayout.Scale.Y := ScaleValue;
```

Не выполнять индивидуальное масштабирование каждого дочернего контрола.

### 5.2. Верхняя панель

`TopToolBar` содержит основные часто используемые команды:

- `Cards`;
- `List`;
- `100`;
- `1 000`;
- `10 000`;
- `50 000`;
- `Clear`;
- `Reset`;
- `Auto Fit`;
- `Save Layout`;
- `Load Layout`.

### 5.3. Левая панель параметров

`ControlPanel` должен быть прокручиваемым и содержать группы настроек.

Рекомендуемый компонент:

```pascal
TVertScrollBox
```

Внутри него разместить группы:

1. View;
2. Scrolling;
3. Cards;
4. Card Template;
5. List;
6. Columns;
7. Actions;
8. Items;
9. Colors;
10. Layout Persistence;
11. Diagnostics.

Для групп допустимо использовать `TExpander`.

### 5.4. Рабочая область

В правой части находится единственный компонент:

```pascal
UniListView1: TUniListView;
```

Рекомендуемые свойства:

```pascal
Align := TAlignLayout.Client;
TabStop := True;
```

### 5.5. Нижняя панель

Нижняя панель должна содержать:

- строку состояния;
- журнал событий.

Рекомендуемая структура:

```text
BottomPanel
├── StatusLabel
└── EventMemo
```

Журнал можно скрывать кнопкой, но он должен существовать в основном окне.

---

## 6. Начальная конфигурация `TUniListView`

При запуске Playground должен:

1. создать стандартный набор колонок;
2. создать стандартный набор карточных действий;
3. настроить `CardTemplate`;
4. загрузить 100 тестовых элементов;
5. установить режим `uvmCards`;
6. вывести параметры в строку состояния.

Начальные поля элемента:

```text
id
parent_id
name
description
status
icon
latency_ms
load_percent
enabled
can_edit
can_delete
updated_at
```

В текущей версии `TUniListItem` поддерживает произвольные поля через `SetField`.

---

## 7. Тестовые данные

### 7.1. Генерация

Создать процедуру:

```pascal
procedure GenerateItems(const ACount: Integer);
```

Она должна:

- вызывать `UniListView1.BeginUpdate` / `EndUpdate` либо `Items.BeginUpdate` / `EndUpdate`;
- очищать старые данные;
- добавлять заданное количество элементов;
- генерировать смешанное содержимое;
- после загрузки обновлять строку состояния.

Не смешивать оба механизма обновления в одном блоке без необходимости.

### 7.2. Наборы данных

Кнопки верхнего toolbar:

- `100`;
- `1 000`;
- `10 000`;
- `50 000`.

Дополнительно в группе Items:

- числовое поле количества;
- кнопка `Generate`.

Количество должно ограничиваться разумным диапазоном, например:

```text
1..200000
```

### 7.3. Содержимое

Генератор должен создавать разные варианты:

- короткий заголовок;
- длинный заголовок;
- короткое описание;
- многострочное описание;
- пустое описание;
- пустой detail;
- длинный detail;
- Unicode;
- узбекская кириллица;
- значения Integer;
- значения Float;
- значения DateTime;
- значения Boolean;
- disabled-элементы;
- элементы с разрешёнными и запрещёнными actions.

Пример Unicode:

```text
Ўзбекистон, Қорақалпоғистон, ёшлар ва таълим
```

### 7.4. Производительность генератора

Генерация 50 000 элементов не должна делать принудительную перерисовку после каждого добавления.

Обязательно использовать пакетное обновление.

В строке состояния показать:

- количество элементов;
- время генерации;
- текущий режим;
- `ContentWidth`;
- `ContentHeight`;
- `ActualCardWidth`;
- `ColumnCount`;
- `SelectedIndex`.

---

## 8. Группа View

Группа должна управлять свойством:

```pascal
ViewMode: TUniViewMode
```

Поддерживаемые значения текущей версии:

```pascal
uvmCards
uvmList
```

Элементы управления:

- `Cards`;
- `List`.

При переключении:

- использовать тот же `UniListView1`;
- не очищать данные;
- не пересоздавать колонки;
- сбрасывать `ScrollX` и `ScrollY` только по отдельной команде либо когда это необходимо для понятного теста;
- обновлять строку состояния.

Не добавлять режим Tree: в предоставленной версии `TUniViewMode` его нет.

---

## 9. Группа Scrolling

Проверить все существующие значения.

### 9.1. ScrollMode

```pascal
usmVertical
usmHorizontal
usmBoth
```

Использовать `TComboBox`.

### 9.2. PanMode

```pascal
upmDisabled
upmMouse
upmTouch
upmMouseAndTouch
```

Использовать `TComboBox`.

### 9.3. ScrollBars

```pascal
usbNever
usbAuto
usbAlways
```

### 9.4. ContentFlow

```pascal
ucfWrap
ucfNoWrap
```

### 9.5. Ручные операции

Добавить:

- поле `ScrollX`;
- поле `ScrollY`;
- кнопку `Apply Scroll`;
- кнопку `Scroll to selected`;
- поле индекса;
- кнопку `ScrollToItem`;
- кнопку `Scroll Home`;
- кнопку `Scroll End`.

`Scroll Home`:

```pascal
UniListView1.ScrollX := 0;
UniListView1.ScrollY := 0;
```

`ScrollToItem` должен вызывать публичный метод:

```pascal
UniListView1.ScrollToItem(Index);
```

---

## 10. Группа Cards

Группа проверяет геометрию карточек.

### 10.1. CardSizingMode

Поддержать все значения:

```pascal
ucsmFixed
ucsmResponsive
ucsmStretchColumns
ucsmAutoByTitle
```

### 10.2. Числовые свойства

Для каждого свойства создать `TSpinBox` или числовое поле:

```pascal
CardMinWidth
CardMaxWidth
CardWidth
CardHeight
HorizontalGap
VerticalGap
ContentPadding
CornerRadius
FixedColumnCount
PanThreshold
```

Изменение значения должно сразу применяться к `UniListView1`.

### 10.3. Готовые пресеты

Добавить кнопки:

- `Compact`;
- `Normal`;
- `Large`;
- `Auto by title`;
- `Horizontal cards`;
- `Wrapped cards`.

Пресеты должны только менять свойства того же `UniListView1`.

Пример `Horizontal cards`:

```pascal
UniListView1.ViewMode := uvmCards;
UniListView1.ContentFlow := ucfNoWrap;
UniListView1.ScrollMode := usmHorizontal;
```

Пример `Wrapped cards`:

```pascal
UniListView1.ViewMode := uvmCards;
UniListView1.ContentFlow := ucfWrap;
UniListView1.ScrollMode := usmVertical;
```

---

## 11. Группа Card Template

Проверить все опубликованные свойства `TUniCardTemplate`.

### 11.1. Видимость частей

Переключатели:

```pascal
ShowIcon
ShowTitle
ShowText
ShowDetail
ShowActions
```

### 11.2. Текст

Переключатели:

```pascal
WordWrap
Ellipsis
AutoCardHeight
SelectableText
```

Числовые параметры:

```pascal
TitleMaxLines
TextMaxLines
DetailMaxLines
MaxCardHeight
```

### 11.3. Геометрия

Числовые параметры:

```pascal
IconSize
IconBoxSize
InnerPadding
TextGap
```

### 11.4. Иконка по умолчанию

`TComboBox` для:

```pascal
uviNone
uviEdit
uviDelete
uviOpen
uviMore
uviServer
uviCheck
uviChevronRight
uviChevronDown
```

### 11.5. Поля шаблона

Редактируемые поля:

```pascal
TitleField
TextField
DetailField
IconField
StatusField
```

Кнопка `Apply Fields` должна применить значения к `CardTemplate`.

Стандартные значения Playground:

```text
TitleField  = name
TextField   = description
DetailField = status
IconField   = icon
StatusField = status
```

### 11.6. Проверка копирования текста

Добавить:

- кнопку `Clear text selection`;
- read-only поле `SelectedText`;
- кнопку `Show selected text`.

Использовать:

```pascal
UniListView1.ClearTextSelection;
UniListView1.SelectedText;
```

Само копирование `Ctrl+C` должно проверяться штатной клавиатурной обработкой компонента.

---

## 12. Группа List

Группа применяется к режиму `uvmList`, но не должна создавать отдельный список.

Параметры:

```pascal
ListHeaderHeight
ListRowHeight
ListGridLines
ListFooterVisible
ListFooterHeight
ListFrozenColumnCount
```

Элементы управления:

- `Header Height`;
- `Row Height`;
- `Grid Lines`;
- `Footer Visible`;
- `Footer Height`;
- `Frozen Column Count`.

Дополнительные кнопки:

- `Switch to List`;
- `Auto Fit All`;
- `Show Column Chooser`;
- `Reset horizontal scroll`.

Использовать публичные методы:

```pascal
UniListView1.AutoFitAllColumns;
UniListView1.ShowColumnChooser;
```

---

## 13. Группа Columns

### 13.1. Стандартные колонки

При запуске создать минимум следующие колонки:

| FieldName | Caption | DataType | WidthMode | Alignment |
|---|---|---|---|---|
| `name` | Наименование | `ucdtText` | `ucwmFill` | Leading |
| `status` | Состояние | `ucdtText` | `ucwmFixed` | Leading |
| `latency_ms` | Задержка, ms | `ucdtInteger` | `ucwmFixed` | Trailing |
| `load_percent` | Нагрузка | `ucdtFloat` | `ucwmFixed` | Trailing |
| `updated_at` | Обновлено | `ucdtDateTime` | `ucwmFixed` | Center |
| `enabled` | Активен | `ucdtBoolean` | `ucwmFixed` | Center |

Для каждой колонки задать уникальный `LayoutID`.

### 13.2. Операции

Добавить:

- выбор текущей колонки;
- `Add Column`;
- `Delete Column`;
- `Clear Columns`;
- `Restore Default Columns`;
- `Visible`;
- `Sortable`;
- `Auto Fit All`;
- `Show Column Chooser`;
- `SetColumnVisible`.

### 13.3. Редактор выбранной колонки

Поля:

```pascal
LayoutID
FieldName
Caption
Width
MinWidth
MaxWidth
WidthMode
DataType
Alignment
Visible
Sortable
Format
```

Поддержать:

```pascal
TUniColumnWidthMode = (
  ucwmFixed,
  ucwmAuto,
  ucwmFill
);
```

Поддержать:

```pascal
TUniColumnDataType = (
  ucdtText,
  ucdtInteger,
  ucdtFloat,
  ucdtDateTime,
  ucdtBoolean
);
```

Поддержать alignment:

```pascal
TTextAlign.Leading
TTextAlign.Center
TTextAlign.Trailing
```

### 13.4. Проверка мышью

В режиме List вручную должны проверяться встроенные возможности:

- сортировка кликом по заголовку;
- multi-sort, если компонент поддерживает модификатор;
- изменение ширины перетаскиванием разделителя;
- автоматическая ширина двойным щелчком;
- перестановка колонок drag-and-drop;
- контекстный выбор видимости колонок;
- frozen columns;
- горизонтальная прокрутка.

Не реализовывать эти функции повторно в Playground. Playground должен только создавать условия для проверки встроенной реализации `TUniListView`.

---

## 14. Группа Actions

Использовать коллекцию:

```pascal
UniListView1.Actions
```

Создать стандартные actions:

1. `open`;
2. `edit`;
3. `delete`;
4. `more`.

Пример настройки:

```pascal
Action.Name := 'edit';
Action.Caption := 'Изменить';
Action.Icon := uviEdit;
Action.Visible := True;
Action.Enabled := True;
Action.VisibleField := '';
Action.EnabledField := 'can_edit';
```

Для `delete`:

```pascal
Action.EnabledField := 'can_delete';
```

### 14.1. Операции

Добавить:

- выбор action;
- `Add Action`;
- `Delete Action`;
- `Clear Actions`;
- `Restore Default Actions`.

### 14.2. Редактор action

Поля:

```pascal
Name
Caption
Icon
Width
Visible
Enabled
VisibleField
EnabledField
```

Изменения должны применяться к коллекции `Actions` текущего `UniListView1`.

### 14.3. Событие

Обрабатывать:

```pascal
OnItemAction
```

В журнал выводить:

```text
OnItemAction: item=25, action=delete
```

---

## 15. Группа Items

### 15.1. Операции коллекции

Добавить кнопки:

- `Add`;
- `Insert imitation` — не требуется, если API не поддерживает Insert;
- `Delete selected`;
- `Clear`;
- `Enable selected`;
- `Disable selected`;
- `Change selected`;
- `Randomize fields`;
- `Sort by field`;
- `Scroll to selected`.

Удаление:

```pascal
if UniListView1.SelectedIndex >= 0 then
  UniListView1.Items.Delete(UniListView1.SelectedIndex);
```

### 15.2. Изменение выбранного элемента

Редактор должен позволять менять:

```text
ID
ParentID
Title
Text
Detail
IconText
Enabled
name
description
status
latency_ms
load_percent
can_edit
can_delete
updated_at
```

Приоритет для отображения карточки задаётся `CardTemplate.*Field`.

### 15.3. Проверка типизированных полей

Необходимо использовать:

```pascal
SetField
SetFieldDateTime
SetFieldColor
FieldAsString
FieldAsInteger
FieldAsInt64
FieldAsFloat
FieldAsBoolean
FieldAsDateTime
FieldAsColor
ContainsField
ClearField
```

Не обязательно создавать отдельную кнопку для каждого getter. Достаточно диагностического просмотра выбранного элемента.

### 15.4. Сортировка коллекции

Добавить:

- поле имени;
- `Ascending`;
- кнопку `SortByField`.

Использовать:

```pascal
UniListView1.Items.SortByField(FieldName, Ascending);
```

Это отдельная проверка коллекции и не заменяет сортировку по заголовкам колонок.

---

## 16. Группа Selection

Текущая предоставленная версия содержит одиночное выделение через:

```pascal
SelectedIndex
```

Добавить:

- числовое поле индекса;
- `Select`;
- `Clear selection`;
- `Previous`;
- `Next`;
- `Scroll to selected`.

Очистка:

```pascal
UniListView1.SelectedIndex := -1;
```

Не добавлять MultiSelect и MultiCheck, если их нет в фактическом API используемой версии.

---

## 17. Группа Colors

Проверить свойства:

```pascal
BackgroundColor
CardColor
CardHotColor
CardSelectedColor
TextColor
SecondaryTextColor
AccentColor
```

Добавить:

- `TColorComboBox` либо стандартный диалог цвета;
- кнопку применения для каждого свойства;
- пресеты `Light`, `Dark`, `High Contrast`, `Reset`.

Все изменения должны применяться к одному `UniListView1`.

Не создавать отдельный Theme Manager.

---

## 18. Layout Persistence

Проверить все публичные методы:

```pascal
SaveLayoutToJSON
LoadLayoutFromJSON
SaveLayoutToFile
LoadLayoutFromFile
```

### 18.1. Интерфейс

Добавить:

- многострочное поле JSON;
- `Get Layout JSON`;
- `Apply Layout JSON`;
- `Save Layout File`;
- `Load Layout File`;
- `Copy JSON` — необязательно;
- `Reset Default Layout`.

### 18.2. Проверяемый сценарий

1. изменить ширины колонок;
2. поменять порядок колонок;
3. скрыть колонку;
4. задать frozen columns;
5. получить JSON;
6. восстановить стандартную раскладку;
7. загрузить JSON;
8. убедиться, что layout восстановился.

Ошибки JSON должны перехватываться и выводиться в журнал, не завершая приложение.

---

## 19. События и журнал

Обработать минимум:

```pascal
OnItemClick
OnItemAction
```

Также логировать действия самого Playground:

- генерация данных;
- очистка;
- смена режима;
- смена размеров;
- сохранение layout;
- загрузка layout;
- исключения.

Формат:

```text
[10:32:14.125] OnItemClick: index=17
[10:32:15.402] ViewMode: uvmList
[10:32:18.016] GenerateItems: count=10000, elapsed=428 ms
```

Добавить кнопки:

- `Clear Log`;
- `Copy Log` — необязательно;
- `Pause Log`.

Не логировать каждую операцию рисования: это создаст лишнюю нагрузку.

---

## 20. Диагностическая строка состояния

После значимых операций отображать:

```text
Items: 10000 |
Columns: 6 |
Mode: Cards |
Selected: 17 |
CardWidth: 312 |
Content: 1280x24600 |
Scroll: 0x840 |
Last operation: 24 ms
```

Данные брать из одного `UniListView1`:

```pascal
Items.Count
ColumnCount
ViewMode
SelectedIndex
ActualCardWidth
ContentWidth
ContentHeight
ScrollX
ScrollY
```

Обновлять статус:

- после генерации;
- после Clear;
- после смены режима;
- после выбора;
- после операций с колонками;
- после изменения размеров;
- после загрузки layout.

---

## 21. Reset

Кнопка `Reset` должна вернуть тот же экземпляр `UniListView1` к исходному состоянию.

Она должна:

1. вызвать `BeginUpdate`;
2. очистить items;
3. восстановить колонки;
4. восстановить actions;
5. восстановить CardTemplate;
6. восстановить цвета;
7. восстановить размеры;
8. установить `uvmCards`;
9. установить стандартную прокрутку;
10. загрузить 100 тестовых элементов;
11. установить `SelectedIndex := -1`;
12. установить `ScrollX := 0`;
13. установить `ScrollY := 0`;
14. завершить update;
15. обновить статус.

Запрещено освобождать и создавать `UniListView1` заново.

---

## 22. Требования к коду

### 22.1. Имена

Использовать понятные имена:

```pascal
GenerateItems
RestoreDefaultColumns
RestoreDefaultActions
RestoreDefaultCardTemplate
ApplySelectedColumn
ApplySelectedAction
UpdateStatus
LogEvent
ResetPlayground
```

### 22.2. Пакетные изменения

Большие изменения выполнять через:

```pascal
UniListView1.BeginUpdate;
try
  ...
finally
  UniListView1.EndUpdate;
end;
```

либо через `Items.BeginUpdate/EndUpdate`, когда изменяются только items.

### 22.3. Обработка исключений

Операции с файлами и JSON выполнять через `try..except`.

Ошибка должна:

- отображаться в журнале;
- отображаться пользователю;
- не завершать приложение.

### 22.4. Отсутствие заглушек

Не оставлять:

```pascal
TODO
```

в обязательных функциях.

Не создавать кнопки без обработчиков.

### 22.5. Прямые действия

Для стенда допустимы прямые обработчики:

```pascal
procedure TMainForm.FooterVisibleSwitchSwitch(Sender: TObject);
begin
  UniListView1.ListFooterVisible := FooterVisibleSwitch.IsChecked;
  UniListView1.Repaint;
  UpdateStatus;
end;
```

Если конкретное свойство текущей реализации не вызывает invalidate автоматически, Playground может вызвать:

```pascal
UniListView1.Repaint;
```

Но не должен исправлять библиотеку без отдельной необходимости.

---

## 23. Требования к `.dpr`

В `contains` явно перечислить все используемые модули библиотеки.

Пример:

```pascal
uses
  System.StartUpCopy,
  FMX.Forms,
  MainUnit in 'MainUnit.pas' {MainForm},
  UniList.Control in '..\src\UniList.Control.pas',
  UniList.Types in '..\src\UniList.Types.pas',
  UniList.Items in '..\src\UniList.Items.pas',
  UniList.Columns in '..\src\UniList.Columns.pas',
  UniList.Vector in '..\src\UniList.Vector.pas',
  UniList.Text in '..\src\UniList.Text.pas';
```

Не полагаться только на косвенные зависимости.

---

## 24. Проверка компиляции

После реализации Codex должен:

1. собрать проект для Win64 Debug;
2. исправить все ошибки компиляции;
3. исправить предупреждения, связанные с новым кодом;
4. запустить приложение, если среда позволяет;
5. перечислить непроверенные вручную функции.

Если локальная среда не содержит Delphi compiler, это должно быть честно указано. Нельзя писать, что проект собран, без фактической сборки.

---

## 25. Ручной приёмочный тест

### 25.1. Запуск

- приложение открывается;
- виден один `TUniListView`;
- загружено 100 элементов;
- нет исключений.

### 25.2. Режимы

- Cards работает;
- List работает;
- данные не теряются при переключении;
- используется тот же экземпляр.

### 25.3. Данные

- генерируются 100;
- генерируются 1 000;
- генерируются 10 000;
- генерируются 50 000;
- Clear очищает данные;
- Reset возвращает исходное состояние.

### 25.4. Cards

Проверяются:

- все `CardSizingMode`;
- wrap/no-wrap;
- размеры;
- gaps;
- padding;
- corner radius;
- auto height;
- word wrap;
- ellipsis;
- max lines;
- selectable text;
- actions.

### 25.5. List

Проверяются:

- header;
- row height;
- grid lines;
- footer;
- frozen columns;
- sorting;
- resize;
- reorder;
- visibility;
- column chooser;
- auto fit;
- horizontal scroll.

### 25.6. Layout

- layout сохраняется в JSON;
- layout загружается из JSON;
- layout сохраняется в файл;
- layout загружается из файла;
- ошибочный JSON не завершает приложение.

### 25.7. Events

- click отображается в журнале;
- action отображается в журнале;
- выбранный индекс отражается в статусе.

### 25.8. Единственный экземпляр

Поиск по проекту должен подтвердить:

- в `.fmx` присутствует один `TUniListView`;
- в `.pas` нет вызовов `TUniListView.Create`;
- других форм или фреймов с `TUniListView` нет.

---

## 26. Что не входит в задачу

Не реализовывать:

- Tree, если его нет в текущем API;
- Popup List;
- Lookup Control;
- DataSource binding;
- JSON-импорт items, если в текущем API нет готового публичного метода;
- MultiSelect;
- MultiCheck;
- checkbox-логику;
- drag-and-drop items;
- редактирование ячеек;
- отдельный benchmark-проект;
- отдельный Showcase;
- документационный портал;
- плагины;
- пользовательские пакеты;
- многооконный интерфейс.

Такие возможности добавляются в Playground только после появления соответствующего API в фактической версии UniListView.

---

## 27. Результат работы

Codex должен передать:

1. исходный код Playground;
2. `.dpr`;
3. `.pas`;
4. `.fmx`;
5. все минимально необходимые изменения библиотеки, если они действительно потребовались;
6. список созданных и изменённых файлов;
7. результат компиляции;
8. краткий список протестированных возможностей;
9. список найденных дефектов `TUniListView`;
10. подтверждение, что используется ровно один экземпляр `TUniListView`.

---

# Итоговая формулировка задачи для Codex

Создать простое FMX-приложение `UniListView Playground` для ручной проверки текущего `TUniListView`.

В приложении должен быть ровно один экземпляр `TUniListView`. Все кнопки, переключатели, поля и команды должны изменять и тестировать именно этот экземпляр. Нельзя создавать сцены, отдельные демонстрационные формы, второй список, фабрики, плагины или дополнительный архитектурный слой.

Playground должен позволять переключать Cards/List, генерировать разные объёмы данных, изменять все доступные свойства карточек и списка, управлять колонками и actions, проверять прокрутку, выделение, события, цвета, сохранение и восстановление layout.

Проект должен компилироваться в Delphi 12 FMX и использовать фактический API загруженной версии UniListView без выдумывания несуществующих возможностей.
