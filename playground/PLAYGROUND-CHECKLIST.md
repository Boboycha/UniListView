# UniListView Playground checklist

## Automated

- [x] Win64 Debug compiles with Delphi compiler 36.0.
- [x] Project contains one `TMainForm`.
- [x] `MainUnit.fmx` contains one `TUniListView`.
- [x] No `TUniListView.Create` call exists in Playground.
- [x] `UniList.Vector` is explicitly included in the DPR.
- [x] No runtime library source was changed for Playground.

## Manual runtime

- [ ] Application opens with 100 cards and no exception.
- [ ] Cards/List preserve the same items and component instance.
- [ ] Generate 100, 1 000, 10 000 and 50 000 items.
- [ ] Verify scrolling modes, pan modes, scroll bars and content flow.
- [ ] Verify card sizing, presets and every card-template setting.
- [ ] Verify list header, rows, footer, frozen columns and grid lines.
- [ ] Verify column add/delete/edit, sorting, resizing, reorder and chooser.
- [ ] Verify action add/delete/edit and item action events.
- [ ] Verify item add/delete/edit, typed fields and collection sorting.
- [ ] Verify selection, selected text and keyboard copy.
- [ ] Verify color presets and individual ARGB values.
- [ ] Verify layout JSON and file round trips, including invalid JSON.
- [ ] Verify Clear, Reset, status text, event log and Pause Log.

