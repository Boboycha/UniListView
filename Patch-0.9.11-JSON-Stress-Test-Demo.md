# Patch 0.9.11 — JSON Stress Test Demo

## 1. Цель Patch

Добавить в demo-проект отдельную страницу для нагрузочного тестирования `TUniJsonDataAdapter` и `TUniListView`.

Эта страница должна позволять без внешних файлов генерировать большие JSON-наборы, загружать их через `TUniJsonDataAdapter` и измерять:

- время генерации JSON;
- размер JSON;
- время загрузки в `TUniListView`;
- количество созданных строк;
- количество колонок;
- примерное потребление памяти процесса до и после загрузки, если это можно сделать кроссплатформенно без платформенных зависимостей;
- скорость повторной загрузки;
- корректность работы поиска и виртуализации на больших объёмах.

Главная задача Patch — создать постоянный инструмент регрессионного и нагрузочного тестирования библиотеки.

---

## 2. Обязательные правила проекта

Все новые и изменяемые файлы:

- UTF-8 with BOM;
- CRLF;
- без `with`;
- использовать guard clauses;
- не использовать magic numbers;
- сохранять design-time совместимость;
- сохранять Linux-совместимость;
- не подключать `Winapi.*` и `Vcl.*`;
- добавлять новые units в соответствующие проекты;
- не выполнять рефакторинг вне области Patch.

При изменении `UniList.Columns.pas` обязательно сохранить:

```delphi
System.UITypes
```

---

## 3. Общая архитектура demo

Создать отдельную страницу или вкладку:

```text
JSON Stress Test
```

Предпочтительно использовать существующую навигационную структуру demo.

UI должен быть максимально настроен через Designer.

Все команды должны использовать `TActionList`.

Не создавать визуальные компоненты программно.

---

## 4. Обязательные design-time компоненты

На странице разместить через Designer:

- `TUniListView`;
- `TUniJsonDataAdapter`;
- `TActionList`;
- набор `TAction`;
- поля ввода параметров генератора;
- переключатели параметров;
- кнопки запуска;
- область со статистикой;
- индикатор выполнения, если он нужен;
- memo или read-only поле для краткого журнала;
- контейнеры и layouts.

`TUniJsonDataAdapter.ListView` должен быть назначен через Object Inspector.

Параметры ListView, колонок, карточек, темы и режима отображения должны по возможности задаваться в Designer.

---

## 5. Параметры генератора

Добавить настройки:

### 5.1 Количество строк

Предустановленные варианты:

```text
100
1 000
10 000
50 000
100 000
```

Допускается editable поле со значением пользователя.

Ограничить некорректные и отрицательные значения.

### 5.2 Количество колонок

Предустановленные варианты:

```text
10
30
50
100
200
```

### 5.3 Дополнительные параметры

Добавить Boolean-настройки:

```text
Nested objects
Unicode
Random nulls
Different field sets
Large text
Boolean fields
Floating-point fields
Date/time strings
GUID strings
Nested array fields
```

Значения по умолчанию:

```text
Nested objects        = True
Unicode              = True
Random nulls         = True
Different field sets = True
Large text           = False
Boolean fields       = True
Floating-point fields= True
Date/time strings    = True
GUID strings         = True
Nested array fields  = True
```

---

## 6. Генерируемая структура JSON

Корневая структура:

```json
{
  "meta": {
    "generatedAt": "2026-01-01T12:00:00Z",
    "rowCount": 10000,
    "columnCount": 30
  },
  "data": {
    "items": [
      {}
    ]
  }
}
```

Настройка адаптера:

```delphi
RootPath := 'data';
ArrayPath := 'items';
```

Эти свойства должны быть настроены через Object Inspector.

---

## 7. Генерация записей

Каждая запись должна иметь стабильный набор базовых полей:

```text
id
code
name
description
active
amount
created_at
guid
```

Дополнительные поля создавать до указанного общего количества колонок.

Пример имён:

```text
field_001
field_002
field_003
...
```

### 7.1 Nested objects

При включённом параметре генерировать:

```json
{
  "address": {
    "country": "Uzbekistan",
    "city": "Tashkent",
    "district": "Yunusabad"
  },
  "profile": {
    "department": "DevOps",
    "role": "Administrator"
  }
}
```

### 7.2 Unicode

Использовать смешанные значения:

```text
Русский текст
O‘zbekcha matn
Ўзбекча матн
العربية
日本語
中文
Emoji 😊 🚀 ✅
```

### 7.3 Random nulls

Примерно 5–15% необязательных значений заменять на `null`.

Процент оформить именованной константой.

### 7.4 Different field sets

Некоторые записи должны пропускать отдельные поля.

Это необходимо для проверки:

- появления колонок по полям из разных записей;
- отсутствующих значений;
- детерминированного порядка колонок.

### 7.5 Large text

При включении генерировать поле с текстом примерно:

```text
10–20 KB
```

Не создавать уникальную огромную строку для каждой записи, если это вызывает чрезмерное потребление памяти.

Разрешается переиспользовать шаблон содержимого.

### 7.6 Nested arrays

При включении добавлять:

```json
"phones": ["+998900000001", "+998900000002"]
```

Это проверяет согласованное поведение адаптера для неподдерживаемых массивов внутри записи.

---

## 8. Генератор JSON

Добавить отдельный невизуальный helper class или unit.

Рекомендуемое имя:

```text
Demo.Json.StressGenerator.pas
```

Пример API:

```delphi
type
  TJsonStressOptions = record
    RowCount: Integer;
    ColumnCount: Integer;
    IncludeNestedObjects: Boolean;
    IncludeUnicode: Boolean;
    IncludeRandomNulls: Boolean;
    IncludeDifferentFieldSets: Boolean;
    IncludeLargeText: Boolean;
    IncludeBooleanFields: Boolean;
    IncludeFloatingPointFields: Boolean;
    IncludeDateTimeStrings: Boolean;
    IncludeGuidStrings: Boolean;
    IncludeNestedArrays: Boolean;
  end;

  TJsonStressGenerator = class
  public
    class function Generate(const AOptions: TJsonStressOptions): string; static;
  end;
```

Допускается другой API, если он остаётся простым и не связан с UI.

Не использовать RTTI.

Не использовать dataset.

Не использовать внешние библиотеки JSON.

Использовать стандартные JSON-классы Delphi.

---

## 9. Actions

Добавить минимум:

```text
actGenerateJson
actLoadJson
actGenerateAndLoad
actReloadJson
actClear
actRunPresetSmall
actRunPresetMedium
actRunPresetLarge
actRunPresetVeryLarge
actToggleListMode
actToggleCardsMode
actApplySearch
actClearSearch
actCopyStatistics
```

Кнопки и горячие клавиши должны быть связаны через `Action`.

Не дублировать бизнес-логику в обработчиках кнопок.

---

## 10. Основные сценарии

### 10.1 Generate JSON

Только генерирует JSON и сохраняет его в памяти формы.

Не загружает его в список.

Обновляет статистику:

- generation time;
- JSON character count;
- JSON byte size в UTF-8;
- выбранные параметры.

### 10.2 Load JSON

Загружает ранее сгенерированный JSON через:

```delphi
UniJsonDataAdapter.LoadFromString(...)
```

Запрещается обходить адаптер и напрямую добавлять строки в ListView.

### 10.3 Generate and Load

Последовательно:

1. генерирует JSON;
2. измеряет время генерации;
3. загружает JSON через адаптер;
4. измеряет время загрузки;
5. обновляет статистику.

### 10.4 Reload

Повторно загружает тот же JSON без повторной генерации.

Нужно для проверки:

- утечек;
- повторного создания колонок;
- стабильности времени;
- `ClearBeforeLoad`.

### 10.5 Clear

Очищает:

- данные ListView;
- сохранённый JSON;
- статистику текущего теста;
- search text.

Не удалять design-time колонки, если они были настроены вручную.

---

## 11. Presets

Добавить четыре готовых сценария:

### Small

```text
Rows: 1 000
Columns: 10
Large text: Off
```

### Medium

```text
Rows: 10 000
Columns: 30
Large text: Off
```

### Large

```text
Rows: 50 000
Columns: 50
Large text: Off
```

### Very Large

```text
Rows: 100 000
Columns: 100
Large text: Off
```

Very Large не должен запускаться автоматически.

---

## 12. Измерение времени

Использовать монотонный таймер, доступный в стандартной RTL.

Рекомендуется:

```delphi
TStopwatch
```

Измерять отдельно:

- generation elapsed;
- load elapsed;
- total elapsed.

Показывать миллисекунды и, при больших значениях, секунды.

---

## 13. Статистика

Отображать:

```text
Rows requested
Rows loaded
Columns requested
Columns created
JSON chars
JSON UTF-8 bytes
Generation time
Load time
Total time
Reload count
Current view mode
Current search text
Visible/filtered row count, если доступно через существующий API
```

Не добавлять новый публичный API в `TUniListView` только ради demo, если нужное значение недоступно.

---

## 14. Память

Не добавлять платформенно-зависимый код в runtime library.

Если кроссплатформенное измерение памяти процесса невозможно средствами текущего проекта:

- не реализовывать точное измерение памяти;
- показать `N/A`;
- оставить краткий комментарий в demo unit.

Не подключать `Winapi.Windows` ради этого Patch.

Допускается показывать размер сгенерированной строки и количество записей как основной показатель нагрузки.

---

## 15. UI responsiveness

Первый вариант Patch может выполнять генерацию и загрузку синхронно.

Но:

- курсор/индикатор состояния должен показывать, что операция выполняется;
- команды запуска должны временно блокироваться;
- состояние UI должно гарантированно восстанавливаться через `try..finally`;
- не добавлять background thread в этом Patch;
- не вызывать `Application.ProcessMessages` внутри циклов генерации.

Асинхронную генерацию оставить на будущий Patch.

---

## 16. Проверка ListView после загрузки

После `Generate and Load` demo должна позволять:

- переключиться между List и Cards;
- прокручивать список;
- применять существующий incremental search;
- очищать поиск;
- проверить сортировку;
- проверить AutoBestFit вручную;
- открыть контекстное меню колонок;
- выполнить повторную загрузку.

Не создавать отдельный renderer или отдельный search.

---

## 17. Проверка повторной загрузки

Добавить сценарий:

```text
Reload x10
```

Допускается отдельный Action:

```text
actReloadTenTimes
```

Он должен:

1. десять раз загрузить тот же JSON;
2. измерить общее и среднее время;
3. проверить, что количество колонок не растёт;
4. вывести результат в журнал.

Если возникло исключение — остановить цикл и показать номер итерации.

---

## 18. Журнал

Добавить компактный read-only журнал.

Пример:

```text
[20:12:10] Generated 10 000 rows, 30 columns, 8.4 MB, 412 ms
[20:12:11] Loaded 10 000 rows, 30 columns, 695 ms
[20:12:17] Reload x10 completed, average 672 ms
```

Ограничить количество строк журнала именованной константой, например 500.

Старые строки удалять.

---

## 19. Ошибки

Все действия должны корректно обрабатывать:

- некорректные параметры;
- отсутствие сгенерированного JSON;
- `EUniJsonAdapter`;
- нехватку памяти;
- прочие исключения.

При ошибке:

- UI разблокируется;
- сообщение отображается пользователю;
- ошибка записывается в журнал;
- предыдущая статистика не маскируется ложным успешным результатом.

---

## 20. Design-Time-first требования

Максимально настроить в Designer:

- расположение контролов;
- подписи;
- значения по умолчанию;
- Actions;
- ListView;
- JsonDataAdapter;
- режим отображения;
- Theme;
- колонки, если используются заранее созданные;
- popup/menu;
- hotkeys.

В коде формы оставить только:

- сбор параметров;
- вызов генератора;
- вызов адаптера;
- измерение времени;
- обновление статистики;
- журнал;
- небольшую demo-логику.

Не создавать UI в `FormCreate`.

---

## 21. Что не входит в Patch

Не реализовывать:

- HTTP;
- REST;
- чтение JSON из URL;
- background threads;
- parallel generation;
- streaming parser;
- экспорт результатов в CSV;
- графики производительности;
- автоматический benchmark при старте;
- отдельный benchmark framework;
- изменение runtime API только ради demo;
- оптимизацию `TUniJsonDataAdapter`, пока тест не выявил конкретную проблему.

---

## 22. Критерии приёмки

Patch считается завершённым, если:

1. В demo появилась отдельная страница `JSON Stress Test`.
2. Все основные визуальные компоненты созданы через Designer.
3. Команды реализованы через `TActionList`.
4. Генерируется 1 000 строк.
5. Генерируется 10 000 строк.
6. Генерируется 50 000 строк.
7. Доступен ручной тест 100 000 строк.
8. Работают 10, 30, 50, 100 и 200 колонок.
9. Работают nested objects.
10. Работает Unicode.
11. Работают random nulls.
12. Работают разные наборы полей.
13. Nested arrays не ломают загрузку.
14. JSON загружается только через `TUniJsonDataAdapter`.
15. Время генерации и загрузки измеряется раздельно.
16. Повторная загрузка не создаёт дубликаты колонок.
17. Работает `Reload x10`.
18. После загрузки работает поиск.
19. После загрузки работают List и Cards.
20. Demo компилируется на Windows.
21. Новый код не создаёт препятствий для Linux.
22. Все изменённые файлы сохранены как UTF-8 BOM + CRLF.

---

## 23. Проверки перед завершением

Перед итоговым отчётом проверить:

- Small preset;
- Medium preset;
- Large preset;
- Very Large preset хотя бы один раз, если среда позволяет;
- 200 колонок;
- Unicode;
- nested objects;
- random nulls;
- different field sets;
- large text;
- nested arrays;
- reload;
- reload x10;
- search;
- List mode;
- Cards mode;
- Clear;
- повторную генерацию после Clear;
- ошибочные значения RowCount и ColumnCount.

---

## 24. Формат итогового отчёта

```text
Implemented:
- ...

Files added:
- ...

Files changed:
- ...

Validation:
- Small preset: ...
- Medium preset: ...
- Large preset: ...
- Very Large preset: ...
- Reload x10: ...
- Windows build: ...
- Linux compatibility review: ...

Performance sample:
- Rows:
- Columns:
- JSON size:
- Generation:
- Load:

Notes:
- ...
```

Не вставлять полные тексты файлов в отчёт.

---

## 25. Эффективность выполнения

Работать экономно:

- изучить только demo, `TUniJsonDataAdapter` и необходимый API `TUniListView`;
- не анализировать весь repository повторно;
- не менять runtime library без конкретной необходимости;
- не оптимизировать код заранее;
- не выполнять косметический рефакторинг;
- не переписывать существующую demo;
- добавить одну законченную страницу;
- максимально использовать Designer и `TActionList`;
- изменить минимальное количество файлов.

Главная цель:

> получить постоянный, воспроизводимый и удобный stress-test для JSON Adapter и UniListView, а не одноразовый тестовый код.
