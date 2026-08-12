unit UniList.Diagnostics;

interface

type
  TUniDiagnosticValue = (
    udvNotEvaluated,
    udvFalse,
    udvTrue
  );

  TUniPopupOpenTrace = record
    MouseClickEntered: Boolean;
    ToggleDropDownEntered: Boolean;
    OpenDropDownEntered: Boolean;
    ShowPopupEntered: Boolean;
    PopupShownCallback: Boolean;
    DoDropDownOpenedEntered: Boolean;
    Destroying: TUniDiagnosticValue;
    AbsoluteEnabled: TUniDiagnosticValue;
    PopupContentAssigned: TUniDiagnosticValue;
    PopupAlreadyOpeningOrOpen: TUniDiagnosticValue;
    DesignMode: TUniDiagnosticValue;
    OnOpeningResult: TUniDiagnosticValue;
    DoDropDownOpeningResult: TUniDiagnosticValue;
    AnchorAssigned: TUniDiagnosticValue;
    ContentAssigned: TUniDiagnosticValue;
    AnchorFormAssigned: TUniDiagnosticValue;
    FormActive: TUniDiagnosticValue;
    AnchorParentedVisible: TUniDiagnosticValue;
  end;

var
  UniPopupDiagnosticsEnabled: Boolean = False;

procedure UniPopupDiagnosticsReset;
procedure UniPopupDiagnosticsDisable;
function UniPopupDiagnosticsSnapshot: TUniPopupOpenTrace;
function UniDiagnosticValue(const AValue: Boolean): TUniDiagnosticValue;
function UniDiagnosticValueText(const AValue: TUniDiagnosticValue): string;
function UniPopupOpenFirstStoppedStage(
  const ATrace: TUniPopupOpenTrace): string;

procedure UniTraceMouseClickEntered;
procedure UniTraceToggleDropDownEntered;
procedure UniTraceOpenDropDownEntered;
procedure UniTraceShowPopupEntered;
procedure UniTracePopupShownCallback;
procedure UniTraceDoDropDownOpenedEntered;
procedure UniTraceDestroying(const AValue: Boolean);
procedure UniTraceAbsoluteEnabled(const AValue: Boolean);
procedure UniTracePopupContentAssigned(const AValue: Boolean);
procedure UniTracePopupAlreadyOpeningOrOpen(const AValue: Boolean);
procedure UniTraceDesignMode(const AValue: Boolean);
procedure UniTraceOnOpeningResult(const AValue: Boolean);
procedure UniTraceDoDropDownOpeningResult(const AValue: Boolean);
procedure UniTraceAnchorAssigned(const AValue: Boolean);
procedure UniTraceContentAssigned(const AValue: Boolean);
procedure UniTraceAnchorFormAssigned(const AValue: Boolean);
procedure UniTraceFormActive(const AValue: Boolean);
procedure UniTraceAnchorParentedVisible(const AValue: Boolean);

implementation

var
  GTrace: TUniPopupOpenTrace;

function UniDiagnosticValue(const AValue: Boolean): TUniDiagnosticValue;
begin
  if AValue then
    Result := udvTrue
  else
    Result := udvFalse;
end;

procedure UniPopupDiagnosticsReset;
begin
  GTrace := Default(TUniPopupOpenTrace);
  GTrace.Destroying := udvNotEvaluated;
  GTrace.AbsoluteEnabled := udvNotEvaluated;
  GTrace.PopupContentAssigned := udvNotEvaluated;
  GTrace.PopupAlreadyOpeningOrOpen := udvNotEvaluated;
  GTrace.DesignMode := udvNotEvaluated;
  GTrace.OnOpeningResult := udvNotEvaluated;
  GTrace.DoDropDownOpeningResult := udvNotEvaluated;
  GTrace.AnchorAssigned := udvNotEvaluated;
  GTrace.ContentAssigned := udvNotEvaluated;
  GTrace.AnchorFormAssigned := udvNotEvaluated;
  GTrace.FormActive := udvNotEvaluated;
  GTrace.AnchorParentedVisible := udvNotEvaluated;
end;

procedure UniPopupDiagnosticsDisable;
begin
  UniPopupDiagnosticsEnabled := False;
end;

function UniPopupDiagnosticsSnapshot: TUniPopupOpenTrace;
begin
  Result := GTrace;
end;

function UniDiagnosticValueText(const AValue: TUniDiagnosticValue): string;
begin
  case AValue of
    udvFalse: Result := 'False';
    udvTrue: Result := 'True';
  else
    Result := 'Not evaluated';
  end;
end;

function UniPopupOpenFirstStoppedStage(
  const ATrace: TUniPopupOpenTrace): string;
begin
  if not ATrace.MouseClickEntered then
    Exit('MouseClick entered');
  if not ATrace.ToggleDropDownEntered then
    Exit('ToggleDropDown entered');
  if not ATrace.OpenDropDownEntered then
    Exit('OpenDropDown entered');
  if not ATrace.ShowPopupEntered then
    Exit('ShowPopup entered');
  if not ATrace.PopupShownCallback then
    Exit('PopupShown callback');
  if not ATrace.DoDropDownOpenedEntered then
    Exit('DoDropDownOpened entered');
  Result := 'None';
end;

procedure UniTraceMouseClickEntered;
begin
  GTrace.MouseClickEntered := True;
end;

procedure UniTraceToggleDropDownEntered;
begin
  GTrace.ToggleDropDownEntered := True;
end;

procedure UniTraceOpenDropDownEntered;
begin
  GTrace.OpenDropDownEntered := True;
end;

procedure UniTraceShowPopupEntered;
begin
  GTrace.ShowPopupEntered := True;
end;

procedure UniTracePopupShownCallback;
begin
  GTrace.PopupShownCallback := True;
end;

procedure UniTraceDoDropDownOpenedEntered;
begin
  GTrace.DoDropDownOpenedEntered := True;
end;

procedure UniTraceDestroying(const AValue: Boolean);
begin
  GTrace.Destroying := UniDiagnosticValue(AValue);
end;

procedure UniTraceAbsoluteEnabled(const AValue: Boolean);
begin
  GTrace.AbsoluteEnabled := UniDiagnosticValue(AValue);
end;

procedure UniTracePopupContentAssigned(const AValue: Boolean);
begin
  GTrace.PopupContentAssigned := UniDiagnosticValue(AValue);
end;

procedure UniTracePopupAlreadyOpeningOrOpen(const AValue: Boolean);
begin
  GTrace.PopupAlreadyOpeningOrOpen := UniDiagnosticValue(AValue);
end;

procedure UniTraceDesignMode(const AValue: Boolean);
begin
  GTrace.DesignMode := UniDiagnosticValue(AValue);
end;

procedure UniTraceOnOpeningResult(const AValue: Boolean);
begin
  GTrace.OnOpeningResult := UniDiagnosticValue(AValue);
end;

procedure UniTraceDoDropDownOpeningResult(const AValue: Boolean);
begin
  GTrace.DoDropDownOpeningResult := UniDiagnosticValue(AValue);
end;

procedure UniTraceAnchorAssigned(const AValue: Boolean);
begin
  GTrace.AnchorAssigned := UniDiagnosticValue(AValue);
end;

procedure UniTraceContentAssigned(const AValue: Boolean);
begin
  GTrace.ContentAssigned := UniDiagnosticValue(AValue);
end;

procedure UniTraceAnchorFormAssigned(const AValue: Boolean);
begin
  GTrace.AnchorFormAssigned := UniDiagnosticValue(AValue);
end;

procedure UniTraceFormActive(const AValue: Boolean);
begin
  GTrace.FormActive := UniDiagnosticValue(AValue);
end;

procedure UniTraceAnchorParentedVisible(const AValue: Boolean);
begin
  GTrace.AnchorParentedVisible := UniDiagnosticValue(AValue);
end;

initialization
  UniPopupDiagnosticsReset;

end.