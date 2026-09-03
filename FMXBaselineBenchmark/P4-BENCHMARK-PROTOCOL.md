# P4 FMX Baseline Benchmark Protocol

## Executables

- Baseline project: `FMXBaselineBenchmark.exe`
- UniListView comparison: `..\demo\UniListDemo.exe`

## Strict Session Protocol

For every row in the decision matrix:

1. Select test.
2. Select workload.
3. Select scale.
4. Select window mode.
5. Click `Prepare`.
6. Wait 3 seconds.
7. Click `Reset`.
8. Click `Start`.
9. Run exactly one scenario for 10 seconds.
10. Click `Stop`.
11. Click `Refresh`.
12. Click `Save`.
13. Repeat 3 times.
14. Use median of the 3 saved reports.

Do not change workload, scale, window mode, or scenario during a session.

## Required Baseline Rows

| Row | Test | Workload | Scenario |
|---|---|---:|---|
| Empty Form | Empty Form | 10 | Idle |
| Empty PaintBox | Empty PaintBox | 10 | Idle and Forced repaint |
| FillRect 100 | FillRect | 100 | Forced repaint |
| FillText 300 | FillText | 300 | Forced repaint |
| DrawBitmap 100 | DrawBitmap | 100 | Forced repaint |
| Combined PaintBox | Combined PaintBox | 100 | Forced repaint |
| 100 Labels | Standard Controls | 300 or 1000 for labels/rectangles; 100 for cards | Idle / Mouse move |
| 100 Cards Controls | Standard Controls | 100 | Idle / Mouse move |
| TVertScrollBox 100 | TVertScrollBox | 100 | Scroll |
| Standard TListView 10k | Standard TListView | 10000 | Scroll |
| UniListView Cards 10k | Showcase Performance | 10000 | Scroll / Hover |

## Scale And Window Modes

Run applicable rows at:

- Scale 1.00
- Scale 1.25
- Scale 1.50
- Scale 2.00
- Normal window
- Maximized window

For production decision, prioritize Release + Debian Physical + Scale 1.00 + Maximized + continuous scroll.

## Metrics To Copy Into Matrix

For every saved report copy:

- FPS average
- FPS 1% low
- Frame interval P95
- Paint Avg
- Frame interval max
- Frames >100 ms
- Load Avg when applicable

## Decision Tree

### Case A

If Linux Empty Form Frame P95 > 33.33 ms or FPS Avg < 30:

`FINAL DECISION: CONDITIONAL GO - Linux Experimental`

Reason: FMX Linux baseline is slow before UniListView participates.

### Case B

If Empty Form is fast but Empty PaintBox is slow:

`FINAL DECISION: CONDITIONAL GO - Linux Experimental`

Reason: bottleneck is FMX paint/scene lifecycle, not UniListView.

### Case C

If PaintBox primitives are fast and standard controls are slow, while UniListView is faster than standard controls:

`FINAL DECISION: GO`

Reason: UniListView avoids the slow standard visual tree path.

### Case D

If Combined PaintBox is fast and UniListView is slow:

`FINAL DECISION: NO-GO`

Reason: bottleneck is inside UniListView or Showcase integration.

### Case E

If Standard TListView and UniListView are equally slow while Empty PaintBox is fast:

`FINAL DECISION: CONDITIONAL GO - Linux Experimental`

Reason: bottleneck is FMX list/control infrastructure or scene invalidation.

### Case F

If UniListView is faster than Standard TListView and production thresholds pass:

`FINAL DECISION: GO`

## Production Thresholds

For UniListView Cards/List 10000 items, Scale 1.00, Maximized, Release, Debian Physical, continuous scroll, median of 3 runs:

- FPS Average >= 30
- FPS 1% Low >= 20
- Frame P95 <= 50 ms
- Component Paint Avg <= 8 ms
- No frame > 500 ms during hover/scroll
- No O(N) rebuild during hover/scroll

If UniListView is the bottleneck and these fail reproducibly:

`FINAL DECISION: NO-GO`
