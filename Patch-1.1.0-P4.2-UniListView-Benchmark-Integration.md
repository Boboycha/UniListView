
# Patch 1.1.0-P4.2 — Integrate UniListView into FMX Benchmark Suite

## Цель

Сделать UniListView полноценным участником FMX Benchmark Suite.

После Patch все тесты должны запускаться из одного приложения и сравниваться по единому сценарию и единому профайлеру.

---

## Общие требования

- Не заменять существующие тесты.
- Не удалять стандартные FMX benchmark.
- UniListView добавить как дополнительный benchmark.
- Использовать тот же profiler и те же метрики.
- Все действия через TActionList.
- UTF-8 BOM, CRLF.
- Без `with`.
- Linux compatible.

---

## Новый экран

Добавить:

```text
Benchmark.UniListView.Frame
```

Использовать существующий UniListView runtime.

Не копировать Showcase.

Создать максимально компактную реализацию.

---

## Режимы

Поддержать:

```text
List
Cards
Tree (если уже реализован)
```

---

## Размеры данных

Поддержать:

```text
100
1000
10000
50000
```

Данные генерируются тем же генератором benchmark.

---

## Сценарии

Те же самые, что и для остальных benchmark:

- Idle
- Hover
- Scroll
- Resize
- Continuous Repaint
- Animated Marker (если реализован)

---

## Параметры

Обязательно поддержать:

- Scale 100/125/150/200
- Normal
- Maximized

---

## Метрики

Использовать абсолютно те же метрики:

```text
FPS Average
FPS 1% Low
Frame Avg
Frame P95
Frame P99
Paint Avg
Paint Max
Input-to-Paint
Requested Frames
Completed Paints
Dropped Requests
```

Не создавать отдельный формат отчёта.

---

## Сравнение

Итоговая таблица должна автоматически включать:

| Test | FPS Avg | FPS 1% Low | Frame P95 | Paint Avg |
|------|--------:|-----------:|----------:|----------:|
| Empty Form | | | | |
| Empty PaintBox | | | | |
| FillRect | | | | |
| FillText | | | | |
| DrawBitmap | | | | |
| Combined PaintBox | | | | |
| Standard Controls | | | | |
| TVertScrollBox | | | | |
| Standard TListView | | | | |
| **UniListView List** | | | | |
| **UniListView Cards** | | | | |
| **UniListView Tree** | | | | |

---

## Benchmark Suite

Benchmark становится постоянной частью проекта.

Его нельзя рассматривать как временный инструмент.

Он предназначен для:

- поиска узких мест;
- сравнения FMX и UniListView;
- регрессионного тестирования производительности;
- проверки новых версий Delphi;
- проверки новых драйверов Linux.

---

## Регрессии

После каждого значимого изменения UniListView должно быть возможно повторить benchmark и сравнить результаты с предыдущими отчётами.

---

## Что не делать

- не дублировать Showcase;
- не менять архитектуру UniListView;
- не менять profiler;
- не добавлять отдельные метрики только для UniListView.

---

## Критерии приёмки

1. UniListView интегрирован в Benchmark Suite.
2. Используется общий profiler.
3. Используется общий отчёт.
4. Используются общие сценарии.
5. Используются общие Scale/Window режимы.
6. Таблица сравнения строится автоматически.
7. Windows и Linux собираются.
8. Benchmark остаётся независимым инструментом проекта.

---

## Главная цель

Получить один эталонный Benchmark Suite, который позволяет честно сравнить:

- чистый FMX;
- стандартные FMX компоненты;
- UniListView

в абсолютно одинаковых условиях.
