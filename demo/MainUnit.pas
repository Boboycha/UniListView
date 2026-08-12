unit MainUnit;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Diagnostics,
  System.Math,
  System.StrUtils,
  System.Types,
  System.UITypes,
  FMX.Types,
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.Forms,
  FMX.StdCtrls,
  FMX.Edit,
  FMX.ListBox,
  FMX.Objects,
  FMX.Layouts,
  UniList.Types,
  UniList.Items,
  UniList.Columns,
  UniList.Theme,
  UniList.Rules,
  UniList.Search,
  UniList.Control,
  UniList.Popup,
  UniList.DropDown,
  UniList.Lookup,
  System.Skia,
  FMX.Skia, UniList.Json.Adapter;

type
  TMainForm = class(TForm)
    BackgroundRect: TRectangle;
    RootLayout: TLayout;
    HeaderPanel: TRectangle;
    HeaderLayout: TLayout;
    SettingsGroupPanel: TRectangle;
    PopupGroupPanel: TRectangle;
    DropDownGroupPanel: TRectangle;
    TitleLabel: TLabel;
    ThemeCaptionLabel: TLabel;
    ThemeComboBox: TComboBox;
    RandomThemeButton: TButton;
    ModeButton: TButton;
    JsonStressButton: TButton;
    ThemeInfoLayout: TLayout;
    ThemeInfoPanel: TRectangle;
    LookupSearchSettingsPanel: TRectangle;
    LookupSearchSettingsLabel: TLabel;
    LookupShowSearchCheckBox: TCheckBox;
    LookupAutoFocusCheckBox: TCheckBox;
    LookupClearSearchCheckBox: TCheckBox;
    LookupSearchDelayLabel: TLabel;
    LookupSearchDelayEdit: TEdit;
    VariantCaptionLabel: TLabel;
    VariantValueLabel: TLabel;
    AuthorCaptionLabel: TLabel;
    AuthorValueLabel: TLabel;
    SearchEdit: TEdit;
    SearchResultLabel: TLabel;
    CardLayoutCaptionLabel: TLabel;
    CardLayoutComboBox: TComboBox;
    CardSizingCaptionLabel: TLabel;
    CardSizingComboBox: TComboBox;
    ActionVisibilityCaptionLabel: TLabel;
    ActionVisibilityComboBox: TComboBox;
    PopupAnchorEdit: TEdit;
    OpenPopupButton: TButton;
    PopupPlacementComboBox: TComboBox;
    PopupWidthModeComboBox: TComboBox;
    PopupEscapeCheckBox: TCheckBox;
    PopupOutsideCheckBox: TCheckBox;
    PopupContentPanel: TRectangle;
    PopupTitleLabel: TLabel;
    PopupEdit: TEdit;
    PopupActionButton: TButton;
    PopupHintLabel: TLabel;
    UniPopupHost1: TUniPopupHost;
    DropDownOpenButton: TButton;
    DropDownCloseButton: TButton;
    DropDownFieldClickCheckBox: TCheckBox;
    DropDownContentPanel: TRectangle;
    DropDownContentTitleLabel: TLabel;
    DropDownContentEdit: TEdit;
    DropDownContentCheckBox: TCheckBox;
    DropDownContentCloseButton: TButton;
    LookupClearButton: TButton;
    LookupCommitCheckBox: TCheckBox;
    LookupViewComboBox: TComboBox;
    LookupSelectionLabel: TLabel;
    UniListView1: TUniListView;
    LookupGroupPanel: TRectangle;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: WideChar; Shift: TShiftState);
    procedure ThemeComboBoxChange(Sender: TObject);
    procedure RandomThemeButtonClick(Sender: TObject);
    procedure ModeButtonClick(Sender: TObject);
    procedure JsonStressButtonClick(Sender: TObject);
    procedure UniListView1TreeLoadChildren(Sender: TObject;
      const ParentKey: string; var Handled: Boolean);
    procedure SearchEditChange(Sender: TObject);
    procedure SearchEditKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: WideChar; Shift: TShiftState);
    procedure UniListView1SearchChanged(Sender: TObject);
    procedure CardLayoutComboBoxChange(Sender: TObject);
    procedure CardSizingComboBoxChange(Sender: TObject);
    procedure ActionVisibilityComboBoxChange(Sender: TObject);
    procedure OpenPopupButtonClick(Sender: TObject);
    procedure PopupActionButtonClick(Sender: TObject);
    procedure UniPopupHost1PopupShown(Sender: TObject);
    procedure UniPopupHost1PopupClosed(Sender: TObject;
      const AReason: TUniPopupCloseReason);
    procedure UniDropDown1Opened(Sender: TObject);
    procedure UniDropDown1Closed(Sender: TObject;
      const AReason: TUniPopupCloseReason);
    procedure LookupViewComboBoxChange(Sender: TObject);
    procedure UniLookup1SelectionChanged(Sender: TObject;
      const AItemIndex: Integer);
    procedure UniLookup1ItemSelected(Sender: TObject;
      const AItem: TUniListItem);
    procedure LookupSearchDelayEditChangeTracking(Sender: TObject);
  private
    FSearchStopwatch: TStopwatch;
    procedure PopulateDemo;
    procedure PopulateLookup;
    procedure FillThemeList;
    procedure ApplySelectedTheme;
    procedure UpdateThemeChrome;
    procedure UpdateModeButton;
  end;

var
  MainForm: TMainForm;

implementation

uses
  JsonStressDemo;

{$R *.fmx}

const
  STRESS_ITEM_COUNT = 30000;

procedure TMainForm.FormCreate(Sender: TObject);
var
  PopulateStopwatch: TStopwatch;
begin
  PopulateStopwatch := TStopwatch.StartNew;
  PopulateDemo;
  PopulateStopwatch.Stop;
  FillThemeList;
  ApplySelectedTheme;
  CardLayoutComboBox.Items.Clear;
  CardLayoutComboBox.Items.Add('Сетка');
  CardLayoutComboBox.Items.Add('На всю ширину');
  CardLayoutComboBox.ItemIndex := Ord(UniListView1.CardLayout);
  CardSizingComboBox.Items.Clear;
  CardSizingComboBox.Items.Add('Fixed');
  CardSizingComboBox.Items.Add('Responsive');
  CardSizingComboBox.Items.Add('Stretch Columns');
  CardSizingComboBox.Items.Add('Auto By Title');
  CardSizingComboBox.ItemIndex := Ord(UniListView1.CardSizingMode);
  UniListView1.CardTemplate.AutoCardHeight := True;
  ActionVisibilityComboBox.Items.Clear;
  ActionVisibilityComboBox.Items.Add('Always');
  ActionVisibilityComboBox.Items.Add('On Hover');
  ActionVisibilityComboBox.ItemIndex := Ord(UniListView1.ActionVisibility);
  PopupPlacementComboBox.Items.Clear;
  PopupPlacementComboBox.Items.Add('Auto');
  PopupPlacementComboBox.Items.Add('Below');
  PopupPlacementComboBox.Items.Add('Above');
  PopupPlacementComboBox.ItemIndex := Ord(UniPopupHost1.Placement);
  PopupWidthModeComboBox.Items.Clear;
  PopupWidthModeComboBox.Items.Add('Anchor');
  PopupWidthModeComboBox.Items.Add('Content');
  PopupWidthModeComboBox.Items.Add('Fixed');
  PopupWidthModeComboBox.ItemIndex := Ord(UniPopupHost1.WidthMode);
  LookupViewComboBox.Items.Clear;
  LookupViewComboBox.Items.Add('List');
  LookupViewComboBox.Items.Add('Full-width');
  LookupViewComboBox.ItemIndex := 0;
  UpdateModeButton;
  TitleLabel.Text := Format('UniListView · %s · %d ms',
    [FormatFloat('#,##0', UniListView1.Items.Count),
     PopulateStopwatch.ElapsedMilliseconds]);
end;

procedure TMainForm.PopulateLookup;
const
  Names: array[0..11] of string = (
    'PostgreSQL Production', 'Redis Cluster', 'Neo4j Knowledge Base',
    'API Gateway', 'Deployment Pipeline', 'Grafana Monitoring',
    'RabbitMQ', 'Security Audit', 'Object Storage', 'DevOps Hub',
    'HAProxy Edge', 'Rocky Linux Builder');
var
  Column: TUniListColumn;
  Item: TUniListItem;
  ItemIndex: Integer;
begin
end;

procedure TMainForm.LookupSearchDelayEditChangeTracking(Sender: TObject);
var
  DelayValue: Integer;
begin
end;

procedure TMainForm.LookupViewComboBoxChange(Sender: TObject);
begin
  if LookupViewComboBox.ItemIndex = 1 then
  begin
  end
  else
end;

procedure TMainForm.UniLookup1SelectionChanged(Sender: TObject;
  const AItemIndex: Integer);
begin
  LookupSelectionLabel.Text := Format('Index: %d', [AItemIndex]);
end;

procedure TMainForm.UniLookup1ItemSelected(Sender: TObject;
  const AItem: TUniListItem);
begin
  if AItem = nil then
    LookupSelectionLabel.Text := 'Selection cleared'
  else
    LookupSelectionLabel.Text := 'Selected: ' + AItem.Title;
end;

procedure TMainForm.UniDropDown1Opened(Sender: TObject);
begin
  DropDownOpenButton.Text := 'Opened';
  PopupContentPanel.Visible:=true;
end;

procedure TMainForm.UniDropDown1Closed(Sender: TObject;
  const AReason: TUniPopupCloseReason);
begin
  DropDownOpenButton.Text := 'Open dropdown';
  PopupContentPanel.Visible:=false
end;

procedure TMainForm.OpenPopupButtonClick(Sender: TObject);
begin
  if PopupPlacementComboBox.ItemIndex >= 0 then
    UniPopupHost1.Placement :=
      TUniPopupPlacement(PopupPlacementComboBox.ItemIndex);
  if PopupWidthModeComboBox.ItemIndex >= 0 then
    UniPopupHost1.WidthMode :=
      TUniPopupWidthMode(PopupWidthModeComboBox.ItemIndex);
  UniPopupHost1.CloseOnEscape := PopupEscapeCheckBox.IsChecked;
  UniPopupHost1.CloseOnOutsideClick := PopupOutsideCheckBox.IsChecked;
  UniPopupHost1.ShowPopup(PopupAnchorEdit, PopupContentPanel);
end;

procedure TMainForm.PopupActionButtonClick(Sender: TObject);
begin
  UniPopupHost1.ClosePopup;
end;

procedure TMainForm.UniPopupHost1PopupShown(Sender: TObject);
begin
  OpenPopupButton.Text := 'Popup открыт';
end;

procedure TMainForm.UniPopupHost1PopupClosed(Sender: TObject;
  const AReason: TUniPopupCloseReason);
begin
  case AReason of
    upcrProgrammatic:
      OpenPopupButton.Text := 'Open Popup';
    upcrEscape:
      OpenPopupButton.Text := 'Esc: закрыт';
    upcrOutsideClick:
      OpenPopupButton.Text := 'Outside: закрыт';
    upcrOwnerHidden:
      OpenPopupButton.Text := 'Anchor скрыт';
    upcrOwnerDestroyed:
      OpenPopupButton.Text := 'Owner destroyed';
  end;
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  if (ssCtrl in Shift) and (Key = Ord('F')) then
  begin
    SearchEdit.SetFocus;
    SearchEdit.SelectAll;
    Key := 0;
    KeyChar := #0;
    Exit;
  end;
  if Key <> vkEscape then
    Exit;
  SearchEdit.Text := '';
  UniListView1.ClearSearch;
  Key := 0;
  KeyChar := #0;
end;

procedure TMainForm.SearchEditChange(Sender: TObject);
begin
  if SearchEdit.Text = '' then
    FSearchStopwatch.Reset
  else
    FSearchStopwatch := TStopwatch.StartNew;
  UniListView1.SearchText := SearchEdit.Text;
end;

procedure TMainForm.SearchEditKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  if Key = vkEscape then
  begin
    SearchEdit.Text := '';
    UniListView1.ClearSearch;
    Key := 0;
    KeyChar := #0;
    Exit;
  end;
  if Key <> vkReturn then
    Exit;
  if ssShift in Shift then
    UniListView1.FindPrevious
  else
    UniListView1.FindNext;
  Key := 0;
  KeyChar := #0;
end;

procedure TMainForm.UniListView1SearchChanged(Sender: TObject);
begin
  if UniListView1.SearchText = '' then
  begin
    SearchResultLabel.Text := '';
    Exit;
  end;
  if UniListView1.SearchRunning then
    SearchResultLabel.Text := Format('%d…', [UniListView1.SearchMatchCount])
  else
  begin
    FSearchStopwatch.Stop;
    SearchResultLabel.Text := Format('%d · %d ms',
      [UniListView1.SearchMatchCount, FSearchStopwatch.ElapsedMilliseconds]);
  end;
end;

procedure TMainForm.PopulateDemo;
var
  Column: TUniListColumn;
  ItemIndex: Integer;
  Item: TUniListItem;
  Rule: TUniColorRule;

  procedure AddServer(const AID, AParentID, AName, ADescription, AStatus: string;
    const ALatency: Integer; const AHasChildren: Boolean = False);
  begin
    Item := UniListView1.Items.Add;
    Item.SetField('id', AID);
    Item.SetField('parent_id', AParentID);
    Item.SetField('name', AName);
    Item.SetField('description', ADescription);
    Item.SetField('status', AStatus);
    Item.SetField('latency_ms', ALatency);
    Item.SetField('icon', 'server');
    Item.SetField('has_children', AHasChildren);
  end;

begin
  UniListView1.CardTemplate.TitleField := 'name';
  UniListView1.CardTemplate.TextField := 'description';
  UniListView1.CardTemplate.DetailField := 'status';
  UniListView1.CardTemplate.IconField := 'icon';
  UniListView1.TreeKeyField := 'id';
  UniListView1.TreeParentField := 'parent_id';
  UniListView1.TreeColumn := 'name';
  UniListView1.TreeLazyLoad := True;
  UniListView1.TreeHasChildrenField := 'has_children';
  UniListView1.ShowCheckBoxes := True;

  { Columns created in the Form Designer remain untouched. }
  if UniListView1.Columns.Count = 0 then
  begin
    Column := UniListView1.Columns.Add;
    Column.FieldName := 'name';
    Column.Caption := 'Наименование';
    Column.WidthMode := ucwmFill;
    Column.MinWidth := 260;
    Column.WrapText := True;
    Column.MaxLines := 3;
    Column.CardRole := ucrTitle;

    Column := UniListView1.Columns.Add;
    Column.FieldName := 'description';
    Column.Caption := 'Описание';
    Column.Visible := False;
    Column.VisibleInCards := True;
    Column.CardRole := ucrSubtitle;

    Column := UniListView1.Columns.Add;
    Column.FieldName := 'status';
    Column.Caption := 'Состояние';
    Column.Width := 190;
    Column.WrapText := True;
    Column.MaxLines := 2;
    Column.CardRole := ucrTrailing;

    Column := UniListView1.Columns.Add;
    Column.FieldName := 'latency_ms';
    Column.Caption := 'Задержка, ms';
    Column.Width := 120;
    Column.DataType := ucdtInteger;
    Column.Alignment := TTextAlign.Trailing;
    Column.CardRole := ucrDetail;

    Column := UniListView1.Columns.Add;
    Column.FieldName := 'id';
    Column.Caption := 'ID';
    Column.Visible := False;
    Column.CardRole := ucrHidden;

    Column := UniListView1.Columns.Add;
    Column.FieldName := 'parent_id';
    Column.Caption := 'Parent ID';
    Column.Visible := False;
    Column.CardRole := ucrHidden;

    Column := UniListView1.Columns.Add;
    Column.FieldName := 'has_children';
    Column.Caption := 'Has children';
    Column.Visible := False;
    Column.CardRole := ucrHidden;
  end;

  UniListView1.ColorRules.BeginUpdate;
  try
    UniListView1.ColorRules.Clear;

    Rule := UniListView1.ColorRules.Add;
    Rule.FieldName := 'latency_ms';
    Rule.Operator := ucroGreater;
    Rule.Value := '20';
    Rule.Scope := ucrsCell;
    Rule.TargetColumn := 'latency_ms';
    Rule.UseThemeColors := True;
    Rule.ThemeTone := ucrttDanger;
    Rule.UseBackgroundColor := True;
    Rule.UseTextColor := True;

    Rule := UniListView1.ColorRules.Add;
    Rule.FieldName := 'status';
    Rule.Operator := ucroContains;
    Rule.Value := 'Healthy';
    Rule.Scope := ucrsRow;
    Rule.UseThemeColors := True;
    Rule.ThemeTone := ucrttSuccess;
    Rule.UseBackgroundColor := True;

    Rule := UniListView1.ColorRules.Add;
    Rule.FieldName := 'status';
    Rule.Operator := ucroContains;
    Rule.Value := 'recommendations';
    Rule.Scope := ucrsCell;
    Rule.TargetColumn := 'status';
    Rule.UseThemeColors := True;
    Rule.ThemeTone := ucrttWarning;
    Rule.UseTextColor := True;
  finally
    UniListView1.ColorRules.EndUpdate;
  end;

  UniListView1.Items.BeginUpdate;
  try
    UniListView1.Clear;
    AddServer('infra', '', 'Infrastructure',
      'Основные сервисы и платформы', 'Healthy', 1);
    AddServer('db', 'infra', 'Databases',
      'Системы хранения данных', 'Healthy', 2);
    AddServer('postgres', 'db', 'PostgreSQL Production',
      'Основной кластер PostgreSQL 17',
      '3 узла · Streaming replication · Healthy', 18);
    AddServer('redis', 'db', 'Redis Cluster',
      'Высокопроизводительный кэш приложений',
      '8 узлов · 16384 slots · Online', 4);
    AddServer('neo4j', 'db', 'Neo4j Knowledge Graph',
      'Граф связей сервисов и документов',
      'Java 21 · Bolt enabled · Ready', 16);

    AddServer('apps', 'infra', 'Applications',
      'Сервисы и прикладные системы', 'Healthy', 3);
    AddServer('api', 'apps', 'DevOps Hub API',
      'Служба управления инфраструктурой',
      'Delphi 12 · FMX · Port 9000', 12);
    AddServer('gateway', 'apps', 'API Gateway',
      'Единая точка доступа к сервисам',
      'HAProxy · TLS · 14 backends', 3);
    AddServer('unilist', 'apps', 'UniListView',
      'Виртуальный список и адаптивные карточки',
      'Skia · Themes · Filters · MultiSort', 1);

    AddServer('ops', 'infra', 'Operations',
      'Мониторинг, доставка и резервирование', 'Healthy', 2);
    AddServer('grafana', 'ops', 'Grafana Monitoring',
      'Метрики баз данных и приложений',
      'Prometheus · pg_exporter · 24 dashboards', 24);
    AddServer('backup', 'ops', 'Backup Storage',
      'Полные и инкрементальные резервные копии',
      'Последняя копия: сегодня · 04:30', 7);
    AddServer('rabbit', 'ops', 'RabbitMQ',
      'Очереди фоновых заданий',
      '12 queues · 4 consumers · No alerts', 11);
    AddServer('pipeline', 'ops', 'Deployment Pipeline',
      'Автоматическая сборка и доставка',
      'Jenkins · 18 jobs · Last build successful', 31);
    AddServer('security', 'ops', 'Security Audit',
      'Контроль ролей, сертификатов и доступа',
      '0 critical · 2 recommendations', 6);
    AddServer('storage', 'ops', 'File Storage',
      'Хранилище документов и вложений',
      '2.4 TB used · 68% free', 9);
    AddServer('remote', 'infra', 'Remote Sites',
      'Дочерние узлы загружаются при раскрытии',
      'Lazy loading · Click to load', 14, True);

    while UniListView1.Items.Count < STRESS_ITEM_COUNT do
    begin
      ItemIndex := UniListView1.Items.Count;
      if ItemIndex = STRESS_ITEM_COUNT - 1 then
        AddServer(Format('stress-%d', [ItemIndex]), '',
          Format('Needle Service %.5d', [ItemIndex]),
          'Редкий маркер для проверки точного поиска',
          'Stress · Ready', ItemIndex mod 100)
      else
        AddServer(Format('stress-%d', [ItemIndex]), '',
          Format('Service %.5d', [ItemIndex]),
          Format('Нагрузочная запись %.5d · UniListView', [ItemIndex]),
          Format('Zone %d · %s', [ItemIndex mod 12,
            IfThen(ItemIndex mod 7 = 0, 'Warning', 'Healthy')]),
          ItemIndex mod 100);
    end;
  finally
    UniListView1.Items.EndUpdate;
  end;
  UniListView1.ExpandAll;
end;

procedure TMainForm.UniListView1TreeLoadChildren(Sender: TObject;
  const ParentKey: string; var Handled: Boolean);
var
  Item: TUniListItem;

  procedure AddChild(const AID, AName, ADescription, AStatus: string;
    const ALatency: Integer);
  begin
    Item := UniListView1.Items.Add;
    Item.SetField('id', AID);
    Item.SetField('parent_id', ParentKey);
    Item.SetField('name', AName);
    Item.SetField('description', ADescription);
    Item.SetField('status', AStatus);
    Item.SetField('latency_ms', ALatency);
    Item.SetField('icon', 'server');
    Item.SetField('has_children', False);
  end;

begin
  Handled := False;
  if not SameText(ParentKey, 'remote') then
    Exit;

  UniListView1.Items.BeginUpdate;
  try
    AddChild('tashkent', 'Tashkent Office',
      'Основной удалённый офис', 'VPN · Online', 22);
    AddChild('samarkand', 'Samarkand Office',
      'Региональная площадка', 'VPN · Online', 37);
    AddChild('bukhara', 'Bukhara Office',
      'Резервная региональная площадка', 'VPN · Standby', 48);
  finally
    UniListView1.Items.EndUpdate;
  end;
  Handled := True;
end;

procedure TMainForm.FillThemeList;
var
  ThemeNames: TArray<string>;
  ThemeName: string;
  SelectedIndex: Integer;
begin
  ThemeNames := UniListView1.AvailableThemeNames;

  ThemeComboBox.BeginUpdate;
  try
    ThemeComboBox.Items.Clear;
    for ThemeName in ThemeNames do
      ThemeComboBox.Items.Add(ThemeName);
  finally
    ThemeComboBox.EndUpdate;
  end;

  SelectedIndex := ThemeComboBox.Items.IndexOf(UniListView1.ThemeName);
  if SelectedIndex < 0 then
    SelectedIndex := ThemeComboBox.Items.IndexOf('Termius Dark');
  if (SelectedIndex < 0) and (ThemeComboBox.Count > 0) then
    SelectedIndex := 0;

  ThemeComboBox.ItemIndex := SelectedIndex;
end;

procedure TMainForm.ApplySelectedTheme;
begin
  if ThemeComboBox.ItemIndex < 0 then
    Exit;

  UniListView1.ThemeName := ThemeComboBox.Items[ThemeComboBox.ItemIndex];
  UpdateThemeChrome;
end;

procedure TMainForm.ThemeComboBoxChange(Sender: TObject);
begin
  ApplySelectedTheme;
end;

procedure TMainForm.RandomThemeButtonClick(Sender: TObject);
var
  NewIndex: Integer;
begin
  if ThemeComboBox.Count = 0 then
    Exit;
  if ThemeComboBox.Count = 1 then
    NewIndex := 0
  else
  begin
    repeat
      NewIndex := Random(ThemeComboBox.Count);
    until NewIndex <> ThemeComboBox.ItemIndex;
  end;
  ThemeComboBox.ItemIndex := NewIndex;
  ApplySelectedTheme;
end;

procedure TMainForm.UpdateThemeChrome;
var
  BorderColor: TAlphaColor;
  GroupColor: TAlphaColor;
  Theme: TUniThemeDefinition;
  HeaderColor: TAlphaColor;
begin
  Theme := TUniThemeManager.Find(UniListView1.ThemeName);
  if Theme = nil then
    Exit;

  UniPopupHost1.ThemeName := UniListView1.ThemeName;
  BackgroundRect.Fill.Color := Theme.Background;
  HeaderColor := UniBlendColor(Theme.Background, Theme.TerminalUI, 0.18);
  GroupColor := UniBlendColor(HeaderColor, Theme.Background, 0.38);
  BorderColor := UniBlendColor(Theme.Background, Theme.Foreground, 0.16);
  HeaderPanel.Fill.Color := HeaderColor;
  HeaderPanel.Stroke.Color := BorderColor;
  SettingsGroupPanel.Fill.Color := GroupColor;
  PopupGroupPanel.Fill.Color := GroupColor;
  DropDownGroupPanel.Fill.Color := GroupColor;
  LookupGroupPanel.Fill.Color := GroupColor;
  ThemeInfoPanel.Fill.Color := GroupColor;
  LookupSearchSettingsPanel.Fill.Color := GroupColor;
  SettingsGroupPanel.Stroke.Color := BorderColor;
  PopupGroupPanel.Stroke.Color := BorderColor;
  DropDownGroupPanel.Stroke.Color := BorderColor;
  LookupGroupPanel.Stroke.Color := BorderColor;
  ThemeInfoPanel.Stroke.Color := BorderColor;
  LookupSearchSettingsPanel.Stroke.Color := BorderColor;

  TitleLabel.TextSettings.FontColor := Theme.Foreground;
  SearchResultLabel.TextSettings.FontColor := Theme.Foreground;
  ThemeCaptionLabel.TextSettings.FontColor := Theme.Foreground;
  CardLayoutCaptionLabel.TextSettings.FontColor := Theme.Foreground;
  ActionVisibilityCaptionLabel.TextSettings.FontColor := Theme.Foreground;
  VariantCaptionLabel.TextSettings.FontColor := Theme.TerminalUI;
  AuthorCaptionLabel.TextSettings.FontColor := Theme.TerminalUI;
  VariantValueLabel.TextSettings.FontColor := Theme.Foreground;
  AuthorValueLabel.TextSettings.FontColor := Theme.Foreground;
  LookupSearchSettingsLabel.TextSettings.FontColor := Theme.Foreground;
  LookupSearchDelayLabel.TextSettings.FontColor := Theme.TerminalUI;
  PopupTitleLabel.TextSettings.FontColor := Theme.Foreground;
  PopupHintLabel.TextSettings.FontColor := Theme.TerminalUI;
  DropDownContentTitleLabel.TextSettings.FontColor := Theme.Foreground;
  LookupSelectionLabel.TextSettings.FontColor := Theme.Foreground;

  if Theme.Variant = utvDark then
    VariantValueLabel.Text := 'Тёмная'
  else
    VariantValueLabel.Text := 'Светлая';

  AuthorValueLabel.Text := Theme.Author;
  UniListView1.Redraw;
end;

procedure TMainForm.UpdateModeButton;
begin
  if UniListView1.ViewMode = uvmCards then
    ModeButton.Text := 'Показать список'
  else if UniListView1.TreeMode then
    ModeButton.Text := 'Показать карточки'
  else
    ModeButton.Text := 'Показать дерево';
end;

procedure TMainForm.CardLayoutComboBoxChange(Sender: TObject);
begin
  if CardLayoutComboBox.ItemIndex < 0 then
    Exit;
  UniListView1.CardLayout :=
    TUniCardLayout(CardLayoutComboBox.ItemIndex);
  UniListView1.CardTemplate.AutoCardHeight := True;
end;

procedure TMainForm.CardSizingComboBoxChange(Sender: TObject);
begin
  if CardSizingComboBox.ItemIndex < 0 then
    Exit;
  UniListView1.CardSizingMode :=
    TUniCardSizingMode(CardSizingComboBox.ItemIndex);
end;

procedure TMainForm.ActionVisibilityComboBoxChange(Sender: TObject);
begin
  if ActionVisibilityComboBox.ItemIndex < 0 then
    Exit;
  UniListView1.ActionVisibility :=
    TUniActionVisibility(ActionVisibilityComboBox.ItemIndex);
end;

procedure TMainForm.ModeButtonClick(Sender: TObject);
begin
  if UniListView1.ViewMode = uvmCards then
  begin
    UniListView1.ViewMode := uvmList;
    UniListView1.TreeMode := False;
  end
  else if not UniListView1.TreeMode then
  begin
    UniListView1.TreeMode := True;
    UniListView1.ExpandAll;
  end
  else
  begin
    UniListView1.TreeMode := False;
    UniListView1.ViewMode := uvmCards;
  end;
  UpdateModeButton;
end;

procedure TMainForm.JsonStressButtonClick(Sender: TObject);
var
  StressForm: TJsonStressForm;
begin
  StressForm := TJsonStressForm.Create(Self);
  try
    StressForm.ShowModal;
  finally
    StressForm.Free;
  end;
end;

end.
