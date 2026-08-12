# Patch 0.9.10 — TUniJsonDataAdapter Core

## 1. Цель Patch

Добавить design-time компонент `TUniJsonDataAdapter`, который преобразует JSON в существующую внутреннюю модель данных `TUniListView`.

Архитектура:

```text
JSON string / stream / bytes
            ↓
   TUniJsonDataAdapter
            ↓
      TUniListView
            ↓
 List / Cards / Tree / Lookup
```

Компонент должен быть универсальным адаптером данных.

Он не должен содержать сетевую логику, HTTP-клиент или REST-функциональность.

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
- добавлять новые units в runtime package, design-time package и соответствующие проекты.

Не выполнять рефакторинг вне области текущего Patch.

Не менять публичный API существующих компонентов без необходимости.

При изменении `UniList.Columns.pas` обязательно сохранить в `uses`:

```delphi
System.UITypes
```

---

## 3. Новый компонент

Добавить:

```delphi
TUniJsonDataAdapter = class(TComponent)
```

Рекомендуемый unit:

```text
UniList.Json.Adapter.pas
```

Компонент должен регистрироваться в палитре UniListView и поддерживать настройку через Object Inspector.

---

## 4. Публичный API

### 4.1 Свойства

Добавить published-свойства:

```delphi
property ListView: TUniListView read ... write ...;

property RootPath: string read ... write ...;
property ArrayPath: string read ... write ...;

property AutoCreateColumns: Boolean read ... write ... default True;
property ClearBeforeLoad: Boolean read ... write ... default True;
property AutoBestFit: Boolean read ... write ... default False;
```

Семантика:

- `ListView` — целевой экземпляр `TUniListView`;
- `RootPath` — необязательный путь к объекту, внутри которого продолжается поиск данных;
- `ArrayPath` — необязательный путь к массиву записей относительно `RootPath`;
- `AutoCreateColumns` — автоматически создавать отсутствующие колонки;
- `ClearBeforeLoad` — очищать существующие строки перед загрузкой;
- `AutoBestFit` — после успешной загрузки вызывать существующий механизм best fit/autofit, не создавая новый алгоритм.

При уничтожении связанного `ListView` ссылка должна корректно обнуляться через `FreeNotification`.

### 4.2 Методы

Добавить public-методы:

```delphi
procedure LoadFromString(const AJson: string);
procedure LoadFromStream(const AStream: TStream);
procedure LoadFromBytes(const ABytes: TBytes);
procedure Clear;
```

Требования:

- `LoadFromStream` не должен владеть переданным stream;
- `LoadFromBytes` должен корректно обрабатывать UTF-8;
- `Clear` очищает данные целевого `TUniListView`, но не удаляет вручную настроенные колонки;
- пустой JSON не должен молча восприниматься как корректный массив.

---

## 5. Исключение

Добавить специализированное исключение:

```delphi
EUniJsonAdapter = class(Exception);
```

Использовать его как минимум для:

- отсутствующего `ListView`;
- некорректного JSON;
- некорректного пути;
- отсутствующего узла по обязательному пути;
- ситуации, когда найденный узел не является массивом записей;
- ошибки структуры записи, которую невозможно корректно обработать.

Сообщения ошибок должны быть понятными и содержать проблемный путь, когда это применимо.

---

## 6. Поддерживаемые структуры JSON

### 6.1 Корневой массив

```json
[
  {
    "id": 1,
    "name": "John",
    "city": "London"
  }
]
```

При пустых `RootPath` и `ArrayPath` корневой узел должен быть массивом.

### 6.2 Массив внутри объекта

```json
{
  "data": [
    {
      "id": 1,
      "name": "John"
    }
  ]
}
```

Настройка:

```delphi
ArrayPath := 'data';
```

### 6.3 Вложенный путь

```json
{
  "result": {
    "items": [
      {
        "id": 1,
        "name": "John"
      }
    ]
  }
}
```

Настройка:

```delphi
ArrayPath := 'result.items';
```

### 6.4 Совместное использование RootPath и ArrayPath

Для JSON:

```json
{
  "payload": {
    "response": {
      "records": [
        {
          "id": 1
        }
      ]
    }
  }
}
```

Настройка:

```delphi
RootPath := 'payload.response';
ArrayPath := 'records';
```

Сначала разрешается `RootPath`, затем относительно найденного узла разрешается `ArrayPath`.

---

## 7. Разрешение путей

Поддержать dot notation:

```text
payload.response.items
address.city
customer.profile.name
```

Правила:

- пустой путь означает текущий узел;
- каждый сегмент должен ссылаться на JSON object property;
- индексирование массивов в пути не поддерживать;
- escaped dots в именах полей пока не поддерживать;
- при ошибке указывать полный проблемный путь.

Не создавать отдельный универсальный JSONPath engine.

---

## 8. Преобразование записей

Каждый элемент массива записей должен быть JSON object.

Поддерживаемые скалярные значения:

- string;
- integer;
- floating-point number;
- boolean;
- null.

Дополнительно:

- datetime остаётся строкой;
- GUID остаётся строкой;
- типы специально не распознавать;
- RTTI не использовать.

### 8.1 Вложенные объекты

Вложенные объекты необходимо flatten-ить через dot notation.

Пример:

```json
{
  "id": 1,
  "address": {
    "city": "London",
    "street": "Baker Street"
  }
}
```

Результирующие поля:

```text
id
address.city
address.street
```

Вложенность должна обрабатываться рекурсивно.

### 8.2 Вложенные массивы

Поля-массивы внутри записи в этом Patch не поддерживаются.

Пример:

```json
{
  "id": 1,
  "phones": ["100", "200"]
}
```

Такое поле не должно приводить к аварийному завершению.

Выбрать одно предсказуемое поведение и документировать его в коде:

- пропускать поле-массив;

или

- сохранять компактное JSON-представление как строку.

Предпочтительный вариант для Core Patch: пропускать поле-массив.

Не разворачивать массивы в отдельные строки или колонки.

---

## 9. Колонки

### 9.1 AutoCreateColumns = True

При загрузке:

- определить все доступные flattened fields;
- создать только отсутствующие колонки;
- существующие колонки не удалять;
- существующие настройки колонок не перезаписывать;
- порядок новых колонок должен быть детерминированным;
- рекомендуется использовать порядок первого появления полей в JSON;
- имя поля использовать как field/key binding;
- Caption формировать из имени поля без сложной локализации.

Для nested field допустим Caption:

```text
address.city
```

Не создавать дубликаты колонок при повторной загрузке.

### 9.2 AutoCreateColumns = False

Использовать только уже существующие колонки.

Поля JSON, для которых нет соответствующей колонки, не должны автоматически добавляться.

Не менять настройки существующих колонок.

---

## 10. Заполнение TUniListView

Использовать существующую модель данных и существующий публичный или внутренний API `TUniListView`.

Запрещается создавать параллельную модель данных специально для JSON Adapter.

Запрещается:

- `TFDMemTable`;
- любой `TDataSet`;
- FireDAC;
- обратная сериализация JSON;
- RTTI;
- собственный renderer;
- изменение Search Engine;
- изменение Lookup;
- изменение Popup;
- изменение Theme Engine.

Все режимы отображения должны начать работать автоматически за счёт заполнения существующей модели:

- List;
- Cards;
- FullWidth Cards;
- Tree;
- Search;
- Lookup.

---

## 11. Атомарность загрузки

Загрузка должна быть предсказуемой.

До изменения данных необходимо:

1. разобрать JSON;
2. разрешить пути;
3. проверить, что найден массив;
4. проверить структуру записей;
5. подготовить flattened representation.

Только после успешной валидации изменять `TUniListView`.

При ошибке парсинга или пути существующие данные не должны частично повреждаться.

Если `ClearBeforeLoad = True`, очищать данные только после успешной подготовки входных данных.

---

## 12. Производительность

Требования:

- один проход без ненужной повторной сериализации;
- не создавать dataset;
- не использовать RTTI;
- не выполнять полный rebuild после добавления каждой отдельной ячейки, если существующий API позволяет batch update;
- использовать `BeginUpdate` / `EndUpdate` или существующий аналог;
- `EndUpdate` должен гарантированно вызываться через `try..finally`;
- не выполнять AutoBestFit до завершения загрузки.

---

## 13. Design-Time

Компонент должен:

- отображаться в Component Palette;
- иметь published-свойства в Object Inspector;
- корректно сохранять ссылку на `TUniListView` в `.fmx`;
- не пытаться автоматически загружать JSON в design-time;
- не выполнять побочные действия при открытии формы в IDE;
- корректно переживать удаление связанного `TUniListView`.

JSON-текст не добавлять как огромное published-свойство компонента.

---

## 14. Значения по умолчанию

Использовать:

```delphi
AutoCreateColumns := True;
ClearBeforeLoad := True;
AutoBestFit := False;
RootPath := '';
ArrayPath := '';
```

Default directives должны соответствовать фактическим значениям конструктора.

---

## 15. Регистрация и packages

Добавить новый unit:

- в runtime package;
- в design-time package, если это требуется структурой проекта;
- в соответствующие `.dpk` / `.dproj`;
- в design-time registration unit.

Не создавать второй registration unit без необходимости.

---

## 16. Минимальный пример использования

Следующий сценарий должен работать:

```delphi
procedure TMainForm.LoadUsers(const AJson: string);
begin
  UniJsonDataAdapter1.ListView := UniListView1;
  UniJsonDataAdapter1.ArrayPath := 'data.items';
  UniJsonDataAdapter1.LoadFromString(AJson);
end;
```

После загрузки данные должны быть доступны существующим режимам `TUniListView` без дополнительного копирования.

---

## 17. Что не входит в Patch

Не реализовывать:

- HTTP;
- REST client;
- URL;
- headers;
- authorization;
- OAuth;
- Bearer token;
- cookies;
- download;
- async loading;
- background threads;
- pagination;
- JSON schema;
- bidirectional binding;
- export в JSON;
- `SaveToFile`;
- `LoadFromFile`;
- nested arrays expansion;
- JSONPath;
- design-time JSON editor;
- automatic REST request.

---

## 18. Критерии приёмки

Patch считается завершённым, если:

1. Компонент устанавливается в IDE.
2. `TUniJsonDataAdapter` виден в палитре.
3. `ListView` назначается через Object Inspector.
4. Загружается корневой JSON array.
5. Работает `ArrayPath`.
6. Совместно работают `RootPath` и `ArrayPath`.
7. Nested objects преобразуются в dot notation.
8. Автоматически создаются отсутствующие колонки.
9. Повторная загрузка не создаёт дубликаты колонок.
10. При `AutoCreateColumns = False` новые колонки не создаются.
11. `ClearBeforeLoad = False` не очищает существующие строки.
12. Некорректный JSON вызывает `EUniJsonAdapter`.
13. Некорректный путь вызывает `EUniJsonAdapter`.
14. Ошибка не оставляет список частично загруженным.
15. `LoadFromStream` не уничтожает stream.
16. `LoadFromBytes` корректно читает UTF-8.
17. Существующие List/Cards/Tree/Search/Lookup продолжают работать.
18. Проект компилируется для Windows.
19. Новый runtime-код не содержит платформенной зависимости, мешающей Linux.
20. Все изменённые файлы сохранены как UTF-8 BOM + CRLF.

---

## 19. Проверки перед завершением

Перед отчётом:

- собрать runtime package;
- собрать design-time package;
- собрать demo project;
- проверить установку компонента;
- проверить загрузку минимум трёх структур JSON;
- проверить повторную загрузку;
- проверить invalid JSON;
- проверить invalid path;
- проверить пустой массив;
- проверить nested object;
- проверить nested array field;
- проверить удаление связанного `TUniListView` в Designer.

---

## 20. Формат итогового отчёта

В конце работы дать краткий отчёт:

```text
Implemented:
- ...

Files added:
- ...

Files changed:
- ...

Validation:
- runtime package: ...
- design-time package: ...
- demo project: ...

Notes:
- ...
```

Не вставлять полные тексты всех изменённых файлов в отчёт, если это не требуется.

---

## 21. Эффективность выполнения

Работать экономно и целенаправленно:

- сначала изучить только относящиеся к задаче units;
- не анализировать повторно весь repository без необходимости;
- изменять минимально необходимое количество файлов;
- не переписывать работающий код;
- не делать косметический рефакторинг;
- не менять форматирование целых файлов;
- не создавать альтернативную архитектуру;
- максимально переиспользовать существующую модель `TUniListView`;
- не выполнять дополнительные улучшения вне этого ТЗ;
- при неоднозначности выбрать самое простое решение, совместимое с текущей архитектурой.

Главная цель:

> минимальный, законченный и компилируемый Patch, полностью соответствующий существующей архитектуре UniListView.
