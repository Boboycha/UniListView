program PopupHostSmoke;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.StartUpCopy,
  System.Math,
  System.Types,
  System.UITypes,
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
  UniList.Popup in '..\src\UniList.Popup.pas';

type
  TPopupEventRecorder = class
  private
    FShownCount: Integer;
    FClosedCount: Integer;
    FLastReason: TUniPopupCloseReason;
  public
    procedure PopupShown(Sender: TObject);
    procedure PopupClosed(Sender: TObject;
      const AReason: TUniPopupCloseReason);
    property ShownCount: Integer read FShownCount;
    property ClosedCount: Integer read FClosedCount;
    property LastReason: TUniPopupCloseReason read FLastReason;
  end;

procedure TPopupEventRecorder.PopupShown(Sender: TObject);
begin
  Inc(FShownCount);
end;

procedure TPopupEventRecorder.PopupClosed(Sender: TObject;
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

procedure PrepareForm(const AForm: TForm; const AAnchor: TControl;
  const AContent: TControl);
begin
  AForm.SetBounds(0, 0, 640, 480);
  AForm.Active := True;
  AAnchor.Parent := AForm;
  AAnchor.SetBounds(100, 100, 180, 34);
  AContent.Parent := AForm;
  AContent.SetBounds(20, 20, 300, 500);
  AContent.Visible := False;
end;

var
  Anchor: TLayout;
  Content: TLayout;
  EventRecorder: TPopupEventRecorder;
  Form: TForm;
  Host: TUniPopupHost;
  Key: Word;
  KeyChar: WideChar;

begin
  Application.Initialize;
  Host := TUniPopupHost.Create(nil);
  EventRecorder := TPopupEventRecorder.Create;
  Form := TForm.Create(nil);
  Anchor := TLayout.Create(Form);
  Content := TLayout.Create(Form);
  try
    Require(Host.Placement = uppAuto, 'Default placement must be Auto');
    Require(Host.WidthMode = upwAnchor,
      'Default width mode must match the anchor');
    Require(Host.CloseOnEscape, 'Escape must close by default');
    Require(Host.CloseOnOutsideClick,
      'Outside click must close by default');
    Require(SameValue(Host.PopupWidth, 240),
      'Unexpected default popup width');
    Require(SameValue(Host.MaxPopupHeight, 320),
      'Unexpected default maximum height');
    Require(not Host.Resizable, 'Resize must be disabled by default');
    Require(Host.RememberUserSize,
      'RememberUserSize must be enabled by default');
    Require(SameValue(Host.MinPopupWidth, 96),
      'Unexpected default minimum width');
    Require(SameValue(Host.MinPopupHeight, 64),
      'Unexpected default minimum height');
    Require(SameValue(Host.MaxPopupWidth, 0),
      'Default maximum width must be unlimited');

    Host.OnPopupShown := EventRecorder.PopupShown;
    Host.OnPopupClosed := EventRecorder.PopupClosed;
    PrepareForm(Form, Anchor, Content);

    Host.MaxPopupHeight := 120;
    Host.ShowPopup(Anchor, Content);
    Require(Host.IsOpen, 'ShowPopup did not open the popup');
    Require(EventRecorder.ShownCount = 1,
      'OnPopupShown must fire exactly once');
    Require(SameValue(Host.PopupBounds.Width, Anchor.Width),
      'Anchor width mode returned the wrong width');
    Require(Host.PopupBounds.Height <= 120,
      'Maximum popup height was ignored');

    Host.ClosePopup;
    Require(not Host.IsOpen, 'ClosePopup did not close the popup');
    Require(EventRecorder.ClosedCount = 1,
      'OnPopupClosed must fire exactly once');
    Require(EventRecorder.LastReason = upcrProgrammatic,
      'Wrong programmatic close reason');
    Host.ClosePopup;
    Require(EventRecorder.ClosedCount = 1,
      'Repeated ClosePopup fired the event again');

    Host.WidthMode := upwContent;
    Host.ShowPopup(Anchor, Content);
    Require(SameValue(Host.PopupBounds.Width, 300),
      'Content width mode did not use the wider content');
    Host.ClosePopup;

    Content.Width := 120;
    Host.ShowPopup(Anchor, Content);
    Require(SameValue(Host.PopupBounds.Width, Anchor.Width),
      'Content width mode created a popup narrower than its anchor');
    Host.ClosePopup;
    Content.Width := 300;

    Host.Resizable := True;
    Host.MinPopupWidth := 140;
    Host.MinPopupHeight := 80;
    Host.MaxPopupWidth := 420;
    Host.MaxPopupHeight := 240;
    Require(Host.Resizable and SameValue(Host.MinPopupWidth, 140) and
      SameValue(Host.MinPopupHeight, 80) and
      SameValue(Host.MaxPopupWidth, 420) and
      SameValue(Host.MaxPopupHeight, 240),
      'Resize constraints were not stored');

    Host.WidthMode := upwFixed;
    Host.PopupWidth := 260;
    Host.Placement := uppAbove;
    Host.ShowPopup(Anchor, Content);
    Require(SameValue(Host.PopupBounds.Width, 260),
      'Fixed width mode returned the wrong width');
    Require(Host.PopupBounds.Bottom <= Anchor.Position.Y,
      'Above placement opened below the anchor');

    Key := vkEscape;
    KeyChar := #0;
    Form.KeyDown(Key, KeyChar, []);
    Require(not Host.IsOpen, 'Escape did not close the popup');
    Require(EventRecorder.LastReason = upcrEscape,
      'Wrong Escape close reason');

    Host.Placement := uppBelow;
    Host.ShowPopup(Anchor, Content);
    Require(Host.PopupBounds.Top >= Anchor.Position.Y + Anchor.Height,
      'Below placement opened above the anchor');
    Anchor.Free;
    Require(not Host.IsOpen, 'Destroying the anchor left popup open');
    Require(EventRecorder.LastReason = upcrOwnerDestroyed,
      'Wrong anchor destruction close reason');

    Anchor := TLayout.Create(Form);
    PrepareForm(Form, Anchor, Content);
    Host.ShowPopup(Anchor, Content);
    FreeAndNil(Form);
    Require(not Host.IsOpen, 'Destroying the form left popup open');
    Require(EventRecorder.LastReason = upcrOwnerDestroyed,
      'Wrong form destruction close reason');

    Writeln('PopupHostSmoke: PASS');
  finally
    Host.Free;
    EventRecorder.Free;
    Form.Free;
  end;
end.
