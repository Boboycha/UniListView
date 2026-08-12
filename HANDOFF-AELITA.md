# UniListView — handoff для продолжения работы

Дата: 2026-07-27  
Текущее состояние: Patch 1.1.0 MultiCheck Core реализован.

## Как продолжить в новой беседе

Передать архив ассистенту и написать:

> Прочитай `HANDOFF-AELITA.md` и последний Patch. Продолжаем UniListView с текущего состояния.

Ассистент работает как Aelita — тёплая напарница по Delphi/FMХ, коротко и по делу 😊

## Среда и правила

- Delphi 13.1 / FMX / Skia.
- Все новые и изменённые текстовые файлы: UTF-8 BOM + CRLF.
- Изменять только относящиеся к Patch файлы.
- Не переписывать код и форматирование без необходимости.
- Не переименовывать символы и не выполнять крупный рефакторинг без ТЗ.
- Переиспользовать существующую архитектуру UniListView.
- Каждый Patch решает одну законченную задачу, полностью компилируется и не оставляет временных решений.
- Пакеты только собирать. Не устанавливать: пользователь устанавливает их сам.

## Реализованные Patch

- 0.9.2 — Incremental Search Engine.
- 0.9.3 — Full Width Card Layout.
- 0.9.4 — Action Visibility.
- 0.9.5 — Popup Infrastructure.
- 0.9.6 / 0.9.6.1 — Design-Time Preview и `ucsmAutoByTitle`.
- 0.9.7 / 0.9.7.1 — `TUniDropDown`, popup resize/content width.
- 0.9.8 — `TUniLookup` Core.
- 0.9.9 — `TUniLookup` Search.
- 0.9.10 — `TUniJsonDataAdapter`.
- 0.9.11 — JSON Stress Test Demo.
- 1.0 RC1 — UniListView Showcase.
- 1.1.0 — MultiCheck Core.

Исходные ТЗ сохранены в корне проекта как `Patch-*.md`.

## Последнее архитектурное решение

Состояние отметки хранится только в `TUniListItem.Checked`.

Старое отдельное Tree-хранилище `FTreeCheckedKeys` и Tree Cascade удалены осознанно. В Tree сейчас независимые checkbox каждого item без cascade/Mixed. После перехода на единую item-модель cascade будет реализован заново поверх `TUniListItem.Checked`.

## MultiCheck API

- `MultiCheck`, `ShowCheckBoxes`, `CheckedCount`.
- `CheckAll`, `UncheckAll`, `InvertChecks`.
- Scope: `ucsAllItems`, `ucsVisibleItems`.
- `IsItemChecked`, `SetItemChecked`, `ToggleItemChecked`.
- `CheckedItems`, `FirstCheckedItem`, `LastCheckedItem`.
- `OnItemCheckChanged`, `OnCheckedChanged`.
- Mouse checkbox и Space.
- List использует отдельную служебную checkbox-область слева.
- Cards, Full Width Cards и Tree используют renderer без FMX checkbox на каждый item.

## Последний найденный и исправленный баг

`CheckAll(ucsVisibleItems)` не выполнялся из-за Delphi dangling `else`: `else` привязался к внутреннему условию item, а не к проверке scope.

В `CheckAll` и `UncheckAll` обе ветви scope теперь явно заключены в `begin..end`.

Добавлен тест:

- `tests/MultiCheckCoreSmoke.dpr`
- `tests/MultiCheckCoreSmoke.dproj`

Тест проверяет All/Visible, search scope, Check/Uncheck/Invert и `CheckedItems`.

Результат последнего запуска:

```text
MultiCheckCoreSmoke: PASS
```

## Последняя валидация

- Runtime package Win32 Release: успешно, 0 warnings / 0 errors.
- Design-time package Win32 Release: успешно, 0 warnings / 0 errors.
- Showcase Verify Win32: успешно.
- Showcase Verify Win64: успешно.
- MultiCheck smoke test Win32: PASS.
- Пакеты не устанавливались.

## Showcase

Проект:

`Demos/UniListView.Showcase/UniListView.Showcase.dproj`

Добавлена страница `MultiCheck` с:

- List/Cards;
- поиском;
- операциями All/Visible;
- обходом `Items` и lightweight `CheckedItems`;
- загрузкой 50 000 items;
- CheckedCount и timing log.

## Известное ограничение

Tree cascade и Mixed state запланированы на следующий отдельный Patch.
