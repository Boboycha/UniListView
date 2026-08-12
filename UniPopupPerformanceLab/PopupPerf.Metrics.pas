unit PopupPerf.Metrics;

interface

uses
  System.Classes, System.Diagnostics;

const
  CPopupPerfSampleCapacity = 4096;
  CPopupPerfStall33Ms = 33.0;
  CPopupPerfStall100Ms = 100.0;

type
  TPopupPerfSnapshot = record
    Running: Boolean;
    DurationMs: Double;
    MarkerUpdates: Int64;
    MarkerAverageMs: Double;
    MarkerP95Ms: Double;
    MarkerMaxMs: Double;
    MarkerStalls33: Int64;
    MarkerStalls100: Int64;
    TestPaintCalls: Int64;
    PopupContentPaintCalls: Int64;
    TestRealignCalls: Int64;
    PopupContentRealignCalls: Int64;
    PopupOpenCount: Int64;
    PopupOpenTotalMs: Double;
    PopupOpenMaxMs: Double;
    PopupCloseCount: Int64;
    PopupCloseTotalMs: Double;
    PopupCloseMaxMs: Double;
  end;

  TPopupPerfMetrics = class
  private
    FRunning: Boolean;
    FStartTicks: Int64;
    FStopTicks: Int64;
    FLastMarkerTicks: Int64;
    FMarkerUpdates: Int64;
    FMarkerTotalMs: Double;
    FMarkerMaxMs: Double;
    FMarkerStalls33: Int64;
    FMarkerStalls100: Int64;
    FSamples: array[0..CPopupPerfSampleCapacity - 1] of Double;
    FSampleCount: Integer;
    FSampleIndex: Integer;
    FTestPaintCalls: Int64;
    FPopupContentPaintCalls: Int64;
    FTestRealignCalls: Int64;
    FPopupContentRealignCalls: Int64;
    FPopupOpenCount: Int64;
    FPopupOpenTotalMs: Double;
    FPopupOpenMaxMs: Double;
    FPopupCloseCount: Int64;
    FPopupCloseTotalMs: Double;
    FPopupCloseMaxMs: Double;
    function ElapsedMs: Double;
    function MarkerP95Ms: Double;
  public
    procedure Reset;
    procedure Start;
    procedure Stop;
    procedure RecordMarkerUpdate;
    procedure RecordTestPaint;
    procedure RecordPopupContentPaint;
    procedure RecordTestRealign;
    procedure RecordPopupContentRealign;
    procedure RecordPopupOpen(const AElapsedMs: Double);
    procedure RecordPopupClose(const AElapsedMs: Double);
    function Snapshot: TPopupPerfSnapshot;
    function Report(const ATestMode, APopupState, APopupContent,
      AVisibilityState, AUniListMetrics: string): string;
  end;

procedure PopupPerfSetMetrics(const AMetrics: TPopupPerfMetrics);
procedure PopupPerfRecordTestPaint;
procedure PopupPerfRecordPopupContentPaint;
procedure PopupPerfRecordTestRealign;
procedure PopupPerfRecordPopupContentRealign;

implementation

uses
  System.SysUtils, System.Math, System.Generics.Collections;

var
  GMetrics: TPopupPerfMetrics;

function TicksToMs(const ATicks: Int64): Double;
begin
  Result := ATicks * 1000.0 / TStopwatch.Frequency;
end;

procedure PopupPerfSetMetrics(const AMetrics: TPopupPerfMetrics);
begin
  GMetrics := AMetrics;
end;

procedure PopupPerfRecordTestPaint;
begin
  if GMetrics <> nil then
    GMetrics.RecordTestPaint;
end;

procedure PopupPerfRecordPopupContentPaint;
begin
  if GMetrics <> nil then
    GMetrics.RecordPopupContentPaint;
end;

procedure PopupPerfRecordTestRealign;
begin
  if GMetrics <> nil then
    GMetrics.RecordTestRealign;
end;

procedure PopupPerfRecordPopupContentRealign;
begin
  if GMetrics <> nil then
    GMetrics.RecordPopupContentRealign;
end;

procedure TPopupPerfMetrics.Reset;
begin
  FRunning := False;
  FStartTicks := 0;
  FStopTicks := 0;
  FLastMarkerTicks := 0;
  FMarkerUpdates := 0;
  FMarkerTotalMs := 0;
  FMarkerMaxMs := 0;
  FMarkerStalls33 := 0;
  FMarkerStalls100 := 0;
  FSampleCount := 0;
  FSampleIndex := 0;
  FTestPaintCalls := 0;
  FPopupContentPaintCalls := 0;
  FTestRealignCalls := 0;
  FPopupContentRealignCalls := 0;
  FPopupOpenCount := 0;
  FPopupOpenTotalMs := 0;
  FPopupOpenMaxMs := 0;
  FPopupCloseCount := 0;
  FPopupCloseTotalMs := 0;
  FPopupCloseMaxMs := 0;
end;

procedure TPopupPerfMetrics.Start;
begin
  Reset;
  FRunning := True;
  FStartTicks := TStopwatch.GetTimeStamp;
  FLastMarkerTicks := FStartTicks;
end;

procedure TPopupPerfMetrics.Stop;
begin
  if not FRunning then
    Exit;
  FStopTicks := TStopwatch.GetTimeStamp;
  FRunning := False;
end;

procedure TPopupPerfMetrics.RecordMarkerUpdate;
var
  CurrentTicks: Int64;
  IntervalMs: Double;
begin
  if not FRunning then
    Exit;
  CurrentTicks := TStopwatch.GetTimeStamp;
  if FLastMarkerTicks > 0 then
  begin
    IntervalMs := TicksToMs(CurrentTicks - FLastMarkerTicks);
    Inc(FMarkerUpdates);
    FMarkerTotalMs := FMarkerTotalMs + IntervalMs;
    if IntervalMs > FMarkerMaxMs then
      FMarkerMaxMs := IntervalMs;
    if IntervalMs > CPopupPerfStall33Ms then
      Inc(FMarkerStalls33);
    if IntervalMs > CPopupPerfStall100Ms then
      Inc(FMarkerStalls100);
    FSamples[FSampleIndex] := IntervalMs;
    FSampleIndex := (FSampleIndex + 1) mod CPopupPerfSampleCapacity;
    if FSampleCount < CPopupPerfSampleCapacity then
      Inc(FSampleCount);
  end;
  FLastMarkerTicks := CurrentTicks;
end;

procedure TPopupPerfMetrics.RecordTestPaint;
begin
  if FRunning then
    Inc(FTestPaintCalls);
end;

procedure TPopupPerfMetrics.RecordPopupContentPaint;
begin
  if FRunning then
    Inc(FPopupContentPaintCalls);
end;

procedure TPopupPerfMetrics.RecordTestRealign;
begin
  if FRunning then
    Inc(FTestRealignCalls);
end;

procedure TPopupPerfMetrics.RecordPopupContentRealign;
begin
  if FRunning then
    Inc(FPopupContentRealignCalls);
end;

procedure TPopupPerfMetrics.RecordPopupOpen(const AElapsedMs: Double);
begin
  if not FRunning then
    Exit;
  Inc(FPopupOpenCount);
  FPopupOpenTotalMs := FPopupOpenTotalMs + AElapsedMs;
  if AElapsedMs > FPopupOpenMaxMs then
    FPopupOpenMaxMs := AElapsedMs;
end;

procedure TPopupPerfMetrics.RecordPopupClose(const AElapsedMs: Double);
begin
  if not FRunning then
    Exit;
  Inc(FPopupCloseCount);
  FPopupCloseTotalMs := FPopupCloseTotalMs + AElapsedMs;
  if AElapsedMs > FPopupCloseMaxMs then
    FPopupCloseMaxMs := AElapsedMs;
end;

function TPopupPerfMetrics.ElapsedMs: Double;
var
  EndTicks: Int64;
begin
  if FStartTicks <= 0 then
    Exit(0);
  if FRunning then
    EndTicks := TStopwatch.GetTimeStamp
  else
    EndTicks := FStopTicks;
  Result := TicksToMs(EndTicks - FStartTicks);
end;

function TPopupPerfMetrics.MarkerP95Ms: Double;
var
  Values: TArray<Double>;
  Index: Integer;
begin
  Result := 0;
  if FSampleCount <= 0 then
    Exit;
  SetLength(Values, FSampleCount);
  for Index := 0 to FSampleCount - 1 do
    Values[Index] := FSamples[Index];
  TArray.Sort<Double>(Values);
  Index := Ceil(Length(Values) * 0.95) - 1;
  Result := Values[EnsureRange(Index, 0, Length(Values) - 1)];
end;

function TPopupPerfMetrics.Snapshot: TPopupPerfSnapshot;
begin
  Result := Default(TPopupPerfSnapshot);
  Result.Running := FRunning;
  Result.DurationMs := ElapsedMs;
  Result.MarkerUpdates := FMarkerUpdates;
  if FMarkerUpdates > 0 then
    Result.MarkerAverageMs := FMarkerTotalMs / FMarkerUpdates;
  Result.MarkerP95Ms := MarkerP95Ms;
  Result.MarkerMaxMs := FMarkerMaxMs;
  Result.MarkerStalls33 := FMarkerStalls33;
  Result.MarkerStalls100 := FMarkerStalls100;
  Result.TestPaintCalls := FTestPaintCalls;
  Result.PopupContentPaintCalls := FPopupContentPaintCalls;
  Result.TestRealignCalls := FTestRealignCalls;
  Result.PopupContentRealignCalls := FPopupContentRealignCalls;
  Result.PopupOpenCount := FPopupOpenCount;
  Result.PopupOpenTotalMs := FPopupOpenTotalMs;
  Result.PopupOpenMaxMs := FPopupOpenMaxMs;
  Result.PopupCloseCount := FPopupCloseCount;
  Result.PopupCloseTotalMs := FPopupCloseTotalMs;
  Result.PopupCloseMaxMs := FPopupCloseMaxMs;
end;

function AverageMs(const ATotalMs: Double; const ACount: Int64): Double;
begin
  if ACount <= 0 then
    Exit(0);
  Result := ATotalMs / ACount;
end;

function TPopupPerfMetrics.Report(const ATestMode, APopupState,
  APopupContent, AVisibilityState, AUniListMetrics: string): string;
var
  Data: TPopupPerfSnapshot;
  Builder: TStringBuilder;
begin
  Data := Snapshot;
  Builder := TStringBuilder.Create;
  try
    Builder.AppendLine('UniPopup Performance Lab');
    Builder.AppendLine('Test mode: ' + ATestMode);
    Builder.AppendLine('Popup state: ' + APopupState);
    Builder.AppendLine('Popup content: ' + APopupContent);
    Builder.AppendLine('Runtime state: ' + AVisibilityState);
    Builder.AppendLine(Format('Running: %s', [BoolToStr(Data.Running, True)]));
    Builder.AppendLine(Format('Duration: %.3f s', [Data.DurationMs / 1000.0]));
    Builder.AppendLine;
    Builder.AppendLine('Marker');
    Builder.AppendLine(Format('  Updates: %d', [Data.MarkerUpdates]));
    Builder.AppendLine(Format('  Average interval: %.3f ms', [Data.MarkerAverageMs]));
    Builder.AppendLine(Format('  P95 interval: %.3f ms', [Data.MarkerP95Ms]));
    Builder.AppendLine(Format('  Max interval: %.3f ms', [Data.MarkerMaxMs]));
    Builder.AppendLine(Format('  Stalls >33 ms: %d', [Data.MarkerStalls33]));
    Builder.AppendLine(Format('  Stalls >100 ms: %d', [Data.MarkerStalls100]));
    Builder.AppendLine;
    Builder.AppendLine('Observable component activity');
    Builder.AppendLine(Format('  Test component Paint calls: %d', [Data.TestPaintCalls]));
    Builder.AppendLine(Format('  Popup content Paint calls: %d', [Data.PopupContentPaintCalls]));
    Builder.AppendLine(Format('  Test component DoRealign calls: %d', [Data.TestRealignCalls]));
    Builder.AppendLine(Format('  Popup content DoRealign calls: %d', [Data.PopupContentRealignCalls]));
    Builder.AppendLine('  General FMX Repaint requests: N/A - Repaint is not virtual');
    Builder.AppendLine('  General FMX Realign requests: N/A - no request hook');
    Builder.AppendLine('  Popup bounds calculations: N/A - PopupHost.PositionPopup is private');
    Builder.AppendLine;
    Builder.AppendLine('Popup operations');
    Builder.AppendLine(Format('  Open: Count=%d Avg=%.3f ms Max=%.3f ms',
      [Data.PopupOpenCount, AverageMs(Data.PopupOpenTotalMs,
       Data.PopupOpenCount), Data.PopupOpenMaxMs]));
    Builder.AppendLine(Format('  Close: Count=%d Avg=%.3f ms Max=%.3f ms',
      [Data.PopupCloseCount, AverageMs(Data.PopupCloseTotalMs,
       Data.PopupCloseCount), Data.PopupCloseMaxMs]));
    if AUniListMetrics <> '' then
    begin
      Builder.AppendLine;
      Builder.AppendLine('Existing TUniListView counters');
      Builder.AppendLine(AUniListMetrics);
    end;
    Result := Builder.ToString;
  finally
    Builder.Free;
  end;
end;

end.