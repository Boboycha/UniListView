# Patch 1.1.0-PopupPerf — Minimal Popup Performance Lab

## 1. Цель

Создать новый маленький FMX-проект для изолированной проверки и оптимизации:

```text
TUniDropDown
TUniLookup
PopupHost
PopupComponent
```

Проблема считается воспроизведённой, если простое присутствие `TUniDropDown` или `TUniLookup` на форме заметно ухудшает отзывчивость Linux UI при закрытом popup.

Сегодня необходимо:

1. воспроизвести дефект в минимальном проекте;
2. точно определить источник;
3. выполнить локальную оптимизацию;
4. подтвердить исправление сравнением до/после;
5. не менять архитектуру остальных компонентов UniListView.

---

## 2. Подтверждённые наблюдения

В Showcase:

```text
Theme Gallery с TUniLookup/TUniDropDown
→ UI заметно тормозит

TUniLookup и TUniDropDown удалены с формы
→ тормоза практически исчезают

TUniLookup скрыт,
у TUniDropDown PopupComponent снят
→ тормоза заметно уменьшаются
```

Следовательно, основной подозреваемый:

```text
закрытый popup и связанный PopupComponent,
остающийся активным в FMX visual tree
```

---

## 3. Правила проекта

Все файлы:

- UTF-8 BOM;
- CRLF;
- без `with`;
- guard clauses;
- без magic numbers;
- Design-Time friendly;
- Linux compatible;
- без `Winapi.*`;
- без `Vcl.*`;
- без сторонних библиотек;
- все команды через `TActionList`;
- не копировать Showcase;
- не добавлять лишние features;
- не выполнять общий рефакторинг UniListView.

---

## 4. Новый проект

Создать отдельный проект:

```text
UniPopupPerformanceLab
```

Рекомендуемые файлы:

```text
UniPopupPerformanceLab.dpr
PopupPerf.MainForm.pas
PopupPerf.MainForm.fmx
PopupPerf.Metrics.pas
PopupPerf.TestContent.pas
```

Проект должен использовать runtime units UniList.

---

## 5. Структура формы

Форма должна быть максимально простой.

### Верхняя панель управления

Стандартные FMX-контролы:

```text
Test Mode
Popup State
Popup Content
Start
Stop
Reset
Refresh
```

### Центральная область

Один тестируемый компонент.

### Фоновый индикатор отзывчивости

Добавить лёгкий движущийся marker:

```text
маленький TRectangle
```

Он должен двигаться с постоянной скоростью и визуально показывать stalls.

Marker не должен зависеть от popup-компонентов.

---

## 6. Test Modes

Добавить режимы:

```text
Baseline — no Uni controls
TUniDropDown only
TUniDropDown + PopupComponent
TUniLookup only
TUniLookup + internal list
TUniDropDown and TUniLookup together
```

В каждый момент времени на форме должен находиться только активный тестовый набор.

Предыдущий набор полностью удалить, а не только скрыть.

---

## 7. Popup Content Modes

Поддержать:

```text
None
Empty TLayout
Standard TRectangle
Small standard FMX control tree
TUniListView with 10 items
TUniListView with 1000 items
```

Цель — определить, зависит ли торможение:

- от самого факта назначения `PopupComponent`;
- от размера popup visual tree;
- от наличия внутреннего `TUniListView`.

---

## 8. Popup States

Проверять отдельно:

```text
No PopupComponent
PopupComponent assigned, popup closed
Popup open
Popup closed after first open
PopupComponent detached
```

Это обязательная матрица.

---

## 9. Главная оптимизация

Реализовать следующую политику.

### Popup closed

Пока popup закрыт:

```delphi
PopupComponent.Visible := False;
```

Для `TUniLookup` применять ту же политику к внутреннему popup content/list.

Закрытый popup content не должен:

- рисоваться;
- участвовать в hit testing;
- получать input;
- запускать поиск;
- обновлять hover;
- выполнять popup positioning;
- инициировать Repaint;
- инициировать Realign без реальной необходимости.

### Popup opening

Перед открытием:

```delphi
PopupComponent.Visible := True;
```

Затем:

```text
attach/setup
calculate bounds
open popup
focus/search initialization
```

### Popup closing

При закрытии:

```delphi
PopupComponent.Visible := False;
```

Visibility должна переключаться для всех путей закрытия:

- выбор элемента;
- Escape;
- click outside;
- loss of focus;
- programmatic close;
- destruction;
- form closing.

---

## 10. Lazy visual-tree participation

После реализации `Visible := False` проверить результат.

Если закрытый popup всё ещё создаёт заметную деградацию, выполнить второй уровень:

### Closed

```delphi
PopupComponent.Visible := False;
PopupComponent.Parent := nil;
```

или эквивалентное безопасное отсоединение от активного popup visual tree.

### Opening

```text
attach to PopupHost
Visible := True
open
```

### Closing

```text
Visible := False
detach from PopupHost
```

Не менять `Owner`.

Не уничтожать пользовательский `PopupComponent`.

Не допускать потери Design-Time ссылки.

Lazy detach применять только если одного `Visible := False` недостаточно и это подтверждено тестом.

---

## 11. TUniLookup

Проверить отдельно:

```text
внутренний TUniListView
search edit
popup host
search delay/timer
event subscriptions
```

При закрытом lookup popup:

- внутренний список невидим;
- search delay/timer не работает;
- filtering не запускается;
- popup bounds не пересчитываются;
- список не получает Paint/MouseMove/HitTest;
- никаких repaint requests от внутреннего списка.

При открытии состояние должно корректно восстанавливаться.

---

## 12. TUniDropDown

Проверить:

- constructor;
- `Loaded`;
- `ParentChanged`;
- `SceneChanged`;
- `Resize`;
- `DoRealign`;
- `Paint`;
- `MouseMove`;
- popup open/close;
- PopupComponent setter.

При закрытом popup запрещены вызовы обновления popup bounds и layout, кроме действительно необходимых изменений состояния.

---

## 13. PopupComponent setter

При назначении нового компонента:

```text
old component
→ hide
→ detach subscriptions
→ detach from popup host if needed

new component
→ assign
→ keep hidden while popup closed
→ attach only when opening or when architecture requires it
```

При `PopupComponent := nil`:

- не должно быть AV;
- popup корректно закрывается;
- старый component не остаётся видимым;
- ссылки очищаются.

---

## 14. Минимальные метрики

Не создавать новый большой profiler.

Собирать только:

```text
Marker update interval
Marker stalls >33 ms
Marker stalls >100 ms
Test component Paint calls
Popup content Paint calls
Repaint requests
Realign requests
Popup bounds calculations
Popup open time
Popup close time
```

Добавить простой текстовый report.

---

## 15. Обязательные тесты до исправления

На Linux выполнить по 10 секунд:

```text
A. Baseline
B. TUniDropDown without PopupComponent
C. TUniDropDown + Empty TLayout, closed
D. TUniDropDown + TUniListView 10 items, closed
E. TUniLookup, closed
F. TUniDropDown + TUniLookup, closed
```

Зафиксировать:

```text
marker average interval
P95
max stall
repaint requests
popup content Paint calls
```

---

## 16. Обязательные тесты после исправления

Повторить те же сценарии.

Ключевое сравнение:

```text
Baseline
vs
TUniDropDown + PopupComponent assigned, popup closed
vs
TUniLookup, popup closed
```

---

## 17. Критерии успешной оптимизации

При закрытом popup:

```text
TUniDropDown + PopupComponent
```

и:

```text
TUniLookup
```

должны работать практически как Baseline.

Допустимое отличие:

```text
Marker P95 не хуже Baseline более чем на 10%
No regular stalls >100 ms
Popup content Paint calls = 0
Popup bounds calculations = 0
No continuous repaint/realign activity
```

При открытом popup функциональность должна сохраниться.

---

## 18. Функциональная проверка

### TUniDropDown

- открытие мышью;
- открытие клавиатурой;
- закрытие Escape;
- click outside;
- выбор;
- повторное открытие;
- смена PopupComponent;
- `PopupComponent := nil`;
- resize формы;
- scale;
- theme change.

### TUniLookup

- открытие;
- поиск;
- фильтрация;
- выбор;
- отмена;
- повторное открытие;
- очистка поиска;
- resize popup;
- закрытие формы;
- destruction.

---

## 19. Design-Time

Проверить:

- компоненты видны в Designer;
- PopupComponent назначается через Object Inspector;
- `.fmx` сохраняется;
- reopen работает;
- popup content не исчезает из design-time hierarchy;
- runtime visibility policy не портит design-time preview.

В Designer не применять runtime hide/detach агрессивно.

Использовать проверку:

```delphi
csDesigning in ComponentState
```

или существующий project helper.

---

## 20. Что не делать

Не выполнять:

- переработку UniListView renderer;
- общий benchmark P4;
- новый popup API;
- breaking changes;
- уничтожение PopupComponent при Close;
- изменение Owner пользовательского компонента;
- Linux-specific code path без крайней необходимости;
- масштабный рефакторинг PopupHost.

---

## 21. Критерии приёмки

1. Новый минимальный проект создан.
2. Baseline режим работает.
3. TUniDropDown test работает.
4. TUniLookup test работает.
5. Popup content modes работают.
6. Проблема воспроизводится до исправления.
7. При закрытом popup PopupComponent невидим.
8. Внутренний lookup content невидим.
9. Popup content не Paint-ится в закрытом состоянии.
10. Popup bounds не пересчитываются в закрытом состоянии.
11. Нет постоянных Repaint/Realign.
12. Open/Close функциональность сохранена.
13. Design-Time не сломан.
14. Windows build работает.
15. Linux build работает.
16. Есть before/after report.
17. Закрытый popup по отзывчивости близок к Baseline.
18. Все файлы UTF-8 BOM + CRLF.

---

## 22. Итоговый отчёт Codex

```text
Reproduced:
- ...

Root cause:
- ...

Files added:
- ...

Files changed:
- ...

Before:
- Baseline:
- DropDown no popup:
- DropDown closed popup:
- Lookup closed popup:

Optimization:
- Visibility policy:
- Lazy attach/detach:
- Timers/subscriptions:
- Repaint/Realign:

After:
- Baseline:
- DropDown closed popup:
- Lookup closed popup:

Functional validation:
- DropDown:
- Lookup:
- Reopen:
- Escape:
- Click outside:
- Selection:
- Search:
- Resize:
- Design-Time:
- Windows:
- Linux:

Result:
- FIXED / PARTIALLY FIXED / NOT FIXED

Remaining issue:
- ...

Notes:
- ...
```

Не вставлять полные исходники.

---

## 23. Финальный результат

Patch принимается только при одном из результатов:

```text
RESULT: FIXED
```

или:

```text
RESULT: PARTIALLY FIXED
```

с точным описанием оставшегося bottleneck.

Главная цель:

> Сегодня локализовать и устранить деградацию Linux UI, возникающую из-за закрытых TUniDropDown/TUniLookup и связанного PopupComponent.
