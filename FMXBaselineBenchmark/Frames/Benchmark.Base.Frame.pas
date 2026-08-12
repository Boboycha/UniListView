unit Benchmark.Base.Frame;

interface

uses
  System.Classes, System.Diagnostics, System.Types, FMX.Types, FMX.Controls, FMX.Forms,
  FMX.Graphics, FMX.Layouts, FMX.Objects,
  Benchmark.Types, Benchmark.Profiler;

type
  TBenchmarkBaseFrame = class(TFrame)
  private
    FProfiler: TBenchmarkProfiler;
    FTestId: TBenchmarkTestId;
    FScenario: TBenchmarkScenario;
    FSamplingMode: TBenchmarkSamplingMode;
    FScaleValue: Single;
    FWindowStateName: string;
    FRootLayout: TLayout;
    FSampler: TPaintBox;
    FForcedRepaintTimer: TTimer;
    procedure SamplerPaint(Sender: TObject; Canvas: TCanvas);
    procedure SamplerMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure ForcedRepaintTimerTick(Sender: TObject);
  protected
    function PaintSurface: TPaintBox; virtual;
    procedure PaintWorkload(Canvas: TCanvas; const ARect: TRectF); virtual;
    procedure BuildContent; virtual;
    function WorkloadText: string; virtual;
    function VisibleWorkloadText: string; virtual;
    procedure ApplyScale; virtual;
    procedure MarkBenchmarkInput;
    procedure RequestBenchmarkFrame;
    property Profiler: TBenchmarkProfiler read FProfiler;
    property BenchmarkScale: Single read FScaleValue;
  public
    constructor CreateBenchmark(AOwner: TComponent;
      const AProfiler: TBenchmarkProfiler); virtual;
    destructor Destroy; override;
    procedure Prepare(const AScale: Single; const AWindowStateName: string); virtual;
    procedure Start(const AScenario: TBenchmarkScenario;
      const AMode: TBenchmarkSamplingMode); virtual;
    procedure Stop; virtual;
    property TestId: TBenchmarkTestId read FTestId write FTestId;
  end;

implementation

uses
  System.SysUtils;

constructor TBenchmarkBaseFrame.CreateBenchmark(AOwner: TComponent;
  const AProfiler: TBenchmarkProfiler);
begin
  inherited Create(AOwner);
  FProfiler := AProfiler;
  TagObject := AProfiler;
  FScenario := bscIdle;
  FSamplingMode := bsmEventDriven;
  FScaleValue := 1.0;
  FWindowStateName := 'Normal';
  Align := TAlignLayout.Client;
  FRootLayout := TLayout.Create(Self);
  FRootLayout.Parent := Self;
  FRootLayout.Align := TAlignLayout.Client;
  FSampler := TPaintBox.Create(Self);
  FSampler.Parent := FRootLayout;
  FSampler.Align := TAlignLayout.Client;
  FSampler.OnPaint := SamplerPaint;
  FSampler.HitTest := True;
  FSampler.OnMouseMove := SamplerMouseMove;
  FForcedRepaintTimer := TTimer.Create(Self);
  FForcedRepaintTimer.Interval := CBenchmarkTimerProbeMs;
  FForcedRepaintTimer.OnTimer := ForcedRepaintTimerTick;
end;

destructor TBenchmarkBaseFrame.Destroy;
begin
  FForcedRepaintTimer.Enabled := False;
  inherited;
end;

function TBenchmarkBaseFrame.PaintSurface: TPaintBox;
begin
  Result := FSampler;
end;

procedure TBenchmarkBaseFrame.Prepare(const AScale: Single;
  const AWindowStateName: string);
begin
  FScaleValue := AScale;
  FWindowStateName := AWindowStateName;
  FForcedRepaintTimer.Enabled := False;
  BuildContent;
  ApplyScale;
  if FProfiler <> nil then
    FProfiler.SetContext(FScaleValue, FWindowStateName, WorkloadText,
      VisibleWorkloadText, '');
end;

procedure TBenchmarkBaseFrame.ApplyScale;
begin
  FRootLayout.Scale.X := FScaleValue;
  FRootLayout.Scale.Y := FScaleValue;
end;

procedure TBenchmarkBaseFrame.MarkBenchmarkInput;
begin
  if FProfiler <> nil then
    FProfiler.MarkInput;
end;

procedure TBenchmarkBaseFrame.RequestBenchmarkFrame;
begin
  if FProfiler <> nil then
    FProfiler.RequestFrame;
  if FSampler <> nil then
    FSampler.Repaint;
end;

procedure TBenchmarkBaseFrame.BuildContent;
begin
end;

function TBenchmarkBaseFrame.WorkloadText: string;
begin
  Result := BenchmarkTestName(FTestId);
end;

function TBenchmarkBaseFrame.VisibleWorkloadText: string;
begin
  Result := 'single test surface';
end;

procedure TBenchmarkBaseFrame.Start(const AScenario: TBenchmarkScenario;
  const AMode: TBenchmarkSamplingMode);
begin
  FScenario := AScenario;
  FSamplingMode := AMode;
  if FProfiler <> nil then
    FProfiler.StartSession(FTestId, AScenario, AMode);
  FForcedRepaintTimer.Enabled := AScenario = bscForcedRepaint;
  Repaint;
end;

procedure TBenchmarkBaseFrame.Stop;
begin
  FForcedRepaintTimer.Enabled := False;
  if FProfiler <> nil then
    FProfiler.StopSession;
end;

procedure TBenchmarkBaseFrame.SamplerMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Single);
begin
  if FProfiler <> nil then
    FProfiler.MarkInput;
end;
procedure TBenchmarkBaseFrame.SamplerPaint(Sender: TObject; Canvas: TCanvas);
var
  StartTicks: Int64;
begin
  StartTicks := 0;
  if FProfiler <> nil then
    StartTicks := FProfiler.BeginPaint;
  PaintWorkload(Canvas, TPaintBox(Sender).LocalRect);
  if FProfiler <> nil then
    FProfiler.EndPaint(StartTicks);
end;

procedure TBenchmarkBaseFrame.ForcedRepaintTimerTick(Sender: TObject);
begin
  if FProfiler <> nil then
    FProfiler.MarkInput;
  Repaint;
end;

procedure TBenchmarkBaseFrame.PaintWorkload(Canvas: TCanvas; const ARect: TRectF);
begin
end;

end.
