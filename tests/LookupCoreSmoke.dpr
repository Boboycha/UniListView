program LookupCoreSmoke;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.Classes,
  System.Math,
  System.UITypes,
  System.StartUpCopy,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  UniList.Types in '..\src\UniList.Types.pas',
  UniList.Canvas in '..\src\UniList.Canvas.pas',
  UniList.Items in '..\src\UniList.Items.pas',
  UniList.Vector in '..\src\UniList.Vector.pas',
  UniList.Text in '..\src\UniList.Text.pas',
  UniList.Columns in '..\src\UniList.Columns.pas',
  UniList.Theme in '..\src\UniList.Theme.pas',
  UniList.Rules in '..\src\UniList.Rules.pas',
  UniList.Search in '..\src\UniList.Search.pas',
  UniList.Control in '..\src\UniList.Control.pas',
  UniList.Popup in '..\src\UniList.Popup.pas',
  UniList.DropDown in '..\src\UniList.DropDown.pas',
  UniList.Lookup in '..\src\UniList.Lookup.pas';

type
  TTestLookup = class(TUniLookup)
  public
    procedure ClickField;
  end;

  TLookupEventRecorder = class
  private
    FAllowChange: Boolean;
    FEvents: TStringList;
    FSelectedItem: TUniListItem;
  public
    constructor Create;
    destructor Destroy; override;
    procedure SelectionChanging(Sender: TObject;
      const AOldIndex, ANewIndex: Integer; var AAllow: Boolean);
    procedure SelectionChanged(Sender: TObject;
      const AItemIndex: Integer);
    procedure ItemSelected(Sender: TObject; const AItem: TUniListItem);
    property AllowChange: Boolean read FAllowChange write FAllowChange;
    property Events: TStringList read FEvents;
    property SelectedItem: TUniListItem read FSelectedItem;
  end;

procedure TTestLookup.ClickField;
begin
  MouseClick(TMouseButton.mbLeft, [], Width * 0.5, Height * 0.5);
end;

constructor TLookupEventRecorder.Create;
begin
  inherited;
  FAllowChange := True;
  FEvents := TStringList.Create;
end;

destructor TLookupEventRecorder.Destroy;
begin
  FEvents.Free;
  inherited;
end;

procedure TLookupEventRecorder.SelectionChanging(Sender: TObject;
  const AOldIndex, ANewIndex: Integer; var AAllow: Boolean);
begin
  FEvents.Add(Format('changing:%d:%d', [AOldIndex, ANewIndex]));
  AAllow := FAllowChange;
end;

procedure TLookupEventRecorder.SelectionChanged(Sender: TObject;
  const AItemIndex: Integer);
begin
  FEvents.Add(Format('changed:%d', [AItemIndex]));
end;

procedure TLookupEventRecorder.ItemSelected(Sender: TObject;
  const AItem: TUniListItem);
begin
  FSelectedItem := AItem;
  if AItem = nil then
    FEvents.Add('selected:nil')
  else
    FEvents.Add('selected:' + AItem.Title);
end;

procedure Require(const ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

var
  EventRecorder: TLookupEventRecorder;
  Form: TForm;
  Item: TUniListItem;
  LightPopupColor: TAlphaColor;
  Lookup: TTestLookup;

begin
  Application.Initialize;
  Form := TForm.CreateNew(nil);
  EventRecorder := TLookupEventRecorder.Create;
  try
    Lookup := TTestLookup.Create(Form);
    Form.SetBounds(0, 0, 640, 480);
    Form.Active := True;
    Lookup.Parent := Form;
    Lookup.SetBounds(40, 40, 260, 36);
    Lookup.OnSelectionChanging := EventRecorder.SelectionChanging;
    Lookup.OnSelectionChanged := EventRecorder.SelectionChanged;
    Lookup.OnItemSelected := EventRecorder.ItemSelected;

    Item := Lookup.Items.Add;
    Item.Title := 'PostgreSQL';
    Item.Text := 'Primary database';
    Item := Lookup.Items.Add;
    Item.Title := 'Redis';
    Item.Text := 'Cache cluster';

    Require(Lookup.ShowSearchBox,
      'Search box must be visible by default');
    Require(Lookup.AutoFocusSearch,
      'Search edit must receive focus by default');
    Require(Lookup.ClearSearchOnClose,
      'Search must clear on close by default');
    Require(Lookup.SearchDelay = 250,
      'Unexpected default search delay');
    Require(Lookup.SearchPrompt = 'Search...',
      'Unexpected default search prompt');
    Require(Lookup.NoMatchesText = 'No matches',
      'Unexpected no-matches text');
    LightPopupColor := Lookup.PopupHost.SurfaceColor;
    Lookup.ThemeName := 'Termius Dark';
    Require(SameText(Lookup.ListView.ThemeName, 'Termius Dark'),
      'Lookup theme was not propagated to its list');
    Require(Lookup.PopupHost.SurfaceColor <> LightPopupColor,
      'Lookup popup surface did not follow the dark theme');
    Lookup.ShowSearchBox := False;
    Require(not Lookup.ShowSearchBox,
      'ShowSearchBox=False was ignored');
    Lookup.ShowSearchBox := True;

    Lookup.ItemIndex := 1;
    Require(Lookup.ItemIndex = 1, 'Programmatic selection was not committed');
    Require(Lookup.SelectedItem = Lookup.Items[1],
      'SelectedItem does not return the committed TUniListItem');
    Require(EventRecorder.SelectedItem = Lookup.Items[1],
      'OnItemSelected did not receive TUniListItem');
    Require(EventRecorder.Events.CommaText =
      'changing:-1:1,changed:1,selected:Redis',
      'Programmatic event order is invalid: ' +
      EventRecorder.Events.CommaText);

    EventRecorder.Events.Clear;
    EventRecorder.AllowChange := False;
    Lookup.ItemIndex := 0;
    Require(Lookup.ItemIndex = 1, 'Canceled selection changed ItemIndex');
    Require(EventRecorder.Events.CommaText = 'changing:1:0',
      'Canceled selection fired committed events');

    EventRecorder.Events.Clear;
    EventRecorder.AllowChange := True;
    Lookup.ClearSelection;
    Require(Lookup.ItemIndex = -1, 'ClearSelection did not clear ItemIndex');
    Require(EventRecorder.SelectedItem = nil,
      'OnItemSelected must receive nil after clear');
    Require(EventRecorder.Events.CommaText =
      'changing:1:-1,changed:-1,selected:nil',
      'Clear event order is invalid');

    Lookup.ItemIndex := 0;
    Lookup.SearchDelay := 0;
    Lookup.SearchText := 'Redis';
    Require(Lookup.ListView.SearchText = 'Redis',
      'Immediate search was not delegated to TUniListView');
    Require(Lookup.ListView.SearchMatchCount = 1,
      'Immediate search returned the wrong match count');
    Require(Lookup.ItemIndex = 0,
      'Search changed committed selection');

    Lookup.OpenDropDown;
    Require(Lookup.IsDropDownOpen, 'Lookup popup did not open');
    Lookup.CommitSelection;
    Require(not Lookup.IsDropDownOpen,
      'CommitSelection did not close the popup');
    Require(Lookup.ItemIndex = 1,
      'CommitSelection did not commit the visible search result');
    Require(Lookup.SearchText = '',
      'ClearSearchOnClose did not clear lookup search');

    Lookup.ItemIndex := 0;
    Lookup.ClearSearchOnClose := False;
    Lookup.SearchText := 'Redis';
    Lookup.OpenDropDown;
    Lookup.CancelSelection;
    Require(Lookup.ItemIndex = 0,
      'CancelSelection did not restore committed selection');
    Require(Lookup.SearchText = 'Redis',
      'Search text was not preserved on close');

    Lookup.SearchText := 'missing';
    Lookup.OpenDropDown;
    Require(Lookup.IsDropDownOpen,
      'No-matches search closed the popup');
    Lookup.CommitSelection;
    Require(Lookup.IsDropDownOpen,
      'Commit with no visible result closed the popup');
    Require(Lookup.ItemIndex = 0,
      'No-matches search changed committed selection');
    Lookup.CancelSelection;

    Form.Active := False;
    Lookup.ClickField;
    Require(Lookup.IsDropDownOpen,
      'Lookup popup did not open by click in an inactive FMX form');
    Lookup.CloseDropDown;
    Form.Active := True;

    Lookup.PopupViewMode := uvmCards;
    Lookup.PopupCardLayout := uclFullWidth;
    Require((Lookup.PopupViewMode = uvmCards) and
      (Lookup.PopupCardLayout = uclFullWidth),
      'Full-width search popup mode was not retained');
    Lookup.PopupViewMode := uvmList;

    Lookup.Resizable := True;
    Lookup.MinPopupHeight := 120;
    Require(Lookup.PopupHost.Resizable and
      SameValue(Lookup.PopupHost.MinPopupHeight, 120),
      'Resizable search popup settings were not delegated');

    Lookup.SearchDelay := 250;
    Lookup.SearchText := 'PostgreSQL';
    Require(Lookup.ListView.SearchText = 'missing',
      'Delayed search was applied without waiting');

    Writeln('LookupCoreSmoke: PASS');
  finally
    EventRecorder.Free;
    Form.Free;
  end;
end.
