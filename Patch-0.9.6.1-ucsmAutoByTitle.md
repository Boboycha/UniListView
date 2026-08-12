# Patch 0.9.6.1 — `ucsmAutoByTitle`

## 1. Цель

Добавить в существующий режим расчёта ширины карточек новое значение:

```delphi
ucsmAutoByTitle
```

В этом режиме минимальная ширина карточки должна автоматически рассчитываться по самому длинному непереносимому слову среди заголовков карточек.

Патч должен решать только эту задачу.

---

## 2. Ограничение области работ

Не добавлять:

- новые popup-компоненты;
- новые режимы переноса текста;
- ellipsis-режимы;
- автоматический расчёт по subtitle/detail;
- новые настройки шрифтов;
- новые design-time preview режимы;
- новые свойства для ручной минимальной ширины;
- новые enum, кроме добавления `ucsmAutoByTitle` в уже существующий enum.

Использовать существующую архитектуру Card Size Mode.

---

## 3. Новый enum value

В существующий enum режима ширины карточек добавить:

```delphi
ucsmAutoByTitle
```

Пример:

```delphi
type
  TUniCardSizeMode = (
    ucsmFixed,
    ucsmResponsive,
    ucsmAutoByTitle
  );
```

Фактический список значений оставить в текущем порядке проекта.

Не переименовывать существующие значения.

Не менять значения по умолчанию.

---

## 4. Основная логика

В режиме:

```delphi
CardSizeMode := ucsmAutoByTitle;
```

компонент должен:

1. определить колонку, которая используется как title карточки;
2. получить title для всех доступных записей;
3. разбить каждый title на слова;
4. измерить каждое слово текущим title-шрифтом;
5. найти максимальную ширину;
6. добавить служебные области карточки;
7. использовать полученное значение как минимальную ширину карточки при расчёте количества колонок.

---

## 5. Что считать непереносимым словом

Разделителями считать как минимум:

```text
space
tab
CR
LF
```

Допускается дополнительно считать разделителями:

```text
-
/
\
|
```

Но не разбивать:

- email;
- URL;
- IP;
- идентификатор без пробелов;
- длинный технический token.

Если title не содержит разделителей, весь title считается одним словом.

Примеры:

```text
Infrastructure
```

Результат:

```text
Infrastructure
```

```text
PostgreSQL Production
```

Слова:

```text
PostgreSQL
Production
```

```text
Neo4j Knowledge Base
```

Слова:

```text
Neo4j
Knowledge
Base
```

---

## 6. Формула эффективной ширины

Минимальная ширина карточки должна учитывать не только текст.

Ориентировочно:

```text
EffectiveCardMinWidth =
    LeftPadding
  + CheckBoxArea
  + IconArea
  + TitleWordWidth
  + ActionsArea
  + RightPadding
```

Также учитывать:

- расстояние между checkbox и icon;
- расстояние между icon и title;
- расстояние между title и actions;
- card border;
- rule indicator, если он занимает горизонтальное место;
- trailing area только если она реально резервируется в текущем renderer.

Не использовать magic numbers.

Использовать существующие layout-константы.

---

## 7. Title source

Использовать существующую логику определения title:

- колонка с `CardRole = ucrTitle`;
- если их несколько — первая по текущему порядку;
- если `ucrTitle` отсутствует — использовать существующий fallback карточного renderer;
- `ucrHidden` и `VisibleInCards = False` не должны участвовать как title.

Не создавать отдельную параллельную логику выбора title.

---

## 8. Измерение текста

Измерять слово теми же параметрами, которыми оно реально рисуется:

- `FontFamily`;
- `TitleFontSize`;
- `FontStyle`, если он используется;
- текущий DPI/scale;
- текущий text renderer.

Нельзя:

- измерять базовым `FontSize`, если title рисуется через `TitleFontSize`;
- использовать приблизительный расчёт по количеству символов;
- использовать фиксированный коэффициент ширины символа.

Измерение и отрисовка должны использовать одинаковые параметры.

---

## 9. Design-Time Preview

`ucsmAutoByTitle` должен работать в Design-Time Preview.

При:

```delphi
DesignPreviewMode := dpmSampleData;
CardSizeMode := ucsmAutoByTitle;
```

ширина должна рассчитываться по preview title.

При:

```delphi
DesignPreviewMode := dpmConnectedData;
```

использовать title из доступного design-time набора данных.

Не открывать DataSet.

Не менять текущую запись.

---

## 10. Runtime

В Runtime:

- использовать реальные title;
- не менять данные;
- не менять selection;
- не менять scroll;
- не менять current item;
- не выполнять сортировку;
- не выполнять фильтрацию;
- не выполнять поиск.

Расчёт должен быть только read-only.

---

## 11. Кеширование

Результат расчёта необходимо кешировать.

Предлагаемое внутреннее поле:

```delphi
FAutoTitleMinCardWidth: Single;
```

или эквивалент.

Пересчитывать только при изменениях, которые могут повлиять на результат:

- данные изменились;
- title-колонка изменилась;
- порядок колонок изменился;
- `CardRole` изменился;
- `VisibleInCards` изменился;
- `FontFamily` изменился;
- `TitleFontSize` изменился;
- Actions изменились;
- `ShowCheckBoxes` изменился;
- icon visibility/size изменились;
- card padding изменился;
- DPI/scale изменился;
- Design Preview пересоздан.

Обычный resize формы не должен повторно измерять все title.

---

## 12. Производительность

Не выполнять полный проход по данным на каждом paint.

Запрещено:

```delphi
for ItemIndex := 0 to ItemCount - 1 do
  MeasureTitle(...)
```

в renderer paint loop.

Допустимо выполнить проход:

- при построении cache;
- при загрузке/изменении данных;
- при явной invalidation layout cache.

Для больших наборов данных использовать существующий data cache, если он есть.

---

## 13. Поведение при пустых данных

Если записей нет:

- использовать существующую минимальную ширину карточки;
- не возвращать `0`;
- не создавать карточки нулевой ширины;
- не вызывать exception.

---

## 14. Поведение при пустом title

Если title пустой:

- пропустить его;
- не учитывать нулевую ширину;
- если все title пустые — использовать существующий fallback width.

---

## 15. Ограничение максимальной ширины

`ucsmAutoByTitle` не должен заставлять одну техническую строку полностью уничтожить responsive layout.

Использовать существующее ограничение максимальной ширины карточки, если оно уже есть.

Если такого ограничения нет, не добавлять новое публичное свойство в этом патче.

Допускается внутренний clamp по доступной ширине viewport:

```text
EffectiveCardMinWidth <= AvailableViewportWidth
```

То есть при очень длинном title должна остаться одна карточка на строку, а не появляться горизонтальный scroll.

---

## 16. Responsive layout

После вычисления `EffectiveCardMinWidth` использовать существующий алгоритм расчёта колонок.

Пример:

```text
ViewportWidth = 1320
EffectiveCardMinWidth = 315
Gap = 12
```

Ожидание:

- алгоритм выбирает допустимое число колонок;
- карточка не становится уже рассчитанного минимума;
- горизонтальный scroll не появляется.

Не создавать отдельный grid algorithm.

---

## 17. Full-Width Cards

Для:

```delphi
CardLayout := uclFullWidth;
```

`ucsmAutoByTitle` не должен менять full-width поведение.

Full-width карточка по-прежнему занимает всю строку.

Автоматическая ширина title применяется только там, где рассчитывается количество карточек по горизонтали.

---

## 18. Tree и List

Новое значение не должно влиять на:

- List Mode;
- Tree Mode;
- Full-Width Cards;
- popup host;
- actions visibility;
- search;
- color rules.

---

## 19. JSON Layout

Если Card Size Mode уже сохраняется в JSON, добавить поддержку:

```json
{
  "cardSizeMode": "autoByTitle"
}
```

Требования:

- старый JSON загружается;
- неизвестное значение использует существующий fallback;
- default не меняется.

Если Card Size Mode пока не сериализуется, не добавлять отдельную новую систему сериализации только ради этого патча.

---

## 20. Demo

В существующий demo добавить возможность выбрать:

```text
Auto By Title
```

в текущем контроле выбора Card Size Mode.

Проверить на title:

```text
Infrastructure
Databases
PostgreSQL Production
Redis Cluster
Neo4j Knowledge Base
Applications
```

Ожидание:

- `Infrastructure` не переносится посимвольно;
- карточки автоматически перестраиваются на меньшее число колонок;
- при увеличении viewport количество колонок может увеличиваться;
- карточка не становится уже самого длинного title-слова с учётом служебных областей.

Не создавать новый demo form.

---

## 21. Acceptance Criteria

Патч готов, если:

- добавлен `ucsmAutoByTitle`;
- существующие режимы не изменились;
- default не изменился;
- title измеряется реальным title-шрифтом;
- используется самое широкое слово среди title;
- служебные области карточки учитываются;
- расчёт кешируется;
- paint loop не сканирует все записи;
- Grid Cards не создаются уже рассчитанного минимума;
- horizontal scroll не появляется;
- Full-Width Cards не ломаются;
- Design-Time Preview работает;
- Runtime работает;
- Win32/Win64 компилируются;
- Linux64 компилируется;
- нет `Winapi.*`;
- нет `Vcl.*`;
- нет `with`;
- нет новых magic numbers.

---

## 22. Ручной тест-план

### Test 1 — Infrastructure

Title:

```text
Infrastructure
```

Ожидание:

- слово не разбивается на:

```text
Infrastructur
e
```

### Test 2 — Multiple words

Title:

```text
PostgreSQL Production
```

Ожидание:

- минимальная ширина определяется словом `PostgreSQL` или `Production`, в зависимости от реальной ширины шрифта;
- перенос допускается только между словами.

### Test 3 — Wide form

Увеличить ширину формы.

Ожидание:

- количество колонок увеличивается только пока карточки не становятся уже `EffectiveCardMinWidth`.

### Test 4 — Narrow form

Уменьшить ширину формы.

Ожидание:

- количество колонок уменьшается;
- horizontal scroll не появляется.

### Test 5 — Font size

Изменить:

```delphi
TitleFontSize
```

Ожидание:

- cache инвалидируется;
- минимальная ширина пересчитывается.

### Test 6 — Font family

Изменить:

```delphi
FontFamily
```

Ожидание:

- ширина пересчитывается по новой метрике шрифта.

### Test 7 — Actions

Изменить количество Actions.

Ожидание:

- reserved action area учитывается;
- title не перекрывает Actions.

### Test 8 — CheckBoxes

Переключить:

```delphi
ShowCheckBoxes
```

Ожидание:

- минимальная ширина пересчитывается.

### Test 9 — Empty data

Очистить данные.

Ожидание:

- exception нет;
- используется fallback width.

### Test 10 — Design-Time

Открыть форму в IDE.

Ожидание:

- preview сразу использует `ucsmAutoByTitle`;
- изменение TitleFontSize обновляет preview.

---

## 23. Не реализовывать

Не добавлять:

```delphi
ucsmAutoByContent
ucsmAutoByDetails
ucsmAutoByAllFields
```

Не менять:

- title wrapping;
- ellipsis;
- card height;
- popup;
- lookup;
- Tree Cards;
- drag-and-drop.

Текущий патч решает только:

```text
ucsmAutoByTitle
```

---

## 24. Definition of Done

- enum обновлён;
- layout calculation обновлён;
- cache invalidation добавлена;
- demo control обновлён;
- JSON обновлён только если соответствующая сериализация уже существует;
- Win64 build проходит;
- Linux64 build проходит либо документирована конкретная ошибка среды;
- результат проверен в Design-Time Preview;
- итоговый diff кратко описан.
