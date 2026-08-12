unit Benchmark.Profiler;

interface

uses
  System.Classes, FMX.Types, Benchmark.Types;

type
  TBenchmarkProfiler = class(TComponent)
  private
    FTimer: TTimer;
    FRunning: Boolean;
    FTestId: TBenchmarkTestId;
    FScenario: TBenchmarkScenario;
    FSamplingMode: TBenchmarkSamplingMode;
    FSessionStartTicks: Int64;
    FSessionStopTicks: Int64;
    FLastSampleTicks: Int64;
    FLastProbeTicks: Int64;
    FPendingInputTicks: Int64;
    FSampleCount: Int64;
    FTimerProbeCount: Int64;
    FSamples: array[0..CBenchmarkSampleCapacity - 1] of Double;
    FSampleIndex: Integer;
    FSampleWindowCount: Integer;
    FLastFrameMs: Double;
    FTotalFrameMs: Double;
    FMaxFrameMs: Double;
    FSlow16Count: Int64;
    FSlow33Count: Int64;
    FSlow50Count: Int64;
    FSlow100Count: Int64;
    FRequestedFrames: Int64;
    FCompletedPaints: Int64;
    FPaint: TBenchmarkMetric;
    FTimerProbeInterval: TBenchmarkMetric;
    FInputToPaint: TBenchmarkMetric;
    FLoad: TBenchmarkMetric;
    FScale: Single;
    FWindowState: string;
    FWorkload: string;
    FVisibleWorkload: string;
    FEnvironment: string;
    FSelfTestReport: string;
    procedure TimerTick(Sender: TObject);
    procedure AddFrameInterval(const AFrameMs: Double);
    function Percentile(const APercentile: Double): Double;
    function OnePercentLowFps: Double;
    function ElapsedMs: Double;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Reset;
    procedure StartSession(const ATestId: TBenchmarkTestId;
      const AScenario: TBenchmarkScenario; const AMode: TBenchmarkSamplingMode);
    procedure StopSession;
    function BeginPaint: Int64;
    procedure EndPaint(const AStartTicks: Int64);
    procedure MarkInput;
    procedure AddLoadMs(const AValueMs: Double);
    procedure RequestFrame;
    procedure ReplacePaintMetric(const ACount: Int64; const ALastMs,
      ATotalMs, AMaxMs: Double);
    procedure SetContext(const AScale: Single; const AWindowState,
      AWorkload, AVisibleWorkload, AEnvironment: string);
    procedure RunSelfTest;
    function Snapshot: TBenchmarkSnapshot;
    function Report: string;
  end;

function BenchmarkTicksToMs(const ATicks: Int64): Double;
function BenchmarkNowTicks: Int64;
function BenchmarkFpsFromMs(const AValueMs: Double): Double;

implementation

uses
  System.SysUtils, System.Diagnostics, System.Math, System.Generics.Collections;

function BenchmarkTicksToMs(const ATicks: Int64): Double;
begin
  Result := ATicks * 1000.0 / TStopwatch.Frequency;
end;

function BenchmarkNowTicks: Int64;
begin
  Result := TStopwatch.GetTimeStamp;
end;

function BenchmarkFpsFromMs(const AValueMs: Double): Double;
begin
  if AValueMs <= 0 then
    Exit(0);
  Result := 1000.0 / AValueMs;
end;

constructor TBenchmarkProfiler.Create(AOwner: TComponent);
begin
  inherited;
  FTimer := TTimer.Create(Self);
  FTimer.Interval := CBenchmarkTimerProbeMs;
  FTimer.OnTimer := TimerTick;
  FScale := 1.0;
  FWindowState := 'Normal';
end;

procedure TBenchmarkProfiler.Reset;
begin
  FTimer.Enabled := False;
  FRunning := False;
  FSessionStartTicks := 0;
  FSessionStopTicks := 0;
  FLastSampleTicks := 0;
  FLastProbeTicks := 0;
  FPendingInputTicks := 0;
  FSampleCount := 0;
  FTimerProbeCount := 0;
  FSampleIndex := 0;
  FSampleWindowCount := 0;
  FLastFrameMs := 0;
  FTotalFrameMs := 0;
  FMaxFrameMs := 0;
  FSlow16Count := 0;
  FSlow33Count := 0;
  FSlow50Count := 0;
  FSlow100Count := 0;
  FRequestedFrames := 0;
  FCompletedPaints := 0;
  FPaint.Reset;
  FTimerProbeInterval.Reset;
  FInputToPaint.Reset;
  FLoad.Reset;
end;

procedure TBenchmarkProfiler.SetContext(const AScale: Single;
  const AWindowState, AWorkload, AVisibleWorkload, AEnvironment: string);
begin
  FScale := AScale;
  FWindowState := AWindowState;
  FWorkload := AWorkload;
  FVisibleWorkload := AVisibleWorkload;
  FEnvironment := AEnvironment;
end;

procedure TBenchmarkProfiler.StartSession(const ATestId: TBenchmarkTestId;
  const AScenario: TBenchmarkScenario; const AMode: TBenchmarkSamplingMode);
begin
  Reset;
  FTestId := ATestId;
  FScenario := AScenario;
  FSamplingMode := AMode;
  FRunning := True;
  FSessionStartTicks := BenchmarkNowTicks;
  FLastProbeTicks := FSessionStartTicks;
  FTimer.Enabled := AMode = bsmTimerProbe;
end;

procedure TBenchmarkProfiler.StopSession;
begin
  if not FRunning then
    Exit;
  FSessionStopTicks := BenchmarkNowTicks;
  FRunning := False;
  FTimer.Enabled := False;
end;

function TBenchmarkProfiler.BeginPaint: Int64;
begin
  if not FRunning then
    Exit(0);
  Result := BenchmarkNowTicks;
end;

procedure TBenchmarkProfiler.EndPaint(const AStartTicks: Int64);
var
  CurrentTicks: Int64;
begin
  if not FRunning then
    Exit;
  CurrentTicks := BenchmarkNowTicks;
  if AStartTicks > 0 then
    FPaint.Add(BenchmarkTicksToMs(CurrentTicks - AStartTicks));
  if FPendingInputTicks > 0 then
  begin
    FInputToPaint.Add(BenchmarkTicksToMs(CurrentTicks - FPendingInputTicks));
    FPendingInputTicks := 0;
  end;
  if FLastSampleTicks > 0 then
    AddFrameInterval(BenchmarkTicksToMs(CurrentTicks - FLastSampleTicks));
  FLastSampleTicks := CurrentTicks;
  Inc(FSampleCount);
  Inc(FCompletedPaints);
end;

procedure TBenchmarkProfiler.MarkInput;
begin
  if not FRunning then
    Exit;
  FPendingInputTicks := BenchmarkNowTicks;
end;

procedure TBenchmarkProfiler.AddLoadMs(const AValueMs: Double);
begin
  FLoad.Add(AValueMs);
end;


procedure TBenchmarkProfiler.RequestFrame;
begin
  if FRunning then
    Inc(FRequestedFrames);
end;

procedure TBenchmarkProfiler.ReplacePaintMetric(const ACount: Int64;
  const ALastMs, ATotalMs, AMaxMs: Double);
begin
  FPaint.Count := ACount;
  FPaint.LastMs := ALastMs;
  FPaint.TotalMs := ATotalMs;
  FPaint.MaxMs := AMaxMs;
end;

procedure TBenchmarkProfiler.TimerTick(Sender: TObject);
var
  CurrentTicks: Int64;
begin
  if not FRunning then
    Exit;
  CurrentTicks := BenchmarkNowTicks;
  if FLastProbeTicks > 0 then
    FTimerProbeInterval.Add(BenchmarkTicksToMs(CurrentTicks - FLastProbeTicks));
  FLastProbeTicks := CurrentTicks;
  Inc(FTimerProbeCount);
end;

procedure TBenchmarkProfiler.AddFrameInterval(const AFrameMs: Double);
begin
  FLastFrameMs := AFrameMs;
  FTotalFrameMs := FTotalFrameMs + AFrameMs;
  if AFrameMs > FMaxFrameMs then
    FMaxFrameMs := AFrameMs;
  if AFrameMs > CBenchmarkSlow16Ms then
    Inc(FSlow16Count);
  if AFrameMs > CBenchmarkSlow33Ms then
    Inc(FSlow33Count);
  if AFrameMs > CBenchmarkSlow50Ms then
    Inc(FSlow50Count);
  if AFrameMs > CBenchmarkSevereMs then
    Inc(FSlow100Count);
  FSamples[FSampleIndex] := AFrameMs;
  FSampleIndex := (FSampleIndex + 1) mod CBenchmarkSampleCapacity;
  if FSampleWindowCount < CBenchmarkSampleCapacity then
    Inc(FSampleWindowCount);
end;

function TBenchmarkProfiler.Percentile(const APercentile: Double): Double;
var
  Values: TArray<Double>;
  Index: Integer;
begin
  Result := 0;
  if FSampleWindowCount <= 0 then
    Exit;
  SetLength(Values, FSampleWindowCount);
  for Index := 0 to FSampleWindowCount - 1 do
    Values[Index] := FSamples[Index];
  TArray.Sort<Double>(Values);
  Index := Ceil((APercentile / 100.0) * Length(Values)) - 1;
  if Index < 0 then
    Index := 0
  else if Index >= Length(Values) then
    Index := Length(Values) - 1;
  Result := Values[Index];
end;

function TBenchmarkProfiler.OnePercentLowFps: Double;
var
  Values: TArray<Double>;
  Index, CountValue: Integer;
  TotalMs: Double;
begin
  Result := 0;
  if FSampleWindowCount <= 0 then
    Exit;
  SetLength(Values, FSampleWindowCount);
  for Index := 0 to FSampleWindowCount - 1 do
    Values[Index] := FSamples[Index];
  TArray.Sort<Double>(Values);
  CountValue := Ceil(Length(Values) * 0.01);
  if CountValue < 1 then
    CountValue := 1;
  TotalMs := 0;
  for Index := Length(Values) - CountValue to Length(Values) - 1 do
    TotalMs := TotalMs + Values[Index];
  Result := BenchmarkFpsFromMs(TotalMs / CountValue);
end;

function TBenchmarkProfiler.ElapsedMs: Double;
var
  EndTicks: Int64;
begin
  if FSessionStartTicks <= 0 then
    Exit(0);
  if FRunning then
    EndTicks := BenchmarkNowTicks
  else if FSessionStopTicks > 0 then
    EndTicks := FSessionStopTicks
  else
    EndTicks := FSessionStartTicks;
  Result := BenchmarkTicksToMs(EndTicks - FSessionStartTicks);
end;

procedure TBenchmarkProfiler.RunSelfTest;
var
  Builder: TStringBuilder;
  StartTicks: Int64;
  Durations: array[0..3] of Integer;
  Index: Integer;
  MeasuredMs: Double;
begin
  Durations[0] := 1;
  Durations[1] := 5;
  Durations[2] := 20;
  Durations[3] := 50;
  Builder := TStringBuilder.Create;
  try
    Builder.AppendLine('Profiler Self-Test');
    Builder.AppendLine('  Method: TStopwatch + Sleep intervals');
    for Index := Low(Durations) to High(Durations) do
    begin
      StartTicks := BenchmarkNowTicks;
      TThread.Sleep(Durations[Index]);
      MeasuredMs := BenchmarkTicksToMs(BenchmarkNowTicks - StartTicks);
      Builder.AppendLine(Format('  Sleep %d ms: measured %.3f ms',
        [Durations[Index], MeasuredMs]));
    end;
    FSelfTestReport := Builder.ToString;
  finally
    Builder.Free;
  end;
end;

function TBenchmarkProfiler.Snapshot: TBenchmarkSnapshot;
var
  IntervalCount: Int64;
begin
  Result := Default(TBenchmarkSnapshot);
  Result.Running := FRunning;
  Result.TestId := FTestId;
  Result.TestName := BenchmarkTestName(FTestId);
  Result.Scenario := FScenario;
  Result.SamplingMode := FSamplingMode;
  Result.SamplingPoint := 'Test surface TPaintBox.OnPaint completion';
  Result.WhatIsMeasured := 'FMX paint handler duration and interval between test-surface paint completions';
  Result.WhatIsNotMeasured := 'Actual GPU present, compositor latency, Canvas.EndScene, driver queue';
  Result.SessionDurationMs := ElapsedMs;
  Result.SampleCount := FSampleCount;
  Result.TimerProbeCount := FTimerProbeCount;
  Result.LastFrameMs := FLastFrameMs;
  IntervalCount := FSampleCount - 1;
  if IntervalCount > 0 then
    Result.AverageFrameMs := FTotalFrameMs / IntervalCount;
  Result.MedianFrameMs := Percentile(50);
  Result.P95FrameMs := Percentile(95);
  Result.P99FrameMs := Percentile(99);
  Result.MaxFrameMs := FMaxFrameMs;
  Result.AverageFps := BenchmarkFpsFromMs(Result.AverageFrameMs);
  Result.MinimumFps := BenchmarkFpsFromMs(Result.MaxFrameMs);
  Result.OnePercentLowFps := OnePercentLowFps;
  Result.Slow16Count := FSlow16Count;
  Result.Slow33Count := FSlow33Count;
  Result.Slow50Count := FSlow50Count;
  Result.Slow100Count := FSlow100Count;
  Result.RequestedFrames := FRequestedFrames;
  Result.CompletedPaints := FCompletedPaints;
  Result.DroppedRequests := FRequestedFrames - FCompletedPaints;
  if Result.DroppedRequests < 0 then
    Result.DroppedRequests := 0;
  Result.Paint := FPaint;
  Result.TimerProbeInterval := FTimerProbeInterval;
  Result.InputToPaint := FInputToPaint;
  Result.Load := FLoad;
  Result.Scale := FScale;
  Result.WindowState := FWindowState;
  Result.Workload := FWorkload;
  Result.VisibleWorkload := FVisibleWorkload;
  Result.Environment := FEnvironment;
  Result.SelfTestReport := FSelfTestReport;
end;

function MetricLine(const AName: string; const AMetric: TBenchmarkMetric): string;
begin
  if AMetric.Count <= 0 then
    Exit('  ' + AName + ': N/A - no samples');
  Result := Format('  %s: Calls=%d Last=%.3f ms Avg=%.3f ms Max=%.3f ms',
    [AName, AMetric.Count, AMetric.LastMs, AMetric.AverageMs, AMetric.MaxMs]);
end;

function SlowLine(const AName: string; const ACount, ASamples: Int64): string;
var
  PercentValue: Double;
begin
  PercentValue := 0;
  if ASamples > 0 then
    PercentValue := ACount * 100.0 / ASamples;
  Result := Format('  %s: %d (%.1f%%)', [AName, ACount, PercentValue]);
end;

function TBenchmarkProfiler.Report: string;
var
  Builder: TStringBuilder;
  Data: TBenchmarkSnapshot;
begin
  Data := Snapshot;
  Builder := TStringBuilder.Create;
  try
    Builder.AppendLine('FMX Baseline Benchmark Report');
    Builder.AppendLine('Test');
    Builder.AppendLine('  Test ID: ' + IntToStr(Ord(Data.TestId)));
    Builder.AppendLine('  Test name: ' + Data.TestName);
    Builder.AppendLine('  Scenario: ' + BenchmarkScenarioName(Data.Scenario));
    Builder.AppendLine('  Sampling mode: ' + BenchmarkSamplingModeName(Data.SamplingMode));
    Builder.AppendLine('  Sampling point: ' + Data.SamplingPoint);
    Builder.AppendLine('  What is measured: ' + Data.WhatIsMeasured);
    Builder.AppendLine('  What is not measured: ' + Data.WhatIsNotMeasured);
    Builder.AppendLine('  Actual GPU present measurable: No');
    Builder.AppendLine('  Main Form Paint: N/A - TForm.Paint is not a public FMX hook in this benchmark; test-surface paint is measured instead');
    Builder.AppendLine('  Canvas.FillText/FillRect/EndScene counters: N/A - not instrumented globally; workload-specific paint duration is measured');
    Builder.AppendLine;
    Builder.AppendLine('Environment');
    Builder.AppendLine('  Platform/OS: ' + TOSVersion.ToString);
    Builder.AppendLine('  X11/Wayland: manual field');
    Builder.AppendLine('  VM/Physical: manual field');
    Builder.AppendLine('  Renderer: manual field');
    Builder.AppendLine('  Software rendering: manual field');
    Builder.AppendLine('  Build: see project configuration');
    Builder.AppendLine('  Scale: ' + FormatFloat('0.00', Data.Scale));
    Builder.AppendLine('  Window state: ' + Data.WindowState);
    Builder.AppendLine('  Workload: ' + Data.Workload);
    Builder.AppendLine('  Visible workload: ' + Data.VisibleWorkload);
    if Data.Environment <> '' then
      Builder.AppendLine(Data.Environment);
    Builder.AppendLine;
    Builder.AppendLine('Session');
    Builder.AppendLine(Format('  Running: %s', [BoolToStr(Data.Running, True)]));
    Builder.AppendLine(Format('  Session duration: %.3f s', [Data.SessionDurationMs / 1000.0]));
    Builder.AppendLine(Format('  Samples: %d', [Data.SampleCount]));
    Builder.AppendLine(Format('  Timer probe samples: %d', [Data.TimerProbeCount]));
    Builder.AppendLine(Format('  Requested frames: %d', [Data.RequestedFrames]));
    Builder.AppendLine(Format('  Completed paints: %d', [Data.CompletedPaints]));
    Builder.AppendLine(Format('  Dropped requests: %d', [Data.DroppedRequests]));
    Builder.AppendLine;
    Builder.AppendLine('Frame Metrics');
    Builder.AppendLine(Format('  FPS average: %.1f', [Data.AverageFps]));
    Builder.AppendLine(Format('  FPS minimum: %.1f', [Data.MinimumFps]));
    Builder.AppendLine(Format('  FPS 1%% low: %.1f', [Data.OnePercentLowFps]));
    Builder.AppendLine(Format('  Frame interval last: %.3f ms', [Data.LastFrameMs]));
    Builder.AppendLine(Format('  Frame interval average: %.3f ms', [Data.AverageFrameMs]));
    Builder.AppendLine(Format('  Frame interval median: %.3f ms', [Data.MedianFrameMs]));
    Builder.AppendLine(Format('  Frame interval P95: %.3f ms', [Data.P95FrameMs]));
    Builder.AppendLine(Format('  Frame interval P99: %.3f ms', [Data.P99FrameMs]));
    Builder.AppendLine(Format('  Frame interval max: %.3f ms', [Data.MaxFrameMs]));
    Builder.AppendLine(SlowLine('Frames >16.67 ms', Data.Slow16Count, Data.SampleCount));
    Builder.AppendLine(SlowLine('Frames >33.33 ms', Data.Slow33Count, Data.SampleCount));
    Builder.AppendLine(SlowLine('Frames >50 ms', Data.Slow50Count, Data.SampleCount));
    Builder.AppendLine(SlowLine('Frames >100 ms', Data.Slow100Count, Data.SampleCount));
    Builder.AppendLine;
    Builder.AppendLine('Cost Metrics');
    Builder.AppendLine(MetricLine('Paint', Data.Paint));
    Builder.AppendLine(MetricLine('Input-to-paint', Data.InputToPaint));
    Builder.AppendLine(MetricLine('Timer probe interval', Data.TimerProbeInterval));
    Builder.AppendLine(MetricLine('Load', Data.Load));
    Builder.AppendLine;
    if Data.SelfTestReport <> '' then
      Builder.AppendLine(Data.SelfTestReport);
    Builder.AppendLine('Decision Matrix Template');
    Builder.AppendLine('| Test | Windows | Ubuntu VM | Debian Physical |');
    Builder.AppendLine('|---|---:|---:|---:|');
    Builder.AppendLine('| Empty Form | | | |');
    Builder.AppendLine('| Empty PaintBox | | | |');
    Builder.AppendLine('| FillRect 100 | | | |');
    Builder.AppendLine('| FillText 300 | | | |');
    Builder.AppendLine('| DrawBitmap 100 | | | |');
    Builder.AppendLine('| Combined PaintBox | | | |');
    Builder.AppendLine('| 100 Labels | | | |');
    Builder.AppendLine('| 100 Cards Controls | | | |');
    Builder.AppendLine('| TVertScrollBox 100 | | | |');
    Builder.AppendLine('| Standard TListView 10k | | | |');
    Builder.AppendLine('| UniListView Cards 10k | import from Showcase | import from Showcase | import from Showcase |');
    Builder.AppendLine;
    Builder.AppendLine('Decision Tree');
    Builder.AppendLine('  Empty Form slow: bottleneck is FMX application loop/scene, UniListView is not primary cause.');
    Builder.AppendLine('  Empty PaintBox slow after fast Empty Form: bottleneck is FMX paint/scene lifecycle.');
    Builder.AppendLine('  PaintBox primitives fast, controls slow: bottleneck is FMX visual tree/layout/style infrastructure.');
    Builder.AppendLine('  Combined PaintBox fast, UniListView slow: bottleneck is UniListView or Showcase integration.');
    Builder.AppendLine('  Standard TListView and UniListView equally slow: bottleneck is FMX list/control infrastructure or scene invalidation.');
    Builder.AppendLine('  UniListView faster than Standard TListView and thresholds pass: UniListView Linux GO.');
    Builder.AppendLine;
    Builder.AppendLine('FINAL DECISION: PENDING - fill three-run Windows/Ubuntu VM/Debian Physical matrix and apply decision tree');
    Result := Builder.ToString;
  finally
    Builder.Free;
  end;
end;

end.
