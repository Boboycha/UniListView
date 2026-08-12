program DropDownCoreSmoke;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.StartUpCopy,
  System.Math,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Layouts,
  UniList.Types in '..\src\UniList.Types.pas',
  UniList.Items in '..\src\UniList.Items.pas',
  UniList.Vector in '..\src\UniList.Vector.pas',
  UniList.Text in '..\src\UniList.Text.pas',
  UniList.Columns in '..\src\UniList.Columns.pas',
  UniList.Theme in '..\src\UniList.Theme.pas',
  UniList.Rules in '..\src\UniList.Rules.pas',
  UniList.Search in '..\src\UniList.Search.pas',
  UniList.Control in '..\src\UniList.Control.pas',
  UniList.Popup in '..\src\UniList.Popup.pas',
  UniList.DropDown in '..\src\UniList.DropDown.pas';

type
  TDropDownEventRecorder = class
  private
    FAllowOpening: Boolean;
    FOpeningCount: Integer;
    FOpenedCount: Integer;
    FClosedCount: Integer;
    FLastReason: TUniPopupCloseReason;
  public
    constructor Create;
    procedure Opening(Sender: TObject; var AAllow: Boolean);
    procedure Opened(Sender: TObject);
    procedure Closed(Sender: TObject;
      const AReason: TUniPopupCloseReason);
    property AllowOpening: Boolean read FAllowOpening write FAllowOpening;
    property OpeningCount: Integer read FOpeningCount;
    property OpenedCount: Integer read FOpenedCount;
    property ClosedCount: Integer read FClosedCount;
    property LastReason: TUniPopupCloseReason read FLastReason;
  end;

constructor TDropDownEventRecorder.Create;
begin
  inherited;
  FAllowOpening := True;
end;

procedure TDropDownEventRecorder.Opening(Sender: TObject;
  var AAllow: Boolean);
begin
  Inc(FOpeningCount);
  AAllow := FAllowOpening;
end;

procedure TDropDownEventRecorder.Opened(Sender: TObject);
begin
  Inc(FOpenedCount);
end;

procedure TDropDownEventRecorder.Closed(Sender: TObject;
  const AReason: TUniPopupCloseReason);
begin
  Inc(FClosedCount);
  FLastReason := AReason;
end;

procedure Require(const ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

var
  Content: TLayout;
  DropDown: TUniDropDown;
  EventRecorder: TDropDownEventRecorder;
  Form: TForm;

begin
  Application.Initialize;
  Form := TForm.Create(nil);
  DropDown := TUniDropDown.Create(Form);
  Content := TLayout.Create(Form);
  EventRecorder := TDropDownEventRecorder.Create;
  try
    Form.SetBounds(0, 0, 640, 480);
    Form.Active := True;
    DropDown.Parent := Form;
    DropDown.SetBounds(40, 40, 220, 36);
    Content.Parent := Form;
    Content.SetBounds(20, 20, 280, 160);
    Content.Visible := False;
    DropDown.PopupContent := Content;
    DropDown.OnOpening := EventRecorder.Opening;
    DropDown.OnOpened := EventRecorder.Opened;
    DropDown.OnClosed := EventRecorder.Closed;

    Require(DropDown.OpenOnFieldClick,
      'OpenOnFieldClick must be enabled by default');
    Require(DropDown.DropDownPlacement = uppAuto,
      'Unexpected default placement');
    Require(DropDown.DropDownWidthMode = upwAnchor,
      'Unexpected default width mode');
    Require(DropDown.CloseOnEscape,
      'Escape must close by default');
    Require(DropDown.CloseOnOutsideClick,
      'Outside click must close by default');
    Require(SameValue(DropDown.DropDownWidth, 240),
      'Unexpected default popup width');
    Require(SameValue(DropDown.DropDownMaxHeight, 320),
      'Unexpected default maximum height');
    Require(not DropDown.Resizable,
      'Dropdown resize must be disabled by default');
    Require(DropDown.RememberUserSize,
      'Dropdown must remember user size by default');
    DropDown.Resizable := True;
    DropDown.MinPopupWidth := 150;
    DropDown.MinPopupHeight := 90;
    DropDown.MaxPopupWidth := 500;
    DropDown.MaxPopupHeight := 280;
    Require(DropDown.PopupHost.Resizable and
      SameValue(DropDown.PopupHost.MinPopupWidth, 150) and
      SameValue(DropDown.PopupHost.MinPopupHeight, 90) and
      SameValue(DropDown.PopupHost.MaxPopupWidth, 500) and
      SameValue(DropDown.PopupHost.MaxPopupHeight, 280),
      'Dropdown resize proxies did not update PopupHost');

    EventRecorder.AllowOpening := False;
    DropDown.OpenDropDown;
    Require(not DropDown.IsDropDownOpen,
      'Cancelable OnOpening was ignored');
    Require(EventRecorder.OpenedCount = 0,
      'OnOpened fired after canceled opening');

    EventRecorder.AllowOpening := True;
    DropDown.OpenDropDown;
    Require(DropDown.IsDropDownOpen,
      'OpenDropDown did not open');
    Require(EventRecorder.OpenedCount = 1,
      'OnOpened must fire exactly once');
    DropDown.CloseDropDown;
    Require(not DropDown.IsDropDownOpen,
      'CloseDropDown did not close');
    Require(EventRecorder.ClosedCount = 1,
      'OnClosed must fire exactly once');
    Require(EventRecorder.LastReason = upcrProgrammatic,
      'Unexpected close reason');
    DropDown.CloseDropDown;
    Require(EventRecorder.ClosedCount = 1,
      'Repeated close fired OnClosed again');

    DropDown.Enabled := False;
    DropDown.OpenDropDown;
    Require(not DropDown.IsDropDownOpen,
      'Disabled dropdown opened');

    Writeln('DropDownCoreSmoke: PASS');
  finally
    EventRecorder.Free;
    Form.Free;
  end;
end.
