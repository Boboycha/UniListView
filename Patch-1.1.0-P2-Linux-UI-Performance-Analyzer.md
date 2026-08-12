# Patch 1.1.0-P2 — Linux UI Performance Analyzer

## 1. Цель Patch

Модернизировать существующий profiler UniListView и довести его до подробного анализатора UI-производительности.

Текущий profiler уже подтвердил:

- виртуализация работает;
- Paint обрабатывает только видимые элементы;
- лишний Repaint на каждом MouseMove отсутствует;
- на Windows Cards renderer работает быстро.

Теперь необходимо определить, какая операция внутри Paint, input, layout или FMX Canvas становится узким местом под Linux.

Этот Patch ориентирован прежде всего на измерения. Масштабную оптимизацию без подтверждения цифрами не выполнять.

---

## 2. Исходные данные

Базовый Windows-отчёт:

```text
Platform: Windows
Mode: Cards
Items total: 10000
Visible items: 21

Paint:
  Calls: 38
  Avg: 1.372 ms

Paint Cards:
  Calls: 38
  Avg: 1.262 ms

Scanned last paint: 21
Drawn last paint: 21

MouseMove calls: 95
Hover changes: 35
Hover unchanged: 60
Hover repaint requests: 35

Visible-range calculations: 280
```

Вывод:

- полного перебора 10 000 items нет;
- renderer рисует только visible items;
- hover invalidation работает корректно;
- текущий profiler не измеряет реальный текстовый путь;
- visible range измеряется только количеством вызовов, но не временем;
- требуется детализация Paint pipeline.

---

## 3. Обязательные правила проекта

Все новые и изменённые файлы:

- UTF-8 BOM;
- CRLF;
- без `with`;
- guard clauses;
- без magic numbers;
- Design-Time friendly;
- Linux compatible;
- без `Winapi.*`;
- без `Vcl.*`;
- без RTTI;
- без anonymous methods в hot paths;
- без string formatting в Paint;
- без allocations в каждом DrawRow/DrawCard;
- без крупного рефакторинга.

При изменении `UniList.Columns.pas` обязательно сохранить:

```delphi
System.UITypes
```

---

## 4. Главный принцип

# Measure first, optimize second

Запрещается:

- переписывать renderer;
- менять virtualization engine;
- менять text engine;
- добавлять renderer cache без измерений;
- менять row-height algorithm;
- делать Linux-specific renderer;
- делать custom OpenGL backend;
- менять публичное поведение компонентов.

Разрешается только локальное исправление дефекта, если profiler однозначно подтверждает проблему и имеется before/after измерение.

---

## 5. Расширение TUniPerfCounter

Расширить существующий enum счётчиков.

Добавить отдельные counters для:

```text
Paint
Paint Background
Paint Header
Paint Footer
Paint Filter Row
Paint List
Paint Cards
Paint Tree
Paint Selection
Paint Focus
Paint CheckBox
Paint Icons
Paint Text

Draw Row
Draw Card
Draw Tree Node

Draw Row Background
Draw Row Columns
Draw Row Text
Draw Row Image
Draw Row Selection
Draw Row Focus
Draw Row CheckBox
Draw Row Grid Lines

Draw Card Background
Draw Card Border
Draw Card Icon
Draw Card Title
Draw Card Subtitle
Draw Card Details
Draw Card Footer
Draw Card Selection
Draw Card Focus
Draw Card CheckBox

Canvas FillRect
Canvas DrawBitmap
Canvas DrawPath
Canvas DrawLine
Canvas FillText
Canvas MeasureText
Canvas BeginScene
Canvas EndScene

Visible Range
Geometry Row Bounds
Geometry Card Bounds
Geometry Column Bounds
Geometry Hit Rect
Geometry Selection Rect

Hit Test
MouseMove
Hover Detect
Cursor Update

Scroll
Scroll Visible Range
Scroll Geometry
Scrollbar Update

Resize
Resize Layout
Resize Realign
Resize Visible Range
Resize Geometry

Measure Text
Create TextLayout
Reuse TextLayout

Calculate Row Height
Calculate Card Height

Search Rebuild
Filter Rebuild

Popup Open
Popup Layout
Popup Paint
Lookup Paint
Lookup Search Latency

Request Repaint
Request Realign
Full Rebuild
```

Названия адаптировать к текущей архитектуре, сохранив детализацию.

---

## 6. Детализация Paint pipeline

Внутри общего Paint измерить отдельно:

```text
Background
Header
Footer
Filter row
Visible-range calculation
List/Cards/Tree body
Icons
Text
Selection
Focus
CheckBox
BeginScene
EndScene
```

Для каждого этапа отчёт должен содержать:

```text
Calls
Last ms
Average ms
Maximum ms
Total ms
```

Допускается вложенность counters, но в отчёте указать, что дочерние времена входят в родительское время.

---

## 7. DrawCard детализация

Разделить `DrawCard` на этапы:

```text
Card Background
Card Border
Card Icon
Card Title
Card Subtitle
Card Details
Card Footer
Card Selection
Card Focus
Card CheckBox
```

Для каждого измерить calls, total, average, max и last.

---

## 8. DrawRow детализация

Разделить `DrawRow` на:

```text
Row Background
Columns
Text
Image/Icon
Selection
Focus
CheckBox
Grid Lines
```

Не менять отрисовку. Только добавить измерения.

---

## 9. Canvas operations

Добавить instrumentation вокруг:

```delphi
Canvas.FillRect
Canvas.DrawBitmap
Canvas.DrawPath
Canvas.DrawLine
Canvas.FillText
Canvas.MeasureText
Canvas.BeginScene
Canvas.EndScene
```

Для каждого собирать:

```text
Calls
Total
Average
Max
Last
```

Не создавать универсальный proxy Canvas и не менять FMX Canvas class.

---

## 10. Text profiler

Текущий profiler показывает нулевые TextLayout/Measure counters при наличии текста.

Необходимо:

1. Найти реальные места отрисовки текста.
2. Измерить время вокруг `Canvas.FillText` или текущего helper.
3. Отдельно измерить text measurement.
4. Считать явные создания `TTextLayout`, если они есть.
5. Считать reuse, если существующий cache уже имеется.

Отчёт:

```text
FillText calls
FillText total/avg/max
MeasureText calls
MeasureText total/avg/max
TextLayout created
TextLayout reused
```

Новый TextLayout cache не создавать.

---

## 11. Geometry profiler

Измерить вычисление:

```text
Row bounds
Card bounds
Column bounds
Hit-test rectangles
Selection rectangles
CheckBox rectangles
Icon rectangles
```

Нужно определить:

- пересчитывается ли geometry на каждом Paint;
- сколько geometry calculations приходится на visible item;
- сколько времени занимает geometry на Windows и Linux.

Geometry cache пока не создавать.

---

## 12. Visible-range timing

Добавить:

```text
Calls
Last
Average
Maximum
Total
Items examined
```

Разделить, если возможно:

```text
List visible range
Cards visible range
Tree visible range
HitTest visible range
Scroll visible range
Resize visible range
```

Нужно объяснить, почему число вызовов значительно выше числа Paint.

---

## 13. Mouse profiler

Разделить MouseMove:

```text
MouseMove total
Hover detect
HitTest
Cursor update
Repaint request
```

Считать:

```text
MouseMove calls
Hover changed
Hover unchanged
Hover repaint requests
Items scanned in hit test
```

Сохранить текущее корректное поведение Repaint только при изменении hover.

---

## 14. Scroll profiler

Добавить:

```text
Scroll events
Scroll total time
Visible-range time
Geometry time
Scrollbar update time
Repaint requests
Realign requests
Full rebuild requests
```

Подтвердить отсутствие полного rebuild, пересчёта всех высот, search/filter rebuild и лишнего Realign.

---

## 15. Resize profiler

Добавить:

```text
Resize calls
Resize total time
Layout time
Realign time
Visible-range time
Geometry time
Repaint requests
```

---

## 16. Search и Filter

Расширить counters:

```text
Search rebuild calls/time
Filter rebuild calls/time
Items scanned
Result count
Visible-range recalculations after search
Paint requests after search
```

Search engine не менять.

---

## 17. Popup и Lookup

Добавить:

```text
Popup open duration
Popup layout duration
Popup first paint duration
Popup resize duration
Lookup ListView paint
Lookup search latency
```

`Lookup search latency` измерять от изменения текста до завершения visible result и запроса repaint.

---

## 18. FMX scene timing

Если архитектура позволяет безопасно измерить:

```delphi
Canvas.BeginScene
Canvas.EndScene
```

добавить counters.

Если UniListView не владеет этими вызовами:

- не внедрять hack;
- указать `Not measurable from component`;
- не имитировать данные.

---

## 19. Cache statistics

Если cache уже существует, добавить:

```text
RowHeight cache hit/miss
CardHeight cache hit/miss
Icon cache hit/miss
VisibleRange cache hit/miss
```

Если cache нет — не создавать его ради profiler.

---

## 20. Snapshot API

Расширить snapshot.

Рекомендуемый metric:

```delphi
type
  TUniPerfMetric = record
    Calls: Int64;
    TotalMilliseconds: Double;
    LastMilliseconds: Double;
    AverageMilliseconds: Double;
    MaxMilliseconds: Double;
    MinMilliseconds: Double;
  end;
```

Snapshot должен содержать:

```text
Platform
ViewMode
TotalItems
VisibleItems
ScannedItems
DrawnItems
MouseMove counters
Hover counters
Invalidation counters
Text counters
Geometry counters
Metrics[Counter]
```

Не использовать string-key dictionary в hot path.

---

## 21. Report format

`PerformanceReport` сделать секционным:

```text
Overview
Paint Pipeline
Rows/Cards/Tree
Canvas
Text
Geometry
Visible Range
Input
Scroll
Resize
Search/Filter
Popup/Lookup
Invalidation
Cache
```

Не формировать отчёт в hot path.

---

## 22. Export report

В Showcase добавить Actions:

```text
Save Report
Copy Report
```

Имя файла:

```text
UniListView-Performance-<Platform>-<Mode>-<Timestamp>.txt
```

Использовать кроссплатформенный RTL file API.

Если file dialog осложняет Linux compatibility, сохранять в application documents/temp directory и показывать путь.

`Copy Report` реализовывать только через уже существующую кроссплатформенную clipboard abstraction.

---

## 23. Showcase Performance UI

Модернизировать существующий Performance frame.

Добавить секции или tabs:

```text
Overview
Paint
Canvas
Text
Geometry
Input
FMX
Raw Report
```

Максимум Design-Time.

Все команды через `TActionList`.

---

## 24. Цветовая индикация

Только в Showcase:

```text
< 1 ms    Good
1..5 ms   Warning
> 5 ms    Slow
```

Использовать theme-aware colors.

Thresholds оформить constants в demo unit.

Это подсказка, а не абсолютный verdict.

---

## 25. Сценарии сравнения

### Cards

```text
10 000 items
около 21 visible cards
Hover 5 seconds
Scroll
Resize
Search
```

### List

```text
10 000 items
около 30 visible rows
Hover
Scroll
Resize
Search
```

### Large

```text
50 000 items
List
Cards
```

После каждого:

1. Reset.
2. Выполнить действие.
3. Refresh.
4. Save Report.

---

## 26. Платформы

Сравнение:

```text
Windows physical host
Ubuntu VMware
Debian physical host
```

GPU detection в runtime library не добавлять.

В Showcase можно добавить ручное поле Environment Notes:

```text
GPU/renderer
VM/physical
Release/Debug
Desktop session
```

---

## 27. Допустимые исправления

Разрешается исправить только доказанный bottleneck.

Для каждого исправления обязательны:

```text
Before
Cause
Code change
After
Windows result
Linux result, если доступен
```

Если Linux недоступен Codex — подготовить код и отчёт для проверки пользователем.

---

## 28. Overhead profiler

Сравнить:

```text
Profiling OFF
Profiling ON
```

Сценарии:

```text
10 000 Cards
50 000 List
Hover
Scroll
```

Не создавать strings, lists, objects или dictionaries на каждый draw call.

Только numeric counters и stopwatch ticks.

---

## 29. Design-Time

Проверить:

- Performance frame открывается;
- profiler не активен в Designer;
- нет timer spam;
- нет AV;
- `.fmx` сохраняется;
- reopen работает;
- Actions сохраняются.

---

## 30. Что не входит

Не реализовывать:

- TextLayout cache;
- geometry cache;
- renderer cache;
- custom Linux renderer;
- OpenGL backend;
- partial invalidation engine;
- rewritten virtualization;
- async Paint;
- background renderer;
- production FPS overlay;
- telemetry;
- external profiler integration.

---

## 31. Критерии приёмки

1. Paint pipeline детализирован.
2. DrawCard детализирован.
3. DrawRow детализирован.
4. Canvas operations измеряются.
5. Реальный text path измеряется.
6. Geometry измеряется.
7. Visible range имеет timing.
8. MouseMove детализирован.
9. Scroll детализирован.
10. Resize детализирован.
11. Search/filter детализирован.
12. Popup/Lookup детализирован.
13. BeginScene/EndScene измеряются либо честно помечены как недоступные.
14. Snapshot расширен.
15. Report секционный.
16. Save Report работает.
17. Performance UI модернизирован.
18. Design-Time не сломан.
19. Profiling OFF имеет минимальный overhead.
20. Runtime package собирается.
21. Design-time package собирается.
22. Showcase собирается.
23. Linux compatibility сохранена.
24. Все файлы UTF-8 BOM + CRLF.

---

## 32. Проверки перед завершением

Проверить:

- profiling OFF;
- profiling ON;
- List;
- Cards;
- Tree;
- 10 items;
- 10 000 items;
- 50 000 items;
- hover;
- scroll;
- resize;
- search;
- filter;
- popup;
- lookup;
- text-heavy cards;
- icon-heavy cards;
- full-width cards;
- reset;
- refresh;
- save report;
- copy report, если реализовано;
- Designer open/save/reopen.

---

## 33. Итоговый отчёт Codex

```text
Implemented:
- ...

Profiler modernization:
- ...

Files added:
- ...

Files changed:
- ...

Validation:
- Paint pipeline:
- DrawCard:
- DrawRow:
- Canvas:
- Text:
- Geometry:
- Visible range:
- Mouse:
- Scroll:
- Resize:
- Search/filter:
- Popup/Lookup:
- Design-Time:
- Runtime package:
- Design-time package:
- Showcase:

Windows baseline:
- ...

Confirmed bottlenecks:
- ...

Minimal fixes applied:
- ...

Unavailable measurements:
- ...

Deferred optimizations:
- ...

Notes:
- ...
```

Не вставлять полные исходники.

---

## 34. Эффективность

- изучить только текущий profiler и реальные renderer hot paths;
- не анализировать repository полностью повторно;
- расширять текущую структуру;
- не создавать allocations в hot paths;
- не форматировать строки во время Paint;
- не делать cache без доказательств;
- минимально менять runtime units;
- максимально переиспользовать Showcase Performance frame.

Главная цель:

> получить точный breakdown времени UniListView и определить, где Linux теряет производительность: renderer, text, Canvas, geometry, visible range, input, layout или FMX scene presentation.
