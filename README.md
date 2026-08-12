# UniListView FMX v0.2.0

Первый этап Vector UI + Card Template для Delphi 12 Athens, FMX и Skia.

## Что реализовано

- виртуализированная отрисовка карточек через `TSkPaintBox`;
- адаптивная сетка и горизонтальная лента;
- колесо мыши, drag-to-scroll и перетаскиваемые полосы прокрутки;
- векторные иконки без PNG, шрифтовых символов и внешних SVG-файлов;
- состояния action-кнопок: normal, hover, pressed, disabled;
- векторные иконки `Edit`, `Delete`, `Open`, `More`, `Server`, `Check`, `ChevronRight`, `ChevronDown`;
- design-time объект `CardTemplate` в Object Inspector;
- настройки видимости icon/title/text/detail/actions;
- все текстовые файлы сохранены в UTF-8 BOM с окончаниями CRLF;
- package-файлы не требуют отсутствующих `.res`.

## Установка

1. Закрыть старые проекты демо.
2. Собрать `packages\UniListViewRuntime.dpk`.
3. Открыть и установить `packages\UniListViewDesign.dpk`.
4. Открыть `demo\UniListDemo.dpr`.

Если ранее был установлен старый BPL, сначала удалить старые `UniListViewRuntime.bpl` и `UniListViewDesign.bpl` из общей папки BPL.

## Design-time

После установки компонент находится на вкладке `UniListView`.

В Object Inspector доступны:

- `Actions` — коллекция action-кнопок; у каждой кнопки есть `Name`, `Icon`, `Caption`, `Width`, `Visible`, `Enabled`;
- `CardTemplate` — шаблон карточки;
- параметры размеров карточек, отступов, цветов, прокрутки и панорамирования.

`Caption` используется как запасной текст только когда `Icon = uviNone`.


## v0.3.1

- Fixed Delphi E1019 in nested text drawing routine.
- Added coding standards and ADR documentation.

## Именованные поля (v0.6.0)

```delphi
Item := UniListView1.Items.Add;
Item.SetField('name', 'PostgreSQL production');
Item.SetField('description', 'Primary database server');
Item.SetField('status', 'Online');
Item.SetField('can_delete', False);
Item.SetField('latency_ms', 18);
Item.SetFieldDateTime('updated_at', Now);

UniListView1.CardTemplate.TitleField := 'name';
UniListView1.CardTemplate.TextField := 'description';
UniListView1.CardTemplate.DetailField := 'status';
UniListView1.Actions[1].EnabledField := 'can_delete';
```

Получение значений:

```delphi
Caption := Item.FieldAsString('name');
CanDelete := Item.FieldAsBoolean('can_delete');
Latency := Item.FieldAsInteger('latency_ms');
```


## List mode

Switch at runtime:

```delphi
UniListView1.ViewMode := uvmList;
```

Columns are editable in the Object Inspector through the `Columns` collection.
Click a sortable header to toggle ascending/descending order.


## Header Engine v0.6.0

- Drag разделителя — изменение ширины столбца.
- Double-click разделителя — AutoFit по заголовку и данным.
- Drag заголовка — изменение порядка столбцов.
- Правая кнопка на заголовке — видимость столбцов.
- `SaveLayoutToJSON` / `LoadLayoutFromJSON`.
- `SaveLayoutToFile` / `LoadLayoutFromFile`.

Состояние связывается с колонкой через `LayoutID`, с резервным поиском по `FieldName`.
