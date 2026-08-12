unit PopupPerf.Diagnostics;

interface

type
  TPopupDiagnosticNode = (
    pdnPopupComponent,
    pdnLookupPopup,
    pdnDropDown
  );

  TPopupDiagnosticCounts = record
    PaintCount: Int64;
    RealignCount: Int64;
  end;

  TPopupDiagnosticsSnapshot = record
    Counts: array[TPopupDiagnosticNode] of TPopupDiagnosticCounts;
  end;

procedure PopupDiagnosticsReset;
procedure PopupDiagnosticsStart;
procedure PopupDiagnosticsStop;
procedure PopupDiagnosticsRecordPaint(const ANode: TPopupDiagnosticNode);
procedure PopupDiagnosticsRecordRealign(const ANode: TPopupDiagnosticNode);
function PopupDiagnosticsSnapshot: TPopupDiagnosticsSnapshot;

implementation

var
  GSnapshot: TPopupDiagnosticsSnapshot;
  GRunning: Boolean;

procedure PopupDiagnosticsReset;
begin
  GSnapshot := Default(TPopupDiagnosticsSnapshot);
  GRunning := False;
end;

procedure PopupDiagnosticsStart;
begin
  PopupDiagnosticsReset;
  GRunning := True;
end;

procedure PopupDiagnosticsStop;
begin
  GRunning := False;
end;

procedure PopupDiagnosticsRecordPaint(const ANode: TPopupDiagnosticNode);
begin
  if GRunning then
    Inc(GSnapshot.Counts[ANode].PaintCount);
end;

procedure PopupDiagnosticsRecordRealign(const ANode: TPopupDiagnosticNode);
begin
  if GRunning then
    Inc(GSnapshot.Counts[ANode].RealignCount);
end;

function PopupDiagnosticsSnapshot: TPopupDiagnosticsSnapshot;
begin
  Result := GSnapshot;
end;

end.