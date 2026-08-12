unit MainUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Math,
  System.Variants, System.Actions,
  System.Diagnostics, System.Rtti, FMX.Types, FMX.Controls, FMX.Forms,
  FMX.Layouts, FMX.StdCtrls, FMX.Edit, FMX.ListBox, FMX.Memo, FMX.Dialogs,
  FMX.Clipboard, FMX.Memo.Types, FMX.ActnList, System.Skia, FMX.Skia, FMX.ScrollBox,
  FMX.Controls.Presentation, Data.DB, Datasnap.DBClient, UniList.Control,
  UniList.Types, UniList.Items, UniList.Columns, UniList.Rules, UniList.Theme,
  UniList.Search, UniList.Performance;

type
  TMainForm = class(TForm)
    RootLayout: TLayout;
    TopToolBar: TToolBar;
    BottomPanel: TLayout;
    StatusLabel: TLabel;
    EventMemo: TMemo;
    MainLayout: TLayout;
    ControlPanel: TVertScrollBox;
    MainSplitter: TSplitter;
    UniListView1: TUniListView;
    ActionList1: TActionList;
    actCards: TAction;
    actList: TAction;
    actGenerate100: TAction;
    actGenerate1000: TAction;
    actGenerate10000: TAction;
    actGenerate50000: TAction;
    actClear: TAction;
    actReset: TAction;
    actAutoFit: TAction;
    actSaveLayoutFile: TAction;
    actLoadLayoutFile: TAction;
    actToggleControlPanel: TAction;
    actCards2: TAction;
    actList2: TAction;
    actApplyTheme: TAction;
    actLoadTheme: TAction;
    actThemeInfo: TAction;
    actApplyFonts: TAction;
    actApplyScroll: TAction;
    actScrollSelected: TAction;
    actScrollIndex: TAction;
    actScrollHome: TAction;
    actScrollEnd: TAction;
    actCardsCompact: TAction;
    actCardsNormal: TAction;
    actCardsLarge: TAction;
    actCardsAutoTitle: TAction;
    actCardsHorizontal: TAction;
    actCardsWrapped: TAction;
    actApplyTemplateFields: TAction;
    actClearTextSelection: TAction;
    actShowSelectedText: TAction;
    actList3: TAction;
    actAutoFit2: TAction;
    actColumnChooser: TAction;
    actResetHScroll: TAction;
    actColumnAdd: TAction;
    actColumnDelete: TAction;
    actColumnsClear: TAction;
    actColumnsRestore: TAction;
    actColumnApply: TAction;
    actColumnVisible: TAction;
    actActionAdd: TAction;
    actActionDelete: TAction;
    actActionsClear: TAction;
    actActionsRestore: TAction;
    actActionApply: TAction;
    actGenerateCustom: TAction;
    actItemAdd: TAction;
    actItemDelete: TAction;
    actItemApply: TAction;
    actItemEnable: TAction;
    actItemDisable: TAction;
    actItemRandomize: TAction;
    actItemInspect: TAction;
    actSortItems: TAction;
    actSortByFields: TAction;
    actSelect: TAction;
    actSelectClear: TAction;
    actSelectPrevious: TAction;
    actSelectNext: TAction;
    actScrollSelected2: TAction;
    actColorsApply: TAction;
    actColorsLight: TAction;
    actColorsDark: TAction;
    actColorsContrast: TAction;
    actColorsReset: TAction;
    actGetLayoutJSON: TAction;
    actApplyLayoutJSON: TAction;
    actSaveLayoutFile2: TAction;
    actLoadLayoutFile2: TAction;
    actDefaultLayout: TAction;
    actApplyExtendedView: TAction;
    actGenerateTree: TAction;
    actTreeExpandAll: TAction;
    actTreeCollapseAll: TAction;
    actTreeExpandLevel: TAction;
    actTreeMarkLoaded: TAction;
    actTreeReload: TAction;
    actTreeChildrenLoaded: TAction;
    actApplyCardTree: TAction;
    actCardTreeRoot: TAction;
    actCardTreeParent: TAction;
    actCardTreeExit: TAction;
    actCardTreeNavigate: TAction;
    actCardTreeTryNavigate: TAction;
    actCardTreeRefresh: TAction;
    actCardTreeExpandAll: TAction;
    actCardTreeCollapseAll: TAction;
    actCardTreeExpandNode: TAction;
    actCardTreeCollapseNode: TAction;
    actCardTreeIsExpanded: TAction;
    actApplyChecks: TAction;
    actCheckAll: TAction;
    actCheckVisible: TAction;
    actUncheckAll: TAction;
    actUncheckVisible: TAction;
    actInvertAll: TAction;
    actInvertVisible: TAction;
    actToggleChecked: TAction;
    actSetChecked: TAction;
    actCheckByID: TAction;
    actSetCheckState: TAction;
    actGetCheckState: TAction;
    actRecalculateChecks: TAction;
    actCheckedInfo: TAction;
    actApplySearch: TAction;
    actFindNext: TAction;
    actFindPrevious: TAction;
    actClearSearch: TAction;
    actClearFilters: TAction;
    actNavigationInfo: TAction;
    actColumnText: TAction;
    actApplyColumnAdvanced: TAction;
    actRuleAdd: TAction;
    actRuleDelete: TAction;
    actRulesClear: TAction;
    actRuleApply: TAction;
    actRuleMatches: TAction;
    actApplyDesignPreview: TAction;
    actBindDataSource: TAction;
    actUnbindDataSource: TAction;
    actAddItemAPI: TAction;
    actTestAssignAPIs: TAction;
    actResetPerformance: TAction;
    actPerformanceSnapshot: TAction;
    actPerformanceReport: TAction;
    actClearLog: TAction;
    actPauseLog: TAction;
    procedure FormCreate(Sender: TObject);
    procedure UniListView1ItemClick(Sender: TObject; const AItemIndex: Integer);
    procedure UniListView1ItemAction(Sender: TObject;
      const AItemIndex: Integer; const AActionName: string);
    procedure SettingChanged(Sender: TObject);
    procedure actCardsExecute(Sender: TObject);
    procedure actListExecute(Sender: TObject);
    procedure actGenerate100Execute(Sender: TObject);
    procedure actGenerate1000Execute(Sender: TObject);
    procedure actGenerate10000Execute(Sender: TObject);
    procedure actGenerate50000Execute(Sender: TObject);
    procedure actClearExecute(Sender: TObject);
    procedure actResetExecute(Sender: TObject);
    procedure actAutoFitExecute(Sender: TObject);
    procedure actSaveLayoutFileExecute(Sender: TObject);
    procedure actLoadLayoutFileExecute(Sender: TObject);
    procedure actToggleControlPanelExecute(Sender: TObject);
    procedure actCards2Execute(Sender: TObject);
    procedure actList2Execute(Sender: TObject);
    procedure actApplyThemeExecute(Sender: TObject);
    procedure actLoadThemeExecute(Sender: TObject);
    procedure actThemeInfoExecute(Sender: TObject);
    procedure actApplyFontsExecute(Sender: TObject);
    procedure actApplyScrollExecute(Sender: TObject);
    procedure actScrollSelectedExecute(Sender: TObject);
    procedure actScrollIndexExecute(Sender: TObject);
    procedure actScrollHomeExecute(Sender: TObject);
    procedure actScrollEndExecute(Sender: TObject);
    procedure actCardsCompactExecute(Sender: TObject);
    procedure actCardsNormalExecute(Sender: TObject);
    procedure actCardsLargeExecute(Sender: TObject);
    procedure actCardsAutoTitleExecute(Sender: TObject);
    procedure actCardsHorizontalExecute(Sender: TObject);
    procedure actCardsWrappedExecute(Sender: TObject);
    procedure actApplyTemplateFieldsExecute(Sender: TObject);
    procedure actClearTextSelectionExecute(Sender: TObject);
    procedure actShowSelectedTextExecute(Sender: TObject);
    procedure actList3Execute(Sender: TObject);
    procedure actAutoFit2Execute(Sender: TObject);
    procedure actColumnChooserExecute(Sender: TObject);
    procedure actResetHScrollExecute(Sender: TObject);
    procedure actColumnAddExecute(Sender: TObject);
    procedure actColumnDeleteExecute(Sender: TObject);
    procedure actColumnsClearExecute(Sender: TObject);
    procedure actColumnsRestoreExecute(Sender: TObject);
    procedure actColumnApplyExecute(Sender: TObject);
    procedure actColumnVisibleExecute(Sender: TObject);
    procedure actActionAddExecute(Sender: TObject);
    procedure actActionDeleteExecute(Sender: TObject);
    procedure actActionsClearExecute(Sender: TObject);
    procedure actActionsRestoreExecute(Sender: TObject);
    procedure actActionApplyExecute(Sender: TObject);
    procedure actGenerateCustomExecute(Sender: TObject);
    procedure actItemAddExecute(Sender: TObject);
    procedure actItemDeleteExecute(Sender: TObject);
    procedure actItemApplyExecute(Sender: TObject);
    procedure actItemEnableExecute(Sender: TObject);
    procedure actItemDisableExecute(Sender: TObject);
    procedure actItemRandomizeExecute(Sender: TObject);
    procedure actItemInspectExecute(Sender: TObject);
    procedure actSortItemsExecute(Sender: TObject);
    procedure actSortByFieldsExecute(Sender: TObject);
    procedure actSelectExecute(Sender: TObject);
    procedure actSelectClearExecute(Sender: TObject);
    procedure actSelectPreviousExecute(Sender: TObject);
    procedure actSelectNextExecute(Sender: TObject);
    procedure actScrollSelected2Execute(Sender: TObject);
    procedure actColorsApplyExecute(Sender: TObject);
    procedure actColorsLightExecute(Sender: TObject);
    procedure actColorsDarkExecute(Sender: TObject);
    procedure actColorsContrastExecute(Sender: TObject);
    procedure actColorsResetExecute(Sender: TObject);
    procedure actGetLayoutJSONExecute(Sender: TObject);
    procedure actApplyLayoutJSONExecute(Sender: TObject);
    procedure actSaveLayoutFile2Execute(Sender: TObject);
    procedure actLoadLayoutFile2Execute(Sender: TObject);
    procedure actDefaultLayoutExecute(Sender: TObject);
    procedure actApplyExtendedViewExecute(Sender: TObject);
    procedure actGenerateTreeExecute(Sender: TObject);
    procedure actTreeExpandAllExecute(Sender: TObject);
    procedure actTreeCollapseAllExecute(Sender: TObject);
    procedure actTreeExpandLevelExecute(Sender: TObject);
    procedure actTreeMarkLoadedExecute(Sender: TObject);
    procedure actTreeReloadExecute(Sender: TObject);
    procedure actTreeChildrenLoadedExecute(Sender: TObject);
    procedure actApplyCardTreeExecute(Sender: TObject);
    procedure actCardTreeRootExecute(Sender: TObject);
    procedure actCardTreeParentExecute(Sender: TObject);
    procedure actCardTreeExitExecute(Sender: TObject);
    procedure actCardTreeNavigateExecute(Sender: TObject);
    procedure actCardTreeTryNavigateExecute(Sender: TObject);
    procedure actCardTreeRefreshExecute(Sender: TObject);
    procedure actCardTreeExpandAllExecute(Sender: TObject);
    procedure actCardTreeCollapseAllExecute(Sender: TObject);
    procedure actCardTreeExpandNodeExecute(Sender: TObject);
    procedure actCardTreeCollapseNodeExecute(Sender: TObject);
    procedure actCardTreeIsExpandedExecute(Sender: TObject);
    procedure actApplyChecksExecute(Sender: TObject);
    procedure actCheckAllExecute(Sender: TObject);
    procedure actCheckVisibleExecute(Sender: TObject);
    procedure actUncheckAllExecute(Sender: TObject);
    procedure actUncheckVisibleExecute(Sender: TObject);
    procedure actInvertAllExecute(Sender: TObject);
    procedure actInvertVisibleExecute(Sender: TObject);
    procedure actToggleCheckedExecute(Sender: TObject);
    procedure actSetCheckedExecute(Sender: TObject);
    procedure actCheckByIDExecute(Sender: TObject);
    procedure actSetCheckStateExecute(Sender: TObject);
    procedure actGetCheckStateExecute(Sender: TObject);
    procedure actRecalculateChecksExecute(Sender: TObject);
    procedure actCheckedInfoExecute(Sender: TObject);
    procedure actApplySearchExecute(Sender: TObject);
    procedure actFindNextExecute(Sender: TObject);
    procedure actFindPreviousExecute(Sender: TObject);
    procedure actClearSearchExecute(Sender: TObject);
    procedure actClearFiltersExecute(Sender: TObject);
    procedure actNavigationInfoExecute(Sender: TObject);
    procedure actColumnTextExecute(Sender: TObject);
    procedure actApplyColumnAdvancedExecute(Sender: TObject);
    procedure actRuleAddExecute(Sender: TObject);
    procedure actRuleDeleteExecute(Sender: TObject);
    procedure actRulesClearExecute(Sender: TObject);
    procedure actRuleApplyExecute(Sender: TObject);
    procedure actRuleMatchesExecute(Sender: TObject);
    procedure actApplyDesignPreviewExecute(Sender: TObject);
    procedure actBindDataSourceExecute(Sender: TObject);
    procedure actUnbindDataSourceExecute(Sender: TObject);
    procedure actAddItemAPIExecute(Sender: TObject);
    procedure actTestAssignAPIsExecute(Sender: TObject);
    procedure actResetPerformanceExecute(Sender: TObject);
    procedure actPerformanceSnapshotExecute(Sender: TObject);
    procedure actPerformanceReportExecute(Sender: TObject);
    procedure actClearLogExecute(Sender: TObject);
    procedure actPauseLogExecute(Sender: TObject);
  private
    FLastOperationMS: Int64;
    FLogPaused: Boolean;
    FBuildingControls: Boolean;
    FDataSource: TDataSource;
    FClientDataSet: TClientDataSet;
    procedure ExecuteCommand(const ACommand: Integer; Sender: TObject);
    function Edit(const AName: string): TEdit;
    function Combo(const AName: string): TComboBox;
    function Switch(const AName: string): TSwitch;
    function Memo(const AName: string): TMemo;
    procedure GenerateItems(const ACount: Integer);
    procedure RestoreDefaultColumns;
    procedure RestoreDefaultActions;
    procedure RestoreDefaultCardTemplate;
    procedure RestoreDefaultColors;
    procedure RestoreDefaultGeometry;
    procedure ResetPlayground;
    procedure RefreshColumnEditor;
    procedure ApplySelectedColumn;
    procedure RefreshActionEditor;
    procedure ApplySelectedAction;
    procedure RefreshItemEditor;
    procedure ApplySelectedItem;
    procedure UpdateStatus;
    procedure LogEvent(const AText: string);
    procedure ReportError(const AContext: string; E: Exception);
    function SelectedColumn: TUniListColumn;
    function SelectedAction: TUniCardAction;
    function SelectedItem: TUniListItem;
    function IntValue(const AName: string; const ADefault: Integer): Integer;
    function FloatValue(const AName: string; const ADefault: Single): Single;
    function ColorValue(const AName: string;
      const ADefault: TAlphaColor): TAlphaColor;
    procedure RepaintAndStatus;
    procedure GenerateTreeItems;
    procedure PopulateThemes;
    procedure BindSampleDataSource;
    procedure UnbindDataSource;
    procedure TreeLoadChildren(Sender: TObject; const ParentKey: string;
      var Handled: Boolean);
    procedure ItemCheckChanged(Sender: TObject; AItem: TUniListItem;
      AChecked: Boolean);
    procedure ItemCheckChanging(Sender: TObject; const AItemId: string;
      const AOldState, ANewState: TUniCheckState; var AAllow: Boolean);
    procedure CheckedChangedEvent(Sender: TObject);
    procedure SearchChangedEvent(Sender: TObject);
    procedure TreePropagationCompletedEvent(Sender: TObject);
    procedure CardTreeLevelChangedEvent(Sender: TObject);
    procedure CardTreeNavigating(Sender: TObject; const ANodeId: string;
      var AAllow: Boolean);
    procedure CardTreeNodeEvent(Sender: TObject; const ANodeId: string);
  public
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

const
  cmdCards = 1;
  cmdList = 2;
  cmdGenerate100 = 3;
  cmdGenerate1000 = 4;
  cmdGenerate10000 = 5;
  cmdGenerate50000 = 6;
  cmdClear = 7;
  cmdReset = 8;
  cmdAutoFit = 9;
  cmdSaveLayoutFile = 10;
  cmdLoadLayoutFile = 11;
  cmdGenerateCustom = 12;
  cmdApplyScroll = 13;
  cmdScrollSelected = 14;
  cmdScrollIndex = 15;
  cmdScrollHome = 16;
  cmdScrollEnd = 17;
  cmdCardsCompact = 18;
  cmdCardsNormal = 19;
  cmdCardsLarge = 20;
  cmdCardsAutoTitle = 21;
  cmdCardsHorizontal = 22;
  cmdCardsWrapped = 23;
  cmdApplyTemplateFields = 24;
  cmdClearTextSelection = 25;
  cmdShowSelectedText = 26;
  cmdColumnChooser = 27;
  cmdResetHScroll = 28;
  cmdColumnAdd = 29;
  cmdColumnDelete = 30;
  cmdColumnsClear = 31;
  cmdColumnsRestore = 32;
  cmdColumnApply = 33;
  cmdColumnVisible = 34;
  cmdActionAdd = 35;
  cmdActionDelete = 36;
  cmdActionsClear = 37;
  cmdActionsRestore = 38;
  cmdActionApply = 39;
  cmdItemAdd = 40;
  cmdItemDelete = 41;
  cmdItemApply = 42;
  cmdItemEnable = 43;
  cmdItemDisable = 44;
  cmdItemRandomize = 45;
  cmdItemInspect = 46;
  cmdSortItems = 47;
  cmdSelect = 48;
  cmdSelectClear = 49;
  cmdSelectPrevious = 50;
  cmdSelectNext = 51;
  cmdColorsApply = 52;
  cmdColorsLight = 53;
  cmdColorsDark = 54;
  cmdColorsContrast = 55;
  cmdColorsReset = 56;
  cmdGetLayoutJSON = 57;
  cmdApplyLayoutJSON = 58;
  cmdDefaultLayout = 59;
  cmdClearLog = 60;
  cmdPauseLog = 61;
  cmdApplyExtendedView = 62;
  cmdGenerateTree = 63;
  cmdTreeExpandAll = 64;
  cmdTreeCollapseAll = 65;
  cmdTreeExpandLevel = 66;
  cmdTreeMarkLoaded = 67;
  cmdTreeReload = 68;
  cmdTreeChildrenLoaded = 69;
  cmdApplyCardTree = 70;
  cmdCardTreeRoot = 71;
  cmdCardTreeParent = 72;
  cmdCardTreeExit = 73;
  cmdCardTreeNavigate = 74;
  cmdCardTreeTryNavigate = 75;
  cmdCardTreeRefresh = 76;
  cmdCardTreeExpandAll = 77;
  cmdCardTreeCollapseAll = 78;
  cmdCardTreeExpandNode = 79;
  cmdCardTreeCollapseNode = 80;
  cmdCardTreeIsExpanded = 81;
  cmdApplyChecks = 82;
  cmdCheckAll = 83;
  cmdCheckVisible = 84;
  cmdUncheckAll = 85;
  cmdUncheckVisible = 86;
  cmdInvertAll = 87;
  cmdInvertVisible = 88;
  cmdToggleChecked = 89;
  cmdSetChecked = 90;
  cmdCheckByID = 91;
  cmdSetCheckState = 92;
  cmdGetCheckState = 93;
  cmdRecalculateChecks = 94;
  cmdCheckedInfo = 95;
  cmdApplySearch = 96;
  cmdFindNext = 97;
  cmdFindPrevious = 98;
  cmdClearSearch = 99;
  cmdClearFilters = 100;
  cmdNavigationInfo = 101;
  cmdColumnText = 102;
  cmdApplyColumnAdvanced = 103;
  cmdRuleAdd = 104;
  cmdRuleDelete = 105;
  cmdRulesClear = 106;
  cmdRuleApply = 107;
  cmdRuleMatches = 108;
  cmdApplyTheme = 109;
  cmdLoadTheme = 110;
  cmdThemeInfo = 111;
  cmdApplyFonts = 112;
  cmdApplyDesignPreview = 113;
  cmdBindDataSource = 114;
  cmdUnbindDataSource = 115;
  cmdResetPerformance = 116;
  cmdPerformanceSnapshot = 117;
  cmdPerformanceReport = 118;
  cmdAddItemAPI = 119;
  cmdSortByFields = 120;
  cmdTestAssignAPIs = 121;
  cmdToggleControlPanel = 122;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FBuildingControls := True;
  try
    PopulateThemes;
//    MainSplitter.Parent := nil;
//    ControlPanel.Parent := nil;
    FDataSource := TDataSource.Create(Self);
    FClientDataSet := TClientDataSet.Create(Self);
    FDataSource.DataSet := FClientDataSet;

  finally
    FBuildingControls := False;
  end;
  ResetPlayground;
  UniListView1.OnTreeLoadChildren := TreeLoadChildren;
  UniListView1.OnItemCheckChanged := ItemCheckChanged;
  UniListView1.OnItemCheckChanging := ItemCheckChanging;
  UniListView1.OnTreeCheckPropagationCompleted := TreePropagationCompletedEvent;
  UniListView1.OnCheckedChanged := CheckedChangedEvent;
  UniListView1.OnSearchChanged := SearchChangedEvent;
  UniListView1.OnCardTreeNavigating := CardTreeNavigating;
  UniListView1.OnCardTreeNavigated := CardTreeNodeEvent;
  UniListView1.OnCardTreeLevelChanged := CardTreeLevelChangedEvent;
  UniListView1.OnCardTreeNodeExpand := CardTreeNodeEvent;
  UniListView1.OnCardTreeNodeCollapse := CardTreeNodeEvent;
  UniListView1.OnCardTreeBreadcrumbClick := CardTreeNodeEvent;end;

function TMainForm.Edit(const AName: string): TEdit;
begin
  Result := FindComponent(AName) as TEdit;
end;

function TMainForm.Combo(const AName: string): TComboBox;
begin
  Result := FindComponent(AName) as TComboBox;
end;

function TMainForm.Switch(const AName: string): TSwitch;
begin
  Result := FindComponent(AName) as TSwitch;
end;

function TMainForm.Memo(const AName: string): TMemo;
begin
  Result := FindComponent(AName) as TMemo;
end;

function TMainForm.IntValue(const AName: string;
  const ADefault: Integer): Integer;
begin
  if not TryStrToInt(Edit(AName).Text, Result) then
    Result := ADefault;
end;

function TMainForm.FloatValue(const AName: string;
  const ADefault: Single): Single;
begin
  if not TryStrToFloat(Edit(AName).Text, Result) then
    Result := ADefault;
end;

function TMainForm.ColorValue(const AName: string;
  const ADefault: TAlphaColor): TAlphaColor;
var
  V: UInt64;
begin
  if TryStrToUInt64('$' + Trim(Edit(AName).Text), V) then
    Result := TAlphaColor(V)
  else
    Result := ADefault;
end;

procedure TMainForm.GenerateItems(const ACount: Integer);
const
  Names: array[0..5] of string = ('Server', 'Application service',
    'Database cluster with a deliberately long display name', 'Gateway',
    'Ўзбекистон, Қорақалпоғистон, ёшлар ва таълим', 'Worker');
  Statuses: array[0..3] of string = ('Active', 'Warning', 'Offline', 'Pending');
var
  Count: Integer;
  I: Integer;
  Item: TUniListItem;
  Timer: TStopwatch;
begin
  Count := EnsureRange(ACount, 1, 200000);
  Timer := TStopwatch.StartNew;
  UniListView1.BeginUpdate;
  try
    UniListView1.Items.Clear;
    for I := 0 to Count - 1 do
    begin
      Item := UniListView1.Items.Add;
      Item.ID := IntToStr(I + 1);
      Item.ParentID := '';
      Item.Title := Names[I mod Length(Names)] + ' ' + IntToStr(I + 1);
      case I mod 4 of
        0: Item.Text := 'Short description';
        1: Item.Text := '';
        2: Item.Text := 'First line' + sLineBreak + 'Second line';
        3: Item.Text := 'A longer description used to verify wrapping and ellipsis behavior';
      end;
      Item.Detail := Statuses[I mod Length(Statuses)];
      Item.IconText := 'server';
      Item.Enabled := I mod 11 <> 0;
      Item.SetField('name', Item.Title);
      Item.SetField('description', Item.Text);
      Item.SetField('status', Item.Detail);
      Item.SetField('icon', 'server');
      Item.SetField('latency_ms', I mod 997);
      Item.SetField('load_percent', (I mod 1000) / 10.0);
      Item.SetField('enabled', Item.Enabled);
      Item.SetField('can_edit', I mod 5 <> 0);
      Item.SetField('can_delete', I mod 7 <> 0);
      Item.SetFieldDateTime('updated_at', Now - (I mod 1440) / 1440);
    end;
  finally
    UniListView1.EndUpdate;
  end;
  Timer.Stop;
  FLastOperationMS := Timer.ElapsedMilliseconds;
  LogEvent(Format('GenerateItems: count=%d, elapsed=%d ms',
    [Count, FLastOperationMS]));
  UpdateStatus;
end;

procedure TMainForm.RestoreDefaultColumns;
  procedure AddColumn(const AID, AField, ACaption: string;
    const AType: TUniColumnDataType; const AMode: TUniColumnWidthMode;
    const AAlign: TTextAlign; const AWidth: Single);
  var
    C: TUniListColumn;
  begin
    C := UniListView1.Columns.Add;
    C.LayoutID := AID;
    C.FieldName := AField;
    C.Caption := ACaption;
    C.DataType := AType;
    C.WidthMode := AMode;
    C.Alignment := AAlign;
    C.Width := AWidth;
  end;
begin
  UniListView1.Columns.Clear;
  AddColumn('col_name', 'name', 'Наименование', ucdtText, ucwmFill,
    TTextAlign.Leading, 260);
  AddColumn('col_status', 'status', 'Состояние', ucdtText, ucwmFixed,
    TTextAlign.Leading, 120);
  AddColumn('col_latency', 'latency_ms', 'Задержка, ms', ucdtInteger,
    ucwmFixed, TTextAlign.Trailing, 110);
  AddColumn('col_load', 'load_percent', 'Нагрузка', ucdtFloat, ucwmFixed,
    TTextAlign.Trailing, 100);
  AddColumn('col_updated', 'updated_at', 'Обновлено', ucdtDateTime,
    ucwmFixed, TTextAlign.Center, 160);
  AddColumn('col_enabled', 'enabled', 'Активен', ucdtBoolean, ucwmFixed,
    TTextAlign.Center, 90);
  RefreshColumnEditor;
end;

procedure TMainForm.RestoreDefaultActions;
var
  A: TUniCardAction;
begin
  UniListView1.Actions.Clear;
  A := UniListView1.Actions.Add;
  A.Name := 'edit';
  A.Caption := 'Edit';
  A.Icon := uviEdit;
  A.EnabledField := 'can_edit';
  A := UniListView1.Actions.Add;
  A.Name := 'delete';
  A.Caption := 'Delete';
  A.Icon := uviDelete;
  A.EnabledField := 'can_delete';
  RefreshActionEditor;
end;

procedure TMainForm.RestoreDefaultCardTemplate;
var
  T: TUniCardTemplate;
begin
  T := UniListView1.CardTemplate;
  T.ShowIcon := True;
  T.ShowTitle := True;
  T.ShowText := True;
  T.ShowDetail := True;
  T.ShowActions := True;
  T.WordWrap := True;
  T.Ellipsis := True;
  T.AutoCardHeight := True;
  T.SelectableText := True;
  T.TitleMaxLines := 2;
  T.TextMaxLines := 3;
  T.DetailMaxLines := 2;
  T.MaxCardHeight := 260;
  T.Icon := uviServer;
  T.IconSize := 20;
  T.IconBoxSize := 40;
  T.InnerPadding := 12;
  T.TextGap := 3;
  T.TitleField := 'name';
  T.TextField := 'description';
  T.DetailField := 'status';
  T.IconField := 'icon';
  T.StatusField := 'status';
end;

procedure TMainForm.RestoreDefaultColors;
begin
  UniListView1.BackgroundColor := $FFF2F4F7;
  UniListView1.CardColor := $FFFFFFFF;
  UniListView1.CardHotColor := $FFF5F7FA;
  UniListView1.CardSelectedColor := $FFE1F0FF;
  UniListView1.TextColor := $FF20242A;
  UniListView1.SecondaryTextColor := $FF68717D;
  UniListView1.AccentColor := $FF1677FF;
  UniListView1.HeaderColor := $FFE7ECF2;
  UniListView1.AlternateRowColor := $FFF7F9FC;
  UniListView1.FooterColor := $FFE7ECF2;
  UniListView1.GridColor := $FFD7DDE5;
end;

procedure TMainForm.RestoreDefaultGeometry;
begin
  UniListView1.CardMinWidth := 240;
  UniListView1.CardMaxWidth := 420;
  UniListView1.CardWidth := 300;
  UniListView1.CardHeight := 110;
  UniListView1.HorizontalGap := 10;
  UniListView1.VerticalGap := 10;
  UniListView1.ContentPadding := 10;
  UniListView1.CornerRadius := 8;
  UniListView1.FixedColumnCount := 3;
  UniListView1.PanThreshold := 6;
  UniListView1.ListHeaderHeight := 34;
  UniListView1.ListRowHeight := 32;
  UniListView1.ListGridLines := True;
  UniListView1.ListFooterVisible := False;
  UniListView1.ListFooterHeight := 32;
  UniListView1.ListFrozenColumnCount := 0;
end;

procedure TMainForm.ResetPlayground;
begin
  UniListView1.DataSource := nil;
  UniListView1.BeginUpdate;
  try
    UniListView1.Items.Clear;
    RestoreDefaultColumns;
    RestoreDefaultActions;
    RestoreDefaultCardTemplate;
    RestoreDefaultColors;
    RestoreDefaultGeometry;
    UniListView1.ViewMode := uvmCards;
    UniListView1.ScrollMode := usmVertical;
    UniListView1.PanMode := upmMouseAndTouch;
    UniListView1.ScrollBars := usbAuto;
    UniListView1.ContentFlow := ucfWrap;
    UniListView1.CardSizingMode := ucsmResponsive;
    UniListView1.CardLayout := uclGrid;
    UniListView1.ActionVisibility := uavAlways;
    UniListView1.ListAutoRowHeight := False;
    UniListView1.ListFilterVisible := False;
    UniListView1.TreeMode := False;
    UniListView1.CardTreeEnabled := False;
    UniListView1.MultiCheck := False;
    UniListView1.ShowCheckBoxes := True;
    UniListView1.TreeCheckMode := tcmIndependent;
    UniListView1.SearchText := '';
    UniListView1.ColorRules.Clear;
    UniListView1.SelectedIndex := -1;
    UniListView1.ScrollX := 0;
    UniListView1.ScrollY := 0;
  finally
    UniListView1.EndUpdate;
  end;
  GenerateItems(100);
  LogEvent('Reset: default state restored on the existing UniListView1');
end;

function TMainForm.SelectedColumn: TUniListColumn;
var
  I: Integer;
begin
  I := Combo('cbColumn').ItemIndex;
  if InRange(I, 0, UniListView1.Columns.Count - 1) then
    Result := UniListView1.Columns[I]
  else
    Result := nil;
end;

procedure TMainForm.RefreshColumnEditor;
var
  C: TUniListColumn;
  I: Integer;
begin
  Combo('cbColumn').Items.BeginUpdate;
  try
    Combo('cbColumn').Items.Clear;
    for I := 0 to UniListView1.Columns.Count - 1 do
      Combo('cbColumn').Items.Add(UniListView1.Columns[I].Caption);
  finally
    Combo('cbColumn').Items.EndUpdate;
  end;
  if UniListView1.Columns.Count > 0 then
    Combo('cbColumn').ItemIndex := 0;
  C := SelectedColumn;
  if C = nil then
    Exit;
  Edit('edColumnLayoutID').Text := C.LayoutID;
  Edit('edColumnField').Text := C.FieldName;
  Edit('edColumnCaption').Text := C.Caption;
  Edit('edColumnWidth').Text := FloatToStr(C.Width);
  Edit('edColumnMinWidth').Text := FloatToStr(C.MinWidth);
  Edit('edColumnMaxWidth').Text := FloatToStr(C.MaxWidth);
  Combo('cbColumnWidthMode').ItemIndex := Ord(C.WidthMode);
  Combo('cbColumnDataType').ItemIndex := Ord(C.DataType);
  Combo('cbColumnAlignment').ItemIndex := Ord(C.Alignment);
  Switch('swColumnVisible').IsChecked := C.Visible;
  Switch('swColumnSortable').IsChecked := C.Sortable;
  Edit('edColumnFormat').Text := C.Format;
end;

procedure TMainForm.ApplySelectedColumn;
var
  C: TUniListColumn;
begin
  C := SelectedColumn;
  if C = nil then
    Exit;
  C.LayoutID := Edit('edColumnLayoutID').Text;
  C.FieldName := Edit('edColumnField').Text;
  C.Caption := Edit('edColumnCaption').Text;
  C.Width := FloatValue('edColumnWidth', C.Width);
  C.MinWidth := FloatValue('edColumnMinWidth', C.MinWidth);
  C.MaxWidth := FloatValue('edColumnMaxWidth', C.MaxWidth);
  C.WidthMode := TUniColumnWidthMode(Combo('cbColumnWidthMode').ItemIndex);
  C.DataType := TUniColumnDataType(Combo('cbColumnDataType').ItemIndex);
  C.Alignment := TTextAlign(Combo('cbColumnAlignment').ItemIndex);
  C.Visible := Switch('swColumnVisible').IsChecked;
  C.Sortable := Switch('swColumnSortable').IsChecked;
  C.Format := Edit('edColumnFormat').Text;
  RefreshColumnEditor;
end;

function TMainForm.SelectedAction: TUniCardAction;
var
  I: Integer;
begin
  I := Combo('cbAction').ItemIndex;
  if InRange(I, 0, UniListView1.Actions.Count - 1) then
    Result := UniListView1.Actions[I]
  else
    Result := nil;
end;

procedure TMainForm.RefreshActionEditor;
var
  A: TUniCardAction;
  I: Integer;
begin
  Combo('cbAction').Items.Clear;
  for I := 0 to UniListView1.Actions.Count - 1 do
    Combo('cbAction').Items.Add(UniListView1.Actions[I].Name);
  if UniListView1.Actions.Count > 0 then
    Combo('cbAction').ItemIndex := 0;
  A := SelectedAction;
  if A = nil then
    Exit;
  Edit('edActionName').Text := A.Name;
  Edit('edActionCaption').Text := A.Caption;
  Combo('cbActionIcon').ItemIndex := Min(Ord(A.Icon), 8);
  Edit('edActionWidth').Text := FloatToStr(A.Width);
  Switch('swActionVisible').IsChecked := A.Visible;
  Switch('swActionEnabled').IsChecked := A.Enabled;
  Edit('edActionVisibleField').Text := A.VisibleField;
  Edit('edActionEnabledField').Text := A.EnabledField;
end;

procedure TMainForm.ApplySelectedAction;
var
  A: TUniCardAction;
begin
  A := SelectedAction;
  if A = nil then
    Exit;
  A.Name := Edit('edActionName').Text;
  A.Caption := Edit('edActionCaption').Text;
  A.Icon := TUniVectorIcon(Combo('cbActionIcon').ItemIndex);
  A.Width := FloatValue('edActionWidth', A.Width);
  A.Visible := Switch('swActionVisible').IsChecked;
  A.Enabled := Switch('swActionEnabled').IsChecked;
  A.VisibleField := Edit('edActionVisibleField').Text;
  A.EnabledField := Edit('edActionEnabledField').Text;
  RefreshActionEditor;
end;

function TMainForm.SelectedItem: TUniListItem;
begin
  if InRange(UniListView1.SelectedIndex, 0, UniListView1.Items.Count - 1) then
    Result := UniListView1.Items[UniListView1.SelectedIndex]
  else
    Result := nil;
end;

procedure TMainForm.RefreshItemEditor;
var
  Item: TUniListItem;
begin
  Item := SelectedItem;
  if Item = nil then
    Exit;
  Edit('edItemID').Text := Item.ID;
  Edit('edItemParentID').Text := Item.ParentID;
  Edit('edItemTitle').Text := Item.Title;
  Edit('edItemText').Text := Item.Text;
  Edit('edItemDetail').Text := Item.Detail;
  Edit('edItemIcon').Text := Item.IconText;
  Switch('swItemEnabled').IsChecked := Item.Enabled;
  Edit('edSelectedIndex').Text := IntToStr(UniListView1.SelectedIndex);
end;

procedure TMainForm.ApplySelectedItem;
var
  Item: TUniListItem;
begin
  Item := SelectedItem;
  if Item = nil then
    Exit;
  Item.ID := Edit('edItemID').Text;
  Item.ParentID := Edit('edItemParentID').Text;
  Item.Title := Edit('edItemTitle').Text;
  Item.Text := Edit('edItemText').Text;
  Item.Detail := Edit('edItemDetail').Text;
  Item.IconText := Edit('edItemIcon').Text;
  Item.Enabled := Switch('swItemEnabled').IsChecked;
  Item.SetField('name', Item.Title);
  Item.SetField('description', Item.Text);
  Item.SetField('status', Item.Detail);
  Item.SetField('icon', Item.IconText);
end;

procedure TMainForm.GenerateTreeItems;
var
  DivisionIndex, DepartmentIndex, TeamIndex: Integer;
  DivisionID, DepartmentID: string;
  Item: TUniListItem;
  procedure AddTreeItem(const AID, AParentID, AName, AKind: string;
    const AHasChildren: Boolean);
  begin
    Item := UniListView1.Items.Add;
    Item.ID := AID;
    Item.ParentID := AParentID;
    Item.Title := AName;
    Item.Text := AKind;
    Item.Detail := 'Active';
    Item.IconText := 'server';
    Item.SetField('id', AID);
    Item.SetField('parent_id', AParentID);
    Item.SetField('name', AName);
    Item.SetField('description', AKind);
    Item.SetField('status', 'Active');
    Item.SetField('icon', 'server');
    Item.SetField('has_children', AHasChildren);
    Item.SetField('enabled', True);
  end;
begin
  UniListView1.BeginUpdate;
  try
    UniListView1.Items.Clear;
    for DivisionIndex := 1 to 4 do
    begin
      DivisionID := 'division_' + IntToStr(DivisionIndex);
      AddTreeItem(DivisionID, '', 'Division ' + IntToStr(DivisionIndex),
        'Company division', True);
      for DepartmentIndex := 1 to 3 do
      begin
        DepartmentID := DivisionID + '_department_' +
          IntToStr(DepartmentIndex);
        AddTreeItem(DepartmentID, DivisionID,
          'Department ' + IntToStr(DepartmentIndex), 'Department', True);
        for TeamIndex := 1 to 2 do
          AddTreeItem(DepartmentID + '_team_' + IntToStr(TeamIndex),
            DepartmentID, 'Team ' + IntToStr(TeamIndex), 'Delivery team', False);
      end;
    end;
    UniListView1.TreeKeyField := 'id';
    UniListView1.TreeParentField := 'parent_id';
    UniListView1.TreeColumn := 'name';
    UniListView1.SelectedIndex := -1;
  finally
    UniListView1.EndUpdate;
  end;
  LogEvent('GenerateTreeItems: hierarchical dataset loaded');
  UpdateStatus;
end;

procedure TMainForm.PopulateThemes;
var
  ThemeNames: TArray<string>;
  ThemeName: string;
begin
  ThemeNames := UniListView1.AvailableThemeNames;
  Combo('cbTheme').Items.Clear;
  for ThemeName in ThemeNames do
    Combo('cbTheme').Items.Add(ThemeName);
  Combo('cbTheme').ItemIndex := Combo('cbTheme').Items.IndexOf(
    UniListView1.ThemeName);
  if (Combo('cbTheme').ItemIndex < 0) and
     (Combo('cbTheme').Items.Count > 0) then
    Combo('cbTheme').ItemIndex := 0;
end;

procedure TMainForm.BindSampleDataSource;
var
  I: Integer;
begin
  UniListView1.DataSource := nil;
  if FClientDataSet.Active then
    FClientDataSet.Close;
  FClientDataSet.FieldDefs.Clear;
  FClientDataSet.FieldDefs.Add('id', ftInteger);
  FClientDataSet.FieldDefs.Add('name', ftWideString, 120);
  FClientDataSet.FieldDefs.Add('description', ftWideString, 250);
  FClientDataSet.FieldDefs.Add('status', ftWideString, 30);
  FClientDataSet.FieldDefs.Add('latency_ms', ftInteger);
  FClientDataSet.FieldDefs.Add('load_percent', ftFloat);
  FClientDataSet.FieldDefs.Add('enabled', ftBoolean);
  FClientDataSet.FieldDefs.Add('updated_at', ftDateTime);
  FClientDataSet.CreateDataSet;
  for I := 1 to 25 do
  begin
    FClientDataSet.Append;
    FClientDataSet.FieldByName('id').AsInteger := I;
    FClientDataSet.FieldByName('name').AsWideString :=
      'DataSource item ' + IntToStr(I);
    FClientDataSet.FieldByName('description').AsWideString :=
      'Live TClientDataSet binding';
    FClientDataSet.FieldByName('status').AsWideString := 'Active';
    FClientDataSet.FieldByName('latency_ms').AsInteger := I * 7;
    FClientDataSet.FieldByName('load_percent').AsFloat := I * 2.5;
    FClientDataSet.FieldByName('enabled').AsBoolean := Odd(I);
    FClientDataSet.FieldByName('updated_at').AsDateTime := Now;
    FClientDataSet.Post;
  end;
  FClientDataSet.First;
  UniListView1.DataSource := FDataSource;
  LogEvent('DataSource: sample TClientDataSet bound');
end;

procedure TMainForm.UnbindDataSource;
begin
  UniListView1.DataSource := nil;
  if (FClientDataSet <> nil) and FClientDataSet.Active then
    FClientDataSet.Close;
  LogEvent('DataSource: unbound');
end;

procedure TMainForm.TreeLoadChildren(Sender: TObject;
  const ParentKey: string; var Handled: Boolean);
begin
  LogEvent('OnTreeLoadChildren: parent=' + ParentKey);
  Handled := False;
end;

procedure TMainForm.ItemCheckChanged(Sender: TObject; AItem: TUniListItem;
  AChecked: Boolean);
begin
  LogEvent(Format('OnItemCheckChanged: id=%s, checked=%s',
    [AItem.ID, BoolToStr(AChecked, True)]));
  UpdateStatus;
end;

procedure TMainForm.ItemCheckChanging(Sender: TObject; const AItemId: string;
  const AOldState, ANewState: TUniCheckState; var AAllow: Boolean);
begin
  LogEvent(Format('OnItemCheckChanging: id=%s, %d -> %d, allow=%s',
    [AItemId, Ord(AOldState), Ord(ANewState), BoolToStr(AAllow, True)]));
end;

procedure TMainForm.CheckedChangedEvent(Sender: TObject);
begin
  LogEvent('OnCheckedChanged: count=' + IntToStr(UniListView1.CheckedCount));
  UpdateStatus;
end;

procedure TMainForm.SearchChangedEvent(Sender: TObject);
begin
  LogEvent(Format('OnSearchChanged: text=%s, matches=%d, running=%s',
    [UniListView1.SearchText, UniListView1.SearchMatchCount,
     BoolToStr(UniListView1.SearchRunning, True)]));
  UpdateStatus;
end;

procedure TMainForm.TreePropagationCompletedEvent(Sender: TObject);
begin
  LogEvent('OnTreeCheckPropagationCompleted');
  UpdateStatus;
end;

procedure TMainForm.CardTreeLevelChangedEvent(Sender: TObject);
begin
  LogEvent(Format('OnCardTreeLevelChanged: depth=%d, node=%s',
    [UniListView1.CardTreeCurrentDepth, UniListView1.CardTreeCurrentNodeId]));
  UpdateStatus;
end;

procedure TMainForm.CardTreeNavigating(Sender: TObject;
  const ANodeId: string; var AAllow: Boolean);
begin
  LogEvent(Format('OnCardTreeNavigating: node=%s, allow=%s',
    [ANodeId, BoolToStr(AAllow, True)]));
end;

procedure TMainForm.CardTreeNodeEvent(Sender: TObject;
  const ANodeId: string);
begin
  LogEvent('Card tree node event: node=' + ANodeId);
  UpdateStatus;
end;
procedure TMainForm.SettingChanged(Sender: TObject);
var
  T: TUniCardTemplate;
begin
  if FBuildingControls then
    Exit;

  T := UniListView1.CardTemplate;
  UniListView1.ScrollMode := TUniScrollMode(Combo('cbScrollMode').ItemIndex);
  UniListView1.PanMode := TUniPanMode(Combo('cbPanMode').ItemIndex);
  UniListView1.ScrollBars := TUniScrollBarVisibility(
    Combo('cbScrollBars').ItemIndex);
  UniListView1.ContentFlow := TUniContentFlow(
    Combo('cbContentFlow').ItemIndex);
  UniListView1.CardSizingMode := TUniCardSizingMode(
    Combo('cbCardSizing').ItemIndex);
  T.ShowIcon := Switch('swShowIcon').IsChecked;
  T.ShowTitle := Switch('swShowTitle').IsChecked;
  T.ShowText := Switch('swShowText').IsChecked;
  T.ShowDetail := Switch('swShowDetail').IsChecked;
  T.ShowActions := Switch('swShowActions').IsChecked;
  T.WordWrap := Switch('swWordWrap').IsChecked;
  T.Ellipsis := Switch('swEllipsis').IsChecked;
  T.AutoCardHeight := Switch('swAutoCardHeight').IsChecked;
  T.SelectableText := Switch('swSelectableText').IsChecked;
  UniListView1.ListGridLines := Switch('swGridLines').IsChecked;
  UniListView1.ListFooterVisible := Switch('swFooterVisible').IsChecked;
  RepaintAndStatus;
end;

procedure TMainForm.RepaintAndStatus;
begin
  UniListView1.Repaint;
  UpdateStatus;
end;

procedure TMainForm.actCardsExecute(Sender: TObject);
begin
  ExecuteCommand(cmdCards, Sender);
end;

procedure TMainForm.actListExecute(Sender: TObject);
begin
  ExecuteCommand(cmdList, Sender);
end;

procedure TMainForm.actGenerate100Execute(Sender: TObject);
begin
  ExecuteCommand(cmdGenerate100, Sender);
end;

procedure TMainForm.actGenerate1000Execute(Sender: TObject);
begin
  ExecuteCommand(cmdGenerate1000, Sender);
end;

procedure TMainForm.actGenerate10000Execute(Sender: TObject);
begin
  ExecuteCommand(cmdGenerate10000, Sender);
end;

procedure TMainForm.actGenerate50000Execute(Sender: TObject);
begin
  ExecuteCommand(cmdGenerate50000, Sender);
end;

procedure TMainForm.actClearExecute(Sender: TObject);
begin
  ExecuteCommand(cmdClear, Sender);
end;

procedure TMainForm.actResetExecute(Sender: TObject);
begin
  ExecuteCommand(cmdReset, Sender);
end;

procedure TMainForm.actAutoFitExecute(Sender: TObject);
begin
  ExecuteCommand(cmdAutoFit, Sender);
end;

procedure TMainForm.actSaveLayoutFileExecute(Sender: TObject);
begin
  ExecuteCommand(cmdSaveLayoutFile, Sender);
end;

procedure TMainForm.actLoadLayoutFileExecute(Sender: TObject);
begin
  ExecuteCommand(cmdLoadLayoutFile, Sender);
end;

procedure TMainForm.actToggleControlPanelExecute(Sender: TObject);
begin
  ExecuteCommand(cmdToggleControlPanel, Sender);
end;

procedure TMainForm.actCards2Execute(Sender: TObject);
begin
  ExecuteCommand(cmdCards, Sender);
end;

procedure TMainForm.actList2Execute(Sender: TObject);
begin
  ExecuteCommand(cmdList, Sender);
end;

procedure TMainForm.actApplyThemeExecute(Sender: TObject);
begin
  ExecuteCommand(cmdApplyTheme, Sender);
end;

procedure TMainForm.actLoadThemeExecute(Sender: TObject);
begin
  ExecuteCommand(cmdLoadTheme, Sender);
end;

procedure TMainForm.actThemeInfoExecute(Sender: TObject);
begin
  ExecuteCommand(cmdThemeInfo, Sender);
end;

procedure TMainForm.actApplyFontsExecute(Sender: TObject);
begin
  ExecuteCommand(cmdApplyFonts, Sender);
end;

procedure TMainForm.actApplyScrollExecute(Sender: TObject);
begin
  ExecuteCommand(cmdApplyScroll, Sender);
end;

procedure TMainForm.actScrollSelectedExecute(Sender: TObject);
begin
  ExecuteCommand(cmdScrollSelected, Sender);
end;

procedure TMainForm.actScrollIndexExecute(Sender: TObject);
begin
  ExecuteCommand(cmdScrollIndex, Sender);
end;

procedure TMainForm.actScrollHomeExecute(Sender: TObject);
begin
  ExecuteCommand(cmdScrollHome, Sender);
end;

procedure TMainForm.actScrollEndExecute(Sender: TObject);
begin
  ExecuteCommand(cmdScrollEnd, Sender);
end;

procedure TMainForm.actCardsCompactExecute(Sender: TObject);
begin
  ExecuteCommand(cmdCardsCompact, Sender);
end;

procedure TMainForm.actCardsNormalExecute(Sender: TObject);
begin
  ExecuteCommand(cmdCardsNormal, Sender);
end;

procedure TMainForm.actCardsLargeExecute(Sender: TObject);
begin
  ExecuteCommand(cmdCardsLarge, Sender);
end;

procedure TMainForm.actCardsAutoTitleExecute(Sender: TObject);
begin
  ExecuteCommand(cmdCardsAutoTitle, Sender);
end;

procedure TMainForm.actCardsHorizontalExecute(Sender: TObject);
begin
  ExecuteCommand(cmdCardsHorizontal, Sender);
end;

procedure TMainForm.actCardsWrappedExecute(Sender: TObject);
begin
  ExecuteCommand(cmdCardsWrapped, Sender);
end;

procedure TMainForm.actApplyTemplateFieldsExecute(Sender: TObject);
begin
  ExecuteCommand(cmdApplyTemplateFields, Sender);
end;

procedure TMainForm.actClearTextSelectionExecute(Sender: TObject);
begin
  ExecuteCommand(cmdClearTextSelection, Sender);
end;

procedure TMainForm.actShowSelectedTextExecute(Sender: TObject);
begin
  ExecuteCommand(cmdShowSelectedText, Sender);
end;

procedure TMainForm.actList3Execute(Sender: TObject);
begin
  ExecuteCommand(cmdList, Sender);
end;

procedure TMainForm.actAutoFit2Execute(Sender: TObject);
begin
  ExecuteCommand(cmdAutoFit, Sender);
end;

procedure TMainForm.actColumnChooserExecute(Sender: TObject);
begin
  ExecuteCommand(cmdColumnChooser, Sender);
end;

procedure TMainForm.actResetHScrollExecute(Sender: TObject);
begin
  ExecuteCommand(cmdResetHScroll, Sender);
end;

procedure TMainForm.actColumnAddExecute(Sender: TObject);
begin
  ExecuteCommand(cmdColumnAdd, Sender);
end;

procedure TMainForm.actColumnDeleteExecute(Sender: TObject);
begin
  ExecuteCommand(cmdColumnDelete, Sender);
end;

procedure TMainForm.actColumnsClearExecute(Sender: TObject);
begin
  ExecuteCommand(cmdColumnsClear, Sender);
end;

procedure TMainForm.actColumnsRestoreExecute(Sender: TObject);
begin
  ExecuteCommand(cmdColumnsRestore, Sender);
end;

procedure TMainForm.actColumnApplyExecute(Sender: TObject);
begin
  ExecuteCommand(cmdColumnApply, Sender);
end;

procedure TMainForm.actColumnVisibleExecute(Sender: TObject);
begin
  ExecuteCommand(cmdColumnVisible, Sender);
end;

procedure TMainForm.actActionAddExecute(Sender: TObject);
begin
  ExecuteCommand(cmdActionAdd, Sender);
end;

procedure TMainForm.actActionDeleteExecute(Sender: TObject);
begin
  ExecuteCommand(cmdActionDelete, Sender);
end;

procedure TMainForm.actActionsClearExecute(Sender: TObject);
begin
  ExecuteCommand(cmdActionsClear, Sender);
end;

procedure TMainForm.actActionsRestoreExecute(Sender: TObject);
begin
  ExecuteCommand(cmdActionsRestore, Sender);
end;

procedure TMainForm.actActionApplyExecute(Sender: TObject);
begin
  ExecuteCommand(cmdActionApply, Sender);
end;

procedure TMainForm.actGenerateCustomExecute(Sender: TObject);
begin
  ExecuteCommand(cmdGenerateCustom, Sender);
end;

procedure TMainForm.actItemAddExecute(Sender: TObject);
begin
  ExecuteCommand(cmdItemAdd, Sender);
end;

procedure TMainForm.actItemDeleteExecute(Sender: TObject);
begin
  ExecuteCommand(cmdItemDelete, Sender);
end;

procedure TMainForm.actItemApplyExecute(Sender: TObject);
begin
  ExecuteCommand(cmdItemApply, Sender);
end;

procedure TMainForm.actItemEnableExecute(Sender: TObject);
begin
  ExecuteCommand(cmdItemEnable, Sender);
end;

procedure TMainForm.actItemDisableExecute(Sender: TObject);
begin
  ExecuteCommand(cmdItemDisable, Sender);
end;

procedure TMainForm.actItemRandomizeExecute(Sender: TObject);
begin
  ExecuteCommand(cmdItemRandomize, Sender);
end;

procedure TMainForm.actItemInspectExecute(Sender: TObject);
begin
  ExecuteCommand(cmdItemInspect, Sender);
end;

procedure TMainForm.actSortItemsExecute(Sender: TObject);
begin
  ExecuteCommand(cmdSortItems, Sender);
end;

procedure TMainForm.actSortByFieldsExecute(Sender: TObject);
begin
  ExecuteCommand(cmdSortByFields, Sender);
end;

procedure TMainForm.actSelectExecute(Sender: TObject);
begin
  ExecuteCommand(cmdSelect, Sender);
end;

procedure TMainForm.actSelectClearExecute(Sender: TObject);
begin
  ExecuteCommand(cmdSelectClear, Sender);
end;

procedure TMainForm.actSelectPreviousExecute(Sender: TObject);
begin
  ExecuteCommand(cmdSelectPrevious, Sender);
end;

procedure TMainForm.actSelectNextExecute(Sender: TObject);
begin
  ExecuteCommand(cmdSelectNext, Sender);
end;

procedure TMainForm.actScrollSelected2Execute(Sender: TObject);
begin
  ExecuteCommand(cmdScrollSelected, Sender);
end;

procedure TMainForm.actColorsApplyExecute(Sender: TObject);
begin
  ExecuteCommand(cmdColorsApply, Sender);
end;

procedure TMainForm.actColorsLightExecute(Sender: TObject);
begin
  ExecuteCommand(cmdColorsLight, Sender);
end;

procedure TMainForm.actColorsDarkExecute(Sender: TObject);
begin
  ExecuteCommand(cmdColorsDark, Sender);
end;

procedure TMainForm.actColorsContrastExecute(Sender: TObject);
begin
  ExecuteCommand(cmdColorsContrast, Sender);
end;

procedure TMainForm.actColorsResetExecute(Sender: TObject);
begin
  ExecuteCommand(cmdColorsReset, Sender);
end;

procedure TMainForm.actGetLayoutJSONExecute(Sender: TObject);
begin
  ExecuteCommand(cmdGetLayoutJSON, Sender);
end;

procedure TMainForm.actApplyLayoutJSONExecute(Sender: TObject);
begin
  ExecuteCommand(cmdApplyLayoutJSON, Sender);
end;

procedure TMainForm.actSaveLayoutFile2Execute(Sender: TObject);
begin
  ExecuteCommand(cmdSaveLayoutFile, Sender);
end;

procedure TMainForm.actLoadLayoutFile2Execute(Sender: TObject);
begin
  ExecuteCommand(cmdLoadLayoutFile, Sender);
end;

procedure TMainForm.actDefaultLayoutExecute(Sender: TObject);
begin
  ExecuteCommand(cmdDefaultLayout, Sender);
end;

procedure TMainForm.actApplyExtendedViewExecute(Sender: TObject);
begin
  ExecuteCommand(cmdApplyExtendedView, Sender);
end;

procedure TMainForm.actGenerateTreeExecute(Sender: TObject);
begin
  ExecuteCommand(cmdGenerateTree, Sender);
end;

procedure TMainForm.actTreeExpandAllExecute(Sender: TObject);
begin
  ExecuteCommand(cmdTreeExpandAll, Sender);
end;

procedure TMainForm.actTreeCollapseAllExecute(Sender: TObject);
begin
  ExecuteCommand(cmdTreeCollapseAll, Sender);
end;

procedure TMainForm.actTreeExpandLevelExecute(Sender: TObject);
begin
  ExecuteCommand(cmdTreeExpandLevel, Sender);
end;

procedure TMainForm.actTreeMarkLoadedExecute(Sender: TObject);
begin
  ExecuteCommand(cmdTreeMarkLoaded, Sender);
end;

procedure TMainForm.actTreeReloadExecute(Sender: TObject);
begin
  ExecuteCommand(cmdTreeReload, Sender);
end;

procedure TMainForm.actTreeChildrenLoadedExecute(Sender: TObject);
begin
  ExecuteCommand(cmdTreeChildrenLoaded, Sender);
end;

procedure TMainForm.actApplyCardTreeExecute(Sender: TObject);
begin
  ExecuteCommand(cmdApplyCardTree, Sender);
end;

procedure TMainForm.actCardTreeRootExecute(Sender: TObject);
begin
  ExecuteCommand(cmdCardTreeRoot, Sender);
end;

procedure TMainForm.actCardTreeParentExecute(Sender: TObject);
begin
  ExecuteCommand(cmdCardTreeParent, Sender);
end;

procedure TMainForm.actCardTreeExitExecute(Sender: TObject);
begin
  ExecuteCommand(cmdCardTreeExit, Sender);
end;

procedure TMainForm.actCardTreeNavigateExecute(Sender: TObject);
begin
  ExecuteCommand(cmdCardTreeNavigate, Sender);
end;

procedure TMainForm.actCardTreeTryNavigateExecute(Sender: TObject);
begin
  ExecuteCommand(cmdCardTreeTryNavigate, Sender);
end;

procedure TMainForm.actCardTreeRefreshExecute(Sender: TObject);
begin
  ExecuteCommand(cmdCardTreeRefresh, Sender);
end;

procedure TMainForm.actCardTreeExpandAllExecute(Sender: TObject);
begin
  ExecuteCommand(cmdCardTreeExpandAll, Sender);
end;

procedure TMainForm.actCardTreeCollapseAllExecute(Sender: TObject);
begin
  ExecuteCommand(cmdCardTreeCollapseAll, Sender);
end;

procedure TMainForm.actCardTreeExpandNodeExecute(Sender: TObject);
begin
  ExecuteCommand(cmdCardTreeExpandNode, Sender);
end;

procedure TMainForm.actCardTreeCollapseNodeExecute(Sender: TObject);
begin
  ExecuteCommand(cmdCardTreeCollapseNode, Sender);
end;

procedure TMainForm.actCardTreeIsExpandedExecute(Sender: TObject);
begin
  ExecuteCommand(cmdCardTreeIsExpanded, Sender);
end;

procedure TMainForm.actApplyChecksExecute(Sender: TObject);
begin
  ExecuteCommand(cmdApplyChecks, Sender);
end;

procedure TMainForm.actCheckAllExecute(Sender: TObject);
begin
  ExecuteCommand(cmdCheckAll, Sender);
end;

procedure TMainForm.actCheckVisibleExecute(Sender: TObject);
begin
  ExecuteCommand(cmdCheckVisible, Sender);
end;

procedure TMainForm.actUncheckAllExecute(Sender: TObject);
begin
  ExecuteCommand(cmdUncheckAll, Sender);
end;

procedure TMainForm.actUncheckVisibleExecute(Sender: TObject);
begin
  ExecuteCommand(cmdUncheckVisible, Sender);
end;

procedure TMainForm.actInvertAllExecute(Sender: TObject);
begin
  ExecuteCommand(cmdInvertAll, Sender);
end;

procedure TMainForm.actInvertVisibleExecute(Sender: TObject);
begin
  ExecuteCommand(cmdInvertVisible, Sender);
end;

procedure TMainForm.actToggleCheckedExecute(Sender: TObject);
begin
  ExecuteCommand(cmdToggleChecked, Sender);
end;

procedure TMainForm.actSetCheckedExecute(Sender: TObject);
begin
  ExecuteCommand(cmdSetChecked, Sender);
end;

procedure TMainForm.actCheckByIDExecute(Sender: TObject);
begin
  ExecuteCommand(cmdCheckByID, Sender);
end;

procedure TMainForm.actSetCheckStateExecute(Sender: TObject);
begin
  ExecuteCommand(cmdSetCheckState, Sender);
end;

procedure TMainForm.actGetCheckStateExecute(Sender: TObject);
begin
  ExecuteCommand(cmdGetCheckState, Sender);
end;

procedure TMainForm.actRecalculateChecksExecute(Sender: TObject);
begin
  ExecuteCommand(cmdRecalculateChecks, Sender);
end;

procedure TMainForm.actCheckedInfoExecute(Sender: TObject);
begin
  ExecuteCommand(cmdCheckedInfo, Sender);
end;

procedure TMainForm.actApplySearchExecute(Sender: TObject);
begin
  ExecuteCommand(cmdApplySearch, Sender);
end;

procedure TMainForm.actFindNextExecute(Sender: TObject);
begin
  ExecuteCommand(cmdFindNext, Sender);
end;

procedure TMainForm.actFindPreviousExecute(Sender: TObject);
begin
  ExecuteCommand(cmdFindPrevious, Sender);
end;

procedure TMainForm.actClearSearchExecute(Sender: TObject);
begin
  ExecuteCommand(cmdClearSearch, Sender);
end;

procedure TMainForm.actClearFiltersExecute(Sender: TObject);
begin
  ExecuteCommand(cmdClearFilters, Sender);
end;

procedure TMainForm.actNavigationInfoExecute(Sender: TObject);
begin
  ExecuteCommand(cmdNavigationInfo, Sender);
end;

procedure TMainForm.actColumnTextExecute(Sender: TObject);
begin
  ExecuteCommand(cmdColumnText, Sender);
end;

procedure TMainForm.actApplyColumnAdvancedExecute(Sender: TObject);
begin
  ExecuteCommand(cmdApplyColumnAdvanced, Sender);
end;

procedure TMainForm.actRuleAddExecute(Sender: TObject);
begin
  ExecuteCommand(cmdRuleAdd, Sender);
end;

procedure TMainForm.actRuleDeleteExecute(Sender: TObject);
begin
  ExecuteCommand(cmdRuleDelete, Sender);
end;

procedure TMainForm.actRulesClearExecute(Sender: TObject);
begin
  ExecuteCommand(cmdRulesClear, Sender);
end;

procedure TMainForm.actRuleApplyExecute(Sender: TObject);
begin
  ExecuteCommand(cmdRuleApply, Sender);
end;

procedure TMainForm.actRuleMatchesExecute(Sender: TObject);
begin
  ExecuteCommand(cmdRuleMatches, Sender);
end;

procedure TMainForm.actApplyDesignPreviewExecute(Sender: TObject);
begin
  ExecuteCommand(cmdApplyDesignPreview, Sender);
end;

procedure TMainForm.actBindDataSourceExecute(Sender: TObject);
begin
  ExecuteCommand(cmdBindDataSource, Sender);
end;

procedure TMainForm.actUnbindDataSourceExecute(Sender: TObject);
begin
  ExecuteCommand(cmdUnbindDataSource, Sender);
end;

procedure TMainForm.actAddItemAPIExecute(Sender: TObject);
begin
  ExecuteCommand(cmdAddItemAPI, Sender);
end;

procedure TMainForm.actTestAssignAPIsExecute(Sender: TObject);
begin
  ExecuteCommand(cmdTestAssignAPIs, Sender);
end;

procedure TMainForm.actResetPerformanceExecute(Sender: TObject);
begin
  ExecuteCommand(cmdResetPerformance, Sender);
end;

procedure TMainForm.actPerformanceSnapshotExecute(Sender: TObject);
begin
  ExecuteCommand(cmdPerformanceSnapshot, Sender);
end;

procedure TMainForm.actPerformanceReportExecute(Sender: TObject);
begin
  ExecuteCommand(cmdPerformanceReport, Sender);
end;

procedure TMainForm.actClearLogExecute(Sender: TObject);
begin
  ExecuteCommand(cmdClearLog, Sender);
end;

procedure TMainForm.actPauseLogExecute(Sender: TObject);
begin
  ExecuteCommand(cmdPauseLog, Sender);
end;

procedure TMainForm.ExecuteCommand(const ACommand: Integer; Sender: TObject);
var
  A: TUniCardAction;
  C: TUniListColumn;
  DlgOpen: TOpenDialog;
  DlgSave: TSaveDialog;
  I: Integer;
  Item: TUniListItem;
  Options: TUniSearchOptions;
  Rule: TUniColorRule;
  Snapshot: TUniPerformanceSnapshot;
  Theme: TUniThemeDefinition;
  TempActions: TUniCardActions;
  TempColumns: TUniListColumns;
  TempTemplate: TUniCardTemplate;
  Keys: TArray<string>;
  S: string;
begin
  try
    case ACommand of
      cmdToggleControlPanel:
        begin
          if ControlPanel.Parent = nil then
          begin
            ControlPanel.Parent := MainLayout;
            ControlPanel.Align := TAlignLayout.Left;
            ControlPanel.Position.X := 0;
            ControlPanel.Visible := True;
            MainSplitter.Parent := MainLayout;
            MainSplitter.Align := TAlignLayout.Left;
            MainSplitter.Position.X := ControlPanel.Width;
            MainSplitter.Visible := True;
            TAction(Sender).Text := 'Hide controls';
          end
          else
          begin
            MainSplitter.Parent := nil;
            ControlPanel.Parent := nil;
            TAction(Sender).Text := 'Show controls';
          end;
          LogEvent('Control panel attached: ' +
            BoolToStr(ControlPanel.Parent <> nil, True));
        end;
      cmdCards: UniListView1.ViewMode := uvmCards;
      cmdList: UniListView1.ViewMode := uvmList;
      cmdGenerate100: GenerateItems(100);
      cmdGenerate1000: GenerateItems(1000);
      cmdGenerate10000: GenerateItems(10000);
      cmdGenerate50000: GenerateItems(50000);
      cmdGenerateCustom: GenerateItems(IntValue('edGenerateCount', 100));
      cmdClear:
        begin
          UniListView1.Clear;
          UniListView1.SelectedIndex := -1;
        end;
      cmdReset: ResetPlayground;
      cmdAutoFit: UniListView1.AutoFitAllColumns;
      cmdApplyScroll:
        begin
          UniListView1.ScrollX := FloatValue('edScrollX', 0);
          UniListView1.ScrollY := FloatValue('edScrollY', 0);
        end;
      cmdScrollSelected: UniListView1.ScrollToItem(UniListView1.SelectedIndex);
      cmdScrollIndex: UniListView1.ScrollToItem(IntValue('edScrollIndex', 0));
      cmdScrollHome:
        begin
          UniListView1.ScrollX := 0;
          UniListView1.ScrollY := 0;
        end;
      cmdScrollEnd: UniListView1.ScrollY := UniListView1.ContentHeight;
      cmdCardsCompact:
        begin
          UniListView1.CardWidth := 220;
          UniListView1.CardHeight := 84;
          UniListView1.CardMinWidth := 180;
        end;
      cmdCardsNormal: RestoreDefaultGeometry;
      cmdCardsLarge:
        begin
          UniListView1.CardWidth := 420;
          UniListView1.CardHeight := 180;
          UniListView1.CardMinWidth := 360;
        end;
      cmdCardsAutoTitle:
        begin
          UniListView1.ViewMode := uvmCards;
          UniListView1.CardSizingMode := ucsmAutoByTitle;
        end;
      cmdCardsHorizontal:
        begin
          UniListView1.ViewMode := uvmCards;
          UniListView1.ContentFlow := ucfNoWrap;
          UniListView1.ScrollMode := usmHorizontal;
        end;
      cmdCardsWrapped:
        begin
          UniListView1.ViewMode := uvmCards;
          UniListView1.ContentFlow := ucfWrap;
          UniListView1.ScrollMode := usmVertical;
        end;
      cmdApplyTemplateFields:
        begin
          UniListView1.CardTemplate.TitleField := Edit('edTitleField').Text;
          UniListView1.CardTemplate.TextField := Edit('edTextField').Text;
          UniListView1.CardTemplate.DetailField := Edit('edDetailField').Text;
          UniListView1.CardTemplate.IconField := Edit('edIconField').Text;
          UniListView1.CardTemplate.StatusField := Edit('edStatusField').Text;
        end;
      cmdClearTextSelection: UniListView1.ClearTextSelection;
      cmdShowSelectedText:
        begin
          S := UniListView1.SelectedText;
          LogEvent('SelectedText: ' + S);
          ShowMessage(S);
        end;
      cmdColumnChooser: UniListView1.ShowColumnChooser;
      cmdResetHScroll: UniListView1.ScrollX := 0;
      cmdColumnAdd:
        begin
          C := UniListView1.Columns.Add;
          C.LayoutID := 'column_' + IntToStr(UniListView1.Columns.Count);
          C.FieldName := 'field_' + IntToStr(UniListView1.Columns.Count);
          C.Caption := C.FieldName;
          RefreshColumnEditor;
        end;
      cmdColumnDelete:
        begin
          C := SelectedColumn;
          if C <> nil then
            C.Free;
          RefreshColumnEditor;
        end;
      cmdColumnsClear:
        begin
          UniListView1.Columns.Clear;
          RefreshColumnEditor;
        end;
      cmdColumnsRestore: RestoreDefaultColumns;
      cmdColumnApply: ApplySelectedColumn;
      cmdColumnVisible:
        begin
          C := SelectedColumn;
          if C <> nil then
            UniListView1.SetColumnVisible(C.LayoutID,
              Switch('swColumnVisible').IsChecked);
        end;
      cmdActionAdd:
        begin
          A := UniListView1.Actions.Add;
          A.Name := 'action_' + IntToStr(UniListView1.Actions.Count);
          A.Caption := A.Name;
          RefreshActionEditor;
        end;
      cmdActionDelete:
        begin
          A := SelectedAction;
          if A <> nil then
            A.Free;
          RefreshActionEditor;
        end;
      cmdActionsClear:
        begin
          UniListView1.Actions.Clear;
          RefreshActionEditor;
        end;
      cmdActionsRestore: RestoreDefaultActions;
      cmdActionApply: ApplySelectedAction;
      cmdItemAdd:
        begin
          Item := UniListView1.Items.Add;
          Item.ID := IntToStr(UniListView1.Items.Count);
          Item.Title := 'New item';
          Item.SetField('name', Item.Title);
          UniListView1.SelectedIndex := UniListView1.Items.Count - 1;
          RefreshItemEditor;
        end;
      cmdItemDelete:
        if SelectedItem <> nil then
        begin
          UniListView1.Items.Delete(UniListView1.SelectedIndex);
          UniListView1.SelectedIndex := -1;
        end;
      cmdItemApply: ApplySelectedItem;
      cmdItemEnable:
        if SelectedItem <> nil then SelectedItem.Enabled := True;
      cmdItemDisable:
        if SelectedItem <> nil then SelectedItem.Enabled := False;
      cmdItemRandomize:
        if SelectedItem <> nil then
        begin
          SelectedItem.SetField('latency_ms', Random(1000));
          SelectedItem.SetField('large_number', Int64(High(Integer)) + 10);
          SelectedItem.SetField('load_percent', Random * 100);
          SelectedItem.SetFieldDateTime('updated_at', Now);
          SelectedItem.SetFieldColor('diagnostic_color', $FF12AB34);
          SelectedItem.SetFieldObject('diagnostic_object', Self);
          SelectedItem.SetValue('legacy_value', 'compatibility');
          SelectedItem.Fields['direct_field'] := TValue.From<string>('direct');
          SelectedItem.SetField('temporary_field', 'remove me');
          SelectedItem.ClearField('temporary_field');
        end;
      cmdItemInspect:
        if SelectedItem <> nil then
          LogEvent(Format('Typed item: id=%s, latency=%d, int64=%d, ' +
            'load=%.2f, updated=%s, enabled=%s, color=%x, object=%s, ' +
            'legacy=%s, status=%s, check=%d/%s, contains(status)=%s, fields=%d',
            [SelectedItem.ID, SelectedItem.FieldAsInteger('latency_ms'),
             SelectedItem.FieldAsInt64('large_number'),
             SelectedItem.FieldAsFloat('load_percent'),
             DateTimeToStr(SelectedItem.FieldAsDateTime('updated_at')),
             BoolToStr(SelectedItem.FieldAsBoolean('enabled'), True),
             SelectedItem.FieldAsColor('diagnostic_color'),
             BoolToStr(SelectedItem.FieldAsObject('diagnostic_object') = Self,
               True),
             VarToStr(SelectedItem.GetValue('legacy_value', 'missing')),
             SelectedItem.FieldAsString('status'), Ord(SelectedItem.CheckState),
             BoolToStr(SelectedItem.Checked, True),
             BoolToStr(SelectedItem.ContainsField('status'), True),
             SelectedItem.Data.Count]));
      cmdSortItems:
        UniListView1.Items.SortByField(Edit('edSortField').Text,
          Switch('swSortAscending').IsChecked);
      cmdSortByFields:
        UniListView1.Items.SortByFields(['status', 'name'], [True, True]);
      cmdSelect:
        UniListView1.SelectedIndex := IntValue('edSelectedIndex', -1);
      cmdSelectClear: UniListView1.SelectedIndex := -1;
      cmdSelectPrevious:
        UniListView1.SelectedIndex := Max(-1, UniListView1.SelectedIndex - 1);
      cmdSelectNext:
        UniListView1.SelectedIndex := Min(UniListView1.Items.Count - 1,
          UniListView1.SelectedIndex + 1);
      cmdColorsApply:
        begin
          UniListView1.BackgroundColor := ColorValue('edBackgroundColor',
            UniListView1.BackgroundColor);
          UniListView1.CardColor := ColorValue('edCardColor',
            UniListView1.CardColor);
          UniListView1.CardHotColor := ColorValue('edCardHotColor',
            UniListView1.CardHotColor);
          UniListView1.CardSelectedColor := ColorValue('edCardSelectedColor',
            UniListView1.CardSelectedColor);
          UniListView1.TextColor := ColorValue('edTextColor',
            UniListView1.TextColor);
          UniListView1.SecondaryTextColor := ColorValue('edSecondaryColor',
            UniListView1.SecondaryTextColor);
          UniListView1.AccentColor := ColorValue('edAccentColor',
            UniListView1.AccentColor);
          UniListView1.HeaderColor := ColorValue('edHeaderColor',
            UniListView1.HeaderColor);
          UniListView1.AlternateRowColor := ColorValue('edAlternateRowColor',
            UniListView1.AlternateRowColor);
          UniListView1.FooterColor := ColorValue('edFooterColor',
            UniListView1.FooterColor);
          UniListView1.GridColor := ColorValue('edGridColor',
            UniListView1.GridColor);
        end;
      cmdColorsLight: RestoreDefaultColors;
      cmdColorsDark:
        begin
          UniListView1.BackgroundColor := $FF111827;
          UniListView1.CardColor := $FF1F2937;
          UniListView1.CardHotColor := $FF374151;
          UniListView1.CardSelectedColor := $FF164E63;
          UniListView1.TextColor := $FFF9FAFB;
          UniListView1.SecondaryTextColor := $FF9CA3AF;
          UniListView1.AccentColor := $FF22D3EE;
        end;
      cmdColorsContrast:
        begin
          UniListView1.BackgroundColor := $FF000000;
          UniListView1.CardColor := $FF000000;
          UniListView1.CardHotColor := $FF222222;
          UniListView1.CardSelectedColor := $FF003366;
          UniListView1.TextColor := $FFFFFFFF;
          UniListView1.SecondaryTextColor := $FFFFFF00;
          UniListView1.AccentColor := $FF00FFFF;
        end;
      cmdColorsReset: RestoreDefaultColors;
      cmdGetLayoutJSON:
        Memo('memoLayout').Text := UniListView1.SaveLayoutToJSON;
      cmdApplyLayoutJSON:
        UniListView1.LoadLayoutFromJSON(Memo('memoLayout').Text);
      cmdDefaultLayout: RestoreDefaultColumns;
      cmdSaveLayoutFile:
        begin
          DlgSave := TSaveDialog.Create(nil);
          try
            DlgSave.Filter := 'JSON files|*.json';
            if DlgSave.Execute then
              UniListView1.SaveLayoutToFile(DlgSave.FileName);
          finally
            DlgSave.Free;
          end;
        end;
      cmdLoadLayoutFile:
        begin
          DlgOpen := TOpenDialog.Create(nil);
          try
            DlgOpen.Filter := 'JSON files|*.json';
            if DlgOpen.Execute then
              UniListView1.LoadLayoutFromFile(DlgOpen.FileName);
          finally
            DlgOpen.Free;
          end;
        end;
      cmdApplyExtendedView:
        begin
          UniListView1.CardLayout := TUniCardLayout(
            Combo('cbCardLayout').ItemIndex);
          UniListView1.ActionVisibility := TUniActionVisibility(
            Combo('cbActionVisibility').ItemIndex);
          UniListView1.ListAutoRowHeight :=
            Switch('swListAutoRowHeight').IsChecked;
          UniListView1.ListFilterVisible :=
            Switch('swListFilterVisible').IsChecked;
          UniListView1.ListFilterHeight := FloatValue('edListFilterHeight', 30);
        end;
      cmdGenerateTree: GenerateTreeItems;
      cmdTreeExpandAll: UniListView1.ExpandAll;
      cmdTreeCollapseAll: UniListView1.CollapseAll;
      cmdTreeExpandLevel:
        UniListView1.ExpandToLevel(IntValue('edTreeLevel', 2));
      cmdTreeMarkLoaded:
        UniListView1.MarkChildrenLoaded(Edit('edTreeNodeID').Text);
      cmdTreeReload:
        UniListView1.ReloadChildren(Edit('edTreeNodeID').Text);
      cmdTreeChildrenLoaded:
        LogEvent('ChildrenLoaded: ' + BoolToStr(
          UniListView1.ChildrenLoaded(Edit('edTreeNodeID').Text), True));
      cmdApplyCardTree:
        begin
          UniListView1.CardTreeEnabled := Switch('swCardTreeEnabled').IsChecked;
          UniListView1.CardTreeMode := TUniCardTreeMode(
            Combo('cbCardTreeMode').ItemIndex);
          UniListView1.CardTreeShowBreadcrumbs :=
            Switch('swBreadcrumbs').IsChecked;
          UniListView1.CardTreeShowRootBreadcrumb :=
            Switch('swRootBreadcrumb').IsChecked;
          UniListView1.CardTreeRootCaption := Edit('edRootCaption').Text;
          UniListView1.CardTreeShowBackButton := Switch('swBackButton').IsChecked;
          UniListView1.CardTreeExplorerShowChildCount :=
            Switch('swChildCount').IsChecked;
          UniListView1.CardTreeExplorerNavigateOnCardClick :=
            Switch('swNavigateOnClick').IsChecked;
          UniListView1.CardTreeExplorerParentEmphasis :=
            FloatValue('edParentEmphasis', 1.15);
          UniListView1.CardTreeExplorerKeepFlatOrder :=
            Switch('swKeepFlatOrder').IsChecked;
          UniListView1.CardTreeParentBackgroundColor :=
            ColorValue('edParentColor', $FF16343A);
          UniListView1.CardTreeNavigationIconColor :=
            ColorValue('edNavIconColor', $FF21B568);
          UniListView1.CardTreeNavigationIconSize :=
            FloatValue('edNavIconSize', 16);
          UniListView1.CardTreeHierarchyIndent :=
            FloatValue('edHierarchyIndent', 24);
          UniListView1.CardTreeHierarchySpacing :=
            FloatValue('edHierarchySpacing', 8);
          UniListView1.CardTreeBreadcrumbHeight :=
            FloatValue('edBreadcrumbHeight', 34);
          UniListView1.CardTreeBreadcrumbSpacing :=
            FloatValue('edBreadcrumbSpacing', 8);
          UniListView1.CardTreeBreadcrumbTextColor :=
            ColorValue('edBreadcrumbColor', $FF21B568);
          UniListView1.CardTreeBreadcrumbHotColor :=
            ColorValue('edBreadcrumbHotColor', $FFFFFFFF);
          UniListView1.CardTreeBreadcrumbSeparator :=
            Edit('edBreadcrumbSeparator').Text;
        end;
      cmdCardTreeRoot: UniListView1.CardTreeNavigateToRoot;
      cmdCardTreeParent: UniListView1.CardTreeNavigateToParent;
      cmdCardTreeExit: UniListView1.CardTreeExitNavigation;
      cmdCardTreeNavigate:
        UniListView1.CardTreeNavigateToNode(Edit('edTreeNodeID').Text);
      cmdCardTreeTryNavigate:
        LogEvent('CardTreeTryNavigateToNode: ' + BoolToStr(
          UniListView1.CardTreeTryNavigateToNode(Edit('edTreeNodeID').Text),
          True));
      cmdCardTreeRefresh: UniListView1.CardTreeRefresh;
      cmdCardTreeExpandAll: UniListView1.CardTreeExpandAll;
      cmdCardTreeCollapseAll: UniListView1.CardTreeCollapseAll;
      cmdCardTreeExpandNode:
        UniListView1.CardTreeExpandNode(Edit('edTreeNodeID').Text);
      cmdCardTreeCollapseNode:
        UniListView1.CardTreeCollapseNode(Edit('edTreeNodeID').Text);
      cmdCardTreeIsExpanded:
        LogEvent('CardTreeIsNodeExpanded: ' + BoolToStr(
          UniListView1.CardTreeIsNodeExpanded(Edit('edTreeNodeID').Text), True));
      cmdApplyChecks:
        begin
          UniListView1.TreeMode := Switch('swTreeMode').IsChecked;
          UniListView1.TreeKeyField := Edit('edTreeKeyField').Text;
          UniListView1.TreeParentField := Edit('edTreeParentField').Text;
          UniListView1.TreeColumn := Edit('edTreeColumn').Text;
          UniListView1.TreeIndent := FloatValue('edTreeIndent', 20);
          UniListView1.TreeLazyLoad := Switch('swTreeLazyLoad').IsChecked;
          UniListView1.TreeHasChildrenField := Edit('edTreeHasChildren').Text;
          UniListView1.MultiCheck := Switch('swMultiCheck').IsChecked;
          UniListView1.ShowCheckBoxes := Switch('swShowCheckBoxes').IsChecked;
          UniListView1.TreeCheckBoxes := Switch('swMultiCheck').IsChecked;
          UniListView1.TreeCheckMode := TUniTreeCheckMode(
            Combo('cbTreeCheckMode').ItemIndex);
        end;
      cmdCheckAll: UniListView1.CheckAll;
      cmdCheckVisible: UniListView1.CheckAll(ucsVisibleItems);
      cmdUncheckAll: UniListView1.UncheckAll;
      cmdUncheckVisible: UniListView1.UncheckAll(ucsVisibleItems);
      cmdInvertAll: UniListView1.InvertChecks;
      cmdInvertVisible: UniListView1.InvertChecks(ucsVisibleItems);
      cmdToggleChecked:
        UniListView1.ToggleItemChecked(IntValue('edCheckIndex', 0));
      cmdSetChecked:
        UniListView1.SetItemChecked(IntValue('edCheckIndex', 0),
          Switch('swCheckValue').IsChecked);
      cmdCheckByID:
        UniListView1.CheckItem(Edit('edCheckID').Text,
          Switch('swCheckValue').IsChecked);
      cmdSetCheckState:
        UniListView1.SetItemCheckState(Edit('edCheckID').Text,
          TUniCheckState(Combo('cbCheckState').ItemIndex));
      cmdGetCheckState:
        LogEvent('GetItemCheckState: ' + IntToStr(Ord(
          UniListView1.GetItemCheckState(Edit('edCheckID').Text))));
      cmdRecalculateChecks: UniListView1.RecalculateTreeCheckStates;
      cmdCheckedInfo:
        begin
          Keys := UniListView1.CheckedKeys;
          S := 'all=';
          for I := 0 to High(Keys) do
          begin
            if I > 0 then S := S + ', ';
            S := S + Keys[I];
          end;
          Keys := UniListView1.CheckedTreeKeys;
          S := S + ' | tree=';
          for I := 0 to High(Keys) do
          begin
            if I > 0 then S := S + ', ';
            S := S + Keys[I];
          end;
          S := S + ' | enumerator=';
          for Item in UniListView1.CheckedItems do
            S := S + Item.ID + ';';
          Item := UniListView1.FirstCheckedItem;
          if Item <> nil then S := S + ' | first=' + Item.ID;
          Item := UniListView1.LastCheckedItem;
          if Item <> nil then S := S + ' | last=' + Item.ID;
          LogEvent(Format('Checked: count=%d, keys=%s, selected-is-checked=%s',
            [UniListView1.CheckedCount, S, BoolToStr(
             UniListView1.IsItemChecked(IntValue('edCheckIndex', 0)), True)]));
        end;
      cmdApplySearch:
        begin
          Options := [];
          if Switch('swSearchIgnoreCase').IsChecked then
            Include(Options, soIgnoreCase);
          if Switch('swSearchVisibleOnly').IsChecked then
            Include(Options, soVisibleColumnsOnly);
          if Switch('swSearchWrap').IsChecked then
            Include(Options, soWrapAround);
          if Switch('swSearchFilters').IsChecked then
            Include(Options, soRespectFilters);
          UniListView1.SearchOptions := Options;
          UniListView1.SearchText := Edit('edSearchText').Text;
        end;
      cmdFindNext: UniListView1.FindNext;
      cmdFindPrevious: UniListView1.FindPrevious;
      cmdClearSearch: UniListView1.ClearSearch;
      cmdClearFilters: UniListView1.ClearFilters;
      cmdNavigationInfo:
        LogEvent(Format('Navigation: count=%d, display->item=%d, ' +
          'item->display=%d, page=%d, search=%d, running=%s',
          [UniListView1.NavigationItemCount,
           UniListView1.NavigationItemIndex(IntValue('edNavDisplayIndex', 0)),
           UniListView1.NavigationIndexOfItem(UniListView1.SelectedIndex),
           UniListView1.NavigationPageSize, UniListView1.SearchMatchCount,
           BoolToStr(UniListView1.SearchRunning, True)]));
      cmdColumnText:
        LogEvent('ItemColumnDisplayText: ' +
          UniListView1.ItemColumnDisplayText(UniListView1.SelectedIndex,
            Edit('edColumnTextName').Text));
      cmdApplyColumnAdvanced:
        begin
          C := SelectedColumn;
          if C <> nil then
          begin
            C.VisibleInCards := Switch('swVisibleInCards').IsChecked;
            C.CardRole := TUniCardRole(Combo('cbCardRole').ItemIndex);
            C.Frozen := Switch('swColumnFrozen').IsChecked;
            C.FooterAggregate := TUniFooterAggregate(
              Combo('cbFooterAggregate').ItemIndex);
            C.FooterText := Edit('edFooterText').Text;
            C.FooterFormat := Edit('edFooterFormat').Text;
            C.FilterOperator := TUniFilterOperator(
              Combo('cbFilterOperator').ItemIndex);
            C.FilterValue := Edit('edFilterValue').Text;
            C.WrapText := Switch('swColumnWrapText').IsChecked;
            C.MaxLines := IntValue('edColumnMaxLines', 0);
          end;
        end;
      cmdRuleAdd:
        begin
          Rule := UniListView1.ColorRules.Add;
          Edit('edRuleIndex').Text := IntToStr(Rule.Index);
        end;
      cmdRuleDelete:
        begin
          I := IntValue('edRuleIndex', -1);
          if InRange(I, 0, UniListView1.ColorRules.Count - 1) then
            UniListView1.ColorRules[I].Free;
        end;
      cmdRulesClear: UniListView1.ColorRules.Clear;
      cmdRuleApply:
        begin
          I := IntValue('edRuleIndex', -1);
          if InRange(I, 0, UniListView1.ColorRules.Count - 1) then
          begin
            Rule := UniListView1.ColorRules[I];
            Rule.Enabled := Switch('swRuleEnabled').IsChecked;
            Rule.FieldName := Edit('edRuleField').Text;
            Rule.Operator := TUniColorRuleOperator(
              Combo('cbRuleOperator').ItemIndex);
            Rule.Value := Edit('edRuleValue').Text;
            Rule.Scope := TUniColorRuleScope(Combo('cbRuleScope').ItemIndex);
            Rule.TargetColumn := Edit('edRuleTarget').Text;
            Rule.UseBackgroundColor := Switch('swRuleUseBackground').IsChecked;
            Rule.BackgroundColor := ColorValue('edRuleBackground', $FFFFE8E8);
            Rule.UseTextColor := Switch('swRuleUseText').IsChecked;
            Rule.TextColor := ColorValue('edRuleTextColor', $FFB91C1C);
            Rule.UseThemeColors := Switch('swRuleUseTheme').IsChecked;
            Rule.ThemeTone := TUniColorRuleThemeTone(
              Combo('cbRuleTone').ItemIndex);
          end;
        end;
      cmdRuleMatches:
        begin
          I := IntValue('edRuleIndex', -1);
          Rule := nil;
          if InRange(I, 0, UniListView1.ColorRules.Count - 1) then
            Rule := UniListView1.ColorRules[I];
          LogEvent('Rule.Matches(selected): ' + BoolToStr(
            (Rule <> nil) and Rule.Matches(SelectedItem), True));
        end;
      cmdApplyTheme:
        if Combo('cbTheme').ItemIndex >= 0 then
          UniListView1.ThemeName := Combo('cbTheme').Selected.Text;
      cmdLoadTheme:
        begin
          DlgOpen := TOpenDialog.Create(nil);
          try
            DlgOpen.Filter := 'YAML themes|*.yaml;*.yml';
            if DlgOpen.Execute then
            begin
              UniListView1.LoadThemeFromFile(DlgOpen.FileName);
              PopulateThemes;
            end;
          finally
            DlgOpen.Free;
          end;
        end;
      cmdThemeInfo:
        begin
          Theme := TUniThemeManager.Find(UniListView1.ThemeName);
          if Theme <> nil then
            LogEvent(Format('Theme: %s, author=%s, variant=%d, bg=%x, fg=%x, cursor=%x, selection=%x, terminal=%x, count=%d',
              [Theme.Name, Theme.Author, Ord(Theme.Variant), Theme.Background,
               Theme.Foreground, Theme.Cursor, Theme.Selection, Theme.TerminalUI,
               TUniThemeManager.Count]));
        end;
      cmdApplyFonts:
        begin
          UniListView1.FontFamily := Edit('edFontFamily').Text;
          UniListView1.FontSize := FloatValue('edFontSize', 13);
          UniListView1.TitleFontSize := FloatValue('edTitleFontSize', 15);
          UniListView1.DetailFontSize := FloatValue('edDetailFontSize', 12);
        end;
      cmdApplyDesignPreview:
        begin
          UniListView1.DesignPreviewMode := TUniDesignPreviewMode(
            Combo('cbDesignPreview').ItemIndex);
          UniListView1.DesignPreviewRows := IntValue('edDesignRows', 8);
        end;
      cmdBindDataSource: BindSampleDataSource;
      cmdUnbindDataSource: UnbindDataSource;
      cmdResetPerformance: UniListView1.ResetPerformanceCounters;
      cmdPerformanceSnapshot:
        begin
          Snapshot := UniListView1.GetPerformanceSnapshot;
          LogEvent(Format('Performance snapshot: enabled=%s, platform=%s, ' +
            'mode=%s, total=%d, visible=%d, paint=%d, cards=%d, rows=%d',
            [BoolToStr(Snapshot.Enabled, True), Snapshot.Platform,
             Snapshot.ViewMode, Snapshot.TotalItems, Snapshot.VisibleItems,
             Snapshot.Paint.Count, Snapshot.CardsDrawn, Snapshot.RowsDrawn]));
        end;
      cmdPerformanceReport:
        begin
          Memo('memoLayout').Text := UniListView1.PerformanceReport;
          LogEvent('PerformanceReport copied to the JSON/report memo');
        end;
      cmdAddItemAPI:
        begin
          Item := UniListView1.AddItem(Edit('edAddTitle').Text,
            Edit('edAddText').Text, Edit('edAddDetail').Text);
          UniListView1.SelectedIndex := UniListView1.Items.IndexOf(Item);
        end;
      cmdTestAssignAPIs:
        begin
          TempColumns := TUniListColumns.Create(nil);
          TempActions := TUniCardActions.Create(nil);
          TempTemplate := TUniCardTemplate.Create(nil);
          try
            if SelectedColumn <> nil then
              TempColumns.Add.Assign(SelectedColumn);
            if SelectedAction <> nil then
              TempActions.Add.Assign(SelectedAction);
            TempTemplate.Assign(UniListView1.CardTemplate);
            I := 0;
            for Item in UniListView1.Items do
              Inc(I);
            LogEvent(Format('Assign/enumerator APIs: columns=%d, actions=%d, title=%s, items=%d',
              [TempColumns.Count, TempActions.Count,
               TempTemplate.TitleField, I]));
          finally
            TempTemplate.Free;
            TempActions.Free;
            TempColumns.Free;
          end;
        end;      cmdClearLog: EventMemo.Lines.Clear;
      cmdPauseLog:
        begin
          FLogPaused := not FLogPaused;
          LogEvent('Logging resumed');
        end;
    end;

    UniListView1.CardMinWidth := FloatValue('edCardMinWidth',
      UniListView1.CardMinWidth);
    UniListView1.CardMaxWidth := FloatValue('edCardMaxWidth',
      UniListView1.CardMaxWidth);
    UniListView1.CardWidth := FloatValue('edCardWidth',
      UniListView1.CardWidth);
    UniListView1.CardHeight := FloatValue('edCardHeight',
      UniListView1.CardHeight);
    UniListView1.HorizontalGap := FloatValue('edHorizontalGap',
      UniListView1.HorizontalGap);
    UniListView1.VerticalGap := FloatValue('edVerticalGap',
      UniListView1.VerticalGap);
    UniListView1.ContentPadding := FloatValue('edContentPadding',
      UniListView1.ContentPadding);
    UniListView1.CornerRadius := FloatValue('edCornerRadius',
      UniListView1.CornerRadius);
    UniListView1.FixedColumnCount := IntValue('edFixedColumns',
      UniListView1.FixedColumnCount);
    UniListView1.PanThreshold := FloatValue('edPanThreshold',
      UniListView1.PanThreshold);
    UniListView1.CardTemplate.TitleMaxLines := IntValue('edTitleMaxLines', 2);
    UniListView1.CardTemplate.TextMaxLines := IntValue('edTextMaxLines', 3);
    UniListView1.CardTemplate.DetailMaxLines := IntValue('edDetailMaxLines', 2);
    UniListView1.CardTemplate.MaxCardHeight := FloatValue('edMaxCardHeight', 260);
    UniListView1.CardTemplate.IconSize := FloatValue('edIconSize', 20);
    UniListView1.CardTemplate.IconBoxSize := FloatValue('edIconBoxSize', 40);
    UniListView1.CardTemplate.InnerPadding := FloatValue('edInnerPadding', 12);
    UniListView1.CardTemplate.TextGap := FloatValue('edTextGap', 3);
    UniListView1.CardTemplate.Icon := TUniVectorIcon(
      Combo('cbDefaultIcon').ItemIndex);
    UniListView1.ListHeaderHeight := FloatValue('edHeaderHeight', 34);
    UniListView1.ListRowHeight := FloatValue('edRowHeight', 32);
    UniListView1.ListFooterHeight := FloatValue('edFooterHeight', 32);
    UniListView1.ListFrozenColumnCount := IntValue('edFrozenColumns', 0);
    RepaintAndStatus;
  except
    on E: Exception do
      ReportError('Command', E);
  end;
end;

procedure TMainForm.UniListView1ItemClick(Sender: TObject;
  const AItemIndex: Integer);
begin
  LogEvent(Format('OnItemClick: index=%d', [AItemIndex]));
  RefreshItemEditor;
  UpdateStatus;
end;

procedure TMainForm.UniListView1ItemAction(Sender: TObject;
  const AItemIndex: Integer; const AActionName: string);
begin
  LogEvent(Format('OnItemAction: index=%d, action=%s',
    [AItemIndex, AActionName]));
end;

procedure TMainForm.UpdateStatus;
var
  ModeText: string;
begin
  if UniListView1.ViewMode = uvmCards then
    ModeText := 'Cards'
  else
    ModeText := 'List';
  StatusLabel.Text := Format(
    'Items: %d | Columns: %d | Mode: %s | Selected: %d | Checked: %d | ' +
    'Search: %d/%s | CardWidth: %.0f | Content: %.0fx%.0f | ' +
    'Scroll: %.0fx%.0f | Theme: %s/%d | Tree: %s back=%s depth=%d node=%s | ' +
    'Last: %d ms',
    [UniListView1.Items.Count, UniListView1.ColumnCount, ModeText,
     UniListView1.SelectedIndex, UniListView1.CheckedCount,
     UniListView1.SearchMatchCount, BoolToStr(UniListView1.SearchRunning, True),
     UniListView1.ActualCardWidth, UniListView1.ContentWidth,
     UniListView1.ContentHeight, UniListView1.ScrollX, UniListView1.ScrollY,
     UniListView1.ThemeName, Ord(UniListView1.ThemeVariant),
     BoolToStr(UniListView1.CardTreeNavigationActive, True),
     BoolToStr(UniListView1.CardTreeCanNavigateBack, True),
     UniListView1.CardTreeCurrentDepth, UniListView1.CardTreeCurrentNodeId,
     FLastOperationMS]);
end;

procedure TMainForm.LogEvent(const AText: string);
begin
  if FLogPaused then
    Exit;
  EventMemo.Lines.Add(FormatDateTime('[hh:nn:ss.zzz] ', Now) + AText);
  EventMemo.GoToTextEnd;
end;

procedure TMainForm.ReportError(const AContext: string; E: Exception);
var
  S: string;
begin
  S := AContext + ': ' + E.ClassName + ': ' + E.Message;
  LogEvent(S);
  ShowMessage(S);
end;

end.


























