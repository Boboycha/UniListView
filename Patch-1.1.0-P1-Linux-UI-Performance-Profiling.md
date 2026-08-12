# Patch 1.1.0-P1 — Linux UI Performance Profiling

## 1. Цель

Добавить отключаемую систему внутреннего профилирования `TUniListView`, чтобы точно определить причину медленного UI под Linux.

Этот Patch должен прежде всего **измерять**, а не оптимизировать.

Нужно получить объективные данные по:

- Paint;
- List/Cards/Tree renderer;
- вычислению видимого диапазона;
- MouseMove и hit testing;
- scrolling;
- row/card height calculation;
- text measurement и созданию `TTextLayout`;
- search/filter rebuild;
- repaint/realign requests;
- popup/lookup rendering.

После Patch один и тот же сценарий должен запускаться на Windows, Ubuntu VM и Debian physical host.

---

## 2. Правила проекта

Все новые и изменённые файлы:

- UTF-8 BOM;
- CRLF;
- без `with`;
- guard clauses;
- без magic numbers;
- Design-Time friendly;
- Linux compatible;
- без `Winapi.*` и `Vcl.*`;
- без крупного рефакторинга;
- без изменения публичного поведения.

При изменении `UniList.Columns.pas` обязательно сохранить:

```delphi
System.UITypes
```

---

## 3. Принцип

# Measure first, optimize second

В этом Patch запрещается:

- переписывать renderer;
- менять виртуализацию;
- добавлять сложные cache;
- менять row-height engine;
- менять TextLayout engine;
- делать оптимизации без подтверждённых измерений.

Допускается только минимальное исправление очевидного дефекта, если profiler однозначно его докажет.

---

## 4. Включение profiler

Добавить compile define:

```delphi
UNILIST_PROFILE
```

Когда define выключен:

- timers не работают;
- counters не увеличиваются;
- строки отчёта не формируются;
- overhead должен быть практически нулевым.

Не включать profiling по умолчанию в release package.

---

## 5. Новый unit

Добавить отдельный unit:

```text
UniList.Performance.pas
```

Рекомендуемый enum:

```delphi
type
  TUniPerfCounter = (
    upcPaint,
    upcPaintList,
    upcPaintCards,
    upcPaintTree,
    upcDrawRow,
    upcDrawCard,
    upcDrawTreeNode,
    upcVisibleRange,
    upcHitTest,
    upcMouseMove,
    upcScroll,
    upcMeasureText,
    upcCreateTextLayout,
    upcCalculateRowHeight,
    upcSearchRebuild,
    upcFilterRebuild,
    upcRequestRepaint,
    upcRequestRealign,
    upcPopupPaint,
    upcLookupPaint
  );
```

Список можно адаптировать к текущей архитектуре.

---

## 6. Данные каждого счётчика

Хранить:

```text
Count
TotalTicks
MinTicks
MaxTicks
LastTicks
```

В snapshot отдавать:

```text
TotalMilliseconds
AverageMilliseconds
MinMilliseconds
MaxMilliseconds
LastMilliseconds
```

Использовать стандартный монотонный таймер:

```delphi
TStopwatch
```

Не использовать WinAPI counters.

---

## 7. Scope timer

Реализовать lightweight timer без allocations и RTTI.

Пример:

```delphi
LTimer := TUniPerfScope.Start(upcPaint);
try
  ...
finally
  LTimer.Stop;
end;
```

Требования:

- без anonymous methods;
- без string formatting в hot path;
- корректная работа при exception;
- почти нулевой overhead при выключенном profiler.

---

## 8. Обязательные числовые counters

Считать:

```text
Paint calls
Rows drawn
Cards drawn
Tree nodes drawn
Visible items
Items scanned during Paint
Items scanned during MouseMove
Text measurements
Text layouts created
Repaint requests
Realign requests
Hit tests
Visible-range calculations
Row-height calculations
Search rebuilds
Filter rebuilds
```

Особенно важно различать:

```text
Total items
Visible items
Items scanned
Items drawn
```

Нормально:

```text
Items total: 50 000
Visible rows: 31
Items scanned: 34
Rows drawn: 31
```

Плохо:

```text
Items total: 50 000
Visible rows: 31
Items scanned: 50 000
```

---

## 9. Paint instrumentation

Измерить отдельно:

- full Paint;
- List Paint;
- Cards Paint;
- Tree Paint;
- header;
- footer;
- filter row.

Для каждого Paint сохранить:

- duration;
- total item count;
- visible range;
- scanned items;
- drawn items;
- text measurements;
- TextLayout creations.

Не писать log на каждый Paint.

---

## 10. Visible range

Инструментировать:

```text
CalculateVisibleRange
FindFirstVisibleRow
FindLastVisibleRow
Binary search offsets
Cards visible range
Tree visible range
```

Нужно выяснить:

- сколько раз диапазон пересчитывается;
- вызывается ли без изменения scroll/size/data;
- сколько items просматривается;
- сколько времени занимает.

Алгоритм в этом Patch не менять.

---

## 11. MouseMove и hit testing

Измерить:

```text
MouseMove calls
HitTest calls
Items scanned per hit test
MouseMove duration
Hover changed
Hover unchanged
Repaint requested
```

Добавить counters:

```text
HoverChangedCount
HoverUnchangedCount
HoverRepaintCount
```

Нужно проверить гипотезу:

> `Repaint` вызывается на каждом `MouseMove`, даже когда hover item не изменился.

---

## 12. Scroll

Измерить:

- scroll event count;
- handler duration;
- visible-range recalculation;
- geometry recalculation;
- repaint requests;
- realign requests.

Проверить, не выполняются ли на scroll:

- полный rebuild;
- пересчёт высот всех элементов;
- search/filter rebuild;
- `Realign`.

---

## 13. Text и TTextLayout

Это главный кандидат Linux slowdown.

Измерить:

```text
Text measure calls
TTextLayout creations
TextLayout reuse, если уже существует
Total text measurement time
```

Нужно ответить:

```text
При 31 видимой строке создаётся 31, 155 или 50 000 TextLayout?
```

Cache пока не добавлять.

---

## 14. Row/Card height

Измерить:

- вызовы расчёта высоты;
- scanned items;
- total duration;
- cache hit/miss, если cache уже есть.

Проверить пересчёт высот при:

- Paint;
- MouseMove;
- scroll;
- resize;
- theme change.

---

## 15. Repaint и Realign

Инструментировать только внутренние вызовы библиотеки:

```delphi
Repaint;
Realign;
Recalc;
UpdateLayout;
```

Counters:

```text
RepaintRequestCount
RealignRequestCount
FullRebuildRequestCount
```

По возможности добавить internal reason:

```delphi
type
  TUniInvalidationReason = (
    uirUnknown,
    uirDataChanged,
    uirScroll,
    uirHoverChanged,
    uirSelectionChanged,
    uirSearchChanged,
    uirThemeChanged,
    uirResize,
    uirColumnChanged,
    uirCheckedChanged
  );
```

Не публиковать reason в Object Inspector.

---

## 16. Search и Filter

Измерить:

- rebuild count;
- rebuild time;
- items scanned;
- result count.

Проверить, не запускается ли rebuild при:

- Paint;
- hover;
- scroll;
- resize;
- обычном repaint.

---

## 17. Popup и Lookup

Измерить:

```text
Popup open duration
Popup layout duration
Popup paint duration
Lookup ListView paint
Search typing latency
Popup resize duration
```

Использовать общий profiler.

---

## 18. Snapshot API

Добавить диагностический snapshot:

```delphi
type
  TUniPerformanceSnapshot = record
    Enabled: Boolean;
    TotalItems: Integer;
    VisibleItems: Integer;
    ItemsScanned: Int64;
    RowsDrawn: Int64;
    CardsDrawn: Int64;
    TextLayoutsCreated: Int64;
    TextMeasureCalls: Int64;
    RepaintRequests: Int64;
    RealignRequests: Int64;
  end;
```

Добавить:

```delphi
procedure ResetPerformanceCounters;
function GetPerformanceSnapshot: TUniPerformanceSnapshot;
function PerformanceReport: string;
```

Diagnostic API не публиковать в Object Inspector.

---

## 19. Формат отчёта

Пример:

```text
UniListView Performance
Platform: Linux
Mode: List
Items total: 50000
Visible items: 31

Paint:
  Calls: 120
  Last: 24.8 ms
  Avg: 22.1 ms
  Max: 39.4 ms

Rows:
  Scanned last paint: 50000
  Drawn last paint: 31

Text:
  Measure calls: 18600
  TextLayout created: 3720

Input:
  MouseMove calls: 540
  Hover changes: 17
  Repaint requests: 540
```

Не определять GPU внутри runtime-библиотеки.

---

## 20. Showcase Performance page

Добавить frame:

```text
Demo.Performance.Frame.pas
Demo.Performance.Frame.fmx
```

Максимум Design-Time.

Все команды через `TActionList`.

Actions:

```text
actPerfLoadSmall
actPerfLoadMedium
actPerfLoadLarge
actPerfReset
actPerfRefresh
actPerfCopyReport
actPerfListMode
actPerfCardsMode
actPerfTreeMode
```

Datasets:

```text
Small: 10 items
Medium: 10 000 items
Large: 50 000 items
```

Переиспользовать существующий JSON/stress generator. Не копировать его.

---

## 21. Performance UI

Показать:

```text
Dataset size
View mode
Total items
Visible items
Last/Avg/Max Paint ms
Items scanned
Items drawn
Text measurements
TextLayouts created
MouseMove calls
Hover changes
Repaint requests
Realign requests
Visible-range calculations
Row-height calculations
Search rebuilds
```

Добавить read-only memo с `PerformanceReport`.

Обновление — вручную через `Refresh`.

Не ставить частый timer, искажающий результаты.

---

## 22. Сценарии

### Idle

1. Load.
2. Reset.
3. Не двигать мышь 5 секунд.
4. Refresh.

### Hover

1. Reset.
2. Двигать мышью внутри одной строки 5 секунд.
3. Refresh.

### Scroll

1. Reset.
2. Прокрутить сверху вниз.
3. Refresh.

### Resize

1. Reset.
2. Изменить размер окна несколько раз.
3. Refresh.

### Search

1. Reset.
2. Ввести поисковый текст.
3. Refresh.

### Modes

Повторить Hover и Scroll для List, Cards и Tree.

---

## 23. Сравнение платформ

Одинаковые сценарии будут запускаться на:

```text
Windows physical host
Ubuntu VMware
Debian physical host
```

Codex должен подготовить report, пригодный для прямого сравнения.

Не задавать абсолютные performance thresholds в коде.

---

## 24. Допустимые минимальные исправления

Разрешается исправить только доказанный очевидный дефект:

- безусловный `Repaint` на каждом MouseMove;
- search rebuild внутри Paint;
- полный row-height rebuild внутри MouseMove;
- обход всех items вместо visible range из-за явной ошибки.

Условия:

1. Есть before measurement.
2. Причина подтверждена.
3. Исправление локальное.
4. Поведение не меняется.
5. Есть after measurement.

Остальные оптимизации оставить следующему Patch.

---

## 25. Overhead profiler

Проверить profiling OFF и ON:

```text
50 000 × 50
Load
Idle
Scroll
```

При OFF overhead должен быть практически незаметен.

Не создавать strings/objects в `DrawRow`.

---

## 26. Design-Time

Profiler по умолчанию не работает в Designer.

Проверить:

- open/save/reopen;
- отсутствие AV;
- отсутствие timers;
- отсутствие log spam.

Performance frame в Designer может показывать:

```text
Profiling disabled
```

---

## 27. Не входит

Не реализовывать:

- TextLayout cache;
- renderer cache;
- partial invalidation engine;
- custom OpenGL backend;
- Linux-specific renderer;
- rewritten virtualization;
- новый row-height algorithm;
- async search;
- FPS overlay в production;
- telemetry.

---

## 28. Критерии приёмки

1. Profiler включается define.
2. При OFF overhead минимален.
3. Измеряется Paint/List/Cards/Tree.
4. Считаются scanned/drawn items.
5. Измеряется visible range.
6. Измеряется MouseMove/hit testing.
7. Считаются hover changes.
8. Считаются repaint/realign requests.
9. Считаются text measurements/TextLayouts.
10. Измеряется row-height.
11. Измеряется search/filter.
12. Измеряется popup/lookup.
13. Есть Reset/Snapshot/Report.
14. Showcase содержит Performance frame.
15. Есть 10/10 000/50 000 datasets.
16. Design-Time не сломан.
17. Runtime/design-time packages собираются.
18. Showcase собирается.
19. Linux compatibility сохранена.
20. Все файлы UTF-8 BOM + CRLF.

---

## 29. Итоговый отчёт Codex

```text
Implemented:
- ...

Profiler counters:
- ...

Files added:
- ...

Files changed:
- ...

Validation:
- Profiling OFF:
- Profiling ON:
- List:
- Cards:
- Tree:
- MouseMove:
- Scroll:
- TextLayout:
- Search/filter:
- Lookup:
- Design-Time:
- Runtime package:
- Design-time package:
- Showcase:

Measurements:
- Small:
- Medium:
- Large:

Confirmed bottlenecks:
- ...

Minimal fixes applied:
- ...

Deferred optimizations:
- ...

Notes:
- ...
```

Не вставлять полные исходники.

---

## 30. Эффективность

- изучить только paint/input/visible-range paths;
- не анализировать repository повторно целиком;
- не переписывать renderer;
- instrumentation добавлять локально;
- не создавать allocations в hot paths;
- не форматировать strings во время Paint;
- переиспользовать `TStopwatch`;
- минимально менять существующие units.

Главная цель:

> получить точный профиль UniListView на Windows и Linux и доказательно определить причину медленного Linux UI.
