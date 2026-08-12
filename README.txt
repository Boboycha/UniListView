UniListView v0.9.0 — Tree Lazy Loading Core

Добавлено:
- TreeLazyLoad;
- TreeHasChildrenField (по умолчанию has_children);
- OnTreeLoadChildren(Sender, ParentKey, var Handled);
- MarkChildrenLoaded;
- ReloadChildren;
- ChildrenLoaded;
- сохранение загруженных веток в layout JSON;
- демонстрационный узел Remote Sites, дети которого создаются при первом раскрытии.

Пример:

  UniListView1.TreeLazyLoad := True;
  UniListView1.TreeHasChildrenField := 'has_children';

  procedure TForm1.UniListView1TreeLoadChildren(Sender: TObject;
    const ParentKey: string; var Handled: Boolean);
  begin
    // Добавить дочерние Items с parent_id = ParentKey
    Handled := True;
  end;

Если загрузка выполняется асинхронно, обработчик может запустить задачу,
оставить Handled=False, а после добавления элементов вызвать:

  UniListView1.MarkChildrenLoaded(ParentKey);

Для повторной загрузки:

  UniListView1.ReloadChildren(ParentKey);

v0.9.1 Tree Toggle Polish
- Unicode tree arrows replaced with vector Skia chevrons.
- Collapsed and expanded states are visually distinct.
- Toggle hit area increased to 18x18 px.
- Tree toggle/check spacing adjusted.
