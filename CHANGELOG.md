# UniListView v0.6.0 patch 3

- Added `TUniListView.BeginUpdate` / `EndUpdate`.
- Sorting is deferred until the batch load finishes.
- Item field notifications are suppressed during `TUniListItems.BeginUpdate`.
- Layout rebuilding and repainting occur once after the batch.
- Prevented repeated `IndexOf`, sorting and redraw calls while loading many items.
