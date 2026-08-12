# Patch 0.9.9 — TUniLookup Search

## 1. Цель

Добавить встроенный поиск в `TUniLookup`.

Поиск должен использовать уже существующий механизм поиска `TUniListView`.

Нельзя создавать отдельный поисковый движок внутри lookup.

Архитектура:

```text
SearchEdit
   ↓
TUniListView.SearchText
   ↓
существующий Incremental Search Engine
```

---

## 2. Основной принцип

`TUniLookup` только предоставляет UI для ввода поискового текста.

Вся логика:

- поиска;
- кеширования;
- поиска следующего совпадения;
- подсветки;
- прокрутки к найденному элементу;

должна оставаться в существующем `TUniListView`.

Не дублировать `UniList.Search.pas`.

---

## 3. Базовые правила проекта

Соблюдать:

- Delphi 12 Athens;
- FMX;
- UTF-8 BOM;
- CRLF;
- без `with`;
- Guard Clauses;
- без magic numbers;
- Win32 / Win64 / Linux64;
- не использовать `Winapi.*`;
- не использовать `Vcl.*`;
- не ломать `TUniLookup Core`;
- не ломать `TUniDropDown`;
- не ломать `TUniPopupHost`;
- визуальные компоненты demo размещать в `.fmx`.

---

## 4. Popup layout

Внутри popup lookup должна появиться структура:

```text
┌──────────────────────────────────────┐
│ 🔍  Search text...              ×   │
├──────────────────────────────────────┤
│                                      │
│          внутренний TUniListView      │
│                                      │
└──────────────────────────────────────┘
```

Рекомендуемая структура:

```text
PopupRootLayout
├── SearchLayout
│   ├── SearchIcon
│   ├── SearchEdit
│   └── ClearButton
└── TUniListView
```

Не создавать отдельное native edit window.

---

## 5. Новый API

Добавить в `TUniLookup`:

```delphi
property ShowSearchBox: Boolean
  read FShowSearchBox
  write SetShowSearchBox
  default True;

property SearchPrompt: string
  read FSearchPrompt
  write SetSearchPrompt;

property SearchText: string
  read GetSearchText
  write SetSearchText;

property SearchDelay: Integer
  read FSearchDelay
  write SetSearchDelay
  default 250;

property AutoFocusSearch: Boolean
  read FAutoFocusSearch
  write FAutoFocusSearch
  default True;

property ClearSearchOnClose: Boolean
  read FClearSearchOnClose
  write FClearSearchOnClose
  default True;
```

Допускается адаптация имён к стилю проекта.

---

## 6. Значения по умолчанию

Рекомендуемые defaults:

```delphi
ShowSearchBox := True;
SearchPrompt := 'Search...';
SearchDelay := 250;
AutoFocusSearch := True;
ClearSearchOnClose := True;
```

Строку `SearchPrompt` не локализовать внутри кода специальной системой.

Пользователь может изменить её самостоятельно.

---

## 7. SearchEdit

Использовать стандартный FMX edit либо существующий внутренний текстовый control проекта.

Требования:

- поддержка Unicode;
- Ctrl+A;
- Backspace;
- Delete;
- Home/End;
- clipboard;
- IME через стандартный FMX механизм;
- Windows и Linux;
- корректный TabStop;
- не создавать собственный текстовый редактор.

---

## 8. Интеграция поиска

При изменении текста:

```delphi
Lookup.ListView.SearchText := SearchEdit.Text;
```

или через существующий публичный метод search engine.

Не выполнять ручной перебор items в lookup.

Не менять данные списка.

Не создавать отдельную filtered collection.

---

## 9. SearchDelay

`SearchDelay` определяет задержку между вводом и передачей текста в search engine.

Требования:

- значение в миллисекундах;
- `0` означает немедленное применение;
- использовать `TTimer` или существующий debounce-механизм;
- не создавать background thread;
- старый таймер останавливать при новом вводе;
- при закрытии popup таймер выключать;
- при destroy таймер освобождать безопасно.

Ограничить отрицательные значения до `0`.

---

## 10. Открытие lookup

При `OpenDropDown`:

1. открыть popup;
2. синхронизировать временный выбор;
3. если `AutoFocusSearch = True` и `ShowSearchBox = True`:
   - передать focus в SearchEdit;
   - выделить существующий поисковый текст при необходимости;
4. если search box скрыт:
   - focus передать внутреннему `TUniListView`.

Открытие popup не должно автоматически менять committed selection.

---

## 11. Закрытие lookup

### Если `ClearSearchOnClose = True`

После закрытия:

```delphi
SearchText := '';
ListView.SearchText := '';
```

Сброс выполнить после завершения commit/cancel логики.

### Если `False`

Сохранить текст для следующего открытия.

Закрытие не должно повреждать committed selection.

---

## 12. Commit и Cancel

Поиск не должен менять смысл commit/cancel.

### Commit

```text
Enter в списке
double click
single click при CommitOnClick = True
```

Подтверждает текущий item.

### Cancel

```text
Escape
click outside
F4 close
```

Восстанавливает прежний committed item.

Важно:

- поиск может изменить видимый набор;
- временный selection внутри результатов допустим;
- committed `ItemIndex` не менять до подтверждения;
- отмена возвращает прежний `ItemIndex` и `Text`.

---

## 13. Клавиатура в SearchEdit

Когда focus находится в SearchEdit:

### Текстовый ввод

Работает стандартно.

### Down

- передать focus в список;
- выбрать первое совпадение, если current item отсутствует;
- не commit.

### Up

- передать focus в список;
- выбрать последнее видимое совпадение либо текущий item;
- не commit.

### Enter

Если есть текущий видимый item:

- выполнить `CommitSelection`;
- закрыть popup.

Если результата нет:

- ничего не commit;
- popup оставить открытым.

### Escape

Поведение в два этапа:

1. если `SearchText <> ''`:
   - очистить поиск;
   - popup оставить открытым;
2. если поиск уже пуст:
   - выполнить `CancelSelection`;
   - закрыть popup.

### Tab

Следовать стандартной focus navigation внутри popup.

---

## 14. Клавиатура в списке

Когда focus находится во внутреннем `TUniListView`:

- Up/Down/PageUp/PageDown/Home/End работают как раньше;
- Enter подтверждает;
- Escape:
  - если поиск непустой — очистить поиск и вернуть focus SearchEdit;
  - если поиск пустой — отменить и закрыть;
- печатный символ при `ShowSearchBox = True`:
  - перевести focus в SearchEdit;
  - добавить символ в поисковую строку;
  - не потерять первый введённый символ.

Последний пункт реализовать только если это можно сделать чисто через FMX.

---

## 15. Clear button

Добавить кнопку очистки справа в SearchEdit.

Требования:

- показывать только если `SearchText <> ''`;
- векторная иконка `×`/close, не Unicode glyph;
- отдельная hit area;
- click очищает поиск;
- focus остаётся в SearchEdit;
- popup остаётся открытым;
- использовать текущую тему.

Не добавлять отдельное публичное событие для Clear.

---

## 16. Search icon

Слева отображать векторную иконку поиска.

Требования:

- Skia/vector;
- не bitmap;
- не Unicode;
- использовать цвет темы;
- не перехватывать mouse;
- не участвовать в focus navigation.

---

## 17. Search options

Не создавать новые копии параметров поискового движка.

Пользователь должен иметь доступ к существующим search options через внутренний список:

```delphi
Lookup.ListView.SearchOptions
```

Допускается прокси-свойство:

```delphi
property SearchOptions;
```

только если оно напрямую делегирует внутреннему `TUniListView`.

Не дублировать enum и флаги.

---

## 18. Область поиска

Поиск должен учитывать текущие правила `TUniListView`:

- IgnoreCase;
- VisibleColumnsOnly;
- RespectFilters;
- текущие колонки;
- CardRole;
- Tree;
- List;
- Cards;
- Full-Width Cards.

Lookup не должен самостоятельно решать, по каким колонкам искать.

---

## 19. Нет результатов

При отсутствии результатов popup должен оставаться открытым.

Показать empty state:

```text
No matches
```

Допускается использовать существующий empty-state `TUniListView`.

Если его нет, добавить минимальное lookup-сообщение:

```delphi
property NoMatchesText: string;
```

Default:

```text
No matches
```

Не закрывать popup автоматически.

Не очищать committed selection.

---

## 20. Selection при фильтрации

Если committed item не входит в результаты поиска:

- committed `ItemIndex` сохраняется;
- временный current item выбирается среди результатов;
- `Text` lookup не меняется;
- после очистки поиска committed item снова может быть показан и прокручен.

Не сбрасывать selection только из-за поискового текста.

---

## 21. Search highlight

Существующая подсветка совпадений должна работать внутри lookup:

- List;
- Cards;
- Full-Width Cards;
- Tree.

Не добавлять собственную подсветку.

---

## 22. Popup resize

Поиск должен работать вместе с уже добавленным resizable popup.

При resize:

- SearchLayout остаётся сверху;
- ListView занимает оставшуюся область;
- SearchEdit растягивается;
- clear button и search icon остаются на месте;
- popup minimum size учитывает высоту SearchLayout.

Не дублировать resize logic.

---

## 23. Геометрия

Использовать именованные константы:

```delphi
const
  CLookupSearchHeight = 38.0;
  CLookupSearchHorizontalPadding = 8.0;
  CLookupSearchIconSize = 16.0;
  CLookupSearchButtonSize = 28.0;
  CLookupSearchGap = 6.0;
```

Точные значения адаптировать к теме.

Не использовать magic numbers.

---

## 24. Theme integration

Search area должна поддерживать:

- background;
- border;
- text;
- prompt;
- search icon;
- clear icon;
- focus;
- hover;
- disabled.

Использовать существующий Theme Engine.

Не использовать фиксированные цвета.

При смене темы открытый popup должен корректно обновляться.

---

## 25. Design-Time

В Form Designer:

- свойства поиска видны в Object Inspector;
- сам popup не раскрывается;
- внутренний SearchEdit не появляется отдельным control на форме;
- `TUniLookup` продолжает корректно отображаться;
- не запускать поиск в design-time автоматически.

---

## 26. Lifecycle

При destroy:

- остановить debounce timer;
- очистить event handlers;
- закрыть popup;
- не оставить overlay;
- не вызвать callback после начала destroy;
- не оставить dangling reference SearchEdit/ListView.

---

## 27. Demo

Обновить существующий demo lookup.

Добавить:

- `ShowSearchBox`;
- `AutoFocusSearch`;
- `ClearSearchOnClose`;
- `SearchDelay`;
- пример с 100–500 items;
- переключение popup view:
  - List;
  - Full-Width Cards;
- label с committed selection.

Все controls demo разместить в `.fmx`.

---

## 28. Tests

Добавить smoke tests:

- ShowSearchBox True/False;
- immediate search;
- delayed search;
- AutoFocusSearch;
- ClearSearchOnClose True/False;
- Escape очищает текст;
- второй Escape закрывает popup;
- Enter commit результата;
- Enter без результата;
- Down из SearchEdit;
- committed item скрыт поиском;
- cancel восстанавливает выбор;
- clear button;
- no matches;
- List mode;
- Full-Width Cards;
- popup resize;
- destroy при активном debounce timer.

---

## 29. Acceptance Criteria

Патч готов, если:

- search box встроен в `TUniLookup`;
- используется существующий `TUniListView` search engine;
- отдельного поискового движка нет;
- SearchDelay работает;
- AutoFocusSearch работает;
- ClearSearchOnClose работает;
- search highlight работает;
- Down переводит focus в список;
- Enter подтверждает результат;
- Escape сначала очищает поиск, затем закрывает popup;
- committed selection не теряется при фильтрации;
- no-results состояние работает;
- popup resize не ломается;
- List работает;
- Full-Width Cards работают;
- Tree не ломается;
- theme работает;
- Design-Time не ломается;
- Win32/Win64 компилируются;
- Linux64 компилируется;
- нет `Winapi.*`;
- нет `Vcl.*`;
- нет `with`;
- нет magic numbers.

---

## 30. Не реализовывать

Не добавлять:

- JSON adapter;
- DataSource;
- DataField;
- KeyField;
- ListField;
- ValueField;
- remote search;
- HTTP;
- autocomplete текста lookup;
- editable lookup field;
- fuzzy search;
- search history;
- multi-select;
- tokens/tags;
- отдельный Popup List;
- отдельный search engine.

---

## 31. Definition of Done

- `TUniLookup` обновлён;
- popup layout с SearchEdit добавлен;
- runtime package обновлён;
- design-time package обновлён;
- demo обновлено;
- tests добавлены;
- Win64 build проходит;
- Linux64 build проходит либо документирована конкретная ошибка среды;
- commit/cancel и поиск протестированы совместно;
- итоговый diff кратко описан.
