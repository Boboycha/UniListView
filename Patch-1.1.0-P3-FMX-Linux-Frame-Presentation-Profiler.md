# Patch 1.1.0-P3 — FMX Linux Frame Presentation Profiler

## 1. Цель Patch

Добить исследование Linux UI и определить, где теряется время после завершения `TUniListView.Paint`.

Текущий component-level profiler доказал:

- виртуализация работает;
- Paint обрабатывает только видимые items;
- Cards renderer работает быстро;
- Visible Range практически бесплатен;
- MouseMove и HitTest быстрые;
- Scroll handler быстрый;
- постоянного создания `TTextLayout` нет;
- Search/Filter не участвуют;
- основная задержка находится вне измеренного участка компонента.

Главное белое пятно:

```text
FMX BeginScene/EndScene: Not measurable from component
```

Следовательно, следующий Patch должен измерять полный UI frame lifecycle на уровне Showcase/Form/Scene, а не только UniListView.

---

## 2. Исходные измерения

Linux, Cards, 10 000 items:

```text
Visible items: 14

Paint:
  Avg: 0.503 ms
  Max: 1.535 ms

Paint Cards:
  Avg: 0.780 ms
  Max: 1.382 ms

Draw Card:
  Avg: 0.053 ms

Visible Range:
  Calls: 1458
  Avg: 0.001 ms
  Total: 1.369 ms

MouseMove:
  Avg: 0.024 ms

HitTest:
  Avg: 0.018 ms

Scroll:
  Avg: 0.020 ms
```

Эти значения не объясняют субъективно медленный Linux UI.

---

## 3. Главный вопрос

Необходимо определить, где находится задержка:

```text
Input event
    ↓
Invalidate/Repaint request
    ↓
FMX frame scheduling
    ↓
Form/Scene Paint
    ↓
TUniListView.Paint
    ↓
Canvas flush
    ↓
EndScene / Present
    ↓
X11/Wayland compositor
    ↓
Следующий отображённый кадр
```

После Patch должно быть возможно ответить:

- компонент медленный или нет;
- FMX долго планирует кадр или нет;
- frame presentation блокируется или нет;
- есть ли frame pacing/stutter;
- сколько фактических FPS выдаёт Showcase;
- сколько кадров пропускается;
- влияет ли масштаб RootLayout;
- влияет ли fullscreen/maximized;
- влияет ли software rendering;
- отличается ли VM от physical Linux.

---

## 4. Правила проекта

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
- без RTTI в hot paths;
- без anonymous methods в hot paths;
- без allocations на каждый кадр;
- без string formatting на каждый кадр;
- без изменения runtime API UniListView, если это не требуется.

При изменении `UniList.Columns.pas` сохранить:

```delphi
System.UITypes
```

---

## 5. Область реализации

Этот profiler должен жить в Showcase/demo infrastructure.

Предпочтительные новые units:

```text
Demo.FrameProfiler.pas
Demo.FrameProfiler.Types.pas
Demo.Performance.Frame.pas
```

Runtime library UniListView менять минимально.

Не внедрять platform-specific hooks внутрь UniListView.

---

## 6. Новый compile define

Добавить отдельный define:

```delphi
UNILIST_FRAME_PROFILE
```

Он независим от:

```delphi
UNILIST_PROFILE
```

Режимы:

```text
оба OFF
только component profiler
только frame profiler
оба ON
```

При OFF overhead должен быть практически нулевым.

---

## 7. Frame profiler metrics

Добавить метрики:

```text
Frame count
Frame interval
Frame duration
FPS current
FPS average
FPS minimum
FPS 1% low
FPS maximum
Dropped/slow frames
Invalidate-to-paint latency
Paint-to-next-frame latency
Input-to-paint latency
Idle interval
Form resize frame duration
RootLayout scale frame duration
```

Thresholds:

```text
Slow frame > 16.67 ms
Very slow frame > 33.33 ms
Severe frame > 100 ms
```

Thresholds оформить constants.

---

## 8. Frame interval

Измерять время между последовательными завершениями frame sampling points.

Предпочтительно использовать:

```delphi
TStopwatch.GetTimeStamp
```

или существующую монотонную инфраструктуру profiler.

Хранить:

```text
LastFrameInterval
AverageFrameInterval
MinFrameInterval
MaxFrameInterval
```

Вычислять:

```text
CurrentFPS = 1000 / LastFrameIntervalMs
AverageFPS = 1000 / AverageFrameIntervalMs
```

Guard against zero/invalid interval.

---

## 9. Реальный sampling point

Codex должен исследовать FMX lifecycle и выбрать максимально позднюю доступную безопасную точку кадра.

Приоритет:

1. Form/Scene post-paint callback, если доступен.
2. Form `Paint` completion.
3. Root visual control paint completion.
4. Application idle callback после repaint.
5. Timer-based frame observer — только как fallback.

Не заявлять, что измеряется actual GPU present, если измеряется только Form Paint completion.

В отчёте обязательно вывести:

```text
Frame sampling point: <actual method>
Presentation visibility: measured / partially measured / not measurable
```

---

## 10. Invalidate-to-Paint latency

Добавить timestamp при внутренних demo actions, вызывающих обновление:

```text
Hover changed
Scroll
Resize
Mode switch
Theme switch
Search text changed
Dataset loaded
RootLayout scale changed
```

При первом следующем Paint вычислить:

```text
InvalidateToPaintLatency
```

Хранить:

```text
Calls
Last
Average
Max
Total
```

Не считать повторно одно событие для нескольких Paint.

---

## 11. Input-to-Paint latency

Измерять для:

```text
MouseMove with hover change
MouseWheel
Keyboard navigation
Search typing
Resize
```

Схема:

```text
Input timestamp
    ↓
Repaint requested
    ↓
First subsequent paint timestamp
```

Отчёт:

```text
Mouse hover input-to-paint
Mouse wheel input-to-paint
Keyboard input-to-paint
Search input-to-paint
Resize input-to-paint
```

Не использовать OS-level input hooks.

---

## 12. Paint-to-next-frame latency

После завершения Form/Root Paint сохранить timestamp.

На следующем sampling point вычислить интервал.

Цель — увидеть задержку после component/form Paint.

Если точка не отражает actual presentation, назвать metric честно:

```text
PaintCompletionToNextSample
```

Не называть её `GPU Present`, если это не подтверждено API.

---

## 13. FPS и frame pacing

Собирать rolling sample window.

Рекомендуемый размер:

```text
120 frames
```

или constant.

Вычислять:

```text
Average FPS
Minimum FPS
Maximum FPS
1% low FPS
Frame time median
Frame time p95
Frame time p99
```

Не сортировать массив на каждый frame.

Percentiles вычислять только при `Refresh Report`.

---

## 14. Slow frame counters

Считать:

```text
Frames > 16.67 ms
Frames > 33.33 ms
Frames > 50 ms
Frames > 100 ms
```

Также вывести проценты от общего frame count.

---

## 15. Idle profiler

Измерить application idle cadence, если доступно без unsafe hook.

Считать:

```text
Idle callbacks
Idle interval avg/max
Idle time before Paint
Idle time after Paint
```

Если FMX API не позволяет безопасно внедриться — не делать hack.

Вывести:

```text
Idle profiling: unavailable
```

---

## 16. Form-level Paint

Измерить:

```text
Main Form Paint
Root Layout Paint
Performance Frame Paint
UniListView Paint
```

Важно разделить:

```text
Full form/frame cost
UniListView cost
Other controls cost
Unaccounted time
```

Рассчитать diagnostic value:

```text
EstimatedOtherPaint =
  FormPaintTotal - UniListViewPaintTotal
```

Только если counters действительно относятся к одному frame lifecycle.

Иначе не показывать misleading value.

---

## 17. RootLayout scale test

В Showcase добавить controlled scale test.

Actions:

```text
actScale100
actScale125
actScale150
actScale200
```

Изменять масштаб существующего root `TLayout`.

Для каждого режима измерять:

```text
FPS
Frame time
Form Paint
UniListView Paint
Input-to-paint
Slow frames
```

Не менять архитектуру root layout.

---

## 18. Window state test

Добавить Actions:

```text
actWindowNormal
actWindowMaximized
actWindowFullScreen
```

Если FullScreen уже поддерживается Showcase.

Измерять отдельно:

```text
Normal
Maximized
FullScreen
```

Не использовать platform-specific window API, если FMX уже предоставляет свойства.

---

## 19. Rendering environment notes

В Performance frame добавить read-only/ручные поля:

```text
Platform
OS
Desktop session
X11/Wayland
VM/Physical
GPU renderer
Software rendering
Root scale
Window state
Build configuration
```

Автоматически определять только то, что надёжно доступно через RTL/FMX.

Остальное вводится вручную.

Не запускать shell commands из runtime library.

В Showcase допускается кнопка копирования environment template.

---

## 20. Test session

Добавить понятие test session.

Actions:

```text
Start Session
Stop Session
Reset Session
Refresh
Save Report
```

При Start:

- reset frame samples;
- reset component profiler;
- сохранить environment;
- начать sampling.

При Stop:

- прекратить accumulation;
- сохранить final timestamp;
- не сбрасывать данные.

---

## 21. Автоматические сценарии

Добавить optional guided scenarios.

### Scenario Idle

```text
Duration: 5 seconds
No input
```

### Scenario Hover

```text
Move over cards manually for 5 seconds
```

### Scenario Scroll

```text
Manual continuous scroll for 5 seconds
```

### Scenario Resize

```text
Resize or maximize window
```

### Scenario Scale

```text
100% → 125% → 150% → 100%
```

Не автоматизировать synthetic mouse input.

UI только показывает инструкцию и таймер сессии.

---

## 22. Performance UI

Расширить Showcase Performance frame.

Tabs/sections:

```text
Overview
Component
Frames
Latency
Frame Pacing
Scale Test
Environment
Raw Report
```

Показать:

```text
Current FPS
Average FPS
1% low FPS
Last frame ms
Average frame ms
p95 frame ms
p99 frame ms
Slow frames
Input-to-paint
Form Paint
UniListView Paint
Sampling point
Presentation visibility
```

Максимум Design-Time.

Все команды через `TActionList`.

---

## 23. Mini frame graph

Разрешается добавить простой frame-time graph только в Showcase.

Требования:

- последние 120 samples;
- без сторонних библиотек;
- отрисовывается отдельным lightweight control;
- не обновляется чаще одного раза на frame;
- может быть отключён;
- собственная стоимость измеряется;
- не должен существенно искажать тест.

Добавить Action:

```text
Show Frame Graph
```

По умолчанию graph выключен во время точного benchmark.

---

## 24. Report format

Добавить новый раздел:

```text
Frame Presentation
```

Пример:

```text
Frame Presentation
  Sampling point: MainForm.Paint completion
  Actual GPU present: not measurable
  Session duration: 5.000 s
  Frames sampled: 142
  FPS average: 28.4
  FPS minimum: 8.7
  FPS 1% low: 11.2

Frame Time
  Last: 34.8 ms
  Average: 35.2 ms
  Median: 33.9 ms
  P95: 48.1 ms
  P99: 96.4 ms
  Max: 103.7 ms

Slow Frames
  >16.67 ms: 128
  >33.33 ms: 71
  >50 ms: 13
  >100 ms: 2

Latency
  Hover input-to-paint: Avg=...
  Scroll input-to-paint: Avg=...
  Resize input-to-paint: Avg=...

Paint Cost
  Form Paint Avg: ...
  UniListView Paint Avg: 0.78 ms
```

---

## 25. Comparison report

Добавить compact comparison block:

```text
Metric             Windows   Ubuntu VM   Debian Physical
FPS average
FPS 1% low
Frame avg ms
Frame p95 ms
UniListView Paint
Input-to-paint
Scale
Window state
```

Codex реализует экспорт текущего отчёта.

Объединение трёх отчётов вручную допустимо.

Не добавлять database/telemetry.

---

## 26. Контрольные тесты

Провести одинаково:

### Test A

```text
Cards
10 000 items
Scale 100%
Window Normal
5 seconds hover
```

### Test B

```text
Cards
10 000 items
Scale 100%
Window Maximized
5 seconds hover
```

### Test C

```text
Cards
10 000 items
Scale 150%
Window Maximized
5 seconds hover
```

### Test D

```text
Cards
10 000 items
Scale 100%
Continuous scroll 5 seconds
```

### Test E

```text
List
10 000 items
Scale 100%
Continuous scroll 5 seconds
```

---

## 27. Диагностические выводы

Report должен автоматически выдавать только осторожные hints.

Примеры:

```text
Component Paint < 2 ms, frame time > 30 ms:
  Delay is likely outside UniListView component Paint.
```

```text
Frame time rises significantly with RootLayout scale:
  FMX scaled scene composition is a likely contributor.
```

```text
Input-to-paint low, next-frame interval high:
  Frame presentation/compositor delay is likely.
```

```text
Form Paint high, UniListView Paint low:
  Other controls or scene composition dominate.
```

Использовать формулировки:

```text
likely
suggests
requires external verification
```

Не выдавать предположение как доказанный GPU fault.

---

## 28. External verification notes

В итоговом отчёте Codex перечислить рекомендуемые внешние инструменты, но не интегрировать их:

```text
RenderDoc, если применимо
apitrace
Mesa HUD
MANGOHUD, если применимо
perf
sysprof
X11/Wayland compositor diagnostics
```

Не запускать их автоматически.

Не добавлять shell scripts в runtime package.

---

## 29. Допустимое исправление

В этом Patch оптимизация не является основной задачей.

Разрешается только минимальное исправление demo/frame lifecycle, если доказано:

- постоянный timer вызывает repaint;
- Performance UI сам создаёт frame storm;
- frame graph искажает benchmark;
- невидимый control постоянно repaint;
- два UniListView одновременно repaint без необходимости.

Для исправления обязательны before/after metrics.

---

## 30. Проверить служебный List

Текущие отчёты показывают одновременно:

```text
Paint List
Paint Cards
```

Необходимо определить, какой `TUniListView` создаёт `Paint List`.

В отчёте profiler желательно добавить instance identifier:

```text
Component Name
Component Pointer/Stable ID
Mode
Visible
```

Требования:

- не использовать pointer в persisted report как единственный ID;
- предпочтительно `Name`;
- unnamed instances получают session-local numeric ID;
- не создавать strings в Paint;
- identifier форматируется только при report generation.

Это позволит понять, не repaint-ится ли скрытый/служебный список.

---

## 31. Per-instance profiler

Существующий global profiler агрегирует разные `TUniListView`.

Добавить per-instance aggregation или хотя бы отдельные snapshots для зарегистрированных instances.

Минимум:

```text
Instance name
Mode
Visible
Paint calls
Paint avg/max
Drawn items
Repaint requests
```

Это критично, потому что текущий отчёт смешивает List и Cards.

Не использовать тяжёлые dictionaries в Paint.

Регистрация/удаление instances выполняется вне hot path.

---

## 32. Критерии приёмки

1. Есть отдельный frame profiler.
2. Component profiler продолжает работать.
3. Frame interval измеряется.
4. Average FPS измеряется.
5. Minimum FPS измеряется.
6. 1% low FPS вычисляется.
7. P95/P99 frame time вычисляются.
8. Slow frames считаются.
9. Input-to-paint latency измеряется.
10. Sampling point явно указан.
11. Actual GPU present не заявляется без измерения.
12. RootLayout scale test доступен.
13. Normal/Maximized test доступен.
14. Test session Start/Stop/Reset работает.
15. Report сохраняется.
16. Performance UI модернизирован.
17. Per-instance UniListView metrics доступны.
18. Служебный List идентифицирован.
19. Frame graph не искажает benchmark или отключается.
20. Design-Time не сломан.
21. Runtime package собирается.
22. Design-time package собирается.
23. Showcase собирается.
24. Linux compatibility сохранена.
25. Все файлы UTF-8 BOM + CRLF.

---

## 33. Проверки перед завершением

Проверить:

- frame profiler OFF;
- frame profiler ON;
- component profiler OFF;
- component profiler ON;
- оба profiler ON;
- idle;
- hover;
- scroll;
- resize;
- maximize;
- normal window;
- scale 100%;
- scale 125%;
- scale 150%;
- Cards;
- List;
- Tree;
- 10 items;
- 10 000 items;
- 50 000 items;
- Start/Stop/Reset;
- Save Report;
- frame graph OFF;
- frame graph ON;
- Designer open/save/reopen;
- Windows build;
- Linux build.

---

## 34. Итоговый отчёт Codex

```text
Implemented:
- ...

Frame sampling point:
- ...

Presentation visibility:
- ...

Per-instance profiling:
- ...

Files added:
- ...

Files changed:
- ...

Validation:
- Frame interval:
- FPS:
- 1% low:
- Percentiles:
- Slow frames:
- Input-to-paint:
- Root scale:
- Window state:
- Per-instance ListView:
- Design-Time:
- Runtime package:
- Design-time package:
- Showcase:

Windows baseline:
- ...

Linux measurements available:
- ...

Confirmed findings:
- ...

Minimal fixes:
- ...

Not measurable:
- ...

External verification recommended:
- ...

Deferred:
- ...

Notes:
- ...
```

Не вставлять полные исходники.

---

## 35. Эффективность

- не переписывать UniListView renderer;
- не анализировать repository повторно целиком;
- переиспользовать существующий performance infrastructure;
- frame samples хранить в fixed-size buffer;
- percentiles считать только при Refresh/Report;
- не создавать объекты и строки на каждый frame;
- Performance UI не должен сам вызывать постоянные Repaint;
- по умолчанию benchmark проводить с выключенным graph;
- все выводы формулировать строго по измеренным данным.

Главная цель:

> доказательно определить, где теряется Linux UI frame time после завершения быстрого `TUniListView.Paint`: в планировании FMX frame, Form/Scene Paint, масштабировании RootLayout, других controls или presentation/compositor path.
