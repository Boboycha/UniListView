# UniListView FMX

Виртуализированный список, карточная сетка и дерево для Delphi FMX.

## Что реализовано

- виртуализированная отрисовка через `TPaintBox` и FMX Canvas;
- адаптивная сетка и горизонтальная лента;
- колесо мыши, drag-to-scroll и перетаскиваемые полосы прокрутки;
- векторные иконки без PNG, шрифтовых символов и внешних SVG-файлов;
- состояния action-кнопок: normal, hover, pressed, disabled;
- векторные иконки `Edit`, `Delete`, `Open`, `More`, `Server`, `Check`, `ChevronRight`, `ChevronDown`;
- design-time объект `CardTemplate` в Object Inspector;
- настройки видимости icon/title/text/detail/actions;
- собственные темы и палитра из назначенного форме `TStyleBook`;
- все текстовые файлы сохранены в UTF-8 BOM с окончаниями CRLF;
- package-файлы не требуют отсутствующих `.res`.

## Редактирование полей

Редактирование включается явно и работает в списке, дереве, сетке карточек
и полноширинных карточках:

```pascal
UniListView1.Editable := True;                 // по умолчанию False
UniListView1.BeginFieldEdit(ItemIndex, 'name');
// Альтернатива: BeginEdit(ItemIndex, ColumnIndex)
```

`Columns[Index].ReadOnly := True` запрещает редактирование соответствующего поля
и в списке, и в карточках. Это настройка поля, а не всего компонента.
`Editable := False` отключает редактирование всех полей компонента.
Оба ограничения действуют и при вызове API; прямое изменение `Item.Fields`
из кода приложения остаётся доступным.

- Двойной щелчок по тексту/ячейке открывает один переиспользуемый FMX-редактор.
  Обычный щелчок выбирает активное поле; F2 редактирует именно его.
  `ActiveFieldName` возвращает имя активного поля. Если поле ещё не выбрано,
  F2 начинает с первого доступного. Для активного `ReadOnly`-поля редактор не открывается.
- Enter сохраняет; Esc отменяет; Tab/Shift+Tab сохраняет и переходит между полями
  текущего элемента. Потеря фокуса также пытается сохранить значение.
- В карточках доступны поля шаблона title/text/detail; в полноширинном режиме —
  поля ролей title/subtitle/detail/trailing. В составном текстовом блоке двойной
  щелчок начинает с первого поля, остальные доступны через Tab или API.
  Пустые поля доступны через клавиатуру/API. Редактор работает с видимым элементом.
- Тип берётся из `Columns.DataType`: текст, Int64, Double, дата/время, Boolean.
  Для поля карточки без столбца используется текст. Для даты и дробных чисел
  применяются текущие региональные настройки; редактируется исходное значение
  без отображаемого `Format`. Редактор однострочный.
- `OnValidateEdit(Sender, Item, FieldName, var Value, var Error)` позволяет изменить
  значение перед записью или отклонить его непустой строкой `Error`.
  Ошибка преобразования/валидации оставляет исходное значение неизменным:
  редактор остаётся открыт, текст красный, причина доступна в `EditError` и подсказке.
- `OnFieldEdited(Sender, Item, FieldName, OldValue, NewValue)` вызывается после
  записи в `Item.Fields`. Сохранение во внешнюю БД/API выполняет приложение.
- `Editing`, `EditText`, `CommitEdit` и `CancelEdit` доступны программно.
  Прокрутка, изменение раскладки или внешнее обновление коллекции отменяют активное
  редактирование. Сортировка после записи сохраняет привязку к объекту элемента.

Редактор использует FMX-стиль формы, в том числе назначенный `TStyleBook`.
Собственные темы UniListView сохраняются; оформление самого редактора задаёт FMX.
В демо редактирование включено, кнопка-карандаш открывает имя, поля id/parent_id
защищены от изменения.

Проверка: `tests/FieldEditingSmoke.dproj` (Win32/Win64). Необязательный первый
аргумент EXE — путь к FMX `.style`; снимки редактора сохраняются рядом с EXE.

## Установка

1. Закрыть старые проекты демо.
2. Собрать `packages\UniListViewRuntime.dpk`.
3. Открыть и установить `packages\UniListViewDesign.dpk`.
4. Открыть `demo\UniListDemo.dpr`.

При обновлении установленных пакетов закройте IDE перед заменой BPL. Разрядность design-time пакета должна соответствовать IDE; runtime-пакет собирайте для целевой платформы приложения.

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

## Цветовая схема формы

По умолчанию `UseStyleBook = False`: используются собственные темы (`ThemeName`,
`LoadThemeFromFile`) и настройки цветов. Для палитры из `TStyleBook` формы:

```delphi
Form1.StyleBook := StyleBook1;
UniListView1.UseStyleBook := True;
```

Смена или удаление `StyleBook`, загрузка формы и перенос списка на другую форму
обновляют палитру автоматически. `UseStyleBook := False` возвращает цвета,
сохранённые перед включением режима, включая ручные настройки. Назначение
`ThemeName` или успешная загрузка YAML-темы также включает собственную тему.
Без назначенного стиля используется сохранённая собственная палитра.

Используются ресурсы `backgroundstyle`, `listboxstyle/background`,
`listboxstyle/selection`, `text`, `labelstyle/text`, `listboxitemstyle/text`.
Поддерживаются solid brush/shape, текстовые и цветовые ресурсы; для bitmap-стиля
цвет определяется по центру отрисованного ресурса. Это адаптация палитры:
геометрия и отрисовка карточек остаются средствами UniListView.

При `UseStyleBook = True` чекбоксы используют `checkboxstyle`: пустое и выбранное
состояния отрисовываются стандартным FMX `TCheckBox` в кэш изображений. Кэш
обновляется при смене стиля или масштаба экрана; отдельные контролы для элементов
не создаются. Промежуточное состояние использует пустой чекбокс стиля и черту
цветом текста, поскольку стандартный `TCheckBox` FMX не имеет третьего состояния.
Без `checkboxstyle` и при собственных темах сохраняется векторная отрисовка UniListView.

Иконки карточек, действий и навигации используют цвет `buttonstyle/text`, а при его
отсутствии — основной цвет текста стиля. Цвет выделения строки остаётся цветом
фона, а не значков. Ресурс `unilisticon` (`TBrushObject` или `TColorObject`) позволяет
явно задать цвет иконок. Неактивные действия приглушаются; собственные темы
сохраняют прежние цвета. Формы векторных значков определяются UniListView.

Для точной палитры нестандартного стиля можно добавить в его корень
`TBrushObject` или `TColorObject` с `StyleName`: `unilistbackground`,
`unilistforeground`, `unilistselection`, `unilistaccent`, `unilistui`.
Эти ресурсы имеют приоритет. После прямого изменения ресурсов в коде вызывайте
`RefreshStyleBook`. Палитра читается при обновлении стиля, а не для каждого элемента.
Режим сохраняется в FMX и JSON layout.

Проверка: `tests/StyleBookRuntimeSmoke.dpr`, первый аргумент — каталог стилей
RAD Studio, содержащий `Dark.style` и `Win10ModernSlateGray.style`.
## Демо и проверка запуска

`demo/UniListDemo.dpr` демонстрирует Cards, List и Tree, поиск, отметки элементов,
выбор FMX-стиля, размеры карточек и наборы до 10 000 элементов. JSON stress-тест
открывается отдельным окном. Форма и её StyleBook доступны в дизайнере FMX.

Кнопка **Load .style...** загружает FMX-файл в `StyleBook1`. Прочитанные файлы
появляются в переключателе; при запуске туда также добавляются `*.style` из папки
`styles` рядом с EXE. **Embedded form style** возвращает встроенный стиль формы.
Файл сначала проверяется во временном StyleBook; ошибка чтения сохраняет текущее
оформление. `UseStyleBook` остаётся включённым, палитра списка и панелей обновляется.
Собственные темы компонента продолжают быть доступны через его API.

Выбор `ThemeName` в коде, в том числе в `OnCreate`, переключает компонент на
собственную тему. Если требуется палитра формы, включайте `UseStyleBook` после
такой инициализации.

Для стилей с `TFillRGBEffect` приложение должно подключать `FMX.Filter.Effects`.
В демо зависимость указана в `MainUnit.pas`. Без неё загрузка StyleBook вызывает
`Class TFillRGBEffect not found`; при освобождении недосозданной формы FMX может
показать вторичный access violation.

Проверки:

- `tests/ThemeRuntimeSmoke.dpr` — собственные темы, сохранность данных и выбора;
- `tests/StyleBookRuntimeSmoke.dpr` — палитра формы, смена стиля и сериализация;
- `tests/DemoStyleStartupSmoke.dpr` — создание, показ и закрытие актуальной формы демо; с каталогом стилей RAD Studio в первом аргументе также проверяет загрузку файлов, переключение и возврат встроенного стиля.

Сборки пакетов и демо проверены в Win32/Win64. Для запуска smoke-тестов добавьте
`src` в путь поиска модулей; для теста формы демо также добавьте `demo`.