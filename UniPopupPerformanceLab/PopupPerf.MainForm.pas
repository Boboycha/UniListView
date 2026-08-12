unit PopupPerf.MainForm;

interface

uses
  System.Classes, System.Actions, System.Types,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Layouts, FMX.StdCtrls,
  FMX.ListBox, FMX.Memo, FMX.Objects, FMX.ActnList,
  UniList.Control, UniList.DropDown, UniList.Lookup,
  PopupPerf.Metrics, PopupPerf.TestContent, FMX.Memo.Types, FMX.ScrollBox,
  FMX.Controls.Presentation, PopupPerf.AutomaticRunner, PopupPerf.Diagnostics;

type
  TPopupPerfMainForm = class(TForm)
    Actions: TActionList;
    actApply: TAction;
    actStart: TAction;
    actStop: TAction;
    actReset: TAction;
    actRefresh: TAction;
    actRunFullMatrix: TAction;
    TopBar: TLayout;
    TestModeLabel: TLabel;
    TestModeCombo: TComboBox;
    PopupStateLabel: TLabel;
    PopupStateCombo: TComboBox;
    PopupContentLabel: TLabel;
    PopupContentCombo: TComboBox;
    StartButton: TButton;
    StopButton: TButton;
    ResetButton: TButton;
    RefreshButton: TButton;
    RunFullMatrixButton: TButton;
    Body: TLayout;
    TestArea: TLayout;
    PopupStage: TLayout;
    ReportMemo: TMemo;
    MarkerTrack: TRectangle;
    Marker: TRectangle;
    MarkerTimer: TTimer;
    procedure ActionExecute(Sender: TObject);
    procedure SelectionChanged(Sender: TObject);
    procedure MarkerTimerTick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FMetrics: TPopupPerfMetrics;
    FTestOwner: TComponent;
    FDropDown: TPopupPerfDropDown;
    FLookup: TPopupPerfLookup;
    FLookupPopupRoot: TControl;
    FPopupContent: TControl;
    FPopupContentList: TUniListView;
    FLastMarkerTicks: Int64;
    FMarkerPosition: Single;
    FAutomaticRunning: Boolean;
    FInteractionRequestedClose: Boolean;
    procedure BuildSelections;
    procedure ClearTestSet;
    procedure ApplyTestSet;
    procedure CreateTestSet;
    procedure CreateDropDown(const AAssignContent: Boolean);
    procedure CreateLookup(const AFillInternalList: Boolean);
    procedure EnsurePopupAssignments;
    procedure ApplyPopupState;
    procedure ApplyScenarioStateByUserInteraction(
      const AScenario: TPopupPerfScenario;
      out ARequestCompleted: Boolean);
    function InteractionOpened: Boolean;
    function InteractionEnteredScene: Boolean;
    function InteractionAutomaticallyClosed: Boolean;
    function PopupOpenTraceText: string;
    procedure OpenActivePopups;
    procedure CloseActivePopups;
    procedure DetachActivePopups;
    procedure ResetUniCounters;
    function SelectedTestMode: TPopupPerfTestMode;
    function SelectedPopupState: TPopupPerfState;
    function SelectedContentMode: TPopupPerfContentMode;
    function RuntimeStateText: string;
    function StoredPropertiesText: string;
    function RuntimeAttachmentText: string;
    function ActivitySourcesText: string;
    function UniListMetricsText: string;
    procedure RunFullMatrix;
    procedure RunScenario(const AScenario: TPopupPerfScenario;
      const AReport: TPopupPerfAutomaticReport);
    procedure DelayWithMessages(const ADelayMs: Cardinal);
    function ScenarioStateReached(const AScenario: TPopupPerfScenario;
      out AReason: string): Boolean;
    function WaitUntilScenarioState(const AScenario: TPopupPerfScenario;
      const ATimeoutMs: Cardinal; out AElapsedMs: Double;
      out AReason: string): Boolean;
    procedure ResetMeasurementCounters;
    function MeasurementCountersReset(out AReason: string): Boolean;
    procedure StartMeasurement;
    procedure StopMeasurement;
    function ValidateScenario(const AScenario: TPopupPerfScenario;
      const APopupPaintCalls: Int64; out AValidation, ANotes: string): Boolean;
    function PopupPaintCalls: Int64;
    function PopupRealignCalls: Int64;
    procedure StartSession;
    procedure StopSession;
    procedure ResetSession;
    procedure RefreshReport;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  PopupPerfMainForm: TPopupPerfMainForm;

implementation

uses
  System.SysUtils, System.Math, System.Diagnostics, System.IOUtils,
  System.TypInfo,
  System.Generics.Collections, UniList.Performance, UniList.Diagnostics;

{$R *.fmx}

const
  CTestControlLeft = 32.0;
  CTestControlTop = 32.0;
  CTestControlWidth = 420.0;
  CTestControlHeight = 36.0;
  CSecondControlTop = 84.0;
  CPopupStageTop = 144.0;
  CMarkerSpeedPixelsPerSecond = 180.0;
  CMarkerTimerInterval = 16;
  CAutomaticStabilizationMs = 1000;
  CAutomaticMeasurementMs = 10000;
  CScenarioStateTimeoutMs = 500;

constructor TPopupPerfMainForm.Create(AOwner: TComponent);
begin
  inherited;
  FMetrics := TPopupPerfMetrics.Create;
  PopupPerfSetMetrics(FMetrics);
  MarkerTimer.Interval := CMarkerTimerInterval;
  MarkerTimer.Enabled := True;
  BuildSelections;
end;

destructor TPopupPerfMainForm.Destroy;
begin
  MarkerTimer.Enabled := False;
  ClearTestSet;
  PopupPerfSetMetrics(nil);
  FMetrics.Free;
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

procedure TPopupPerfMainForm.BuildSelections;
begin
  AddItems(TestModeCombo,
    ['Baseline - no Uni controls', 'TUniDropDown only',
     'TUniDropDown + PopupComponent', 'TUniLookup only',
     'TUniLookup + internal list',
     'TUniDropDown and TUniLookup together'], 0);
  AddItems(PopupStateCombo,
    ['No PopupComponent', 'PopupComponent assigned, popup closed',
     'Popup open', 'Popup closed after first open',
     'PopupComponent detached'], 0);
  AddItems(PopupContentCombo,
    ['None', 'Empty TLayout', 'Standard TRectangle',
     'Small standard FMX control tree', 'TUniListView with 10 items',
     'TUniListView with 1000 items'], 0);
end;

function TPopupPerfMainForm.SelectedTestMode: TPopupPerfTestMode;
begin
  Result := TPopupPerfTestMode(TestModeCombo.ItemIndex);
end;

function TPopupPerfMainForm.SelectedPopupState: TPopupPerfState;
begin
  Result := TPopupPerfState(PopupStateCombo.ItemIndex);
end;

function TPopupPerfMainForm.SelectedContentMode: TPopupPerfContentMode;
begin
  Result := TPopupPerfContentMode(PopupContentCombo.ItemIndex);
end;

procedure TPopupPerfMainForm.FormShow(Sender: TObject);
begin
  actApply.Execute;
end;

procedure TPopupPerfMainForm.SelectionChanged(Sender: TObject);
begin
  if FAutomaticRunning then
    Exit;
  if not Visible then
    Exit;
  actApply.Execute;
end;

procedure TPopupPerfMainForm.ClearTestSet;
begin
  if FDropDown <> nil then
    FDropDown.CloseDropDown;
  if FLookup <> nil then
    FLookup.CloseDropDown;
  FreeAndNil(FTestOwner);
  FDropDown := nil;
  FLookup := nil;
  FLookupPopupRoot := nil;
  FPopupContent := nil;
  FPopupContentList := nil;
end;

procedure TPopupPerfMainForm.CreateDropDown(const AAssignContent: Boolean);
begin
  FDropDown := TPopupPerfDropDown.Create(FTestOwner);
  FDropDown.Parent := TestArea;
  FDropDown.SetBounds(CTestControlLeft, CTestControlTop,
    CTestControlWidth, CTestControlHeight);
  FDropDown.Text := 'Popup performance dropdown';
  if not AAssignContent then
    Exit;
  FPopupContent := TPopupPerfContentFactory.CreateContent(FTestOwner,
    SelectedContentMode, FPopupContentList);
  if FPopupContent = nil then
    Exit;
  FPopupContent.Parent := PopupStage;
  FPopupContent.Position.Point := TPointF.Zero;
  FDropDown.PopupContent := FPopupContent;
end;

procedure TPopupPerfMainForm.CreateLookup(
  const AFillInternalList: Boolean);
var
  ItemCount: Integer;
begin
  FLookup := TPopupPerfLookup.Create(FTestOwner);
  FLookup.Parent := TestArea;
  FLookup.SetBounds(CTestControlLeft,
    IfThen(FDropDown = nil, CTestControlTop, CSecondControlTop),
    CTestControlWidth, CTestControlHeight);
  FLookup.PromptText := 'Popup performance lookup';
  FLookupPopupRoot := FLookup.PopupContent;
  if not AFillInternalList then
    Exit;
  ItemCount := TPopupPerfContentFactory.LookupItemCount(
    SelectedContentMode);
  TPopupPerfContentFactory.FillList(FLookup.ListView, ItemCount);
end;

procedure TPopupPerfMainForm.CreateTestSet;
begin
  ClearTestSet;
  FTestOwner := TComponent.Create(Self);
  PopupStage.Position.Y := CPopupStageTop;
  case SelectedTestMode of
    pptBaseline:
      ;
    pptDropDownOnly:
      CreateDropDown(False);
    pptDropDownWithContent:
      CreateDropDown(True);
    pptLookupOnly:
      CreateLookup(False);
    pptLookupWithInternalList:
      CreateLookup(True);
    pptDropDownAndLookup:
      begin
        CreateDropDown(True);
        CreateLookup(True);
      end;
  end;
end;

procedure TPopupPerfMainForm.ApplyTestSet;
var
  Data: TPopupPerfSnapshot;
begin
  Data := FMetrics.Snapshot;
  if Data.Running then
    FMetrics.Stop;
  CreateTestSet;
  ApplyPopupState;
  ResetSession;
end;
procedure TPopupPerfMainForm.EnsurePopupAssignments;
begin
  if (FDropDown <> nil) and (FDropDown.PopupContent = nil) and
     (FPopupContent <> nil) then
    FDropDown.PopupContent := FPopupContent;
  if (FLookup <> nil) and (FLookup.PopupContent = nil) and
     (FLookupPopupRoot <> nil) then
    FLookup.PopupContent := FLookupPopupRoot;
end;

function ElapsedOperationMs(const AStartTicks: Int64): Double;
begin
  Result := (TStopwatch.GetTimeStamp - AStartTicks) * 1000.0 /
    TStopwatch.Frequency;
end;

procedure TPopupPerfMainForm.OpenActivePopups;
var
  StartTicks: Int64;
begin
  if FDropDown <> nil then
  begin
    StartTicks := TStopwatch.GetTimeStamp;
    FDropDown.OpenDropDown;
    FMetrics.RecordPopupOpen(ElapsedOperationMs(StartTicks));
  end;
  if FLookup <> nil then
  begin
    StartTicks := TStopwatch.GetTimeStamp;
    FLookup.OpenDropDown;
    FMetrics.RecordPopupOpen(ElapsedOperationMs(StartTicks));
  end;
end;

procedure TPopupPerfMainForm.CloseActivePopups;
var
  StartTicks: Int64;
begin
  if FDropDown <> nil then
  begin
    StartTicks := TStopwatch.GetTimeStamp;
    FDropDown.CloseDropDown;
    FMetrics.RecordPopupClose(ElapsedOperationMs(StartTicks));
  end;
  if FLookup <> nil then
  begin
    StartTicks := TStopwatch.GetTimeStamp;
    FLookup.CloseDropDown;
    FMetrics.RecordPopupClose(ElapsedOperationMs(StartTicks));
  end;
end;

procedure TPopupPerfMainForm.DetachActivePopups;
begin
  CloseActivePopups;
  if FDropDown <> nil then
    FDropDown.PopupContent := nil;
  if FLookup <> nil then
    FLookup.PopupContent := nil;
  if FPopupContent <> nil then
    FPopupContent.Parent := nil;
  if FLookupPopupRoot <> nil then
    FLookupPopupRoot.Parent := nil;
end;

procedure TPopupPerfMainForm.ApplyPopupState;
begin
  case SelectedPopupState of
    ppsNoPopupComponent:
      begin
        if FDropDown <> nil then
          FDropDown.PopupContent := nil;
        if FLookup <> nil then
          FLookup.PopupContent := nil;
      end;
    ppsAssignedClosed:
      begin
        EnsurePopupAssignments;
        CloseActivePopups;
      end;
    ppsOpen:
      begin
        EnsurePopupAssignments;
        OpenActivePopups;
      end;
    ppsClosedAfterOpen:
      begin
        EnsurePopupAssignments;
        OpenActivePopups;
        CloseActivePopups;
      end;
    ppsDetached:
      begin
        EnsurePopupAssignments;
        DetachActivePopups;
      end;
  end;
end;

procedure TPopupPerfMainForm.ApplyScenarioStateByUserInteraction(
  const AScenario: TPopupPerfScenario; out ARequestCompleted: Boolean);
begin
  ARequestCompleted := False;
  FInteractionRequestedClose := False;
  if not (AScenario.PopupState in [ppsOpen, ppsClosedAfterOpen]) then
  begin
    ApplyPopupState;
    ARequestCompleted := True;
    Exit;
  end;

  EnsurePopupAssignments;
  CloseActivePopups;
  if FDropDown <> nil then
    FDropDown.ResetInteractionTrace;
  if FLookup <> nil then
    FLookup.ResetInteractionTrace;

  if FDropDown <> nil then
    FDropDown.PerformUserClick;
  if FLookup <> nil then
    FLookup.PerformUserClick;
  ARequestCompleted := (FDropDown <> nil) or (FLookup <> nil);

  if AScenario.PopupState = ppsClosedAfterOpen then
  begin
    Application.ProcessMessages;
    if (FDropDown <> nil) and FDropDown.PopupHost.IsOpen then
    begin
      FInteractionRequestedClose := True;
      FDropDown.PerformUserClick;
    end;
    if (FLookup <> nil) and FLookup.PopupHost.IsOpen then
    begin
      FInteractionRequestedClose := True;
      FLookup.PerformUserClick;
    end;
  end;
end;

function TPopupPerfMainForm.InteractionOpened: Boolean;
begin
  Result := (FDropDown <> nil) or (FLookup <> nil);
  if FDropDown <> nil then
    Result := Result and FDropDown.InteractionOpened;
  if FLookup <> nil then
    Result := Result and FLookup.InteractionOpened;
end;

function TPopupPerfMainForm.InteractionEnteredScene: Boolean;
begin
  Result := (FDropDown <> nil) or (FLookup <> nil);
  if FDropDown <> nil then
    Result := Result and FDropDown.InteractionEnteredScene;
  if FLookup <> nil then
    Result := Result and FLookup.InteractionEnteredScene;
end;

function TPopupPerfMainForm.InteractionAutomaticallyClosed: Boolean;
begin
  if FInteractionRequestedClose then
    Exit(False);
  Result := False;
  if FDropDown <> nil then
    Result := Result or (FDropDown.InteractionOpened and
      FDropDown.InteractionClosed);
  if FLookup <> nil then
    Result := Result or (FLookup.InteractionOpened and
      FLookup.InteractionClosed);
end;
function TPopupPerfMainForm.PopupOpenTraceText: string;
var
  Trace: TUniPopupOpenTrace;
  Builder: TStringBuilder;

  procedure AppendFlag(const AName: string; const AValue: Boolean);
  begin
    Builder.AppendLine(Format('  %s: %s',
      [AName, BoolToStr(AValue, True)]));
  end;

  procedure AppendGuard(const AName: string;
    const AValue: TUniDiagnosticValue);
  begin
    Builder.AppendLine(Format('  %s: %s',
      [AName, UniDiagnosticValueText(AValue)]));
  end;

begin
  Trace := UniPopupDiagnosticsSnapshot;
  Builder := TStringBuilder.Create;
  try
    Builder.AppendLine('Popup Open Chain Trace:');
    AppendFlag('MouseClick entered', Trace.MouseClickEntered);
    AppendFlag('ToggleDropDown entered', Trace.ToggleDropDownEntered);
    AppendFlag('OpenDropDown entered', Trace.OpenDropDownEntered);
    AppendFlag('ShowPopup entered', Trace.ShowPopupEntered);
    AppendFlag('PopupShown callback', Trace.PopupShownCallback);
    AppendFlag('DoDropDownOpened entered',
      Trace.DoDropDownOpenedEntered);
    Builder.AppendLine('  First stopped stage: ' +
      UniPopupOpenFirstStoppedStage(Trace));
    Builder.AppendLine('Guard Conditions:');
    AppendGuard('FDestroying', Trace.Destroying);
    AppendGuard('AbsoluteEnabled', Trace.AbsoluteEnabled);
    AppendGuard('PopupContent assigned', Trace.PopupContentAssigned);
    AppendGuard('Popup already opening/open',
      Trace.PopupAlreadyOpeningOrOpen);
    AppendGuard('DesignMode', Trace.DesignMode);
    AppendGuard('OnOpening result', Trace.OnOpeningResult);
    AppendGuard('DoDropDownOpening result',
      Trace.DoDropDownOpeningResult);
    AppendGuard('Anchor assigned', Trace.AnchorAssigned);
    AppendGuard('Content assigned', Trace.ContentAssigned);
    AppendGuard('AnchorForm assigned', Trace.AnchorFormAssigned);
    AppendGuard('Form.Active', Trace.FormActive);
    AppendGuard('Anchor.ParentedVisible',
      Trace.AnchorParentedVisible);
    Result := Builder.ToString;
  finally
    Builder.Free;
  end;
end;
procedure TPopupPerfMainForm.ResetUniCounters;
begin
  if FPopupContentList <> nil then
    FPopupContentList.ResetPerformanceCounters;
  if (FLookup <> nil) and (FLookup.ListView <> nil) then
    FLookup.ListView.ResetPerformanceCounters;
end;

procedure TPopupPerfMainForm.StartSession;
begin
  if SelectedPopupState in [ppsOpen, ppsClosedAfterOpen] then
  begin
    EnsurePopupAssignments;
    CloseActivePopups;
  end;
  ResetUniCounters;
  PopupDiagnosticsStart;
  FMetrics.Start;
  case SelectedPopupState of
    ppsOpen:
      OpenActivePopups;
    ppsClosedAfterOpen:
      begin
        OpenActivePopups;
        CloseActivePopups;
      end;
  end;
  RefreshReport;
end;

procedure TPopupPerfMainForm.StopSession;
begin
  FMetrics.Stop;
  PopupDiagnosticsStop;
  RefreshReport;
end;

procedure TPopupPerfMainForm.ResetSession;
begin
  FMetrics.Reset;
  ResetUniCounters;
  PopupDiagnosticsReset;
  RefreshReport;
end;

function AbsoluteVisibleValue(const AControl: TControl): Boolean;
var
  Current: TFmxObject;
begin
  Result := AControl <> nil;
  Current := AControl;
  while Result and (Current <> nil) do
  begin
    if (Current is TControl) and not TControl(Current).Visible then
      Exit(False);
    Current := Current.Parent;
  end;
end;

function StoredControlProperties(const AName: string;
  const AControl: TControl): string;
begin
  if AControl = nil then
    Exit(AName + ':' + sLineBreak +
      '  Visible: N/A' + sLineBreak +
      '  Enabled: N/A' + sLineBreak +
      '  HitTest: N/A' + sLineBreak +
      '  Opacity: N/A' + sLineBreak +
      '  Align: N/A' + sLineBreak +
      '  Size: N/A');
  Result := AName + ':' + sLineBreak +
    Format('  Visible: %s', [BoolToStr(AControl.Visible, True)]) + sLineBreak +
    Format('  Enabled: %s', [BoolToStr(AControl.Enabled, True)]) + sLineBreak +
    Format('  HitTest: %s', [BoolToStr(AControl.HitTest, True)]) + sLineBreak +
    Format('  Opacity: %.3f', [AControl.Opacity]) + sLineBreak +
    Format('  Align: %s', [GetEnumName(TypeInfo(TAlignLayout),
      Ord(AControl.Align))]) + sLineBreak +
    Format('  Size: %.3f x %.3f', [AControl.Width, AControl.Height]);
end;

function AttachmentControlState(const AName: string;
  const AControl: TControl; const APopupHostAssigned,
  APopupOpen: Boolean): string;
var
  ParentValue: string;
  ParentClassValue: string;
  RootValue: string;
  SceneValue: string;
  Attached: Boolean;
  Participates: Boolean;
begin
  if AControl = nil then
  begin
    ParentValue := 'nil';
    ParentClassValue := 'nil';
    RootValue := 'nil';
    SceneValue := 'nil';
    Attached := False;
    Participates := False;
  end
  else
  begin
    if AControl.Parent = nil then
    begin
      ParentValue := 'nil';
      ParentClassValue := 'nil';
    end
    else
    begin
      ParentValue := AControl.Parent.Name;
      if ParentValue = '' then
        ParentValue := AControl.Parent.ClassName;
      ParentClassValue := AControl.Parent.ClassName;
    end;
    if AControl.Root = nil then
      RootValue := 'nil'
    else
      RootValue := 'assigned';
    if AControl.Scene = nil then
      SceneValue := 'nil'
    else
      SceneValue := 'assigned';
    Attached := (AControl.Parent <> nil) and (AControl.Root <> nil);
    Participates := Attached and (AControl.Scene <> nil);
  end;
  Result := AName + ':' + sLineBreak +
    Format('  Parent: %s', [ParentValue]) + sLineBreak +
    Format('  ParentClass: %s', [ParentClassValue]) + sLineBreak +
    Format('  Root: %s', [RootValue]) + sLineBreak +
    Format('  Scene: %s', [SceneValue]) + sLineBreak +
    Format('  AbsoluteVisible: %s', [BoolToStr(
      AbsoluteVisibleValue(AControl), True)]) + sLineBreak +
    Format('  AttachedToVisualTree: %s', [BoolToStr(Attached, True)]) + sLineBreak +
    Format('  ParticipatesInScene: %s', [BoolToStr(Participates, True)]) + sLineBreak +
    Format('  PopupHostAssigned: %s', [BoolToStr(
      APopupHostAssigned, True)]) + sLineBreak +
    Format('  PopupOpened: %s', [BoolToStr(APopupOpen, True)]);
end;

function TPopupPerfMainForm.StoredPropertiesText: string;
var
  Builder: TStringBuilder;
begin
  Builder := TStringBuilder.Create;
  try
    if FDropDown <> nil then
      Builder.AppendLine(StoredControlProperties('DropDown PopupComponent',
        FPopupContent));
    if FLookup <> nil then
      Builder.AppendLine(StoredControlProperties('Lookup PopupComponent',
        FLookupPopupRoot));
    if (FDropDown = nil) and (FLookup = nil) then
      Builder.AppendLine(StoredControlProperties('PopupComponent', nil));
    Result := Builder.ToString;
  finally
    Builder.Free;
  end;
end;

function TPopupPerfMainForm.RuntimeAttachmentText: string;
var
  Builder: TStringBuilder;
begin
  Builder := TStringBuilder.Create;
  try
    if FDropDown <> nil then
      Builder.AppendLine(AttachmentControlState('DropDown PopupComponent',
        FPopupContent, FDropDown.PopupHost <> nil,
        FDropDown.PopupHost.IsOpen));
    if FLookup <> nil then
      Builder.AppendLine(AttachmentControlState('Lookup PopupComponent',
        FLookupPopupRoot, FLookup.PopupHost <> nil,
        FLookup.PopupHost.IsOpen));
    if (FDropDown = nil) and (FLookup = nil) then
      Builder.AppendLine(AttachmentControlState('PopupComponent', nil,
        False, False));
    Result := Builder.ToString;
  finally
    Builder.Free;
  end;
end;

function ActivityLine(const AName, APaint, ARealign, AMouseMove,
  AHitTest, ARepaint: string): string;
begin
  Result := AName + ':' + sLineBreak +
    '  Paint Count: ' + APaint + sLineBreak +
    '  Realign Count: ' + ARealign + sLineBreak +
    '  MouseMove: ' + AMouseMove + sLineBreak +
    '  HitTest: ' + AHitTest + sLineBreak +
    '  Repaint Requests: ' + ARepaint;
end;

function CountText(const AValue: Int64): string;
begin
  Result := IntToStr(AValue);
end;

function TPopupPerfMainForm.ActivitySourcesText: string;
const
  CNotExposed = 'N/A (runtime hook not exposed)';
  CNotObserved = 'N/A (benchmark hook not installed)';
var
  Builder: TStringBuilder;
  Diagnostics: TPopupDiagnosticsSnapshot;
  ListData: TUniPerformanceSnapshot;
begin
  Diagnostics := PopupDiagnosticsSnapshot;
  Builder := TStringBuilder.Create;
  try
    Builder.AppendLine(ActivityLine('PopupHost', CNotExposed, CNotExposed,
      CNotExposed, CNotExposed, CNotExposed));
    Builder.AppendLine(ActivityLine('PopupRoot', CNotExposed, CNotExposed,
      CNotExposed, CNotExposed, CNotExposed));
    Builder.AppendLine(ActivityLine('PopupComponent',
      CountText(Diagnostics.Counts[pdnPopupComponent].PaintCount),
      CountText(Diagnostics.Counts[pdnPopupComponent].RealignCount),
      CNotObserved, CNotObserved, CNotObserved));
    Builder.AppendLine(ActivityLine('LookupPopup',
      CountText(Diagnostics.Counts[pdnLookupPopup].PaintCount),
      CountText(Diagnostics.Counts[pdnLookupPopup].RealignCount),
      CNotObserved, CNotObserved, CNotObserved));
    if (FLookup <> nil) and (FLookup.ListView <> nil) then
    begin
      ListData := FLookup.ListView.GetPerformanceSnapshot;
      Builder.AppendLine(ActivityLine('LookupList',
        CountText(ListData.MetricSnapshots[upcPaint].Calls),
        CountText(ListData.RealignRequests),
        CountText(ListData.MouseMoveCalls), CountText(ListData.HitTests),
        CountText(ListData.RepaintRequests)));
    end
    else
      Builder.AppendLine(ActivityLine('LookupList', 'N/A', 'N/A',
        'N/A', 'N/A', 'N/A'));
    Builder.AppendLine(ActivityLine('DropDown',
      CountText(Diagnostics.Counts[pdnDropDown].PaintCount),
      CountText(Diagnostics.Counts[pdnDropDown].RealignCount),
      CNotObserved, CNotObserved, CNotObserved));
    Builder.AppendLine(ActivityLine('TestForm', CNotObserved, CNotObserved,
      CNotObserved, CNotObserved, CNotObserved));
    Result := Builder.ToString;
  finally
    Builder.Free;
  end;
end;

function TPopupPerfMainForm.RuntimeStateText: string;
begin
  Result := 'Stored Properties' + sLineBreak + StoredPropertiesText +
    sLineBreak + 'Runtime Attachment' + sLineBreak +
    RuntimeAttachmentText + sLineBreak + 'Activity Sources' + sLineBreak +
    ActivitySourcesText;
end;
procedure AppendUniListSnapshot(const ABuilder: TStringBuilder;
  const AName: string; const AListView: TUniListView);
var
  Data: TUniPerformanceSnapshot;
begin
  if AListView = nil then
    Exit;
  Data := AListView.GetPerformanceSnapshot;
  ABuilder.AppendLine(Format('  %s: Items=%d Visible=%d Paint=%d '
    + 'RepaintRequests=%d RealignRequests=%d MouseMove=%d HitTests=%d',
    [AName, Data.TotalItems, Data.VisibleItems,
     Data.MetricSnapshots[upcPaint].Calls, Data.RepaintRequests,
     Data.RealignRequests, Data.MouseMoveCalls, Data.HitTests]));
end;

function TPopupPerfMainForm.UniListMetricsText: string;
var
  Builder: TStringBuilder;
begin
  Builder := TStringBuilder.Create;
  try
    AppendUniListSnapshot(Builder, 'Popup content list',
      FPopupContentList);
    if FLookup <> nil then
      AppendUniListSnapshot(Builder, 'Lookup internal list',
        FLookup.ListView);
    Result := Builder.ToString;
  finally
    Builder.Free;
  end;
end;

procedure TPopupPerfMainForm.RefreshReport;
begin
  ReportMemo.Text := FMetrics.Report(
    PopupPerfTestModeName(SelectedTestMode),
    PopupPerfStateName(SelectedPopupState),
    PopupPerfContentModeName(SelectedContentMode), RuntimeStateText,
    UniListMetricsText);
end;

procedure TPopupPerfMainForm.DelayWithMessages(const ADelayMs: Cardinal);
var
  Started: Int64;
begin
  Started := TStopwatch.GetTimeStamp;
  repeat
    Application.ProcessMessages;
  until ElapsedOperationMs(Started) >= ADelayMs;
end;

function TPopupPerfMainForm.PopupPaintCalls: Int64;
var
  Diagnostics: TPopupDiagnosticsSnapshot;
  Data: TUniPerformanceSnapshot;
begin
  Diagnostics := PopupDiagnosticsSnapshot;
  Result := Diagnostics.Counts[pdnPopupComponent].PaintCount;
  if (FLookup <> nil) and (FLookup.ListView <> nil) then
  begin
    Data := FLookup.ListView.GetPerformanceSnapshot;
    Inc(Result, Data.MetricSnapshots[upcPaint].Calls);
  end;
end;

function TPopupPerfMainForm.PopupRealignCalls: Int64;
var
  Diagnostics: TPopupDiagnosticsSnapshot;
  Data: TUniPerformanceSnapshot;
begin
  Diagnostics := PopupDiagnosticsSnapshot;
  Result := Diagnostics.Counts[pdnPopupComponent].RealignCount;
  if (FLookup <> nil) and (FLookup.ListView <> nil) then
  begin
    Data := FLookup.ListView.GetPerformanceSnapshot;
    Inc(Result, Data.RealignRequests);
  end;
end;
function TPopupPerfMainForm.ScenarioStateReached(
  const AScenario: TPopupPerfScenario; out AReason: string): Boolean;

  function PopupStateMatches(const AName: string; const AControl: TControl;
    const AAssigned, AOpened: Boolean): Boolean;
  var
    ParentAssigned: Boolean;
    RootAssigned: Boolean;
    SceneAssigned: Boolean;
    Attached: Boolean;
  begin
    ParentAssigned := (AControl <> nil) and (AControl.Parent <> nil);
    RootAssigned := (AControl <> nil) and (AControl.Root <> nil);
    SceneAssigned := (AControl <> nil) and (AControl.Scene <> nil);
    Attached := ParentAssigned and RootAssigned;
    Result := False;
    case AScenario.PopupState of
      ppsNoPopupComponent:
        begin
          Result := not AAssigned;
          if not Result then
            AReason := AName + ': PopupComponent is still assigned';
        end;
      ppsAssignedClosed,
      ppsClosedAfterOpen:
        begin
          Result := AAssigned and not AOpened and not ParentAssigned and
            not SceneAssigned and not Attached;
          if not Result then
            AReason := AName + ': expected closed attachment state';
        end;
      ppsOpen:
        begin
          Result := AAssigned and AOpened and ParentAssigned and
            SceneAssigned and RootAssigned and Attached;
          if not Result then
            AReason := AName + ': expected open attachment state';
        end;
      ppsDetached:
        begin
          Result := not AAssigned and not ParentAssigned and
            not SceneAssigned and not RootAssigned and not Attached;
          if not Result then
            AReason := AName + ': expected detached attachment state';
        end;
    end;
  end;

begin
  AReason := '';
  if AScenario.TestMode = pptBaseline then
  begin
    Result := (FDropDown = nil) and (FLookup = nil);
    if not Result then
      AReason := 'Baseline controls still exist';
    Exit;
  end;
  Result := True;
  if FDropDown <> nil then
    Result := PopupStateMatches('DropDown popup', FPopupContent,
      FDropDown.PopupContent <> nil, FDropDown.PopupHost.IsOpen);
  if Result and (FLookup <> nil) then
    Result := PopupStateMatches('Lookup popup', FLookupPopupRoot,
      FLookup.PopupContent <> nil, FLookup.PopupHost.IsOpen);
  if Result and (AScenario.PopupState = ppsClosedAfterOpen) and
     not InteractionOpened then
  begin
    AReason := 'Popup was never opened by user interaction';
    Result := False;
  end;
end;

function TPopupPerfMainForm.WaitUntilScenarioState(
  const AScenario: TPopupPerfScenario; const ATimeoutMs: Cardinal;
  out AElapsedMs: Double; out AReason: string): Boolean;
const
  CRequiredStableChecks = 3;
var
  Started: Int64;
  StableChecks: Integer;
begin
  Started := TStopwatch.GetTimeStamp;
  StableChecks := 0;
  repeat
    Application.ProcessMessages;
    if ScenarioStateReached(AScenario, AReason) then
    begin
      Inc(StableChecks);
      if StableChecks >= CRequiredStableChecks then
      begin
        AElapsedMs := ElapsedOperationMs(Started);
        Exit(True);
      end;
    end
    else
      StableChecks := 0;
    AElapsedMs := ElapsedOperationMs(Started);
  until AElapsedMs >= ATimeoutMs;
  Result := False;
end;

procedure TPopupPerfMainForm.ResetMeasurementCounters;
begin
  FMetrics.Reset;
  ResetUniCounters;
  PopupDiagnosticsReset;
end;

function TPopupPerfMainForm.MeasurementCountersReset(
  out AReason: string): Boolean;
var
  Metrics: TPopupPerfSnapshot;
  Diagnostics: TPopupDiagnosticsSnapshot;
  Data: TUniPerformanceSnapshot;
  Node: TPopupDiagnosticNode;

  function UniCountersAreZero(const AList: TUniListView): Boolean;
  begin
    if AList = nil then
      Exit(True);
    Data := AList.GetPerformanceSnapshot;
    Result := (Data.MetricSnapshots[upcPaint].Calls = 0) and
      (Data.RepaintRequests = 0) and (Data.RealignRequests = 0) and
      (Data.MouseMoveCalls = 0) and (Data.HitTests = 0);
  end;

begin
  AReason := '';
  Metrics := FMetrics.Snapshot;
  Result := not Metrics.Running and (Metrics.MarkerUpdates = 0) and
    (Metrics.TestPaintCalls = 0) and
    (Metrics.PopupContentPaintCalls = 0) and
    (Metrics.TestRealignCalls = 0) and
    (Metrics.PopupContentRealignCalls = 0) and
    (Metrics.PopupOpenCount = 0) and (Metrics.PopupCloseCount = 0);
  if not Result then
  begin
    AReason := 'Popup performance counters are not zero';
    Exit;
  end;
  Diagnostics := PopupDiagnosticsSnapshot;
  for Node := Low(TPopupDiagnosticNode) to High(TPopupDiagnosticNode) do
    if (Diagnostics.Counts[Node].PaintCount <> 0) or
       (Diagnostics.Counts[Node].RealignCount <> 0) then
    begin
      AReason := 'Diagnostic counters are not zero';
      Exit(False);
    end;
  if not UniCountersAreZero(FPopupContentList) then
  begin
    AReason := 'Popup content list counters are not zero';
    Exit(False);
  end;
  if (FLookup <> nil) and not UniCountersAreZero(FLookup.ListView) then
  begin
    AReason := 'Lookup list counters are not zero';
    Exit(False);
  end;
  Result := True;
end;

procedure TPopupPerfMainForm.StartMeasurement;
begin
  PopupDiagnosticsStart;
  FMetrics.Start;
end;

procedure TPopupPerfMainForm.StopMeasurement;
begin
  FMetrics.Stop;
  PopupDiagnosticsStop;
end;
function TPopupPerfMainForm.ValidateScenario(
  const AScenario: TPopupPerfScenario; const APopupPaintCalls: Int64;
  out AValidation, ANotes: string): Boolean;
var
  Builder: TStringBuilder;
  Failed: Boolean;

  procedure Check(const ACondition: Boolean; const AMessage: string);
  begin
    if ACondition then
      Builder.AppendLine('PASS: ' + AMessage)
    else
    begin
      Builder.AppendLine('FAILED: ' + AMessage);
      Failed := True;
    end;
  end;

  procedure CheckPopup(const AName: string; const AControl: TControl;
    const AAssigned, AOpen: Boolean);
  var
    ParentAssigned: Boolean;
    RootAssigned: Boolean;
    SceneAssigned: Boolean;
    Attached: Boolean;
  begin
    ParentAssigned := (AControl <> nil) and (AControl.Parent <> nil);
    RootAssigned := (AControl <> nil) and (AControl.Root <> nil);
    SceneAssigned := (AControl <> nil) and (AControl.Scene <> nil);
    Attached := ParentAssigned and RootAssigned;
    case AScenario.PopupState of
      ppsNoPopupComponent:
        Check(not AAssigned, AName + ' is not assigned');
      ppsAssignedClosed,
      ppsClosedAfterOpen:
        begin
          Check(AAssigned, AName + ' is assigned');
          Check(not AOpen, AName + ' PopupOpened=False');
          Check(not ParentAssigned, AName + ' Parent=nil');
          Check(not SceneAssigned, AName + ' Scene=nil');
          Check(not Attached,
            AName + ' AttachedToVisualTree=False');
        end;
      ppsOpen:
        begin
          Check(AAssigned, AName + ' is assigned');
          Check(AOpen, AName + ' PopupOpened=True');
          Check(ParentAssigned, AName + ' Parent<>nil');
          Check(SceneAssigned, AName + ' Scene<>nil');
          Check(Attached,
            AName + ' AttachedToVisualTree=True');
        end;
      ppsDetached:
        begin
          Check(not AAssigned, AName + ' is detached');
          Check(not ParentAssigned, AName + ' Parent=nil');
          Check(not SceneAssigned, AName + ' Scene=nil');
          Check(not RootAssigned, AName + ' Root=nil');
        end;
    end;
  end;

begin
  Builder := TStringBuilder.Create;
  try
    Failed := False;
    if AScenario.TestMode = pptBaseline then
      Check((FDropDown = nil) and (FLookup = nil),
        'baseline has no Uni controls');
    if FDropDown <> nil then
      CheckPopup('DropDown popup', FPopupContent,
        FDropDown.PopupContent <> nil, FDropDown.PopupHost.IsOpen);
    if FLookup <> nil then
      CheckPopup('Lookup popup', FLookupPopupRoot,
        FLookup.PopupContent <> nil, FLookup.PopupHost.IsOpen);
    if AScenario.PopupState in [ppsAssignedClosed, ppsClosedAfterOpen] then
      Check(APopupPaintCalls = 0, 'closed Popup Paint = 0');
    if AScenario.PopupState = ppsDetached then
      Check(APopupPaintCalls = 0, 'detached Popup Paint = 0');
    Result := not Failed;
    if Result then
      ANotes := ''
    else
      ANotes := 'Runtime attachment validation failed';
    AValidation := Builder.ToString;
  finally
    Builder.Free;
  end;
end;
procedure TPopupPerfMainForm.RunScenario(const AScenario: TPopupPerfScenario;
  const AReport: TPopupPerfAutomaticReport);
var
  Item: TPopupPerfScenarioResult;
  PaintCalls: Int64;
  RealignCalls: Int64;
  VerificationMs: Double;
  VerificationReason: string;
  CountersReason: string;
  StateReached: Boolean;
  CountersReady: Boolean;
  OpenRequestCompleted: Boolean;
  OpenTrace: string;
  TraceEnabled: Boolean;
begin
  Item := TPopupPerfScenarioResult.Create;
  try
    try
      Item.ScenarioName := AScenario.Name;
      OpenTrace := '';
      TraceEnabled := AScenario.PopupState in
        [ppsOpen, ppsClosedAfterOpen];
      UniPopupDiagnosticsDisable;
      if TraceEnabled then
      begin
        UniPopupDiagnosticsReset;
        UniPopupDiagnosticsEnabled := True;
      end;

      ClearTestSet;
      TestModeCombo.ItemIndex := Ord(AScenario.TestMode);
      PopupStateCombo.ItemIndex := Ord(AScenario.PopupState);
      PopupContentCombo.ItemIndex := Ord(AScenario.ContentMode);
      CreateTestSet;

      if FPopupContent <> nil then
      begin
        CloseActivePopups;
        FPopupContent.Parent := nil;
      end;

      ApplyScenarioStateByUserInteraction(AScenario,
        OpenRequestCompleted);
      StateReached := WaitUntilScenarioState(AScenario,
        CScenarioStateTimeoutMs, VerificationMs, VerificationReason);
      if TraceEnabled then
        OpenTrace := PopupOpenTraceText;
      UniPopupDiagnosticsDisable;
      if StateReached then
      begin
        Item.Verification := 'OK';
        Item.StateTransition := Format(
          'Requested: %s' + sLineBreak +
          'Reached: YES' + sLineBreak +
          'Verification Time: %.3f ms',
          [PopupPerfStateName(AScenario.PopupState), VerificationMs]);
        if AScenario.PopupState in [ppsOpen, ppsClosedAfterOpen] then
          Item.StateTransition := Item.StateTransition + sLineBreak +
            'Open request completed: ' +
            BoolToStr(OpenRequestCompleted, True) + sLineBreak +
            'Popup actually entered Scene: ' +
            BoolToStr(InteractionEnteredScene, True) + sLineBreak +
            'Popup was automatically closed: ' +
            BoolToStr(InteractionAutomaticallyClosed, True);
        if OpenTrace <> '' then
          Item.StateTransition := Item.StateTransition + sLineBreak +
            OpenTrace;

        ResetMeasurementCounters;
        CountersReady := MeasurementCountersReset(CountersReason);
        if CountersReady then
        begin
          StartMeasurement;
          DelayWithMessages(CAutomaticMeasurementMs);
          StopMeasurement;

          Item.Snapshot := FMetrics.Snapshot;
          PaintCalls := PopupPaintCalls;
          RealignCalls := PopupRealignCalls;
          Item.PopupPaintCalls := PaintCalls;
          Item.PopupRealignCalls := RealignCalls;
          Item.RuntimeState := RuntimeStateText;
          Item.MetricsText := Format(
            'Duration=%.3f ms Avg=%.3f ms P95=%.3f ms Max=%.3f ms' +
            sLineBreak + 'Popup Paint=%d Popup Realign=%d' +
            sLineBreak + '%s',
            [Item.Snapshot.DurationMs, Item.Snapshot.MarkerAverageMs,
             Item.Snapshot.MarkerP95Ms, Item.Snapshot.MarkerMaxMs,
             PaintCalls, RealignCalls, UniListMetricsText]);
          Item.Passed := ValidateScenario(AScenario, PaintCalls,
            Item.ValidationText, Item.Notes);
          if Item.Passed then
            Item.ResultStatus := 'PASS'
          else
            Item.ResultStatus := 'FAILED';
        end
        else
        begin
          Item.Passed := False;
          Item.Verification := 'Wrong State';
          Item.ResultStatus := 'FAILED (Verification)';
          Item.RuntimeState := RuntimeStateText;
          Item.MetricsText := 'Measurement not started.';
          Item.ValidationText := 'FAILED: Counter reset verification failed.' +
            sLineBreak + CountersReason;
          Item.Notes := CountersReason;
        end;
      end
      else
      begin
        Item.Passed := False;
        Item.Verification := 'Timeout';
        Item.ResultStatus := 'FAILED (Timeout)';
        Item.StateTransition := Format(
          'Requested: %s' + sLineBreak +
          'Reached: NO' + sLineBreak +
          'Timeout: %d ms',
          [PopupPerfStateName(AScenario.PopupState),
           CScenarioStateTimeoutMs]);
        if AScenario.PopupState in [ppsOpen, ppsClosedAfterOpen] then
        begin
          Item.StateTransition := Item.StateTransition + sLineBreak +
            'Popup did not reach Open state.' + sLineBreak +
            'Open request completed: ' +
            BoolToStr(OpenRequestCompleted, True) + sLineBreak +
            'Popup actually entered Scene: ' +
            BoolToStr(InteractionEnteredScene, True) + sLineBreak +
            'Popup was automatically closed: ' +
            BoolToStr(InteractionAutomaticallyClosed, True) + sLineBreak +
            'Reason: ' + VerificationReason;
          if OpenTrace <> '' then
            Item.StateTransition := Item.StateTransition + sLineBreak +
              OpenTrace;
        end;
        Item.RuntimeState := RuntimeStateText;
        Item.MetricsText := 'Measurement not started.';
        Item.ValidationText :=
          'FAILED: Expected runtime state was not reached.' + sLineBreak +
          VerificationReason;
        Item.Notes := 'Expected runtime state was not reached.';
      end;
    except
      on E: Exception do
      begin
        StopMeasurement;
        Item.Passed := False;
        Item.Verification := 'Wrong State';
        Item.ResultStatus := 'FAILED (Verification)';
        Item.RuntimeState := RuntimeStateText;
        Item.MetricsText := 'Measurement not completed.';
        Item.ValidationText := 'FAILED: Exception ' + E.ClassName + ': ' +
          E.Message;
        Item.Notes := 'Scenario exception; matrix continued';
      end;
    end;
    AReport.Add(Item);
    Item := nil;
  finally
    UniPopupDiagnosticsDisable;
    Item.Free;
    ClearTestSet;
    Application.ProcessMessages;
  end;
end;
procedure TPopupPerfMainForm.RunFullMatrix;
var
  Scenarios: TObjectList<TPopupPerfScenario>;
  Scenario: TPopupPerfScenario;
  Report: TPopupPerfAutomaticReport;
  Started: Int64;
  ReportText: string;
  ReportFileName: string;
begin
  if FAutomaticRunning then
    Exit;
  FAutomaticRunning := True;
  actRunFullMatrix.Enabled := False;
  TopBar.Enabled := False;
  Scenarios := CreatePopupPerfScenarioRegistry;
  Report := TPopupPerfAutomaticReport.Create;
  Started := TStopwatch.GetTimeStamp;
  try
    for Scenario in Scenarios do
    begin
      ReportMemo.Text := 'Running: ' + Scenario.Name;
      Application.ProcessMessages;
      RunScenario(Scenario, Report);
    end;
    Report.Finish(ElapsedOperationMs(Started));
    ReportText := Report.Build;
    ReportFileName := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
      'UniPopupPerformanceLab-FullMatrix-' +
      FormatDateTime('yyyymmdd-hhnnss', Now) + '.txt';
    TFile.WriteAllText(ReportFileName, ReportText, TEncoding.UTF8);
    ReportMemo.Text := ReportText + sLineBreak + 'Report file: ' + ReportFileName;
  finally
    ClearTestSet;
    Report.Free;
    Scenarios.Free;
    FAutomaticRunning := False;
    TopBar.Enabled := True;
    actRunFullMatrix.Enabled := True;
  end;
end;
procedure TPopupPerfMainForm.MarkerTimerTick(Sender: TObject);
var
  CurrentTicks: Int64;
  DeltaSeconds: Double;
  TravelWidth: Single;
begin
  CurrentTicks := TStopwatch.GetTimeStamp;
  if FLastMarkerTicks = 0 then
    FLastMarkerTicks := CurrentTicks;
  DeltaSeconds := (CurrentTicks - FLastMarkerTicks) /
    TStopwatch.Frequency;
  FLastMarkerTicks := CurrentTicks;
  FMetrics.RecordMarkerUpdate;
  TravelWidth := Max(0, MarkerTrack.Width - Marker.Width);
  if TravelWidth <= 0 then
    Exit;
  FMarkerPosition := FMarkerPosition +
    CMarkerSpeedPixelsPerSecond * DeltaSeconds;
  while FMarkerPosition > TravelWidth do
    FMarkerPosition := FMarkerPosition - TravelWidth;
  Marker.Position.X := FMarkerPosition;
end;

procedure TPopupPerfMainForm.ActionExecute(Sender: TObject);
begin
  if Sender = actApply then
    ApplyTestSet
  else if Sender = actStart then
    StartSession
  else if Sender = actStop then
    StopSession
  else if Sender = actReset then
    ResetSession
  else if Sender = actRefresh then
    RefreshReport
  else if Sender = actRunFullMatrix then
    RunFullMatrix;
end;

end.