unit Benchmark.MainForm;

interface

uses
  System.Classes, System.Actions, System.UITypes,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Layouts, FMX.StdCtrls, FMX.Memo,
  FMX.ListBox, FMX.ActnList,
  Benchmark.Types, Benchmark.Profiler, Benchmark.Base.Frame;

type
  TBenchmarkMainForm = class(TForm)
    FActions: TActionList;
    actPrepare: TAction;
    actReset: TAction;
    actStart: TAction;
    actStop: TAction;
    actRefresh: TAction;
    actSave: TAction;
    actSelfTest: TAction;
    FTopBar: TLayout;
    PrepareButton: TButton;
    ResetButton: TButton;
    StartButton: TButton;
    StopButton: TButton;
    RefreshButton: TButton;
    SaveButton: TButton;
    SelfTestButton: TButton;
    FBody: TLayout;
    FLeftPanel: TLayout;
    TestLabel: TLabel;
    FTestCombo: TComboBox;
    WorkloadLabel: TLabel;
    FWorkloadCombo: TComboBox;
    ScenarioLabel: TLabel;
    FScenarioCombo: TComboBox;
    SamplingLabel: TLabel;
    FSamplingCombo: TComboBox;
    ScaleLabel: TLabel;
    FScaleCombo: TComboBox;
    WindowLabel: TLabel;
    FWindowCombo: TComboBox;
    FReportMemo: TMemo;
    FContent: TLayout;
    procedure ActionExecute(Sender: TObject);
  private
    FProfiler: TBenchmarkProfiler;
    FActiveFrame: TBenchmarkBaseFrame;
    FResults: array[TBenchmarkTestId] of TBenchmarkSnapshot;
    FHasResult: array[TBenchmarkTestId] of Boolean;
    procedure BuildUi;
    procedure PrepareTest;
    procedure ResetSession;
    procedure StartSession;
    procedure StopSession;
    procedure RefreshReport;
    procedure SaveReport;
    procedure RunSelfTest;
    function BuildComparisonTable: string;
    function SelectedTestId: TBenchmarkTestId;
    function SelectedScenario: TBenchmarkScenario;
    function SelectedSamplingMode: TBenchmarkSamplingMode;
    function SelectedScale: Single;
    function SelectedWindowState: string;
    function SelectedWorkload: Integer;
    procedure ConfigureFrame(const AFrame: TBenchmarkBaseFrame;
      const ATestId: TBenchmarkTestId);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  BenchmarkMainForm: TBenchmarkMainForm;

implementation

uses
  System.SysUtils, System.IOUtils,
  Benchmark.Empty.Frame, Benchmark.PaintBox.Frame, Benchmark.Canvas.Frame,
  Benchmark.Controls.Frame, Benchmark.ScrollBox.Frame, Benchmark.ListView.Frame,
  Benchmark.UniListView.Frame;

{$R *.fmx}

constructor TBenchmarkMainForm.Create(AOwner: TComponent);
begin
  inherited;
  FProfiler := TBenchmarkProfiler.Create(Self);
  BuildUi;
  PrepareTest;
end;

destructor TBenchmarkMainForm.Destroy;
begin
  FActiveFrame.Free;
  inherited;
end;

procedure AddItems(const ACombo: TComboBox; const AValues: array of string;
  const AIndex: Integer);
var
  Value: string;
begin
  ACombo.Items.Clear;
  for Value in AValues do
    ACombo.Items.Add(Value);
  ACombo.ItemIndex := AIndex;
end;

procedure TBenchmarkMainForm.BuildUi;
begin
  actPrepare.OnExecute := ActionExecute;
  actReset.OnExecute := ActionExecute;
  actStart.OnExecute := ActionExecute;
  actStop.OnExecute := ActionExecute;
  actRefresh.OnExecute := ActionExecute;
  actSave.OnExecute := ActionExecute;
  actSelfTest.OnExecute := ActionExecute;

  AddItems(FTestCombo,
    ['Empty Form', 'Empty PaintBox', 'FillRect', 'FillText', 'DrawBitmap',
     'Combined PaintBox', 'Standard Controls', 'TVertScrollBox',
     'Standard TListView', 'UniListView List', 'UniListView Cards',
     'UniListView Tree'], 0);
  AddItems(FWorkloadCombo,
    ['10', '50', '100', '300', '500', '1000', '10000', '50000'], 2);
  AddItems(FScenarioCombo,
    ['Idle', 'Hover', 'Continuous Repaint', 'Scroll', 'Resize', 'Selection'], 0);
  AddItems(FSamplingCombo, ['Event Driven', 'Timer Probe'], 0);
  AddItems(FScaleCombo, ['1.00', '1.25', '1.50', '2.00'], 0);
  AddItems(FWindowCombo, ['Normal', 'Maximized'], 0);
end;

function TBenchmarkMainForm.SelectedTestId: TBenchmarkTestId;
begin
  Result := TBenchmarkTestId(FTestCombo.ItemIndex);
end;

function TBenchmarkMainForm.SelectedScenario: TBenchmarkScenario;
begin
  Result := TBenchmarkScenario(FScenarioCombo.ItemIndex);
end;

function TBenchmarkMainForm.SelectedSamplingMode: TBenchmarkSamplingMode;
begin
  if FSamplingCombo.ItemIndex = 1 then
    Exit(bsmTimerProbe);
  Result := bsmEventDriven;
end;

function TBenchmarkMainForm.SelectedScale: Single;
begin
  Result := StrToFloatDef(FScaleCombo.Items[FScaleCombo.ItemIndex], 1.0);
end;

function TBenchmarkMainForm.SelectedWindowState: string;
begin
  Result := FWindowCombo.Items[FWindowCombo.ItemIndex];
end;

function TBenchmarkMainForm.SelectedWorkload: Integer;
begin
  Result := StrToIntDef(FWorkloadCombo.Items[FWorkloadCombo.ItemIndex], 100);
end;

procedure TBenchmarkMainForm.ConfigureFrame(const AFrame: TBenchmarkBaseFrame;
  const ATestId: TBenchmarkTestId);
var
  Workload: Integer;
begin
  Workload := SelectedWorkload;
  AFrame.TestId := ATestId;
  if AFrame is TBenchmarkCanvasFrame then
  begin
    case ATestId of
      btiFillRect: TBenchmarkCanvasFrame(AFrame).Configure(bcmFillRect, Workload);
      btiFillText: TBenchmarkCanvasFrame(AFrame).Configure(bcmText, Workload);
      btiBitmap: TBenchmarkCanvasFrame(AFrame).Configure(bcmBitmap, Workload);
      btiCombined: TBenchmarkCanvasFrame(AFrame).Configure(bcmCombined, Workload);
    end;
  end
  else if AFrame is TBenchmarkControlsFrame then
  begin
    if Workload <= 100 then
      TBenchmarkControlsFrame(AFrame).Configure(bcmCards, Workload)
    else if Workload <= 500 then
      TBenchmarkControlsFrame(AFrame).Configure(bcmLabels, Workload)
    else
      TBenchmarkControlsFrame(AFrame).Configure(bcmRectangles, Workload);
  end
  else if AFrame is TBenchmarkScrollBoxFrame then
    TBenchmarkScrollBoxFrame(AFrame).Configure(Workload)
  else if AFrame is TBenchmarkListViewFrame then
    TBenchmarkListViewFrame(AFrame).Configure(Workload)
  else if AFrame is TBenchmarkUniListViewFrame then
    TBenchmarkUniListViewFrame(AFrame).Configure(ATestId, Workload);
end;

procedure TBenchmarkMainForm.PrepareTest;
var
  TestId: TBenchmarkTestId;
begin
  if FActiveFrame <> nil then
    FreeAndNil(FActiveFrame);
  TestId := SelectedTestId;
  case TestId of
    btiEmpty: FActiveFrame := TBenchmarkEmptyFrame.CreateBenchmark(FContent, FProfiler);
    btiPaintBox: FActiveFrame := TBenchmarkPaintBoxFrame.CreateBenchmark(FContent, FProfiler);
    btiFillRect, btiFillText, btiBitmap, btiCombined:
      FActiveFrame := TBenchmarkCanvasFrame.CreateBenchmark(FContent, FProfiler);
    btiControls: FActiveFrame := TBenchmarkControlsFrame.CreateBenchmark(FContent, FProfiler);
    btiScrollBox: FActiveFrame := TBenchmarkScrollBoxFrame.CreateBenchmark(FContent, FProfiler);
    btiListView: FActiveFrame := TBenchmarkListViewFrame.CreateBenchmark(FContent, FProfiler);
    btiUniList, btiUniCards, btiUniTree:
      FActiveFrame := TBenchmarkUniListViewFrame.CreateBenchmark(FContent, FProfiler);
  end;
  FActiveFrame.Parent := FContent;
  ConfigureFrame(FActiveFrame, TestId);
  if SelectedWindowState = 'Maximized' then
    WindowState := TWindowState.wsMaximized
  else
  begin
    WindowState := TWindowState.wsNormal;
    Width := CBenchmarkNormalWidth;
    Height := CBenchmarkNormalHeight;
  end;
  FActiveFrame.Prepare(SelectedScale, SelectedWindowState);
  RefreshReport;
end;

procedure TBenchmarkMainForm.ResetSession;
begin
  FProfiler.Reset;
  RefreshReport;
end;

procedure TBenchmarkMainForm.StartSession;
begin
  if FActiveFrame = nil then
    PrepareTest;
  FActiveFrame.Start(SelectedScenario, SelectedSamplingMode);
  RefreshReport;
end;

procedure TBenchmarkMainForm.StopSession;
begin
  if FActiveFrame <> nil then
  begin
    FActiveFrame.Stop;
    FResults[SelectedTestId] := FProfiler.Snapshot;
    FHasResult[SelectedTestId] := True;
  end;
  RefreshReport;
end;

function TBenchmarkMainForm.BuildComparisonTable: string;
var
  Builder: TStringBuilder;
  TestId: TBenchmarkTestId;
  Data: TBenchmarkSnapshot;
begin
  Builder := TStringBuilder.Create;
  try
    Builder.AppendLine('Automatic Comparison Table');
    Builder.AppendLine('| Test | FPS Avg | FPS 1% Low | Frame P95 | Paint Avg |');
    Builder.AppendLine('|---|---:|---:|---:|---:|');
    for TestId := Low(TBenchmarkTestId) to High(TBenchmarkTestId) do
      if FHasResult[TestId] then
      begin
        Data := FResults[TestId];
        Builder.AppendLine(Format('| %s | %.1f | %.1f | %.3f ms | %.3f ms |',
          [BenchmarkTestName(TestId), Data.AverageFps, Data.OnePercentLowFps,
           Data.P95FrameMs, Data.Paint.AverageMs]));
      end
      else
        Builder.AppendLine(Format('| %s | | | | |', [BenchmarkTestName(TestId)]));
    Result := Builder.ToString;
  finally
    Builder.Free;
  end;
end;

procedure TBenchmarkMainForm.RefreshReport;
begin
  FReportMemo.Text := FProfiler.Report + sLineBreak + BuildComparisonTable;
end;

procedure TBenchmarkMainForm.SaveReport;
var
  FileName, ReportPath, Stamp: string;
begin
  Stamp := FormatDateTime('yyyymmdd-hhnnss', Now);
  FileName := Format('FMXBaselineBenchmark-%s-%s-%s.txt',
    [BenchmarkTestName(SelectedTestId).Replace(' ', '_'),
     BenchmarkScenarioName(SelectedScenario).Replace(' ', '_'), Stamp]);
  ReportPath := TPath.Combine(ExtractFilePath(ParamStr(0)), FileName);
  TFile.WriteAllText(ReportPath, FReportMemo.Text, TEncoding.UTF8);
  Caption := 'FMX Baseline Benchmark - saved ' + ReportPath;
end;

procedure TBenchmarkMainForm.RunSelfTest;
begin
  FProfiler.RunSelfTest;
  RefreshReport;
end;

procedure TBenchmarkMainForm.ActionExecute(Sender: TObject);
begin
  if Sender = actPrepare then
    PrepareTest
  else if Sender = actReset then
    ResetSession
  else if Sender = actStart then
    StartSession
  else if Sender = actStop then
    StopSession
  else if Sender = actRefresh then
    RefreshReport
  else if Sender = actSave then
    SaveReport
  else if Sender = actSelfTest then
    RunSelfTest;
end;

end.
