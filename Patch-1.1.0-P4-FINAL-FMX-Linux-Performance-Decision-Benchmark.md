# Patch 1.1.0-P4 FINAL — FMX Linux Performance Decision Benchmark

## 1. Статус документа

Это окончательное техническое задание по исследованию производительности UniListView под Linux.

После выполнения Patch должен быть получен однозначный инженерный вывод:

```text
A. Узкое место находится в UniListView
или
B. Узкое место находится вне UniListView — в FMX/Scene/Presentation/Showcase
```

По итогам Patch принимается решение:

```text
GO
Продолжать развитие UniListView для Linux
```

или:

```text
NO-GO
Отказаться от Linux-поддержки UniListView либо временно заморозить её
```

Нельзя завершить Patch формулировками:

```text
возможно
скорее всего
похоже
нужно исследовать дальше
```

Допускается только вывод, подтверждённый повторяемыми измерениями.

---

# 2. Главная цель

Создать отдельный эталонный FMX benchmark-проект, полностью независимый от UniListView, и сравнить:

```text
пустой FMX frame
чистый FMX Canvas
стандартные FMX-контролы
стандартный TListView
UniListView
```

Необходимо локализовать точку, после которой UI под Linux становится медленным.

---

# 3. Исходные факты

Текущий profiler UniListView показал:

```text
UniListView Paint Cards Avg ≈ 1.2 ms
Draw Card Avg ≈ 0.05 ms
Visible Range Avg ≈ 0.001 ms
MouseMove Avg ≈ 0.024 ms
HitTest Avg ≈ 0.017 ms
Scroll Avg ≈ 0.020 ms
```

Одновременно frame profiler показал:

```text
FPS Avg ≈ 7.7
Frame Avg ≈ 129 ms
P95 ≈ 348 ms
P99 > 2 s
```

Следовательно, существует большой разрыв между:

```text
быстрым component Paint
```

и:

```text
медленным воспринимаемым frame/UI
```

Текущий sampling point:

```text
TPaintBox.OnPaint completion
```

не является доказанным actual frame-present point.

Поэтому P4 должен одновременно:

1. проверить базовую производительность FMX;
2. валидировать сам frame profiler;
3. сравнить UniListView с эталонами;
4. сформировать окончательное GO/NO-GO решение.

---

# 4. Обязательные правила проекта

Все новые и изменённые файлы:

- UTF-8 BOM;
- CRLF;
- без `with`;
- guard clauses;
- без magic numbers;
- Design-Time First;
- Linux compatible;
- без `Winapi.*`;
- без `Vcl.*`;
- без сторонних UI-компонентов;
- без сторонних profiler-библиотек;
- без RTTI в hot paths;
- без anonymous methods в hot paths;
- без allocations на каждый кадр;
- без string formatting на каждый кадр.

Все команды должны выполняться через `TActionList`.

---

# 5. Новый проект

Создать отдельный проект:

```text
FMXBaselineBenchmark
```

Проект не должен ссылаться на:

```text
UniList runtime package
UniList design-time package
Showcase frames
UniList themes
UniList data model
```

Допускается копирование только общей идеи profiler, но не скрытая зависимость от UniListView.

Проект должен собираться отдельно.

---

# 6. Архитектура benchmark

Создать MainForm и отдельные frames:

```text
Benchmark.Empty.Frame
Benchmark.PaintBox.Frame
Benchmark.Controls.Frame
Benchmark.ScrollBox.Frame
Benchmark.ListView.Frame
Benchmark.Results.Frame
Benchmark.Profiler.pas
Benchmark.Types.pas
```

Каждый benchmark запускается отдельно.

В один момент времени активен только один test frame.

Не держать скрытые benchmark frames активными.

Скрытые frames не должны продолжать:

- Repaint;
- Timer;
- OnPaint;
- Layout;
- Animation;
- sampling.

---

# 7. Test 0 — Profiler Self-Test

До начала FMX benchmark проверить сам profiler.

## 7.1 Требования

Добавить synthetic timer test:

```text
Sleep/BusyWork 1 ms
Sleep/BusyWork 5 ms
Sleep/BusyWork 20 ms
Sleep/BusyWork 50 ms
```

Profiler должен измерять эти интервалы с допустимой погрешностью.

## 7.2 Sampling point

В отчёте явно указать:

```text
Sampling point
What is measured
What is not measured
Actual GPU present measurable: Yes/No
```

Запрещается называть metric `Frame Present`, если измеряется только:

```text
TPaintBox.OnPaint completion
Form.Paint completion
Application idle callback
```

## 7.3 Main Form Paint

Исправить ситуацию:

```text
Main Form Paint Avg = 0
```

Либо реально измерять MainForm Paint, либо честно удалить metric и вывести:

```text
Main Form Paint: not measurable with current FMX hooks
```

Нулевой metric без объяснения запрещён.

## 7.4 Canvas metrics

Если невозможно перехватить:

```text
Canvas.FillText
Canvas.FillRect
Canvas.EndScene
```

не показывать их как нулевые измерения.

Показывать:

```text
not instrumented
```

или:

```text
not measurable
```

## 7.5 Session counters

Разделить:

```text
Lifetime counters
Session counters
Current test counters
```

После `Start Test` все сравниваемые показатели должны начинаться с нуля.

Загрузка данных и построение UI до старта теста не должны попадать в session metrics.

---

# 8. Test 1 — Empty Form

Абсолютно пустой FMX screen:

```text
TForm
TLayout
```

Без:

- ListView;
- ScrollBox;
- labels;
- images;
- animations;
- timers;
- background effects.

## 8.1 Scenarios

```text
Idle 10 s
Mouse move 10 s
Resize 10 s
Normal window
Maximized window
Scale 100%
Scale 150%
```

## 8.2 Purpose

Определить baseline самого FMX application loop и scene.

Если пустой screen уже имеет низкий FPS или большие frame spikes, UniListView исключается как первичная причина.

---

# 9. Test 2 — Empty PaintBox

Один:

```text
TPaintBox Align=Client
```

`OnPaint` ничего не рисует.

## Scenarios

```text
Idle
Forced Repaint 60 times
Mouse move
Resize
Normal
Maximized
Scale 100%
Scale 150%
```

## Purpose

Определить стоимость самого FMX Paint lifecycle без Canvas workload.

---

# 10. Test 3 — Canvas FillRect

Один `TPaintBox`.

Режимы нагрузки:

```text
10 FillRect
100 FillRect
500 FillRect
1000 FillRect
```

Без текста и изображений.

Измерить:

```text
OnPaint duration
Frame interval
FPS
P95/P99
Slow frames
```

---

# 11. Test 4 — Canvas Text

Один `TPaintBox`.

Режимы:

```text
10 FillText
100 FillText
300 FillText
1000 FillText
```

Использовать одинаковый текст и одинаковый шрифт.

Отдельно проверить:

```text
single-line text
wrapped text
different font sizes
```

Не создавать дочерние `TLabel`.

Purpose:

```text
стоимость чистого FMX text rendering
```

---

# 12. Test 5 — Canvas Bitmap

Один `TPaintBox`.

Режимы:

```text
10 DrawBitmap
100 DrawBitmap
300 DrawBitmap
```

Использовать одну заранее загруженную bitmap.

Не читать файлы во время Paint.

Не создавать bitmap на каждый frame.

---

# 13. Test 6 — Combined Custom Paint

Один `TPaintBox` или custom `TControl`.

Нарисовать нагрузку, сопоставимую с UniListView Cards:

```text
100 backgrounds
100 borders
100 icons
300 text lines
selection rectangles
focus rectangles
separator lines
```

Никаких дочерних controls.

Это главный контрольный тест чистого Canvas.

---

# 14. Test 7 — Standard Controls

Отдельные режимы:

```text
100 TLabel
500 TLabel
1000 TLabel
```

Затем:

```text
100 TRectangle
500 TRectangle
1000 TRectangle
```

Затем mixed cards:

```text
50 cards
100 cards
```

Каждая card:

```text
TRectangle
TImage
3 TLabel
```

Purpose:

```text
стоимость visual tree стандартных FMX controls
```

---

# 15. Test 8 — TVertScrollBox

Использовать:

```text
TVertScrollBox
```

Внутри:

```text
50 cards
100 cards
500 cards
```

Card:

```text
TRectangle
TImage
3 TLabel
```

Проверить:

```text
Idle
Hover
Scroll
Resize
Maximize
Scale 100%
Scale 150%
```

---

# 16. Test 9 — Standard FMX TListView

Использовать только штатный:

```text
FMX.ListView.TListView
```

Datasets:

```text
100
1000
10000
50000
```

Item:

```text
icon
title
subtitle
detail
```

Проверить:

```text
Load
Idle
Hover
Selection
Scroll
Resize
Maximize
Scale 100%
Scale 150%
```

Обязательно фиксировать:

```text
visible item count
total item count
load time
session frame metrics
```

Load metrics не смешивать с interactive metrics.

---

# 17. Test 10 — UniListView Control Run

UniListView не подключать внутрь baseline project.

Использовать уже существующий Showcase и тот же profiler session protocol.

Параметры:

```text
Cards
10000 items
примерно 20–30 visible cards
Scale 100%
Normal
Maximized
```

Сценарии:

```text
Idle 10 s
Hover 10 s
Scroll 10 s
Resize 10 s
```

Результаты импортируются вручную в итоговую comparison table.

---

# 18. Масштаб

Для всех применимых тестов:

```text
100%
125%
150%
200%
```

Масштабировать общий root `TLayout`.

В отчёте фиксировать:

```text
Scale
Logical size
Physical window size
Visible controls/items
```

Не сравнивать результаты разных scale без указания visible workload.

---

# 19. Window modes

Для всех применимых тестов:

```text
Normal
Maximized
```

FullScreen не обязателен.

Размер normal window должен быть фиксирован и указан в отчёте.

---

# 20. Test Session Protocol

Каждый тест выполняется строго так:

1. Открыть test frame.
2. Загрузить/создать controls.
3. Дождаться стабилизации 3 секунды.
4. Нажать `Reset`.
5. Нажать `Start`.
6. Выполнять только заданный сценарий.
7. Продолжительность — 10 секунд.
8. Нажать `Stop`.
9. Нажать `Save Report`.
10. Не менять другие параметры внутри session.

Тест повторить минимум 3 раза.

Использовать median трёх запусков.

---

# 21. Метрики

Для каждого теста сохранить:

```text
Session duration
Samples
FPS average
FPS minimum
FPS 1% low
Frame interval average
Frame interval median
Frame interval P95
Frame interval P99
Frame interval max
Frames >16.67 ms
Frames >33.33 ms
Frames >50 ms
Frames >100 ms
Paint calls
Paint average
Paint max
Input-to-paint average
Input-to-paint max
Resize latency
Scale
Window state
Visible workload
```

Если metric не измерим:

```text
N/A — reason
```

Не использовать искусственные нули.

---

# 22. Frame Sampling

Benchmark должен поддерживать два режима sampling:

## Mode A — Event Driven

Sample фиксируется после фактического Paint test surface.

## Mode B — Independent Timer Probe

Отдельный lightweight timer/animation probe фиксирует scheduling cadence.

Цель — сравнить:

```text
Paint cadence
Application scheduling cadence
```

Timer probe не считать actual GPU present.

В отчёте указать ограничения.

---

# 23. Visual Smoothness Marker

Добавить небольшой benchmark marker:

```text
движущийся прямоугольник
```

Он движется с постоянной скоростью.

Режим включается только для визуальной проверки.

Profiler отдельно фиксирует:

```text
expected position
actual update interval
missed updates
```

Marker не использовать в чистом Idle benchmark.

---

# 24. Отчёт

Каждый отчёт должен содержать:

```text
Test ID
Test name
Platform
OS
X11/Wayland
VM/Physical
Renderer
Software rendering
Build Debug/Release
Scale
Window state
Dataset/workload
Sampling mode
Sampling point
Session duration
All metrics
Notes
```

Environment fields допускается вводить вручную.

---

# 25. Итоговая матрица

Codex должен подготовить таблицу:

| Test | Windows | Ubuntu VM | Debian Physical |
|---|---:|---:|---:|
| Empty Form | | | |
| Empty PaintBox | | | |
| FillRect 100 | | | |
| FillText 300 | | | |
| DrawBitmap 100 | | | |
| Combined PaintBox | | | |
| 100 Labels | | | |
| 100 Cards Controls | | | |
| TVertScrollBox 100 | | | |
| Standard TListView 10k | | | |
| UniListView Cards 10k | | | |

Для каждой ячейки минимум:

```text
FPS Avg
FPS 1% Low
Frame P95
Paint Avg
```

---

# 26. Decision Tree

## Case A — Empty Form медленный

Условие:

```text
Linux Empty Form Frame P95 > 33.33 ms
или
Linux Empty Form FPS Avg < 30
```

при стабильном test session.

Вывод:

```text
FMX Linux baseline сам по себе недостаточно отзывчив.
UniListView не является первичной причиной.
```

Решение:

```text
UniListView Linux GO только как experimental/unsupported
или NO-GO для production Linux
```

---

## Case B — Empty Form быстрый, Empty PaintBox медленный

Вывод:

```text
Проблема находится в FMX Paint/Scene lifecycle.
```

UniListView не является первичной причиной.

---

## Case C — PaintBox primitives быстрые, Standard Controls медленные

Вывод:

```text
Узкое место — visual tree/layout/style infrastructure стандартных FMX controls.
```

Если UniListView быстрее стандартных controls:

```text
UniListView Linux GO
```

---

## Case D — Combined PaintBox быстрый, UniListView медленный

Вывод:

```text
Узкое место внутри UniListView или Showcase integration.
```

Требуется оптимизация UniListView.

До исправления:

```text
NO-GO
```

---

## Case E — Standard TListView и UniListView одинаково медленные

Если Empty PaintBox быстрый:

```text
Проблема в list/control infrastructure FMX либо общей scene invalidation.
```

Решение зависит от production threshold.

---

## Case F — UniListView быстрее Standard TListView

Вывод:

```text
UniListView не является причиной Linux slowdown.
```

Linux support допускается при выполнении acceptance thresholds.

---

# 27. Production Acceptance Thresholds

Для сценария:

```text
Cards/List
10000 items
Scale 100%
Maximized
Continuous scroll
Release build
Physical Debian
```

UniListView считается пригодным для production Linux, если median трёх запусков удовлетворяет:

```text
FPS Average >= 30
FPS 1% Low >= 20
Frame P95 <= 50 ms
Component Paint Avg <= 8 ms
No frame > 500 ms during normal hover/scroll
No O(N) rebuild during hover/scroll
```

Желательная цель:

```text
FPS Average >= 50
FPS 1% Low >= 30
Frame P95 <= 33.33 ms
```

---

# 28. GO / NO-GO Decision

## GO

Решение `GO` принимается, если:

1. UniListView не хуже стандартного `TListView` более чем на 20% по:
   - FPS Average;
   - FPS 1% Low;
   - Frame P95.
2. Выполнены production acceptance thresholds.
3. Нет O(N) операций во время hover/scroll.
4. Нет зависаний >500 ms в обычном interactive scenario.
5. Поведение повторяется минимум в 3 запусках.

## CONDITIONAL GO

Допускается:

```text
Linux Experimental
```

если:

- UniListView не является bottleneck;
- FMX baseline сам медленный;
- production thresholds не достигнуты;
- Windows остаётся основной платформой.

## NO-GO

Решение `NO-GO` принимается, если:

1. UniListView существенно хуже Combined PaintBox и Standard TListView;
2. Frame P95 >100 ms на physical Debian;
3. FPS Average <20;
4. имеются регулярные stalls >500 ms;
5. проблема воспроизводится в Release;
6. причина находится внутри UniListView и не устраняется локально.

---

# 29. Запрет на бесконечное исследование

После выполнения P4 запрещается создавать:

```text
P5 profiler
P6 diagnostics
ещё один общий benchmark
```

Допускается только:

```text
один локальный fix patch
```

если P4 точно выявил конкретный дефект UniListView.

После локального fix повторяются те же P4 tests.

Затем принимается окончательное GO/NO-GO решение.

---

# 30. Что не входит

Не реализовывать:

- custom OpenGL renderer;
- DirectX/Vulkan backend;
- external compositor hooks;
- telemetry;
- background renderer;
- сторонние profiler SDK;
- автоматический запуск Linux shell tools;
- оптимизацию UniListView без доказанного bottleneck;
- новую архитектуру Showcase.

---

# 31. Критерии приёмки Patch

1. Новый независимый benchmark project создан.
2. UniListView dependency отсутствует.
3. Profiler self-test пройден.
4. Нулевые недоступные metrics заменены на N/A.
5. Session counters отделены от lifetime.
6. Empty Form test работает.
7. Empty PaintBox test работает.
8. FillRect test работает.
9. FillText test работает.
10. DrawBitmap test работает.
11. Combined PaintBox test работает.
12. Standard Controls test работает.
13. TVertScrollBox test работает.
14. Standard TListView test работает.
15. Scale tests работают.
16. Normal/Maximized tests работают.
17. Session protocol работает.
18. Save Report работает.
19. 3-run comparison поддерживается.
20. Итоговая matrix создана.
21. Decision Tree реализован в документации.
22. GO/NO-GO report сформирован.
23. Windows build работает.
24. Linux build работает.
25. Design-Time не сломан.
26. Все файлы UTF-8 BOM + CRLF.

---

# 32. Итоговый отчёт Codex

```text
Implemented:
- ...

Profiler validation:
- ...

Sampling point:
- ...

Not measurable:
- ...

Files added:
- ...

Files changed:
- ...

Windows results:
- ...

Linux template:
- ...

Benchmark results:
- Empty Form:
- Empty PaintBox:
- FillRect:
- FillText:
- DrawBitmap:
- Combined PaintBox:
- Standard Controls:
- TVertScrollBox:
- Standard TListView:

Comparison with UniListView:
- ...

Detected bottleneck level:
- Application loop / Scene / Canvas / Controls / ListView / UniListView / Showcase

Production thresholds:
- Passed / Failed

Decision:
- GO / CONDITIONAL GO / NO-GO

Reason:
- ...

Allowed next action:
- None / One local fix patch

Notes:
- ...
```

Не вставлять полные исходники.

---

# 33. Главная формулировка результата

Patch считается завершённым только тогда, когда итоговый отчёт содержит одну из трёх строк:

```text
FINAL DECISION: GO
```

или:

```text
FINAL DECISION: CONDITIONAL GO — Linux Experimental
```

или:

```text
FINAL DECISION: NO-GO
```

Без этого Patch не принимается.

---

# 34. Главная цель

> Один раз, объективно и окончательно определить: пригоден ли UniListView для production Linux, где именно находится bottleneck и стоит ли продолжать Linux-направление проекта.
