unit PopupPerf.TestContent;

interface

uses
  System.Classes, System.UITypes, FMX.Types, FMX.Controls, FMX.Graphics,
  FMX.Layouts,
  FMX.Objects, UniList.Control, UniList.DropDown, UniList.Lookup,
  UniList.Popup;

type
  TPopupPerfTestMode = (
    pptBaseline,
    pptDropDownOnly,
    pptDropDownWithContent,
    pptLookupOnly,
    pptLookupWithInternalList,
    pptDropDownAndLookup);

  TPopupPerfContentMode = (
    ppcNone,
    ppcEmptyLayout,
    ppcRectangle,
    ppcStandardTree,
    ppcUniList10,
    ppcUniList1000);

  TPopupPerfState = (
    ppsNoPopupComponent,
    ppsAssignedClosed,
    ppsOpen,
    ppsClosedAfterOpen,
    ppsDetached);

  TPopupPerfDropDown = class(TUniDropDown)
  private
    FInteractionOpened: Boolean;
    FInteractionClosed: Boolean;
    FInteractionEnteredScene: Boolean;
  protected
    procedure Paint; override;
    procedure DoRealign; override;
    procedure DoDropDownOpened; override;
    procedure DoDropDownClosed(
      const AReason: TUniPopupCloseReason); override;
  public
    procedure ResetInteractionTrace;
    procedure PerformUserClick;
    property InteractionOpened: Boolean read FInteractionOpened;
    property InteractionClosed: Boolean read FInteractionClosed;
    property InteractionEnteredScene: Boolean
      read FInteractionEnteredScene;
  end;

  TPopupPerfLookup = class(TUniLookup)
  private
    FInteractionOpened: Boolean;
    FInteractionClosed: Boolean;
    FInteractionEnteredScene: Boolean;
  protected
    procedure Paint; override;
    procedure DoRealign; override;
    procedure DoDropDownOpened; override;
    procedure DoDropDownClosed(
      const AReason: TUniPopupCloseReason); override;
  public
    procedure ResetInteractionTrace;
    procedure PerformUserClick;
    property InteractionOpened: Boolean read FInteractionOpened;
    property InteractionClosed: Boolean read FInteractionClosed;
    property InteractionEnteredScene: Boolean
      read FInteractionEnteredScene;
  end;

  TPopupPerfLayout = class(TLayout)
  protected
    procedure Paint; override;
    procedure DoRealign; override;
  end;

  TPopupPerfRectangle = class(TRectangle)
  protected
    procedure Paint; override;
    procedure DoRealign; override;
  end;

  TPopupPerfContentFactory = class
  public
    class function CreateContent(const AOwner: TComponent;
      const AMode: TPopupPerfContentMode;
      out AUniListView: TUniListView): TControl; static;
    class procedure FillList(const AListView: TUniListView;
      const ACount: Integer); static;
    class function LookupItemCount(
      const AMode: TPopupPerfContentMode): Integer; static;
  end;

function PopupPerfTestModeName(const AMode: TPopupPerfTestMode): string;
function PopupPerfContentModeName(const AMode: TPopupPerfContentMode): string;
function PopupPerfStateName(const AState: TPopupPerfState): string;

implementation

uses
  System.SysUtils, FMX.StdCtrls, FMX.Edit, UniList.Items, UniList.Columns,
  PopupPerf.Metrics, PopupPerf.Diagnostics;

const
  CPopupContentWidth = 420.0;
  CPopupContentHeight = 300.0;
  CStandardTreeRowHeight = 32.0;
  CStandardTreeRowCount = 8;
  CLookupSmallItemCount = 10;
  CLookupLargeItemCount = 1000;

procedure TPopupPerfDropDown.ResetInteractionTrace;
begin
  FInteractionOpened := False;
  FInteractionClosed := False;
  FInteractionEnteredScene := False;
end;

procedure TPopupPerfDropDown.PerformUserClick;
var
  X: Single;
  Y: Single;
begin
  X := Width * 0.5;
  Y := Height * 0.5;
  MouseDown(TMouseButton.mbLeft, [], X, Y);
  MouseClick(TMouseButton.mbLeft, [], X, Y);
  MouseUp(TMouseButton.mbLeft, [], X, Y);
end;

procedure TPopupPerfDropDown.DoDropDownOpened;
begin
  inherited;
  FInteractionOpened := True;
  FInteractionEnteredScene := (PopupContent <> nil) and
    (PopupContent.Parent <> nil) and (PopupContent.Root <> nil) and
    (PopupContent.Scene <> nil);
end;

procedure TPopupPerfDropDown.DoDropDownClosed(
  const AReason: TUniPopupCloseReason);
begin
  inherited;
  FInteractionClosed := True;
end;

procedure TPopupPerfLookup.ResetInteractionTrace;
begin
  FInteractionOpened := False;
  FInteractionClosed := False;
  FInteractionEnteredScene := False;
end;

procedure TPopupPerfLookup.PerformUserClick;
var
  X: Single;
  Y: Single;
begin
  X := Width * 0.5;
  Y := Height * 0.5;
  MouseDown(TMouseButton.mbLeft, [], X, Y);
  MouseClick(TMouseButton.mbLeft, [], X, Y);
  MouseUp(TMouseButton.mbLeft, [], X, Y);
end;

procedure TPopupPerfLookup.DoDropDownOpened;
begin
  inherited;
  FInteractionOpened := True;
  FInteractionEnteredScene := (PopupContent <> nil) and
    (PopupContent.Parent <> nil) and (PopupContent.Root <> nil) and
    (PopupContent.Scene <> nil);
end;

procedure TPopupPerfLookup.DoDropDownClosed(
  const AReason: TUniPopupCloseReason);
begin
  inherited;
  FInteractionClosed := True;
end;
procedure TPopupPerfDropDown.Paint;
begin
  PopupDiagnosticsRecordPaint(pdnDropDown);
  PopupPerfRecordTestPaint;
  inherited;
end;

procedure TPopupPerfDropDown.DoRealign;
begin
  PopupDiagnosticsRecordRealign(pdnDropDown);
  PopupPerfRecordTestRealign;
  inherited;
end;

procedure TPopupPerfLookup.Paint;
begin
  PopupDiagnosticsRecordPaint(pdnLookupPopup);
  PopupPerfRecordTestPaint;
  inherited;
end;

procedure TPopupPerfLookup.DoRealign;
begin
  PopupDiagnosticsRecordRealign(pdnLookupPopup);
  PopupPerfRecordTestRealign;
  inherited;
end;

procedure TPopupPerfLayout.Paint;
begin
  PopupDiagnosticsRecordPaint(pdnPopupComponent);
  inherited;
end;

procedure TPopupPerfLayout.DoRealign;
begin
  PopupDiagnosticsRecordRealign(pdnPopupComponent);
  PopupPerfRecordPopupContentRealign;
  inherited;
end;

procedure TPopupPerfRectangle.Paint;
begin
  PopupDiagnosticsRecordPaint(pdnPopupComponent);
  PopupPerfRecordPopupContentPaint;
  inherited;
end;

procedure TPopupPerfRectangle.DoRealign;
begin
  PopupDiagnosticsRecordRealign(pdnPopupComponent);
  PopupPerfRecordPopupContentRealign;
  inherited;
end;

class procedure TPopupPerfContentFactory.FillList(
  const AListView: TUniListView; const ACount: Integer);
var
  Index: Integer;
  Item: TUniListItem;
begin
  if AListView = nil then
    Exit;
  AListView.BeginUpdate;
  try
    AListView.Clear;
    for Index := 0 to ACount - 1 do
    begin
      Item := AListView.AddItem('Popup item ' + IntToStr(Index + 1),
        'Group ' + IntToStr(Index mod 10),
        'Status ' + IntToStr(Index mod 3));
      Item.SetField('name', Item.Title);
    end;
  finally
    AListView.EndUpdate;
  end;
  AListView.ResetPerformanceCounters;
end;

class function TPopupPerfContentFactory.LookupItemCount(
  const AMode: TPopupPerfContentMode): Integer;
begin
  case AMode of
    ppcUniList10:
      Result := CLookupSmallItemCount;
    ppcUniList1000:
      Result := CLookupLargeItemCount;
  else
    Result := 0;
  end;
end;

class function TPopupPerfContentFactory.CreateContent(
  const AOwner: TComponent; const AMode: TPopupPerfContentMode;
  out AUniListView: TUniListView): TControl;
var
  RootLayout: TPopupPerfLayout;
  RootRectangle: TPopupPerfRectangle;
  LabelControl: TLabel;
  EditControl: TEdit;
  ButtonControl: TButton;
  Index: Integer;
begin
  Result := nil;
  AUniListView := nil;
  case AMode of
    ppcNone:
      Exit;
    ppcEmptyLayout:
      begin
        RootLayout := TPopupPerfLayout.Create(AOwner);
        RootLayout.SetBounds(0, 0, CPopupContentWidth, CPopupContentHeight);
        Result := RootLayout;
      end;
    ppcRectangle:
      begin
        RootRectangle := TPopupPerfRectangle.Create(AOwner);
        RootRectangle.SetBounds(0, 0, CPopupContentWidth,
          CPopupContentHeight);
        RootRectangle.Fill.Color := $FFF3F5F7;
        RootRectangle.Stroke.Color := $FF68737D;
        Result := RootRectangle;
      end;
    ppcStandardTree:
      begin
        RootRectangle := TPopupPerfRectangle.Create(AOwner);
        RootRectangle.SetBounds(0, 0, CPopupContentWidth,
          CPopupContentHeight);
        RootRectangle.Fill.Color := $FFF3F5F7;
        RootRectangle.Stroke.Color := $FF68737D;
        for Index := 0 to CStandardTreeRowCount - 1 do
        begin
          LabelControl := TLabel.Create(RootRectangle);
          LabelControl.Parent := RootRectangle;
          LabelControl.Align := TAlignLayout.Top;
          LabelControl.Height := CStandardTreeRowHeight;
          LabelControl.Text := 'Standard label ' + IntToStr(Index + 1);
        end;
        EditControl := TEdit.Create(RootRectangle);
        EditControl.Parent := RootRectangle;
        EditControl.Align := TAlignLayout.Bottom;
        EditControl.TextPrompt := 'Standard edit';
        ButtonControl := TButton.Create(RootRectangle);
        ButtonControl.Parent := RootRectangle;
        ButtonControl.Align := TAlignLayout.Bottom;
        ButtonControl.Text := 'Standard button';
        Result := RootRectangle;
      end;
    ppcUniList10, ppcUniList1000:
      begin
        RootRectangle := TPopupPerfRectangle.Create(AOwner);
        RootRectangle.SetBounds(0, 0, CPopupContentWidth,
          CPopupContentHeight);
        RootRectangle.Fill.Color := $FFF3F5F7;
        RootRectangle.Stroke.Color := $FF68737D;
        AUniListView := TUniListView.Create(RootRectangle);
        AUniListView.Parent := RootRectangle;
        AUniListView.Align := TAlignLayout.Client;
        AUniListView.Columns.Add.FieldName := 'name';
        if AMode = ppcUniList10 then
          FillList(AUniListView, CLookupSmallItemCount)
        else
          FillList(AUniListView, CLookupLargeItemCount);
        Result := RootRectangle;
      end;
  end;
end;

function PopupPerfTestModeName(const AMode: TPopupPerfTestMode): string;
begin
  case AMode of
    pptBaseline: Result := 'Baseline - no Uni controls';
    pptDropDownOnly: Result := 'TUniDropDown only';
    pptDropDownWithContent: Result := 'TUniDropDown + PopupComponent';
    pptLookupOnly: Result := 'TUniLookup only';
    pptLookupWithInternalList: Result := 'TUniLookup + internal list';
    pptDropDownAndLookup: Result := 'TUniDropDown and TUniLookup together';
  else
    Result := 'Unknown';
  end;
end;

function PopupPerfContentModeName(
  const AMode: TPopupPerfContentMode): string;
begin
  case AMode of
    ppcNone: Result := 'None';
    ppcEmptyLayout: Result := 'Empty TLayout';
    ppcRectangle: Result := 'Standard TRectangle';
    ppcStandardTree: Result := 'Small standard FMX control tree';
    ppcUniList10: Result := 'TUniListView with 10 items';
    ppcUniList1000: Result := 'TUniListView with 1000 items';
  else
    Result := 'Unknown';
  end;
end;

function PopupPerfStateName(const AState: TPopupPerfState): string;
begin
  case AState of
    ppsNoPopupComponent: Result := 'No PopupComponent';
    ppsAssignedClosed: Result := 'PopupComponent assigned, popup closed';
    ppsOpen: Result := 'Popup open';
    ppsClosedAfterOpen: Result := 'Popup closed after first open';
    ppsDetached: Result := 'PopupComponent detached';
  else
    Result := 'Unknown';
  end;
end;

end.