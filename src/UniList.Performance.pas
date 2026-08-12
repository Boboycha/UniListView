unit UniList.Performance;

interface

uses
  System.SysUtils, System.Diagnostics;

type
  TUniPerfCounter = (
    upcPaint,
    upcPaintBackground,
    upcPaintHeader,
    upcPaintFooter,
    upcPaintFilterRow,
    upcPaintList,
    upcPaintCards,
    upcPaintTree,
    upcPaintSelection,
    upcPaintFocus,
    upcPaintCheckBox,
    upcPaintIcons,
    upcPaintText,
    upcDrawRow,
    upcDrawCard,
    upcDrawTreeNode,
    upcDrawRowBackground,
    upcDrawRowColumns,
    upcDrawRowText,
    upcDrawRowImage,
    upcDrawRowSelection,
    upcDrawRowFocus,
    upcDrawRowCheckBox,
    upcDrawRowGridLines,
    upcDrawCardBackground,
    upcDrawCardBorder,
    upcDrawCardIcon,
    upcDrawCardTitle,
    upcDrawCardSubtitle,
    upcDrawCardDetails,
    upcDrawCardFooter,
    upcDrawCardSelection,
    upcDrawCardFocus,
    upcDrawCardCheckBox,
    upcCanvasFillRect,
    upcCanvasDrawBitmap,
    upcCanvasDrawPath,
    upcCanvasDrawLine,
    upcCanvasFillText,
    upcCanvasMeasureText,
    upcCanvasBeginScene,
    upcCanvasEndScene,
    upcVisibleRange,
    upcVisibleRangeList,
    upcVisibleRangeCards,
    upcVisibleRangeTree,
    upcVisibleRangeHitTest,
    upcVisibleRangeScroll,
    upcVisibleRangeResize,
    upcGeometryRowBounds,
    upcGeometryCardBounds,
    upcGeometryColumnBounds,
    upcGeometryHitRect,
    upcGeometrySelectionRect,
    upcGeometryCheckBoxRect,
    upcGeometryIconRect,
    upcHitTest,
    upcMouseMove,
    upcHoverDetect,
    upcCursorUpdate,
    upcScroll,
    upcScrollVisibleRange,
    upcScrollGeometry,
    upcScrollbarUpdate,
    upcResize,
    upcResizeLayout,
    upcResizeRealign,
    upcResizeVisibleRange,
    upcResizeGeometry,
    upcMeasureText,
    upcCreateTextLayout,
    upcReuseTextLayout,
    upcCalculateRowHeight,
    upcCalculateCardHeight,
    upcSearchRebuild,
    upcFilterRebuild,
    upcPopupOpen,
    upcPopupLayout,
    upcPopupPaint,
    upcPopupResize,
    upcLookupPaint,
    upcLookupSearchLatency,
    upcRequestRepaint,
    upcRequestRealign,
    upcFullRebuild,
    upcCardTreeRebuild,
    upcCardTreeExplorerVisibleSetBuild,
    upcCardTreeNavigateVisibleSetBuild,
    upcCardTreeHierarchyVisibleSetBuild,
    upcCardTreeBreadcrumbBuild,
    upcCardTreeLayoutRecalculate,
    upcCardTreeExplorerLayoutRecalculate,
    upcCardTreeNavigateLayoutRecalculate,
    upcCardTreeHierarchyLayoutRecalculate
  );

  TUniPerfMetric = record
    Count: Int64;
    TotalTicks: Int64;
    MinTicks: Int64;
    MaxTicks: Int64;
    LastTicks: Int64;
  end;

  TUniPerfMetricSnapshot = record
    Calls: Int64;
    TotalMilliseconds: Double;
    LastMilliseconds: Double;
    AverageMilliseconds: Double;
    MaxMilliseconds: Double;
    MinMilliseconds: Double;
  end;

  TUniPerformanceSnapshot = record
    Enabled: Boolean;
    Platform: string;
    ViewMode: string;
    TotalItems: Integer;
    VisibleItems: Integer;
    ItemsScanned: Int64;
    RowsDrawn: Int64;
    CardsDrawn: Int64;
    TreeNodesDrawn: Int64;
    TextLayoutsCreated: Int64;
    TextLayoutsReused: Int64;
    TextMeasureCalls: Int64;
    FillTextCalls: Int64;
    GeometryCalculations: Int64;
    RepaintRequests: Int64;
    RealignRequests: Int64;
    FullRebuildRequests: Int64;
    HitTests: Int64;
    MouseMoveCalls: Int64;
    ScrollEvents: Int64;
    ResizeCalls: Int64;
    HoverChangedCount: Int64;
    HoverUnchangedCount: Int64;
    HoverRepaintCount: Int64;
    VisibleRangeCalculations: Int64;
    VisibleRangeItemsExamined: Int64;
    RowHeightCalculations: Int64;
    CardHeightCalculations: Int64;
    SearchRebuilds: Int64;
    SearchItemsScanned: Int64;
    SearchResultCount: Int64;
    FilterRebuilds: Int64;
    FilterItemsScanned: Int64;
    FilterResultCount: Int64;
    LastPaintScannedItems: Int64;
    LastPaintDrawnItems: Int64;
    LastPaintVisibleItems: Integer;
    Metrics: array[TUniPerfCounter] of TUniPerfMetric;
    MetricSnapshots: array[TUniPerfCounter] of TUniPerfMetricSnapshot;
    Paint: TUniPerfMetric;
    PaintList: TUniPerfMetric;
    PaintCards: TUniPerfMetric;
    PaintTree: TUniPerfMetric;
    MouseMove: TUniPerfMetric;
    HitTest: TUniPerfMetric;
    Scroll: TUniPerfMetric;
    MeasureText: TUniPerfMetric;
    CreateTextLayout: TUniPerfMetric;
    CalculateRowHeight: TUniPerfMetric;
    SearchRebuild: TUniPerfMetric;
    FilterRebuild: TUniPerfMetric;
  end;

  TUniPerfScope = record
  private
{$IFDEF UNILIST_PROFILE}
    FCounter: TUniPerfCounter;
    FStartTicks: Int64;
    FActive: Boolean;
{$ENDIF}
  public
    class function Start(const ACounter: TUniPerfCounter): TUniPerfScope; static;
    procedure Stop;
  end;

procedure UniPerfReset;
function UniPerfSnapshot: TUniPerformanceSnapshot;
function UniPerfReport(const ASnapshot: TUniPerformanceSnapshot;
  const AMode: string): string;
function UniPerfCounterName(const ACounter: TUniPerfCounter): string;
procedure UniPerfSetContext(const ATotalItems, AVisibleItems: Integer);
procedure UniPerfSetLastPaint(const AScannedItems, ADrawnItems: Int64;
  const AVisibleItems: Integer);
procedure UniPerfSetViewMode(const AViewMode: string);
procedure UniPerfAdd(const ACounter: TUniPerfCounter; const ATicks: Int64);
procedure UniPerfInc(const ACounter: TUniPerfCounter; const AValue: Int64 = 1);
procedure UniPerfAddItemsScanned(const AValue: Int64);
procedure UniPerfAddVisibleRangeItemsExamined(const AValue: Int64);
procedure UniPerfSetSearchResultCount(const AValue: Int64);
procedure UniPerfSetFilterResultCount(const AValue: Int64);
procedure UniPerfAddHoverChanged;
procedure UniPerfAddHoverUnchanged;
procedure UniPerfAddHoverRepaint;

implementation

const
  CCounterNames: array[TUniPerfCounter] of string = (
    'Paint',
    'Paint Background',
    'Paint Header',
    'Paint Footer',
    'Paint Filter Row',
    'Paint List',
    'Paint Cards',
    'Paint Tree',
    'Paint Selection',
    'Paint Focus',
    'Paint CheckBox',
    'Paint Icons',
    'Paint Text',
    'Draw Row',
    'Draw Card',
    'Draw Tree Node',
    'Draw Row Background',
    'Draw Row Columns',
    'Draw Row Text',
    'Draw Row Image',
    'Draw Row Selection',
    'Draw Row Focus',
    'Draw Row CheckBox',
    'Draw Row Grid Lines',
    'Draw Card Background',
    'Draw Card Border',
    'Draw Card Icon',
    'Draw Card Title',
    'Draw Card Subtitle',
    'Draw Card Details',
    'Draw Card Footer',
    'Draw Card Selection',
    'Draw Card Focus',
    'Draw Card CheckBox',
    'Canvas FillRect',
    'Canvas DrawBitmap',
    'Canvas DrawPath',
    'Canvas DrawLine',
    'Canvas FillText',
    'Canvas MeasureText',
    'Canvas BeginScene',
    'Canvas EndScene',
    'Visible Range',
    'Visible Range List',
    'Visible Range Cards',
    'Visible Range Tree',
    'Visible Range HitTest',
    'Visible Range Scroll',
    'Visible Range Resize',
    'Geometry Row Bounds',
    'Geometry Card Bounds',
    'Geometry Column Bounds',
    'Geometry Hit Rect',
    'Geometry Selection Rect',
    'Geometry CheckBox Rect',
    'Geometry Icon Rect',
    'Hit Test',
    'MouseMove',
    'Hover Detect',
    'Cursor Update',
    'Scroll',
    'Scroll Visible Range',
    'Scroll Geometry',
    'Scrollbar Update',
    'Resize',
    'Resize Layout',
    'Resize Realign',
    'Resize Visible Range',
    'Resize Geometry',
    'Measure Text',
    'Create TextLayout',
    'Reuse TextLayout',
    'Calculate Row Height',
    'Calculate Card Height',
    'Search Rebuild',
    'Filter Rebuild',
    'Popup Open',
    'Popup Layout',
    'Popup Paint',
    'Popup Resize',
    'Lookup Paint',
    'Lookup Search Latency',
    'Request Repaint',
    'Request Realign',
    'Full Rebuild',
    'Card Tree Rebuild',
    'Explorer Visible Set Build',
    'Navigate Visible Set Build',
    'Hierarchy Visible Set Build',
    'Breadcrumb Build',
    'Card Tree Layout Recalculate',
    'Explorer Layout Recalculate',
    'Navigate Layout Recalculate',
    'Hierarchy Layout Recalculate'
  );

var
  GSnapshot: TUniPerformanceSnapshot;

function TicksToMilliseconds(const ATicks: Int64): Double;
begin
  if TStopwatch.Frequency <= 0 then
    Exit(0);
  Result := ATicks * 1000 / TStopwatch.Frequency;
end;

function MetricToSnapshot(const AMetric: TUniPerfMetric): TUniPerfMetricSnapshot;
begin
  Result.Calls := AMetric.Count;
  Result.TotalMilliseconds := TicksToMilliseconds(AMetric.TotalTicks);
  Result.LastMilliseconds := TicksToMilliseconds(AMetric.LastTicks);
  Result.MaxMilliseconds := TicksToMilliseconds(AMetric.MaxTicks);
  Result.MinMilliseconds := TicksToMilliseconds(AMetric.MinTicks);
  if AMetric.Count <= 0 then
    Result.AverageMilliseconds := 0
  else
    Result.AverageMilliseconds := Result.TotalMilliseconds / AMetric.Count;
end;

procedure AddMetric(var AMetric: TUniPerfMetric; const ATicks: Int64);
begin
  Inc(AMetric.Count);
  Inc(AMetric.TotalTicks, ATicks);
  AMetric.LastTicks := ATicks;
  if (AMetric.MinTicks = 0) or (ATicks < AMetric.MinTicks) then
    AMetric.MinTicks := ATicks;
  if ATicks > AMetric.MaxTicks then
    AMetric.MaxTicks := ATicks;
end;

procedure SyncLegacyMetrics(var ASnapshot: TUniPerformanceSnapshot);
begin
  ASnapshot.Paint := ASnapshot.Metrics[upcPaint];
  ASnapshot.PaintList := ASnapshot.Metrics[upcPaintList];
  ASnapshot.PaintCards := ASnapshot.Metrics[upcPaintCards];
  ASnapshot.PaintTree := ASnapshot.Metrics[upcPaintTree];
  ASnapshot.MouseMove := ASnapshot.Metrics[upcMouseMove];
  ASnapshot.HitTest := ASnapshot.Metrics[upcHitTest];
  ASnapshot.Scroll := ASnapshot.Metrics[upcScroll];
  ASnapshot.MeasureText := ASnapshot.Metrics[upcMeasureText];
  ASnapshot.CreateTextLayout := ASnapshot.Metrics[upcCreateTextLayout];
  ASnapshot.CalculateRowHeight := ASnapshot.Metrics[upcCalculateRowHeight];
  ASnapshot.SearchRebuild := ASnapshot.Metrics[upcSearchRebuild];
  ASnapshot.FilterRebuild := ASnapshot.Metrics[upcFilterRebuild];
end;

procedure BuildMetricSnapshots(var ASnapshot: TUniPerformanceSnapshot);
var
  Counter: TUniPerfCounter;
begin
  for Counter := Low(TUniPerfCounter) to High(TUniPerfCounter) do
    ASnapshot.MetricSnapshots[Counter] := MetricToSnapshot(
      ASnapshot.Metrics[Counter]);
end;

function PlatformName: string;
begin
{$IFDEF MSWINDOWS}
  Result := 'Windows';
{$ELSEIF DEFINED(LINUX)}
  Result := 'Linux';
{$ELSEIF DEFINED(MACOS)}
  Result := 'macOS';
{$ELSE}
  Result := 'Other';
{$ENDIF}
end;

class function TUniPerfScope.Start(
  const ACounter: TUniPerfCounter): TUniPerfScope;
begin
  Result := Default(TUniPerfScope);
{$IFDEF UNILIST_PROFILE}
  Result.FCounter := ACounter;
  Result.FStartTicks := TStopwatch.GetTimeStamp;
  Result.FActive := True;
{$ENDIF}
end;

procedure TUniPerfScope.Stop;
begin
{$IFDEF UNILIST_PROFILE}
  if not FActive then
    Exit;
  FActive := False;
  UniPerfAdd(FCounter, TStopwatch.GetTimeStamp - FStartTicks);
{$ENDIF}
end;

procedure UniPerfReset;
begin
{$IFDEF UNILIST_PROFILE}
  GSnapshot := Default(TUniPerformanceSnapshot);
  GSnapshot.Enabled := True;
  GSnapshot.Platform := PlatformName;
{$ENDIF}
end;

function UniPerfSnapshot: TUniPerformanceSnapshot;
begin
  Result := GSnapshot;
{$IFDEF UNILIST_PROFILE}
  Result.Enabled := True;
{$ELSE}
  Result.Enabled := False;
  Result.Platform := PlatformName;
{$ENDIF}
  if Result.Platform = '' then
    Result.Platform := PlatformName;
  SyncLegacyMetrics(Result);
  BuildMetricSnapshots(Result);
end;

function UniPerfCounterName(const ACounter: TUniPerfCounter): string;
begin
  Result := CCounterNames[ACounter];
end;

function MetricLine(const ACounter: TUniPerfCounter;
  const ASnapshot: TUniPerformanceSnapshot): string;
var
  Metric: TUniPerfMetricSnapshot;
begin
  Metric := ASnapshot.MetricSnapshots[ACounter];
  Result := Format('%s: Calls=%d Last=%.3f ms Avg=%.3f ms Max=%.3f ms Total=%.3f ms',
    [CCounterNames[ACounter], Metric.Calls, Metric.LastMilliseconds,
     Metric.AverageMilliseconds, Metric.MaxMilliseconds,
     Metric.TotalMilliseconds]);
end;

procedure AppendMetric(var ABuilder: TStringBuilder;
  const ASnapshot: TUniPerformanceSnapshot; const ACounter: TUniPerfCounter);
begin
  ABuilder.AppendLine('  ' + MetricLine(ACounter, ASnapshot));
end;

function UniPerfReport(const ASnapshot: TUniPerformanceSnapshot;
  const AMode: string): string;
var
  Builder: TStringBuilder;
begin
  Builder := TStringBuilder.Create;
  try
    Builder.AppendLine('UniListView Performance');
    Builder.AppendLine('Profiler: ' + BoolToStr(ASnapshot.Enabled, True));
    Builder.AppendLine('Platform: ' + ASnapshot.Platform);
    Builder.AppendLine('Mode: ' + AMode);
    Builder.AppendLine('Note: child metric times are included in parent metric times.');
    Builder.AppendLine('FMX BeginScene/EndScene: Not measurable from component');
    Builder.AppendLine('');
    Builder.AppendLine('Overview');
    Builder.AppendLine(Format('  Items total: %d', [ASnapshot.TotalItems]));
    Builder.AppendLine(Format('  Visible items: %d', [ASnapshot.VisibleItems]));
    Builder.AppendLine(Format('  Scanned last paint: %d', [ASnapshot.LastPaintScannedItems]));
    Builder.AppendLine(Format('  Drawn last paint: %d', [ASnapshot.LastPaintDrawnItems]));
    Builder.AppendLine(Format('  Items scanned total: %d', [ASnapshot.ItemsScanned]));
    Builder.AppendLine('');
    Builder.AppendLine('Paint Pipeline');
    AppendMetric(Builder, ASnapshot, upcPaint);
    AppendMetric(Builder, ASnapshot, upcPaintBackground);
    AppendMetric(Builder, ASnapshot, upcPaintHeader);
    AppendMetric(Builder, ASnapshot, upcPaintFooter);
    AppendMetric(Builder, ASnapshot, upcPaintFilterRow);
    AppendMetric(Builder, ASnapshot, upcPaintList);
    AppendMetric(Builder, ASnapshot, upcPaintCards);
    AppendMetric(Builder, ASnapshot, upcPaintTree);
    AppendMetric(Builder, ASnapshot, upcPaintText);
    AppendMetric(Builder, ASnapshot, upcPaintIcons);
    AppendMetric(Builder, ASnapshot, upcPaintCheckBox);
    Builder.AppendLine('');
    Builder.AppendLine('Rows/Cards/Tree');
    Builder.AppendLine(Format('  Rows drawn: %d', [ASnapshot.RowsDrawn]));
    Builder.AppendLine(Format('  Cards drawn: %d', [ASnapshot.CardsDrawn]));
    Builder.AppendLine(Format('  Tree nodes drawn: %d', [ASnapshot.TreeNodesDrawn]));
    AppendMetric(Builder, ASnapshot, upcDrawRow);
    AppendMetric(Builder, ASnapshot, upcDrawCard);
    AppendMetric(Builder, ASnapshot, upcDrawTreeNode);
    AppendMetric(Builder, ASnapshot, upcDrawRowBackground);
    AppendMetric(Builder, ASnapshot, upcDrawRowColumns);
    AppendMetric(Builder, ASnapshot, upcDrawRowText);
    AppendMetric(Builder, ASnapshot, upcDrawRowCheckBox);
    AppendMetric(Builder, ASnapshot, upcDrawRowGridLines);
    AppendMetric(Builder, ASnapshot, upcDrawCardBackground);
    AppendMetric(Builder, ASnapshot, upcDrawCardBorder);
    AppendMetric(Builder, ASnapshot, upcDrawCardIcon);
    AppendMetric(Builder, ASnapshot, upcDrawCardTitle);
    AppendMetric(Builder, ASnapshot, upcDrawCardSubtitle);
    AppendMetric(Builder, ASnapshot, upcDrawCardDetails);
    AppendMetric(Builder, ASnapshot, upcDrawCardCheckBox);
    Builder.AppendLine('');
    Builder.AppendLine('Canvas');
    AppendMetric(Builder, ASnapshot, upcCanvasFillRect);
    AppendMetric(Builder, ASnapshot, upcCanvasDrawBitmap);
    AppendMetric(Builder, ASnapshot, upcCanvasDrawPath);
    AppendMetric(Builder, ASnapshot, upcCanvasDrawLine);
    AppendMetric(Builder, ASnapshot, upcCanvasFillText);
    AppendMetric(Builder, ASnapshot, upcCanvasMeasureText);
    AppendMetric(Builder, ASnapshot, upcCanvasBeginScene);
    AppendMetric(Builder, ASnapshot, upcCanvasEndScene);
    Builder.AppendLine('');
    Builder.AppendLine('Text');
    Builder.AppendLine(Format('  FillText calls: %d', [ASnapshot.FillTextCalls]));
    Builder.AppendLine(Format('  Measure calls: %d', [ASnapshot.TextMeasureCalls]));
    Builder.AppendLine(Format('  TextLayout created: %d', [ASnapshot.TextLayoutsCreated]));
    Builder.AppendLine(Format('  TextLayout reused: %d', [ASnapshot.TextLayoutsReused]));
    AppendMetric(Builder, ASnapshot, upcMeasureText);
    AppendMetric(Builder, ASnapshot, upcCreateTextLayout);
    AppendMetric(Builder, ASnapshot, upcReuseTextLayout);
    AppendMetric(Builder, ASnapshot, upcCanvasFillText);
    Builder.AppendLine('');
    Builder.AppendLine('Geometry');
    Builder.AppendLine(Format('  Geometry calculations: %d', [ASnapshot.GeometryCalculations]));
    AppendMetric(Builder, ASnapshot, upcGeometryRowBounds);
    AppendMetric(Builder, ASnapshot, upcGeometryCardBounds);
    AppendMetric(Builder, ASnapshot, upcGeometryColumnBounds);
    AppendMetric(Builder, ASnapshot, upcGeometryHitRect);
    AppendMetric(Builder, ASnapshot, upcGeometrySelectionRect);
    AppendMetric(Builder, ASnapshot, upcGeometryCheckBoxRect);
    AppendMetric(Builder, ASnapshot, upcGeometryIconRect);
    Builder.AppendLine('');
    Builder.AppendLine('Visible Range');
    Builder.AppendLine(Format('  Visible-range calculations: %d', [ASnapshot.VisibleRangeCalculations]));
    Builder.AppendLine(Format('  Items examined: %d', [ASnapshot.VisibleRangeItemsExamined]));
    AppendMetric(Builder, ASnapshot, upcVisibleRange);
    AppendMetric(Builder, ASnapshot, upcVisibleRangeList);
    AppendMetric(Builder, ASnapshot, upcVisibleRangeCards);
    AppendMetric(Builder, ASnapshot, upcVisibleRangeTree);
    AppendMetric(Builder, ASnapshot, upcVisibleRangeHitTest);
    AppendMetric(Builder, ASnapshot, upcVisibleRangeScroll);
    AppendMetric(Builder, ASnapshot, upcVisibleRangeResize);
    Builder.AppendLine('');
    Builder.AppendLine('Input');
    Builder.AppendLine(Format('  MouseMove calls: %d', [ASnapshot.MouseMoveCalls]));
    Builder.AppendLine(Format('  Hit tests: %d', [ASnapshot.HitTests]));
    Builder.AppendLine(Format('  Hover changes: %d', [ASnapshot.HoverChangedCount]));
    Builder.AppendLine(Format('  Hover unchanged: %d', [ASnapshot.HoverUnchangedCount]));
    Builder.AppendLine(Format('  Hover repaint requests: %d', [ASnapshot.HoverRepaintCount]));
    AppendMetric(Builder, ASnapshot, upcMouseMove);
    AppendMetric(Builder, ASnapshot, upcHoverDetect);
    AppendMetric(Builder, ASnapshot, upcHitTest);
    AppendMetric(Builder, ASnapshot, upcCursorUpdate);
    Builder.AppendLine('');
    Builder.AppendLine('Scroll');
    Builder.AppendLine(Format('  Scroll events: %d', [ASnapshot.ScrollEvents]));
    AppendMetric(Builder, ASnapshot, upcScroll);
    AppendMetric(Builder, ASnapshot, upcScrollVisibleRange);
    AppendMetric(Builder, ASnapshot, upcScrollGeometry);
    AppendMetric(Builder, ASnapshot, upcScrollbarUpdate);
    Builder.AppendLine('');
    Builder.AppendLine('Resize');
    Builder.AppendLine(Format('  Resize calls: %d', [ASnapshot.ResizeCalls]));
    AppendMetric(Builder, ASnapshot, upcResize);
    AppendMetric(Builder, ASnapshot, upcResizeLayout);
    AppendMetric(Builder, ASnapshot, upcResizeRealign);
    AppendMetric(Builder, ASnapshot, upcResizeVisibleRange);
    AppendMetric(Builder, ASnapshot, upcResizeGeometry);
    Builder.AppendLine('');
    Builder.AppendLine('Search/Filter');
    Builder.AppendLine(Format('  Search rebuilds: %d', [ASnapshot.SearchRebuilds]));
    Builder.AppendLine(Format('  Search items scanned: %d', [ASnapshot.SearchItemsScanned]));
    Builder.AppendLine(Format('  Search result count: %d', [ASnapshot.SearchResultCount]));
    Builder.AppendLine(Format('  Filter rebuilds: %d', [ASnapshot.FilterRebuilds]));
    Builder.AppendLine(Format('  Filter items scanned: %d', [ASnapshot.FilterItemsScanned]));
    Builder.AppendLine(Format('  Filter result count: %d', [ASnapshot.FilterResultCount]));
    AppendMetric(Builder, ASnapshot, upcSearchRebuild);
    AppendMetric(Builder, ASnapshot, upcFilterRebuild);
    Builder.AppendLine('');
    Builder.AppendLine('Popup/Lookup');
    AppendMetric(Builder, ASnapshot, upcPopupOpen);
    AppendMetric(Builder, ASnapshot, upcPopupLayout);
    AppendMetric(Builder, ASnapshot, upcPopupPaint);
    AppendMetric(Builder, ASnapshot, upcPopupResize);
    AppendMetric(Builder, ASnapshot, upcLookupPaint);
    AppendMetric(Builder, ASnapshot, upcLookupSearchLatency);
    Builder.AppendLine('');
    Builder.AppendLine('Invalidation');
    Builder.AppendLine(Format('  Repaint requests: %d', [ASnapshot.RepaintRequests]));
    Builder.AppendLine(Format('  Realign requests: %d', [ASnapshot.RealignRequests]));
    Builder.AppendLine(Format('  Full rebuild requests: %d', [ASnapshot.FullRebuildRequests]));
    AppendMetric(Builder, ASnapshot, upcRequestRepaint);
    AppendMetric(Builder, ASnapshot, upcRequestRealign);
    AppendMetric(Builder, ASnapshot, upcFullRebuild);
    Builder.AppendLine('');
    Builder.AppendLine('Cache');
    Builder.AppendLine('  RowHeight cache: no cache in current implementation');
    Builder.AppendLine('  CardHeight cache: existing item-height arrays measured via calculate counters');
    Builder.AppendLine('  VisibleRange cache: no cache in current implementation');
    Result := Builder.ToString;
  finally
    Builder.Free;
  end;
end;

procedure UniPerfSetContext(const ATotalItems, AVisibleItems: Integer);
begin
{$IFDEF UNILIST_PROFILE}
  GSnapshot.TotalItems := ATotalItems;
  GSnapshot.VisibleItems := AVisibleItems;
{$ENDIF}
end;

procedure UniPerfSetLastPaint(const AScannedItems, ADrawnItems: Int64;
  const AVisibleItems: Integer);
begin
{$IFDEF UNILIST_PROFILE}
  GSnapshot.LastPaintScannedItems := AScannedItems;
  GSnapshot.LastPaintDrawnItems := ADrawnItems;
  GSnapshot.LastPaintVisibleItems := AVisibleItems;
  Inc(GSnapshot.ItemsScanned, AScannedItems);
{$ENDIF}
end;

procedure UniPerfSetViewMode(const AViewMode: string);
begin
{$IFDEF UNILIST_PROFILE}
  GSnapshot.ViewMode := AViewMode;
{$ENDIF}
end;

procedure UniPerfAdd(const ACounter: TUniPerfCounter; const ATicks: Int64);
begin
{$IFDEF UNILIST_PROFILE}
  AddMetric(GSnapshot.Metrics[ACounter], ATicks);
{$ENDIF}
end;

procedure UniPerfInc(const ACounter: TUniPerfCounter; const AValue: Int64);
begin
{$IFDEF UNILIST_PROFILE}
  case ACounter of
    upcDrawRow: Inc(GSnapshot.RowsDrawn, AValue);
    upcDrawCard: Inc(GSnapshot.CardsDrawn, AValue);
    upcDrawTreeNode: Inc(GSnapshot.TreeNodesDrawn, AValue);
    upcHitTest: Inc(GSnapshot.HitTests, AValue);
    upcMouseMove: Inc(GSnapshot.MouseMoveCalls, AValue);
    upcScroll: Inc(GSnapshot.ScrollEvents, AValue);
    upcResize: Inc(GSnapshot.ResizeCalls, AValue);
    upcMeasureText: Inc(GSnapshot.TextMeasureCalls, AValue);
    upcCanvasMeasureText: Inc(GSnapshot.TextMeasureCalls, AValue);
    upcCanvasFillText: Inc(GSnapshot.FillTextCalls, AValue);
    upcCreateTextLayout: Inc(GSnapshot.TextLayoutsCreated, AValue);
    upcReuseTextLayout: Inc(GSnapshot.TextLayoutsReused, AValue);
    upcCalculateRowHeight: Inc(GSnapshot.RowHeightCalculations, AValue);
    upcCalculateCardHeight: Inc(GSnapshot.CardHeightCalculations, AValue);
    upcSearchRebuild: Inc(GSnapshot.SearchRebuilds, AValue);
    upcFilterRebuild: Inc(GSnapshot.FilterRebuilds, AValue);
    upcRequestRepaint: Inc(GSnapshot.RepaintRequests, AValue);
    upcRequestRealign: Inc(GSnapshot.RealignRequests, AValue);
    upcFullRebuild: Inc(GSnapshot.FullRebuildRequests, AValue);
    upcVisibleRange,
    upcVisibleRangeList,
    upcVisibleRangeCards,
    upcVisibleRangeTree,
    upcVisibleRangeHitTest,
    upcVisibleRangeScroll,
    upcVisibleRangeResize: Inc(GSnapshot.VisibleRangeCalculations, AValue);
    upcGeometryRowBounds,
    upcGeometryCardBounds,
    upcGeometryColumnBounds,
    upcGeometryHitRect,
    upcGeometrySelectionRect,
    upcGeometryCheckBoxRect,
    upcGeometryIconRect: Inc(GSnapshot.GeometryCalculations, AValue);
  end;
{$ENDIF}
end;

procedure UniPerfAddItemsScanned(const AValue: Int64);
begin
{$IFDEF UNILIST_PROFILE}
  Inc(GSnapshot.ItemsScanned, AValue);
{$ENDIF}
end;

procedure UniPerfAddVisibleRangeItemsExamined(const AValue: Int64);
begin
{$IFDEF UNILIST_PROFILE}
  Inc(GSnapshot.VisibleRangeItemsExamined, AValue);
{$ENDIF}
end;

procedure UniPerfSetSearchResultCount(const AValue: Int64);
begin
{$IFDEF UNILIST_PROFILE}
  GSnapshot.SearchResultCount := AValue;
{$ENDIF}
end;

procedure UniPerfSetFilterResultCount(const AValue: Int64);
begin
{$IFDEF UNILIST_PROFILE}
  GSnapshot.FilterResultCount := AValue;
{$ENDIF}
end;

procedure UniPerfAddHoverChanged;
begin
{$IFDEF UNILIST_PROFILE}
  Inc(GSnapshot.HoverChangedCount);
{$ENDIF}
end;

procedure UniPerfAddHoverUnchanged;
begin
{$IFDEF UNILIST_PROFILE}
  Inc(GSnapshot.HoverUnchangedCount);
{$ENDIF}
end;

procedure UniPerfAddHoverRepaint;
begin
{$IFDEF UNILIST_PROFILE}
  Inc(GSnapshot.HoverRepaintCount);
{$ENDIF}
end;

initialization
  UniPerfReset;

end.