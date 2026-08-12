# UniPopup Performance Lab Protocol

The lab uses the existing UniList runtime directly. It does not detach private
lookup children, replace PopupHost, or change TUniLookup architecture.

## Before run

1. Build Release outside the Delphi debugger.
2. Use the same machine, renderer, window size, and desktop scale for every run.
3. Run each case for 10 seconds.
4. Press Reset, then Start. After 10 seconds press Stop and Refresh.
5. Store the report text together with OS, renderer, VM/physical, and scale.

## Required Before matrix

- A: Baseline / No PopupComponent / None
- B: TUniDropDown only / No PopupComponent / None
- C: TUniDropDown + PopupComponent / assigned closed / Empty TLayout
- D: TUniDropDown + PopupComponent / assigned closed / TUniListView 10
- E: TUniLookup + internal list / assigned closed / TUniListView 10
- F: TUniDropDown and TUniLookup together / assigned closed / TUniListView 10

For lookup modes, `TUniLookup only` is the real component with its normal
internally-created list left empty. `TUniLookup + internal list` fills that same
real list only when the selected content mode is TUniListView 10 or 1000.
No private lookup field is replaced or removed.

## Popup state behavior

- No PopupComponent assigns nil through the existing public property.
- Assigned closed keeps the existing component assigned and closes the popup.
- Popup open opens through OpenDropDown.
- Closed after first open performs OpenDropDown followed by CloseDropDown.
- Detached closes and assigns nil without destroying the content owner.

Changing any selector destroys the previous test owner and creates one fresh
active test set. Hidden previous controls are not retained.

## Metric scope

Exact:

- marker average, P95, maximum, stalls over 33/100 ms;
- test-control Paint calls;
- observable popup-content Paint calls;
- benchmark operation open/close time;
- existing TUniListView Paint/Repaint/Realign/MouseMove/HitTest counters.

Reported as N/A because the existing runtime exposes no observation hook:

- general FMX Repaint request count;
- general FMX Realign request count;
- private PopupHost.PositionPopup call count.

These values must not be inferred from Paint or timer activity.

## After run

After a separately reviewed runtime optimization, repeat the same matrix with
the same build configuration and environment. Lazy detach is considered only
if the visibility-only result still fails the acceptance thresholds.
## Automatic regression matrix

`Run Full Matrix` executes the explicit scenario registry without manual input. Each scenario destroys the previous controls, creates and configures a clean test set, processes messages, stabilizes for 1 second, resets counters, measures for 10 seconds, captures runtime state and metrics, validates assertions, and destroys the controls.

The unified UTF-8 report is saved beside the executable as `UniPopupPerformanceLab-FullMatrix-yyyyMMdd-hhnnss.txt`. A failed scenario does not stop the remaining matrix.
## Popup diagnostics 1.1.2

Each automatic scenario reports Stored Properties separately from Runtime Attachment. Validation uses only Parent, Root, Scene, attachment, PopupHost assignment/open state, and measured Paint activity; stored Visible does not determine attachment.

Activity Sources separates PopupHost, PopupRoot, PopupComponent, LookupPopup, LookupList, DropDown, and TestForm. PopupHost and PopupRoot are reported as `N/A (runtime hook not exposed)` because their visual controls are private to `TUniPopupHost`; the lab does not modify runtime code to observe them. Other unavailable FMX input/invalidation hooks are reported as N/A rather than inferred.
## Stable scenario state machine 1.1.3

Automatic scenarios execute Create, Configure, Apply Requested State, Verify State, Reset Counters, Verify Counters, Measurement, Collect Results, Destroy, and Cleanup in that order. `WaitUntilScenarioState` processes FMX messages and requires three consecutive matching state checks within the shared 500 ms timeout.

Measurement is not started after a state timeout or failed counter-reset verification. Such failures are recorded as `FAILED (Timeout)` or `FAILED (Verification)` and the matrix continues with a clean scenario.
## Real user interaction 1.1.4

Automatic `Popup Open` and `Closed After Open` states are requested through the benchmark control's normal FMX input sequence: `MouseDown`, `MouseClick`, and `MouseUp`. The click uses the dropdown field, whose normal handler executes `ToggleDropDown`. Direct `OpenDropDown` is not used by these automatic scenarios.

The interaction trace records whether the request returned, whether `DoDropDownOpened` observed the popup attached to Parent, Root, and Scene, and whether `DoDropDownClosed` occurred without an explicit second click. State timeout remains 500 ms and no Sleep is used.