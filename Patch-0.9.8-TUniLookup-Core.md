# Patch 0.9.8 — TUniLookup Core

## 1. Цель

Добавить новый компонент:

```delphi
TUniLookup
```

Он должен использовать уже готовые:

```text
TUniDropDown
TUniPopupHost
TUniListView
```

Задача текущего патча — реализовать обычный lookup без DataSet и без data-aware логики.

---

## 2. Архитектура

```text
TUniLookup
  ├─ наследуется от TUniDropDown
  └─ использует внутренний TUniListView как PopupContent
```

`TUniLookup` отвечает за:

- отображение списка в popup;
- одиночный выбор элемента;
- отображаемый текст;
- выбранный индекс;
- выбранный объект;
- клавиатурную навигацию;
- применение и отмену выбора.

Не добавлять DataSource, KeyField, DataField и Locate.

---

## 3. Новый unit

Добавить:

```text
UniList.Lookup.pas
```

Компонент зарегистрировать в Tool Palette.

---

## 4. Новый компонент

```delphi
type
  TUniLookup = class(TUniDropDown)
  end;
```

Не дублировать код dropdown и popup host.

---

## 5. Встроенный список

`TUniLookup` должен создавать внутренний:

```delphi
TUniListView
```

Предпочтительно:

```delphi
FListView := TUniListView.Create(Self);
```

Требования:

- использовать его как `PopupContent`;
- не требовать отдельного `TUniListView` на форме;
- сделать доступным read-only свойством:

```delphi
property ListView: TUniListView read FListView;
```

- основные настройки списка должны быть доступны через прокси-свойства или subproperty;
- не копировать renderer и selection logic.

---

## 6. Источник элементов

Использовать существующую модель данных `TUniListView`.

Не создавать параллельную коллекцию строк.

Если у `TUniListView` уже есть `Items`, `Data`, provider или adapter API — использовать его.

Допускается published-свойство:

```delphi
property Items;
```

только как прокси к существующему источнику списка.

---

## 7. Выбор

Поддержать только одиночный выбор.

Публичный API:

```delphi
property ItemIndex: Integer
  read FItemIndex
  write SetItemIndex
  default -1;

property SelectedItem: TObject
  read GetSelectedItem;

property SelectedText: string
  read GetSelectedText;
```

`SelectedItem` может иметь другой тип, если текущая модель данных библиотеки использует собственный item class.

Не добавлять multi-select.

---

## 8. DisplayColumn

Добавить:

```delphi
property DisplayColumn: string
  read FDisplayColumn
  write SetDisplayColumn;
```

Семантика:

- определяет колонку, значение которой показывается в поле lookup;
- после выбора:

```delphi
Text := ValueFromDisplayColumn;
```

Fallback:

1. колонка с `CardRole = ucrTitle`;
2. первая видимая колонка;
3. пустая строка.

Не создавать отдельную `DisplayField` data-aware семантику.

---

## 9. Открытие popup

При открытии:

- внутренний `TUniListView` должен быть синхронизирован с текущим `ItemIndex`;
- выбранный элемент должен быть видимым;
- focus должен перейти в список;
- dropdown не должен автоматически менять выбор;
- popup использует настройки `TUniDropDown`.

---

## 10. Временный и подтверждённый выбор

Нужно разделить:

```text
Current Item in popup
Committed ItemIndex
```

При навигации стрелками в открытом popup:

- меняется только временный current item;
- `Text` и `ItemIndex` не меняются до подтверждения.

Подтверждение:

```text
Enter
double click
single click, если CommitOnClick = True
```

Отмена:

```text
Escape
click outside
```

После отмены восстановить прежний `ItemIndex` и `Text`.

---

## 11. Новое свойство

```delphi
property CommitOnClick: Boolean
  read FCommitOnClick
  write FCommitOnClick
  default True;
```

При `True`:

- single click по item подтверждает выбор и закрывает popup.

При `False`:

- single click только меняет current item;
- Enter или double click подтверждает.

---

## 12. Методы

Добавить:

```delphi
procedure SelectItem(const AIndex: Integer);
procedure ClearSelection;
procedure CommitSelection;
procedure CancelSelection;
```

Требования:

- Guard Clauses;
- безопасная работа при пустом списке;
- invalid index не вызывает exception;
- `ClearSelection` устанавливает:

```delphi
ItemIndex := -1;
Text := '';
```

---

## 13. События

Добавить:

```delphi
property OnSelectionChanging;
property OnSelectionChanged;
property OnItemSelected;
```

Рекомендуемые сигнатуры:

```delphi
TUniLookupSelectionChangingEvent = procedure(
  Sender: TObject;
  const AOldIndex: Integer;
  const ANewIndex: Integer;
  var AAllow: Boolean
) of object;

TUniLookupSelectionChangedEvent = procedure(
  Sender: TObject;
  const AItemIndex: Integer
) of object;
```

`OnSelectionChanged` вызывать только после commit.

Не вызывать при простой навигации внутри popup.

---

## 14. Клавиатура

Когда popup закрыт:

```text
Alt+Down / F4  → открыть
Down           → открыть и выбрать текущий/первый item
Home           → выбрать первый item
End            → выбрать последний item
Delete         → ClearSelection, если AllowClear = True
```

Когда popup открыт:

```text
Up / Down      → навигация
PageUp/PageDown
Home / End
Enter          → CommitSelection
Escape         → CancelSelection
F4             → закрыть с отменой
```

Не добавлять incremental search в этом патче.

---

## 15. AllowClear

Добавить:

```delphi
property AllowClear: Boolean
  read FAllowClear
  write FAllowClear
  default True;
```

При `False`:

- `ClearSelection` программно допускается;
- пользовательская клавиша Delete не очищает значение.

Не добавлять отдельную clear-button icon.

---

## 16. Mouse

Поддержать:

- hover через существующий `TUniListView`;
- single click;
- double click;
- wheel scroll;
- click outside;
- click по scrollbar не считается выбором.

Не добавлять drag-and-drop.

---

## 17. Search

В этом патче не делать встроенную строку поиска.

Но `TUniLookup` не должен ломать уже существующий search API внутреннего `TUniListView`.

Разрешить программно:

```delphi
Lookup.ListView.SearchText := '...';
```

Не добавлять AutoComplete.

---

## 18. Режим отображения popup

Внутренний `TUniListView` должен поддерживать все существующие режимы:

- List;
- Grid Cards;
- Full-Width Cards;
- Tree.

Добавить прокси:

```delphi
property PopupViewMode;
property PopupCardLayout;
```

Имена можно адаптировать.

Default:

```delphi
PopupViewMode := uvmList;
```

---

## 19. Размер popup

Использовать свойства `TUniDropDown`:

- DropDownPlacement;
- DropDownWidthMode;
- DropDownWidth;
- DropDownMaxHeight.

Не добавлять отдельную систему размеров.

---

## 20. Theme

`TUniLookup` и внутренний список должны использовать одну тему.

При смене темы lookup:

- dropdown перерисовывается;
- popup host обновляется;
- внутренний `TUniListView` обновляется.

Не использовать фиксированные цвета.

---

## 21. Design-Time

В Form Designer:

- компонент отображается как dropdown;
- `Text` или `PromptText` видны;
- внутренний popup не открывается автоматически;
- свойства lookup доступны в Object Inspector;
- внутренний `ListView` не должен появляться отдельным визуальным child на форме;
- старый Design-Time Preview `TUniListView` не ломается.

Не требуется design-time preview раскрытого lookup.

---

## 22. Lifecycle

При destroy:

- popup закрыть;
- внутренний list уничтожить owner-механизмом;
- события отсоединить;
- не оставить overlay;
- не вызвать AV;
- не вызывать callbacks после начала destroy.

---

## 23. Demo

Добавить в существующий demo:

- `TUniLookup`;
- 10–20 sample items;
- DisplayColumn;
- ItemIndex;
- Clear button вне lookup;
- переключатель `CommitOnClick`;
- переключатель popup view:
  - List;
  - Full-Width Cards.

Показать события выбора в label/log.

UI разместить design-time в `.fmx`.

---

## 24. Acceptance Criteria

Патч готов, если:

- `TUniLookup` добавлен;
- наследуется от `TUniDropDown`;
- использует внутренний `TUniListView`;
- popup открывается;
- список получает focus;
- одиночный выбор работает;
- Enter подтверждает;
- Escape отменяет;
- click outside отменяет;
- `CommitOnClick` работает;
- `ItemIndex` синхронизирован;
- `Text` обновляется по DisplayColumn;
- `ClearSelection` работает;
- keyboard navigation работает;
- List popup работает;
- Full-Width Cards popup работает;
- theme работает;
- design-time работает;
- Win32/Win64 компилируются;
- Linux64 компилируется;
- нет `Winapi.*`;
- нет `Vcl.*`;
- нет `with`;
- нет magic numbers.

---

## 25. Не реализовывать

Не добавлять:

```delphi
DataSource
DataField
KeyField
ListField
ValueField
SelectedValue
Locate
AutoComplete
SearchEdit
MultiSelect
Tags
TokenEdit
```

Не добавлять:

- data-aware binding;
- remote loading;
- async provider;
- multi-column editor;
- inline editing;
- Tree Cards;
- drag-and-drop.

---

## 26. Definition of Done

- новый unit добавлен;
- runtime package обновлён;
- design-time package обновлён;
- demo обновлено;
- smoke tests добавлены;
- Win64 build проходит;
- Linux64 build проходит либо документирована конкретная ошибка среды;
- commit/cancel сценарий протестирован;
- итоговый diff кратко описан.
