unit MainUnit;

interface

uses
  System.SysUtils, System.Classes, System.Actions, System.Math, System.UITypes,
  FMX.Types, FMX.Controls, FMX.Controls.Presentation, FMX.Forms, FMX.StdCtrls,
  FMX.Edit, FMX.ListBox, FMX.Objects, FMX.Layouts, FMX.ActnList, FMX.Filter.Effects,
  UniList.Types, UniList.Items, UniList.Columns, UniList.Theme, UniList.Rules,
  UniList.Control;

type
  TMainForm = class(TForm)
    Background: TRectangle;
    Header: TRectangle;
    ProductLabel: TLabel;
    SubtitleLabel: TLabel;
    ThemeComboBox: TComboBox;
    JsonButton: TButton;
    Toolbar: TRectangle;
    SearchEdit: TEdit;
    ModeLayout: TLayout;
    CardsButton: TButton;
    ListButton: TButton;
    TreeButton: TButton;
    DataSetComboBox: TComboBox;
    ReloadButton: TButton;
    BodyLayout: TLayout;
    Sidebar: TRectangle;
    OptionsLabel: TLabel;
    ShowChecksCheckBox: TCheckBox;
    HoverActionsCheckBox: TCheckBox;
    AutoRowHeightCheckBox: TCheckBox;
    GridLinesCheckBox: TCheckBox;
    CardSizingLabel: TLabel;
    CardSizingComboBox: TComboBox;
    SelectionLabel: TLabel;
    CheckAllButton: TButton;
    ClearChecksButton: TButton;
    TreeCommandsLabel: TLabel;
    ExpandAllButton: TButton;
    CollapseAllButton: TButton;
    UniListView1: TUniListView;
    StatusBar: TRectangle;
    StatusLabel: TLabel;
    EventLabel: TLabel;
    Actions: TActionList;
    actCards: TAction;
    actList: TAction;
    actTree: TAction;
    actReload: TAction;
    actCheckAll: TAction;
    actClearChecks: TAction;
    actExpandAll: TAction;
    actCollapseAll: TAction;
    actJsonStress: TAction;
    StyleBook1: TStyleBook;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: WideChar; Shift: TShiftState);
    procedure ThemeComboBoxChange(Sender: TObject);
    procedure SearchEditChangeTracking(Sender: TObject);
    procedure SearchEditKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: WideChar; Shift: TShiftState);
    procedure ModeActionExecute(Sender: TObject);
    procedure actReloadExecute(Sender: TObject);
    procedure actCheckAllExecute(Sender: TObject);
    procedure actClearChecksExecute(Sender: TObject);
    procedure actExpandAllExecute(Sender: TObject);
    procedure actCollapseAllExecute(Sender: TObject);
    procedure actJsonStressExecute(Sender: TObject);
    procedure ShowChecksCheckBoxChange(Sender: TObject);
    procedure HoverActionsCheckBoxChange(Sender: TObject);
    procedure AutoRowHeightCheckBoxChange(Sender: TObject);
    procedure GridLinesCheckBoxChange(Sender: TObject);
    procedure CardSizingComboBoxChange(Sender: TObject);
    procedure UniListView1ItemClick(Sender: TObject; const AItemIndex: Integer);
    procedure UniListView1ItemAction(Sender: TObject;
      const AItemIndex: Integer; const AActionName: string);
    procedure UniListView1ItemCheckChanged(Sender: TObject;
      AItem: TUniListItem; AChecked: Boolean);
    procedure UniListView1StateChanged(Sender: TObject);
  private
    FEventText: string;
    procedure ConfigureList;
    procedure PopulateDemo(const AItemCount: Integer);
    procedure FillThemes;
    procedure ApplyTheme;
    procedure ApplyMode(const AMode: Integer);
    procedure UpdateChrome;
    procedure UpdateModeButtons;
    procedure UpdateStatus;
  end;

var
  MainForm: TMainForm;

implementation

uses
  JsonStressDemo;

{$R *.fmx}

const
  MODE_CARDS = 0;
  MODE_LIST = 1;
  MODE_TREE = 2;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FillThemes;
  DataSetComboBox.Items.Add('32 items');
  DataSetComboBox.Items.Add('1,000 items');
  DataSetComboBox.Items.Add('10,000 items');
  DataSetComboBox.ItemIndex := 0;
  CardSizingComboBox.Items.Add('Responsive');
  CardSizingComboBox.Items.Add('Fixed width');
  CardSizingComboBox.Items.Add('Stretch columns');
  CardSizingComboBox.Items.Add('Auto by title');
  CardSizingComboBox.ItemIndex := 0;
  ConfigureList;
  PopulateDemo(32);
  ApplyMode(MODE_CARDS);
  ApplyTheme;
end;

procedure TMainForm.ConfigureList;
var
  Column: TUniListColumn;
  CardAction: TUniCardAction;
  Rule: TUniColorRule;
begin
  UniListView1.BeginUpdate;
  try
    UniListView1.Columns.Clear;
    Column := UniListView1.Columns.Add;
    Column.LayoutID := 'name';
    Column.FieldName := 'name';
    Column.Caption := 'Name';
    Column.WidthMode := ucwmFill;
    Column.MinWidth := 180;
    Column.CardRole := ucrTitle;
    Column.Frozen := True;
    Column := UniListView1.Columns.Add;
    Column.LayoutID := 'description';
    Column.FieldName := 'description';
    Column.Caption := 'Endpoint';
    Column.WidthMode := ucwmFill;
    Column.MinWidth := 190;
    Column.CardRole := ucrSubtitle;
    Column := UniListView1.Columns.Add;
    Column.LayoutID := 'status';
    Column.FieldName := 'status';
    Column.Caption := 'Status';
    Column.Width := 120;
    Column.CardRole := ucrDetail;
    Column := UniListView1.Columns.Add;
    Column.LayoutID := 'latency';
    Column.FieldName := 'latency';
    Column.Caption := 'Latency';
    Column.Width := 90;
    Column.DataType := ucdtInteger;
    Column.Alignment := TTextAlign.Trailing;
    Column.CardRole := ucrTrailing;
    Column := UniListView1.Columns.Add;
    Column.LayoutID := 'id';
    Column.FieldName := 'id';
    Column.Visible := False;
    Column.VisibleInCards := False;
    Column.CardRole := ucrHidden;
    Column := UniListView1.Columns.Add;
    Column.LayoutID := 'parent_id';
    Column.FieldName := 'parent_id';
    Column.Visible := False;
    Column.VisibleInCards := False;
    Column.CardRole := ucrHidden;

    UniListView1.Actions.Clear;
    CardAction := UniListView1.Actions.Add;
    CardAction.Name := 'favorite';
    CardAction.Caption := 'Favorite';
    CardAction.Icon := uviStarFilled;
    CardAction.Width := 28;
    CardAction.Visibility := ucavAlways;
    CardAction := UniListView1.Actions.Add;
    CardAction.Name := 'edit';
    CardAction.Caption := 'Edit';
    CardAction.Icon := uviEdit;
    CardAction.Width := 28;
    CardAction.Visibility := ucavOnHover;

    UniListView1.ColorRules.Clear;
    Rule := UniListView1.ColorRules.Add;
    Rule.FieldName := 'status';
    Rule.Operator := ucroContains;
    Rule.Value := 'Degraded';
    Rule.Scope := ucrsCell;
    Rule.TargetColumn := 'status';
    Rule.UseThemeColors := True;
    Rule.ThemeTone := ucrttWarning;
    Rule := UniListView1.ColorRules.Add;
    Rule.FieldName := 'status';
    Rule.Operator := ucroContains;
    Rule.Value := 'Offline';
    Rule.Scope := ucrsRow;
    Rule.UseThemeColors := True;
    Rule.ThemeTone := ucrttDanger;

    UniListView1.CardTemplate.TitleField := 'name';
    UniListView1.CardTemplate.TextField := 'description';
    UniListView1.CardTemplate.DetailField := 'status';
    UniListView1.CardTemplate.StatusField := 'status';
    UniListView1.CardTemplate.Icon := uviServer;
    UniListView1.CardTemplate.AutoCardHeight := True;
    UniListView1.CardTemplate.TitleMaxLines := 2;
    UniListView1.CardTemplate.TextMaxLines := 1;
    UniListView1.CardTemplate.DetailMaxLines := 1;
    UniListView1.CardTemplate.SelectableText := True;
    UniListView1.TreeKeyField := 'id';
    UniListView1.TreeParentField := 'parent_id';
    UniListView1.TreeColumn := 'name';
    UniListView1.TreeCheckMode := tcmCascadeFull;
    UniListView1.MultiCheck := True;
  finally
    UniListView1.EndUpdate;
  end;
end;

procedure TMainForm.PopulateDemo(const AItemCount: Integer);
const
  GROUP_NAMES: array[0..3] of string = (
    'Production', 'Development', 'Infrastructure', 'Remote sites');
  STATUSES: array[0..4] of string = (
    'Healthy', 'Healthy', 'Healthy', 'Degraded', 'Offline');
var
  I: Integer;
  GroupIndex: Integer;
  Item: TUniListItem;
  procedure AddItem(const AID, AParentID, AName, ADescription,
    AStatus: string; const ALatency: Integer);
  begin
    Item := UniListView1.Items.Add;
    Item.ID := AID;
    Item.ParentID := AParentID;
    Item.SetField('id', AID);
    Item.SetField('parent_id', AParentID);
    Item.SetField('name', AName);
    Item.SetField('description', ADescription);
    Item.SetField('status', AStatus);
    Item.SetField('latency', ALatency);
  end;
begin
  UniListView1.BeginUpdate;
  try
    UniListView1.Items.Clear;
    for GroupIndex := Low(GROUP_NAMES) to High(GROUP_NAMES) do
      AddItem(Format('group-%d', [GroupIndex]), '', GROUP_NAMES[GroupIndex],
        Format('%d managed endpoints', [Max(0, (AItemCount - 4) div 4)]),
        'Group', 0);
    for I := 1 to Max(0, AItemCount - 4) do
    begin
      GroupIndex := (I - 1) mod Length(GROUP_NAMES);
      AddItem(Format('server-%d', [I]), Format('group-%d', [GroupIndex]),
        Format('%s-node-%2.2d', [LowerCase(StringReplace(GROUP_NAMES[GroupIndex],
          ' ', '-', [rfReplaceAll])), I]),
        Format('10.%d.%d.%d:22', [20 + GroupIndex, (I div 240) mod 240,
          10 + (I mod 240)]), STATUSES[I mod Length(STATUSES)],
        4 + ((I * 7) mod 73));
    end;
  finally
    UniListView1.EndUpdate;
  end;
  FEventText := Format('%s loaded',
    [DataSetComboBox.Items[DataSetComboBox.ItemIndex]]);
  UpdateStatus;
end;

procedure TMainForm.FillThemes;
var
  ThemeName: string;
  DefaultIndex: Integer;
begin
  ThemeComboBox.Items.Clear;
  DefaultIndex := -1;
  for ThemeName in TUniThemeManager.ThemeNames do
  begin
    ThemeComboBox.Items.Add(ThemeName);
    if SameText(ThemeName, 'Atom One Dark') then
      DefaultIndex := ThemeComboBox.Items.Count - 1;
  end;
  if DefaultIndex < 0 then
    DefaultIndex := 0;
  ThemeComboBox.ItemIndex := DefaultIndex;
end;

procedure TMainForm.ApplyTheme;
begin
  if ThemeComboBox.ItemIndex < 0 then
    Exit;
  UniListView1.ThemeName := ThemeComboBox.Items[ThemeComboBox.ItemIndex];
  UpdateChrome;
end;

procedure TMainForm.UpdateChrome;
var
  Theme: TUniThemeDefinition;
  Surface: TAlphaColor;
begin
  Theme := TUniThemeManager.Find(UniListView1.ThemeName);
  if Theme = nil then
    Exit;
  Surface := UniBlendColor(Theme.Background, Theme.Foreground, 0.08);
  Background.Fill.Color := Theme.Background;
  Header.Fill.Color := Surface;
  Toolbar.Fill.Color := Surface;
  Sidebar.Fill.Color := Surface;
  StatusBar.Fill.Color := Surface;
  Header.Stroke.Color := UniBlendColor(Theme.Background, Theme.Foreground, 0.18);
  Toolbar.Stroke.Color := Header.Stroke.Color;
  Sidebar.Stroke.Color := Header.Stroke.Color;
  StatusBar.Stroke.Color := Header.Stroke.Color;
  ProductLabel.TextSettings.FontColor := Theme.Foreground;
  SubtitleLabel.TextSettings.FontColor := Theme.TerminalUI;
  OptionsLabel.TextSettings.FontColor := Theme.Foreground;
  CardSizingLabel.TextSettings.FontColor := Theme.TerminalUI;
  SelectionLabel.TextSettings.FontColor := Theme.Foreground;
  TreeCommandsLabel.TextSettings.FontColor := Theme.TerminalUI;
  StatusLabel.TextSettings.FontColor := Theme.Foreground;
  EventLabel.TextSettings.FontColor := Theme.TerminalUI;
  UpdateModeButtons;
end;

procedure TMainForm.ThemeComboBoxChange(Sender: TObject);
begin
  ApplyTheme;
end;

procedure TMainForm.ApplyMode(const AMode: Integer);
begin
  UniListView1.TreeMode := AMode = MODE_TREE;
  if AMode = MODE_CARDS then
    UniListView1.ViewMode := uvmCards
  else
    UniListView1.ViewMode := uvmList;
  if AMode = MODE_TREE then
    UniListView1.ExpandAll;
  ExpandAllButton.Enabled := AMode = MODE_TREE;
  CollapseAllButton.Enabled := AMode = MODE_TREE;
  CardSizingComboBox.Enabled := AMode = MODE_CARDS;
  FEventText := 'View changed';
  UpdateModeButtons;
  UpdateStatus;
end;

procedure TMainForm.UpdateModeButtons;
var
  ActiveMode: Integer;
begin
  if UniListView1.TreeMode then
    ActiveMode := MODE_TREE
  else if UniListView1.ViewMode = uvmList then
    ActiveMode := MODE_LIST
  else
    ActiveMode := MODE_CARDS;
  CardsButton.Opacity := IfThen(ActiveMode = MODE_CARDS, 1.0, 0.68);
  ListButton.Opacity := IfThen(ActiveMode = MODE_LIST, 1.0, 0.68);
  TreeButton.Opacity := IfThen(ActiveMode = MODE_TREE, 1.0, 0.68);
end;

procedure TMainForm.ModeActionExecute(Sender: TObject);
begin
  if Sender = actCards then
    ApplyMode(MODE_CARDS)
  else if Sender = actList then
    ApplyMode(MODE_LIST)
  else if Sender = actTree then
    ApplyMode(MODE_TREE);
end;

procedure TMainForm.UpdateStatus;
var
  SelectedName: string;
begin
  if (UniListView1.SelectedIndex >= 0) and
     (UniListView1.SelectedIndex < UniListView1.Items.Count) then
    SelectedName := UniListView1.Items[UniListView1.SelectedIndex]
      .FieldAsString('name')
  else
    SelectedName := 'none';
  StatusLabel.Text := Format('%s items  |  %s matches  |  %s checked',
    [FormatFloat('#,##0', UniListView1.Items.Count),
     FormatFloat('#,##0', UniListView1.SearchMatchCount),
     FormatFloat('#,##0', UniListView1.CheckedCount)]);
  EventLabel.Text := Format('Selected: %s  |  %s', [SelectedName, FEventText]);
end;

procedure TMainForm.SearchEditChangeTracking(Sender: TObject);
begin
  UniListView1.SearchText := SearchEdit.Text;
  FEventText := 'Search updated';
  UpdateStatus;
end;

procedure TMainForm.SearchEditKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  if Key = vkEscape then
  begin
    SearchEdit.Text := '';
    UniListView1.ClearSearch;
    Key := 0;
  end
  else if Key = vkReturn then
  begin
    if ssShift in Shift then
      UniListView1.FindPrevious
    else
      UniListView1.FindNext;
    Key := 0;
  end;
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  if (Key = Ord('F')) and (ssCtrl in Shift) then
  begin
    SearchEdit.SetFocus;
    SearchEdit.SelectAll;
    Key := 0;
  end;
end;

procedure TMainForm.actReloadExecute(Sender: TObject);
const
  ITEM_COUNTS: array[0..2] of Integer = (32, 1000, 10000);
begin
  if DataSetComboBox.ItemIndex < 0 then
    DataSetComboBox.ItemIndex := 0;
  PopulateDemo(ITEM_COUNTS[DataSetComboBox.ItemIndex]);
  if UniListView1.TreeMode then
    UniListView1.ExpandAll;
end;

procedure TMainForm.actCheckAllExecute(Sender: TObject);
begin
  UniListView1.CheckAll;
  FEventText := 'All visible items checked';
  UpdateStatus;
end;

procedure TMainForm.actClearChecksExecute(Sender: TObject);
begin
  UniListView1.UncheckAll;
  FEventText := 'Selection cleared';
  UpdateStatus;
end;

procedure TMainForm.actExpandAllExecute(Sender: TObject);
begin
  UniListView1.ExpandAll;
  FEventText := 'Tree expanded';
  UpdateStatus;
end;

procedure TMainForm.actCollapseAllExecute(Sender: TObject);
begin
  UniListView1.CollapseAll;
  FEventText := 'Tree collapsed';
  UpdateStatus;
end;

procedure TMainForm.actJsonStressExecute(Sender: TObject);
var
  Form: TJsonStressForm;
begin
  Form := TJsonStressForm.Create(Self);
  Form.Show;
end;

procedure TMainForm.ShowChecksCheckBoxChange(Sender: TObject);
begin
  UniListView1.ShowCheckBoxes := ShowChecksCheckBox.IsChecked;
end;

procedure TMainForm.HoverActionsCheckBoxChange(Sender: TObject);
begin
  if HoverActionsCheckBox.IsChecked then
    UniListView1.ActionVisibility := uavOnHover
  else
    UniListView1.ActionVisibility := uavAlways;
end;

procedure TMainForm.AutoRowHeightCheckBoxChange(Sender: TObject);
begin
  UniListView1.ListAutoRowHeight := AutoRowHeightCheckBox.IsChecked;
end;

procedure TMainForm.GridLinesCheckBoxChange(Sender: TObject);
begin
  UniListView1.ListGridLines := GridLinesCheckBox.IsChecked;
  UniListView1.ListHorizontalGridLines := GridLinesCheckBox.IsChecked;
  UniListView1.Repaint;
end;

procedure TMainForm.CardSizingComboBoxChange(Sender: TObject);
const
  SIZING_MODES: array[0..3] of TUniCardSizingMode =
    (ucsmResponsive, ucsmFixed, ucsmStretchColumns, ucsmAutoByTitle);
begin
  if CardSizingComboBox.ItemIndex >= 0 then
    UniListView1.CardSizingMode := SIZING_MODES[CardSizingComboBox.ItemIndex];
end;

procedure TMainForm.UniListView1ItemClick(Sender: TObject;
  const AItemIndex: Integer);
begin
  FEventText := 'Item clicked';
  UpdateStatus;
end;

procedure TMainForm.UniListView1ItemAction(Sender: TObject;
  const AItemIndex: Integer; const AActionName: string);
begin
  if (AItemIndex >= 0) and (AItemIndex < UniListView1.Items.Count) then
    FEventText := Format('%s: %s', [AActionName,
      UniListView1.Items[AItemIndex].FieldAsString('name')]);
  UpdateStatus;
end;

procedure TMainForm.UniListView1ItemCheckChanged(Sender: TObject;
  AItem: TUniListItem; AChecked: Boolean);
begin
  UpdateStatus;
end;

procedure TMainForm.UniListView1StateChanged(Sender: TObject);
begin
  UpdateStatus;
end;

end.
