# Patch 1.1.2 --- Popup Diagnostics

## Цель

Доработать существующий проект **UniPopupPerformanceLab**.

Автоматический запуск уже реализован.

Настоящий Patch посвящён исключительно повышению точности диагностики.

Не изменять алгоритмы компонентов UniListView.

Не выполнять оптимизацию Popup.

Добавить только средства диагностики.

------------------------------------------------------------------------

# 1. Не менять

Не изменять:

-   сценарии;
-   Automatic Runner;
-   структуру отчёта;
-   существующие метрики;
-   существующие проверки.

Все изменения должны быть совместимы с существующим проектом.

------------------------------------------------------------------------

# 2. Разделить состояние объекта

В отчёте больше не смешивать свойства объекта и его участие в FMX Scene.

Вместо одного блока Runtime State сделать два.

## Stored Properties

Выводить:

-   Visible
-   Enabled
-   HitTest
-   Opacity
-   Align
-   Size

Это только сохранённые свойства объекта.

## Runtime Attachment

Выводить:

-   Parent
-   ParentClass
-   Root
-   Scene
-   AbsoluteVisible
-   AttachedToVisualTree
-   ParticipatesInScene
-   PopupHostAssigned
-   PopupOpened

Не делать выводов по свойству Visible.

------------------------------------------------------------------------

# 3. Runtime Validation

Если

-   Parent=nil
-   Scene=nil
-   Root=nil

то объект считается отключённым от Scene независимо от Visible.

Validation должна использовать Runtime Attachment, а не Stored
Properties.

------------------------------------------------------------------------

# 4. Детализировать Paint

Вместо одного счётчика

    Popup Paint

вести отдельные счётчики для:

-   PopupHost
-   PopupRoot
-   PopupComponent
-   LookupPopup
-   LookupList
-   DropDown
-   TestForm

------------------------------------------------------------------------

# 5. Детализировать Realign

Отдельные счётчики:

-   PopupHost
-   PopupRoot
-   PopupComponent
-   LookupList

------------------------------------------------------------------------

# 6. Источник активности

Добавить раздел:

    Activity Sources

Для каждого объекта вывести:

-   Paint Count
-   Realign Count
-   MouseMove
-   HitTest
-   Repaint Requests

Цель --- определить, какой объект реально создаёт нагрузку.

------------------------------------------------------------------------

# 7. Validation Rules

Добавить проверки:

## Popup Closed

Обязательно:

-   Parent=nil
-   Scene=nil
-   AttachedToVisualTree=False
-   Popup Paint=0

## Popup Detached

Обязательно:

-   Parent=nil
-   Scene=nil
-   Root=nil
-   Paint=0

## Popup Open

Обязательно:

-   Parent\<\>nil
-   Scene\<\>nil
-   AttachedToVisualTree=True

При нарушении любого правила сценарий получает FAILED.

------------------------------------------------------------------------

# 8. Report

После каждого сценария выводить:

## Stored Properties

...

## Runtime Attachment

...

## Activity Sources

...

## Validation

...

## Result

...

------------------------------------------------------------------------

# 9. Acceptance

Patch считается выполненным если:

-   существующие сценарии не изменены;
-   Automatic Runner продолжает работать;
-   отчёт разделяет Stored Properties и Runtime Attachment;
-   Paint и Realign отображаются отдельно по каждому узлу popup;
-   Validation использует Runtime Attachment;
-   все существующие проверки продолжают работать;
-   итоговый отчёт успешно формируется.

------------------------------------------------------------------------

## Итоговый отчёт Codex

Указать:

-   Files changed
-   New diagnostics
-   New validation rules
-   Report changes
-   Remaining limitations

Полные исходные тексты не вставлять.
