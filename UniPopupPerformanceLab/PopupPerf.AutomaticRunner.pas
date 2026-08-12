unit PopupPerf.AutomaticRunner;

interface

uses
  System.Generics.Collections,
  PopupPerf.Metrics, PopupPerf.TestContent;

type
  TPopupPerfScenario = class
  public
    Name: string;
    TestMode: TPopupPerfTestMode;
    PopupState: TPopupPerfState;
    ContentMode: TPopupPerfContentMode;
    constructor Create(const AName: string; const ATestMode: TPopupPerfTestMode;
      const APopupState: TPopupPerfState; const AContentMode: TPopupPerfContentMode);
  end;

  TPopupPerfScenarioResult = class
  public
    ScenarioName: string;
    RuntimeState: string;
    MetricsText: string;
    ValidationText: string;
    Passed: Boolean;
    Skipped: Boolean;
    Notes: string;
    ResultStatus: string;
    Verification: string;
    StateTransition: string;
    Snapshot: TPopupPerfSnapshot;
    PopupPaintCalls: Int64;
    PopupRealignCalls: Int64;
  end;

  TPopupPerfAutomaticReport = class
  private
    FResults: TObjectList<TPopupPerfScenarioResult>;
    FStartedAt: TDateTime;
    FDurationMs: Double;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(const AResult: TPopupPerfScenarioResult);
    procedure Finish(const ADurationMs: Double);
    function Build: string;
  end;

function CreatePopupPerfScenarioRegistry: TObjectList<TPopupPerfScenario>;

implementation

uses
  System.SysUtils, System.Classes;

constructor TPopupPerfScenario.Create(const AName: string;
  const ATestMode: TPopupPerfTestMode; const APopupState: TPopupPerfState;
  const AContentMode: TPopupPerfContentMode);
begin
  inherited Create;
  Name := AName;
  TestMode := ATestMode;
  PopupState := APopupState;
  ContentMode := AContentMode;
end;

function CreatePopupPerfScenarioRegistry: TObjectList<TPopupPerfScenario>;
  procedure RegisterScenario(const AName: string;
    const ATestMode: TPopupPerfTestMode; const APopupState: TPopupPerfState;
    const AContentMode: TPopupPerfContentMode);
  begin
    Result.Add(TPopupPerfScenario.Create(AName, ATestMode, APopupState, AContentMode));
  end;
begin
  Result := TObjectList<TPopupPerfScenario>.Create(True);
  RegisterScenario('Baseline', pptBaseline, ppsNoPopupComponent, ppcNone);
  RegisterScenario('DropDown / No PopupComponent', pptDropDownOnly, ppsNoPopupComponent, ppcNone);
  RegisterScenario('DropDown / Empty / Assigned Closed', pptDropDownWithContent, ppsAssignedClosed, ppcEmptyLayout);
  RegisterScenario('DropDown / 10 items / Assigned Closed', pptDropDownWithContent, ppsAssignedClosed, ppcUniList10);
  RegisterScenario('DropDown / 1000 items / Assigned Closed', pptDropDownWithContent, ppsAssignedClosed, ppcUniList1000);
  RegisterScenario('DropDown / Popup Open', pptDropDownWithContent, ppsOpen, ppcEmptyLayout);
  RegisterScenario('DropDown / Closed After Open', pptDropDownWithContent, ppsClosedAfterOpen, ppcEmptyLayout);
  RegisterScenario('DropDown / Detached', pptDropDownWithContent, ppsDetached, ppcEmptyLayout);
  RegisterScenario('Lookup / Empty', pptLookupOnly, ppsAssignedClosed, ppcNone);
  RegisterScenario('Lookup / 10 items', pptLookupWithInternalList, ppsAssignedClosed, ppcUniList10);
  RegisterScenario('Lookup / 1000 items', pptLookupWithInternalList, ppsAssignedClosed, ppcUniList1000);
  RegisterScenario('Lookup / Popup Open', pptLookupWithInternalList, ppsOpen, ppcUniList10);
  RegisterScenario('Lookup / Closed After Open', pptLookupWithInternalList, ppsClosedAfterOpen, ppcUniList10);
  RegisterScenario('Lookup / Detached', pptLookupWithInternalList, ppsDetached, ppcUniList10);
  RegisterScenario('DropDown + Lookup / 10 items / Assigned Closed', pptDropDownAndLookup, ppsAssignedClosed, ppcUniList10);
end;

constructor TPopupPerfAutomaticReport.Create;
begin
  inherited;
  FResults := TObjectList<TPopupPerfScenarioResult>.Create(True);
  FStartedAt := Now;
end;

destructor TPopupPerfAutomaticReport.Destroy;
begin
  FResults.Free;
  inherited;
end;

procedure TPopupPerfAutomaticReport.Add(const AResult: TPopupPerfScenarioResult);
begin
  FResults.Add(AResult);
end;

procedure TPopupPerfAutomaticReport.Finish(const ADurationMs: Double);
begin
  FDurationMs := ADurationMs;
end;

function ResultName(const AResult: TPopupPerfScenarioResult): string;
begin
  if AResult.ResultStatus <> '' then
    Exit(AResult.ResultStatus);
  if AResult.Skipped then
    Result := 'SKIPPED'
  else if AResult.Passed then
    Result := 'PASS'
  else
    Result := 'FAILED';
end;

function TPopupPerfAutomaticReport.Build: string;
var
  Builder: TStringBuilder;
  Item: TPopupPerfScenarioResult;
  Executed, Passed, Failed, Skipped: Integer;
begin
  Executed := 0; Passed := 0; Failed := 0; Skipped := 0;
  Builder := TStringBuilder.Create;
  try
    Builder.AppendLine('UniPopupPerformanceLab Automatic Regression Report');
    Builder.AppendLine('Started: ' + DateTimeToStr(FStartedAt));
    Builder.AppendLine('Platform: ' + TOSVersion.ToString);
    Builder.AppendLine;
    for Item in FResults do
    begin
      Inc(Executed);
      if Item.Skipped then Inc(Skipped) else if Item.Passed then Inc(Passed) else Inc(Failed);
      Builder.AppendLine('============================================================');
      Builder.AppendLine('Scenario: ' + Item.ScenarioName);
      Builder.AppendLine('State Transition:');
      Builder.AppendLine(Item.StateTransition);
      Builder.AppendLine(Item.RuntimeState);
      Builder.AppendLine('Metrics:'); Builder.AppendLine(Item.MetricsText);
      Builder.AppendLine('Validation:'); Builder.AppendLine(Item.ValidationText);
      Builder.AppendLine('Result: ' + ResultName(Item));
      if Item.Notes <> '' then Builder.AppendLine('Notes: ' + Item.Notes);
      Builder.AppendLine;
    end;
    Builder.AppendLine('SUMMARY');
    Builder.AppendLine('Scenario | Verification | Result | Avg | P95 | Max | Popup Paint | Popup Realign | Notes');
    for Item in FResults do
      Builder.AppendLine(Format('%s | %s | %s | %.3f | %.3f | %.3f | %d | %d | %s',
        [Item.ScenarioName, Item.Verification, ResultName(Item),
         Item.Snapshot.MarkerAverageMs, Item.Snapshot.MarkerP95Ms,
         Item.Snapshot.MarkerMaxMs, Item.PopupPaintCalls,
         Item.PopupRealignCalls, Item.Notes]));
    Builder.AppendLine;
    Builder.AppendLine(Format('Executed: %d', [Executed]));
    Builder.AppendLine(Format('Passed: %d', [Passed]));
    Builder.AppendLine(Format('Failed: %d', [Failed]));
    Builder.AppendLine(Format('Skipped: %d', [Skipped]));
    Builder.AppendLine(Format('Total duration: %.3f ms', [FDurationMs]));
    Result := Builder.ToString;
  finally
    Builder.Free;
  end;
end;

end.