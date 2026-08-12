# Patch 1.0 RC1 — UniListView Showcase Demo

## 1. Цель Patch

Создать новый отдельный демонстрационный проект, который станет официальной showcase-demo для UniListView 1.0 RC1.

Это не тестовая форма и не набор случайных кнопок.

Новый проект должен показывать правильный способ использования библиотеки:

- максимум Design-Time;
- минимум runtime-кода;
- все команды через `TActionList`;
- все визуальные компоненты размещены через Designer;
- все связи между компонентами по возможности настроены через Object Inspector;
- использование реальных компонентов UniListView без дублирования их логики.

Старая demo должна остаться без изменений.

---

## 2. Новый проект

Создать новый FMX-проект.

Рекомендуемое имя:

```text
UniListView.Showcase
```

Допустимое альтернативное имя:

```text
UniListView.Demo
```

Предпочтительная структура:

```text
Demos/
  UniListView.Showcase/
    UniListView.Showcase.dpr
    UniListView.Showcase.dproj
    MainForm.pas
    MainForm.fmx
    Frames/
      Demo.List.Frame.pas
      Demo.List.Frame.fmx
      Demo.Cards.Frame.pas
      Demo.Cards.Frame.fmx
      Demo.Tree.Frame.pas
      Demo.Tree.Frame.fmx
      Demo.Lookup.Frame.pas
      Demo.Lookup.Frame.fmx
      Demo.Json.Frame.pas
      Demo.Json.Frame.fmx
      Demo.Themes.Frame.pas
      Demo.Themes.Frame.fmx
      Demo.Stress.Frame.pas
      Demo.Stress.Frame.fmx
      Demo.About.Frame.pas
      Demo.About.Frame.fmx
    Data/
      Demo.SampleData.pas
      Demo.SampleJson.pas
```

Имена units можно адаптировать под существующие соглашения проекта, но структура должна оставаться понятной и модульной.

---

## 3. Обязательные правила проекта

Все новые и изменённые файлы:

- UTF-8 with BOM;
- CRLF;
- без `with`;
- использовать guard clauses;
- не использовать magic numbers;
- сохранять Linux-совместимость;
- не подключать `Winapi.*`;
- не подключать `Vcl.*`;
- не создавать визуальные компоненты программно;
- не выполнять крупный рефакторинг runtime-библиотеки;
- не менять публичный API существующих компонентов без критической необходимости.

При изменении `UniList.Columns.pas` обязательно сохранить:

```delphi
System.UITypes
```

---

## 4. Главный принцип

# Design-Time First

Перед написанием обработчиков сначала полностью собрать интерфейс через FMX Designer.

В Designer должны быть настроены:

- layouts;
- toolbars;
- buttons;
- labels;
- edits;
- combos;
- splitters;
- tabs или контейнеры страниц;
- `TActionList`;
- `TUniListView`;
- `TUniLookup`;
- `TUniDropDown`;
- `TUniJsonDataAdapter`;
- темы;
- колонки;
- popup-параметры;
- search-параметры;
- card-параметры;
- tree-параметры;
- bindings между компонентами, если они поддерживаются через Object Inspector.

В runtime-коде оставить только:

- загрузку sample data;
- переключение страниц;
- обработчики Actions;
- небольшую demo-логику;
- обновление текстовой статистики;
- реакции на selection/search/theme events.

Запрещено создавать визуальные компоненты через:

```delphi
TButton.Create
TLayout.Create
TLabel.Create
TPanel.Create
TEdit.Create
TUniListView.Create
TUniLookup.Create
TUniDropDown.Create
```

---

## 5. Главная форма

Создать главную форму showcase-приложения.

Рекомендуемая компоновка:

```text
+------------------------------------------------------+
| Top toolbar / title / theme selector                 |
+----------------------+-------------------------------+
| Navigation           | Content area                  |
|                      |                               |
| List                 | Active demo frame             |
| Cards                |                               |
| Tree                 |                               |
| Lookup               |                               |
| JSON                 |                               |
| Themes               |                               |
| Stress Test          |                               |
| About                |                               |
+----------------------+-------------------------------+
| Status bar                                           |
+------------------------------------------------------+
```

### Требования к MainForm

- навигация слева;
- рабочая область справа;
- status area внизу;
- все основные команды через `TActionList`;
- визуальные элементы создаются только в Designer;
- код MainForm не должен содержать бизнес-логику отдельных страниц;
- MainForm отвечает только за навигацию, глобальную тему и общие Actions.

Желательный предел:

```text
MainForm.pas <= 300 строк
```

Это мягкое ограничение, но его нужно соблюдать по возможности.

---

## 6. Навигация

Для левой навигации использовать `TUniListView`.

Не использовать:

- `TListBox`;
- `TTreeView`;
- `TTabControl` как видимое меню;
- ручные кнопки для каждой страницы.

Навигационный `TUniListView` должен быть настроен через Designer.

Данные навигации могут быть загружены из кода один раз, но сам компонент, его стиль, колонки, режим и theme должны быть design-time.

Навигационные пункты:

```text
List
Cards
Tree
Lookup
JSON
Themes
Stress Test
About
```

При выборе пункта отображается соответствующий frame.

---

## 7. Frames

Каждый раздел должен быть отдельным FMX frame.

Обязательные frames:

```text
List
Cards
Tree
Lookup
JSON
Themes
Stress Test
About
```

Каждый frame:

- создаётся как отдельный `.pas + .fmx`;
- проектируется через Designer;
- содержит собственный `TActionList`, если у страницы есть локальные команды;
- не должен управлять соседними frames;
- не должен содержать глобальную навигацию;
- не должен программно создавать UI.

Желательный предел:

```text
Каждый frame unit <= 500 строк
```

---

## 8. Общие Actions

На MainForm добавить `TActionList`.

Минимальный набор глобальных Actions:

```text
actNavigateList
actNavigateCards
actNavigateTree
actNavigateLookup
actNavigateJson
actNavigateThemes
actNavigateStress
actNavigateAbout
actThemePrevious
actThemeNext
actThemeDefault
actExit
```

Если существующая архитектура позволяет привязать навигацию к selection без отдельных Actions, допускается использовать один общий Action/handler.

Кнопки, меню и горячие клавиши должны использовать `Action`.

Не дублировать код в нескольких обработчиках.

---

## 9. List Demo

Создать отдельный frame для обычного List mode.

Показать:

- колонки;
- resize колонок;
- reorder колонок;
- hide/show колонок;
- frozen columns;
- sorting;
- multisort;
- footer;
- filter row;
- adaptive width;
- row wrapping;
- variable row heights;
- search;
- selection;
- контекстное меню колонок.

### Design-Time требования

Через Designer настроить:

- `TUniListView`;
- колонки;
- captions;
- widths;
- frozen state;
- footer;
- filter row;
- row height mode;
- popup/context menu;
- theme;
- search options.

### Actions

Минимум:

```text
actListLoadSample
actListClear
actListBestFit
actListToggleFilter
actListToggleFooter
actListClearSort
actListSearch
actListClearSearch
```

Sample data может добавляться кодом, но сам компонент и его свойства должны быть design-time.

---

## 10. Cards Demo

Создать отдельный frame для Cards mode.

Показать:

- responsive cards;
- auto height;
- selectable text;
- copy;
- vector icons;
- full-width cards;
- card roles;
- AutoByTitle;
- theme-aware rendering;
- search highlight.

### Design-Time требования

Через Designer настроить:

- режим Cards;
- card roles;
- title/subtitle/details;
- icon field;
- auto height;
- full-width mode;
- spacing;
- theme;
- search options.

### Actions

Минимум:

```text
actCardsLoadSample
actCardsClear
actCardsToggleFullWidth
actCardsToggleAutoHeight
actCardsSearch
actCardsClearSearch
```

Не создавать отдельный card renderer.

Использовать только существующий `TUniListView`.

---

## 11. Tree Demo

Создать отдельный frame для Tree mode.

Показать:

- hierarchy;
- expand/collapse;
- lazy loading;
- checkboxes;
- universal checkboxes;
- search compatibility;
- selection.

### Design-Time требования

Через Designer настроить:

- Tree mode;
- hierarchy fields;
- checkbox options;
- search options;
- theme;
- columns или card representation, если поддерживается.

### Actions

Минимум:

```text
actTreeLoadSample
actTreeExpandAll
actTreeCollapseAll
actTreeCheckAll
actTreeUncheckAll
actTreeSearch
actTreeClearSearch
```

Не реализовывать собственное дерево.

---

## 12. Lookup Demo

Создать отдельный frame для `TUniLookup`.

Показать:

- обычный lookup;
- lookup search;
- keyboard navigation;
- Enter;
- Escape;
- clear search;
- selection commit;
- no-results state;
- использование embedded `TUniListView`;
- List mode;
- Cards mode;
- Tree mode, если текущий API уже поддерживает;
- themes.

### Обязательная архитектура

Использовать существующую архитектуру:

```text
TUniLookup
    ↓
TUniDropDown
    ↓
TUniPopupHost
    ↓
TUniListView
```

Не создавать собственный renderer списка.

Не обходить встроенный `Lookup.ListView`.

### Design-Time требования

Через Designer настроить:

- `TUniLookup`;
- popup size;
- search properties;
- prompt;
- delay;
- autofocus;
- clear-on-close;
- columns/card roles встроенного ListView;
- theme;
- selection/value fields.

### Actions

Минимум:

```text
actLookupLoadSample
actLookupClear
actLookupOpen
actLookupToggleListCards
actLookupApplyTheme
```

---

## 13. JSON Demo

Создать отдельный frame для `TUniJsonDataAdapter`.

Показать:

- `LoadFromString`;
- `RootPath`;
- `ArrayPath`;
- `AutoCreateColumns`;
- `ClearBeforeLoad`;
- `AutoBestFit`;
- nested objects;
- Unicode;
- null;
- boolean;
- number;
- datetime as string;
- GUID as string.

### Design-Time требования

Разместить через Designer:

- `TUniListView`;
- `TUniJsonDataAdapter`;
- controls параметров;
- buttons;
- stats labels;
- sample JSON selector;
- optional read-only memo preview.

Связь:

```delphi
UniJsonDataAdapter1.ListView := UniListView1
```

должна быть настроена через Object Inspector.

`RootPath` и `ArrayPath` также настроить через Object Inspector для основного примера.

### Actions

Минимум:

```text
actJsonLoadSimple
actJsonLoadNested
actJsonLoadUnicode
actJsonReload
actJsonClear
actJsonBestFit
```

Запрещается:

- напрямую наполнять ListView вместо adapter;
- создавать adapter программно;
- добавлять HTTP;
- добавлять REST client.

---

## 14. Themes Demo

Создать отдельный frame для Theme Engine.

Показать:

- список всех доступных тем;
- применение темы;
- preview на реальном `TUniListView`;
- popup;
- lookup;
- cards;
- list;
- tree;
- YAML themes, если текущий API это уже поддерживает;
- Theme-aware Color Rules.

### Design-Time требования

Через Designer разместить:

- theme list;
- preview controls;
- sample list;
- sample cards;
- sample lookup;
- theme selector;
- description area.

Не создавать отдельный theme engine.

### Actions

Минимум:

```text
actThemeApply
actThemePrevious
actThemeNext
actThemeReset
actThemeLoadYamlSample
```

Если YAML loading требует файл, использовать локальный sample из проекта.

Не добавлять network loading.

---

## 15. Stress Test Demo

Использовать уже реализованный JSON stress-test.

Предпочтительный вариант:

- вынести существующую stress-test страницу в отдельный reusable frame;
- подключить этот frame в новый Showcase-проект;
- не копировать бизнес-логику;
- не переписывать генератор.

Если существующая реализация тесно связана со старой form, выполнить минимальное извлечение в frame без изменения поведения.

Обязательные сценарии:

```text
1 000 × 10
10 000 × 30
50 000 × 50
100 000 × 100 manual
Reload x10
Search
List/Cards
```

Известное ограничение `100 000 × 100` с возможным `Out of memory` допускается отобразить как documented stress limit.

Не пытаться исправлять это потоковым parser в текущем Patch.

---

## 16. About Demo

Создать отдельный frame About.

Показать:

- название;
- версия `1.0 RC1`;
- Delphi version;
- поддерживаемые платформы;
- основные возможности;
- архитектурные компоненты;
- Design-Time First philosophy;
- known limitations.

Не добавлять web links, если для этого нужен platform-specific код.

---

## 17. Sample Data

Создать отдельный невизуальный unit для sample data.

Рекомендуемые units:

```text
Demo.SampleData.pas
Demo.SampleJson.pas
```

Они должны содержать:

- sample list records;
- card records;
- tree records;
- lookup records;
- JSON examples;
- Unicode examples.

Не размазывать большие JSON constants по frame units.

Не использовать внешние HTTP sources.

---

## 18. Состояние страниц

Каждый frame должен корректно работать после повторного открытия.

Не выполнять тяжёлую инициализацию в constructor без необходимости.

Допускается lazy initialization данных при первом показе.

Состояние:

- выбранная тема;
- последний активный раздел;
- search text;

может сохраняться только в памяти текущего запуска.

Не добавлять settings storage в этом Patch.

---

## 19. UX

Showcase должен выглядеть как единое приложение, а не как набор тестов.

Требования:

- единые отступы;
- единая высота toolbar;
- единый стиль заголовков;
- понятные подписи;
- status area;
- отсутствие случайных debug-кнопок;
- отсутствие технических captions вроде `Button1`;
- отсутствие `Form1`, `Frame1` в пользовательских надписях;
- keyboard navigation;
- корректный tab order;
- читаемый layout при resize.

Не добавлять сложные анимации.

---

## 20. Размер формы и адаптивность

Главная форма должна корректно работать минимум при:

```text
1280 × 720
1600 × 900
1920 × 1080
```

Минимальный размер можно задать через свойства формы.

Layouts должны корректно растягиваться.

Не использовать абсолютную компоновку там, где достаточно Align/Anchors.

---

## 21. Status Bar

На MainForm добавить status area.

Показывать:

- текущий раздел;
- текущую тему;
- количество строк активного списка, если доступно;
- search text, если применимо;
- краткое сообщение последнего Action.

Не добавлять новый runtime API только ради status bar.

---

## 22. Hotkeys

Настроить через `TActionList`, где это уместно:

```text
Ctrl+F      Search
Esc         Clear search / close popup
Ctrl+L      List page
Ctrl+K      Cards page
Ctrl+T      Tree page
Ctrl+U      Lookup page
Ctrl+J      JSON page
F5          Reload current demo
```

Не перехватывать клавиатуру вручную, если Action supports shortcut.

---

## 23. Design-Time Verification

Перед завершением обязательно проверить:

- проект открывается в Delphi IDE;
- все forms и frames открываются в Designer;
- нет AV в Designer;
- `.fmx` сохраняются;
- проект закрывается и повторно открывается;
- ссылки между компонентами сохраняются;
- `TUniJsonDataAdapter.ListView` сохраняется;
- `TUniLookup` открывается в Designer;
- встроенный `Lookup.ListView` доступен для настройки;
- Actions отображаются в Object Inspector;
- удаление связанного компонента не вызывает AV;
- themes не применяются автоматически с побочными эффектами в Designer;
- sample data не загружается автоматически в design-time без необходимости.

---

## 24. Runtime Verification

Проверить:

- запуск Showcase;
- навигацию по всем страницам;
- List;
- Cards;
- Tree;
- Lookup;
- Lookup Search;
- JSON;
- Themes;
- Stress Test;
- About;
- resize формы;
- theme switching;
- search;
- Actions;
- hotkeys;
- повторное открытие popup;
- повторную загрузку JSON;
- повторную загрузку stress test.

---

## 25. Packages и проекты

Добавить новый project в repository.

Не добавлять showcase units в runtime package библиотеки.

Не добавлять demo units в design-time package.

Добавить новый `.dproj` и `.dpr`.

Если repository использует project group, добавить Showcase в group.

Старую demo не удалять и не переименовывать.

---

## 26. Ограничения Patch

Не реализовывать:

- новые runtime-компоненты;
- новые renderer;
- streaming JSON parser;
- HTTP;
- REST client;
- async engine;
- background loading;
- новый selection subsystem;
- новый theme engine;
- новый popup engine;
- новую navigation library;
- сохранение настроек;
- telemetry;
- installer;
- документационный сайт.

---

## 27. Критерии приёмки

Patch считается завершённым, если:

1. Создан новый отдельный Showcase-проект.
2. Старая demo не изменена функционально.
3. Главная форма создана через Designer.
4. Навигация использует `TUniListView`.
5. Все разделы реализованы как отдельные frames.
6. Визуальные компоненты не создаются программно.
7. Все основные команды используют `TActionList`.
8. Работает List demo.
9. Работает Cards demo.
10. Работает Tree demo.
11. Работает Lookup demo.
12. Lookup использует встроенный `TUniListView`.
13. Работает Lookup Search.
14. Работает JSON demo через `TUniJsonDataAdapter`.
15. Связь Adapter → ListView настроена design-time.
16. Работает Themes demo.
17. Stress Test переиспользован без копирования логики.
18. Работает About.
19. Все forms/frames открываются в Designer.
20. Нет AV в Designer.
21. Проект компилируется для Windows.
22. Новый код не мешает Linux-совместимости.
23. Все изменённые файлы UTF-8 BOM + CRLF.
24. Публичный API runtime-библиотеки не изменён без необходимости.
25. Приложение выглядит как единая showcase-demo, а не как тестовый стенд.

---

## 28. Проверки перед завершением

Перед итоговым отчётом:

- clean build;
- build runtime package;
- build design-time package;
- build Showcase;
- открыть каждый frame в Designer;
- закрыть и повторно открыть проект;
- проверить navigation;
- проверить Actions;
- проверить hotkeys;
- проверить resize;
- проверить List;
- проверить Cards;
- проверить Tree;
- проверить Lookup;
- проверить Lookup Search;
- проверить JSON simple;
- проверить JSON nested;
- проверить JSON Unicode;
- проверить Themes;
- проверить Stress Small;
- проверить Stress Medium;
- проверить Stress Large;
- проверить About.

---

## 29. Формат итогового отчёта

В конце предоставить:

```text
Implemented:
- ...

Project added:
- ...

Frames added:
- ...

Files added:
- ...

Files changed:
- ...

Design-Time validation:
- MainForm: ...
- Frames: ...
- Component links: ...
- Reopen project: ...

Runtime validation:
- List: ...
- Cards: ...
- Tree: ...
- Lookup: ...
- JSON: ...
- Themes: ...
- Stress: ...

Build:
- Runtime package: ...
- Design-time package: ...
- Showcase project: ...

Known limitations:
- ...

Notes:
- ...
```

Не вставлять полные тексты исходников в отчёт.

---

## 30. Эффективность выполнения

Работать экономно и целенаправленно:

- сначала изучить структуру текущей demo;
- изучить только публичные API компонентов, используемых Showcase;
- не анализировать весь repository повторно;
- не переписывать runtime library;
- не выполнять косметический рефакторинг;
- не менять форматирование существующих файлов;
- не копировать stress-test логику;
- максимально переиспользовать существующие units и sample helpers;
- создавать новый UI только через Designer;
- сначала собрать `.fmx`, потом писать обработчики;
- изменять минимально необходимое количество runtime files.

Главная цель:

> создать официальный эталонный Showcase-проект UniListView 1.0 RC1, который демонстрирует возможности библиотеки и подтверждает её Design-Time First архитектуру.
