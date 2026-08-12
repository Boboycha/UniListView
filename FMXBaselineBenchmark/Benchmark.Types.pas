unit Benchmark.Types;

interface

type
  TBenchmarkTestId = (
    btiEmpty,
    btiPaintBox,
    btiFillRect,
    btiFillText,
    btiBitmap,
    btiCombined,
    btiControls,
    btiScrollBox,
    btiListView,
    btiUniList,
    btiUniCards,
    btiUniTree);

  TBenchmarkScenario = (
    bscIdle,
    bscMouseMove,
    bscForcedRepaint,
    bscScroll,
    bscResize,
    bscSelection);

  TBenchmarkSamplingMode = (
    bsmEventDriven,
    bsmTimerProbe);

  TBenchmarkMetric = record
    Count: Int64;
    LastMs: Double;
    TotalMs: Double;
    MaxMs: Double;
    procedure Reset;
    procedure Add(const AValueMs: Double);
    function AverageMs: Double;
  end;

  TBenchmarkSnapshot = record
    Running: Boolean;
    TestId: TBenchmarkTestId;
    TestName: string;
    Scenario: TBenchmarkScenario;
    SamplingMode: TBenchmarkSamplingMode;
    SamplingPoint: string;
    WhatIsMeasured: string;
    WhatIsNotMeasured: string;
    SessionDurationMs: Double;
    SampleCount: Int64;
    TimerProbeCount: Int64;
    LastFrameMs: Double;
    AverageFrameMs: Double;
    MedianFrameMs: Double;
    P95FrameMs: Double;
    P99FrameMs: Double;
    MaxFrameMs: Double;
    AverageFps: Double;
    MinimumFps: Double;
    OnePercentLowFps: Double;
    Slow16Count: Int64;
    Slow33Count: Int64;
    Slow50Count: Int64;
    Slow100Count: Int64;
    RequestedFrames: Int64;
    CompletedPaints: Int64;
    DroppedRequests: Int64;
    Paint: TBenchmarkMetric;
    TimerProbeInterval: TBenchmarkMetric;
    InputToPaint: TBenchmarkMetric;
    Load: TBenchmarkMetric;
    Scale: Single;
    WindowState: string;
    Workload: string;
    VisibleWorkload: string;
    Environment: string;
    SelfTestReport: string;
  end;

const
  CBenchmarkSampleCapacity = 2048;
  CBenchmarkTimerProbeMs = 16;
  CBenchmarkNormalWidth = 1280;
  CBenchmarkNormalHeight = 800;
  CBenchmarkSlow16Ms = 16.67;
  CBenchmarkSlow33Ms = 33.33;
  CBenchmarkSlow50Ms = 50.0;
  CBenchmarkSevereMs = 100.0;

function BenchmarkTestName(const ATestId: TBenchmarkTestId): string;
function BenchmarkScenarioName(const AScenario: TBenchmarkScenario): string;
function BenchmarkSamplingModeName(const AMode: TBenchmarkSamplingMode): string;

implementation

procedure TBenchmarkMetric.Reset;
begin
  Self := Default(TBenchmarkMetric);
end;

procedure TBenchmarkMetric.Add(const AValueMs: Double);
begin
  Inc(Count);
  LastMs := AValueMs;
  TotalMs := TotalMs + AValueMs;
  if AValueMs > MaxMs then
    MaxMs := AValueMs;
end;

function TBenchmarkMetric.AverageMs: Double;
begin
  if Count <= 0 then
    Exit(0);
  Result := TotalMs / Count;
end;

function BenchmarkTestName(const ATestId: TBenchmarkTestId): string;
begin
  case ATestId of
    btiEmpty: Result := 'Empty Form';
    btiPaintBox: Result := 'Empty PaintBox';
    btiFillRect: Result := 'Canvas FillRect';
    btiFillText: Result := 'Canvas Text';
    btiBitmap: Result := 'Canvas Bitmap';
    btiCombined: Result := 'Combined Custom Paint';
    btiControls: Result := 'Standard Controls';
    btiScrollBox: Result := 'TVertScrollBox';
    btiListView: Result := 'Standard FMX TListView';
    btiUniList: Result := 'UniListView List';
    btiUniCards: Result := 'UniListView Cards';
    btiUniTree: Result := 'UniListView Tree';
  else
    Result := 'Unknown';
  end;
end;

function BenchmarkScenarioName(const AScenario: TBenchmarkScenario): string;
begin
  case AScenario of
    bscIdle: Result := 'Idle';
    bscMouseMove: Result := 'Mouse move';
    bscForcedRepaint: Result := 'Forced repaint';
    bscScroll: Result := 'Scroll';
    bscResize: Result := 'Resize';
    bscSelection: Result := 'Selection';
  else
    Result := 'Unknown';
  end;
end;

function BenchmarkSamplingModeName(const AMode: TBenchmarkSamplingMode): string;
begin
  case AMode of
    bsmEventDriven: Result := 'Event Driven';
    bsmTimerProbe: Result := 'Independent Timer Probe';
  else
    Result := 'Unknown';
  end;
end;

end.
