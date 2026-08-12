# Patch 0.9.6 — Design-Time Preview

## 1. Цель

Сделать `TUniListView` "живым" в Design-Time.

Разработчик должен сразу видеть будущий результат без запуска приложения.

Поддерживаемые режимы:

- List
- Cards
- Full-Width Cards
- Tree

---

## 2. Основные требования

- Delphi 12 Athens
- FMX
- UTF-8 BOM
- CRLF
- без `with`
- Guard Clauses
- без magic numbers
- Win32 / Win64 / Linux64
- не использовать `Winapi.*`
- не использовать `Vcl.*`

---

## 3. Новый API

### 3.1 DesignPreviewMode

```delphi
type
  TUniDesignPreviewMode = (
    dpmNone,
    dpmSampleData,
    dpmConnectedData
  );
```

### 3.2 Свойства

```delphi
property DesignPreviewMode: TUniDesignPreviewMode
  default dpmSampleData;

property DesignPreviewRows: Integer
  default 8;
```

---

## 4. Поведение

### dpmNone

Компонент ведёт себя как сейчас.

### dpmSampleData

Если компонент находится в Design-Time:

```delphi
csDesigning in ComponentState
```

автоматически генерируются тестовые записи.

### dpmConnectedData

Если подключён активный DataSet:

- показать первые записи реального DataSet;

если DataSet отсутствует или закрыт:

- автоматически перейти на SampleData.

---

## 5. Генерация Sample Data

Не использовать фиксированную структуру.

Использовать существующие колонки.

Пример:

| Колонка | Пример |
|---------|--------|
| Name | John Smith |
| Email | john@example.com |
| Status | Active |
| Date | 2026-01-15 |
| Amount | 1250.50 |
| Boolean | Yes |

Для неизвестных типов:

```
Value 1
Value 2
...
```

---

## 6. Совместимость

Preview обязан работать с:

- темы;
- Color Rules;
- Actions;
- CheckBoxes;
- Search Highlight (если установлен SearchText);
- Card Roles;
- Card Layout;
- Tree expand/collapse (фиктивная иерархия).

---

## 7. Tree Preview

Автоматически создать небольшую структуру:

```
Servers
 ├─ PostgreSQL
 ├─ Redis
 └─ MongoDB
```

Только для визуальной проверки.

---

## 8. Design-Time Refresh

Изменение:

- ViewMode
- CardLayout
- Theme
- Columns
- VisibleInCards
- CardRole
- RowHeight
- Font

должно автоматически обновлять Preview.

---

## 9. Запреты

Не выполнять:

- реальные запросы к БД;
- Locate;
- Refresh;
- Edit/Post;
- открытие закрытого DataSet.

---

## 10. Demo

Добавить отдельную форму:

```
DesignPreviewDemo
```

где показаны:

- List
- Cards
- Full Width
- Tree

без единой строки кода заполнения.

Всё должно отображаться сразу после открытия формы в IDE.

---

## 11. Acceptance Criteria

Готово, если:

- предпросмотр работает без запуска приложения;
- автоматически обновляется при изменении свойств;
- поддерживает все режимы отображения;
- не ломает Runtime;
- старые проекты работают без изменений;
- Win64 и Linux64 компилируются.

---

## 12. Не реализовывать

Не добавлять:

- Popup;
- Lookup;
- Data Editing;
- Live Binding Designer;
- генератор изображений;
- drag&drop.

Цель патча только одна:

```
Максимально полезный Design-Time Preview.
```
