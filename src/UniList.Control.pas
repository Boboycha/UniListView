unit UniList.Control;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.UITypes, System.Math,
  System.Math.Vectors,
  System.Rtti, System.Generics.Collections, System.JSON, System.IOUtils,
  System.StrUtils, System.Actions, System.Messaging,
  Data.DB,
  FMX.Types, FMX.Controls, FMX.Objects, FMX.Platform, FMX.Graphics,
  FMX.Styles.Objects, FMX.StdCtrls, FMX.Ani,
  UniList.Canvas,
  UniList.Types, UniList.Items, UniList.Vector, UniList.Performance, UniList.Text,
  UniList.Columns, UniList.Theme, UniList.Rules, UniList.Search;

type
  TUniCheckScope = (ucsAllItems, ucsVisibleItems);
  TUniTreeLoadChildrenEvent = procedure(Sender: TObject;
    const ParentKey: string; var Handled: Boolean) of object;
  TUniItemCheckChangedEvent = procedure(Sender: TObject;
    AItem: TUniListItem; AChecked: Boolean) of object;
  TUniItemCheckChangingEvent = procedure(Sender: TObject;
    const AItemId: string; const AOldState, ANewState: TUniCheckState;
    var AAllow: Boolean) of object;
  TUniCardTreeNavigatingEvent = procedure(Sender: TObject;
    const ANodeId: string; var AAllow: Boolean) of object;
  TUniCardTreeNodeEvent = procedure(Sender: TObject;
    const ANodeId: string) of object;

  TUniCardTreeLayoutItem = record
    ItemIndex: Integer;
    Depth: Integer;
    Bounds: TRectF;
    IconRect: TRectF;
    HasChildren: Boolean;
    IsExpanded: Boolean;
    IsFullWidthParent: Boolean;
  end;

  TUniCardTreeBreadcrumb = record
    NodeId: string;
    Caption: string;
    Bounds: TRectF;
  end;

  TUniListView = class;

  TUniDesignPreviewDataLink = class(TDataLink)
  private
    FListView: TUniListView;
  protected
    procedure ActiveChanged; override;
    procedure DataSetChanged; override;
    procedure LayoutChanged; override;
  public
    constructor Create(const AListView: TUniListView);
  end;

  TUniListView = class(TPaintBox)
  private
    FItems: TUniListItems;
    FViewMode: TUniViewMode;
    FCardLayout: TUniCardLayout;
    FColumns: TUniListColumns;
    FColumnWidths: TArray<Single>;
    FColumnLefts: TArray<Single>;
    FListHeaderHeight: Single;
    FListRowHeight: Single;
    FListAutoRowHeight: Boolean;
    FListRowTops: TArray<Single>;
    FListRowHeights: TArray<Single>;
    FListGridLines: Boolean;
    FListHorizontalGridLines: Boolean;
    FListFilterVisible: Boolean;
    FListFilterHeight: Single;
    FFilteredIndices: TArray<Integer>;
    FTreeMode: Boolean;
    FTreeKeyField: string;
    FTreeParentField: string;
    FTreeColumn: string;
    FTreeIndent: Single;
    FTreeVisibleIndices: TArray<Integer>;
    FTreeLevels: TArray<Integer>;
    FTreeChildFlags: TArray<Boolean>;
    FTreeFirstChild: TArray<Integer>;
    FTreeNextSibling: TArray<Integer>;
    FTreeParentIndices: TArray<Integer>;
    FTreeKeyToIndex: TDictionary<string, Integer>;
    FTreeExpandedKeys: TStringList;
    FCardTreeEnabled: Boolean;
    FCardTreeMode: TUniCardTreeMode;
    FCardTreeShowBreadcrumbs: Boolean;
    FCardTreeShowRootBreadcrumb: Boolean;
    FCardTreeRootCaption: string;
    FCardTreeShowBackButton: Boolean;
    FCardTreeExplorerShowChildCount: Boolean;
    FCardTreeExplorerNavigateOnCardClick: Boolean;
    FCardTreeExplorerParentEmphasis: Single;
    FCardTreeExplorerKeepFlatOrder: Boolean;
    FCardTreeNavigationActive: Boolean;
    FCardTreeExplorerScrollX: Single;
    FCardTreeExplorerScrollY: Single;
    FCardTreeExplorerSelectedIndex: Integer;
    FCardTreeParentBackgroundColor: TAlphaColor;
    FCardTreeNavigationIconColor: TAlphaColor;
    FCardTreeNavigationIconSize: Single;
    FCardTreeHierarchyIndent: Single;
    FCardTreeHierarchySpacing: Single;
    FCardTreeBreadcrumbHeight: Single;
    FCardTreeBreadcrumbSpacing: Single;
    FCardTreeBreadcrumbTextColor: TAlphaColor;
    FCardTreeBreadcrumbHotColor: TAlphaColor;
    FCardTreeBreadcrumbSeparator: string;
    FCardTreeCurrentNodeIndex: Integer;
    FCardTreeVisibleIndices: TArray<Integer>;
    FCardTreeFilteredFlags: TArray<Boolean>;
    FCardTreeHasVisibleChildren: TArray<Boolean>;
    FCardTreeChildCounts: TArray<Integer>;
    FCardTreeVisibleChildCounts: TArray<Integer>;
    FCardTreeVisibleDepths: TArray<Integer>;
    FCardTreeLayoutItems: TArray<TUniCardTreeLayoutItem>;
    FCardTreeBreadcrumbs: TArray<TUniCardTreeBreadcrumb>;
    FCardTreeHotBreadcrumb: Integer;
    FCardTreeOnNavigating: TUniCardTreeNavigatingEvent;
    FCardTreeOnNavigated: TUniCardTreeNodeEvent;
    FCardTreeOnLevelChanged: TNotifyEvent;
    FCardTreeOnNodeExpand: TUniCardTreeNodeEvent;
    FCardTreeOnNodeCollapse: TUniCardTreeNodeEvent;
    FCardTreeOnBreadcrumbClick: TUniCardTreeNodeEvent;
    FMultiCheck: Boolean;
    FShowCheckBoxes: Boolean;
    FCheckedCount: Integer;
    FCheckBatch: Boolean;
    FApplyingCheckEngine: Boolean;
    FTreeCheckMode: TUniTreeCheckMode;
    FTreeLazyLoad: Boolean;
    FTreeHasChildrenField: string;
    FTreeLoadedKeys: TStringList;
    FTreeLoadingKeys: TStringList;
    FOnTreeLoadChildren: TUniTreeLoadChildrenEvent;
    FFilterEditColumn: Integer;
    FListFooterVisible: Boolean;
    FListFooterHeight: Single;
    FListFrozenColumnCount: Integer;
    FSortColumnIndex: Integer;
    FSortAscending: Boolean;
    FSortColumnIndices: TArray<Integer>;
    FSortAscendingValues: TArray<Boolean>;
    FApplyingSort: Boolean;
    FUpdateCount: Integer;
    FHeaderResizeColumn: Integer;
    FHeaderResizeStartWidth: Single;
    FHeaderDragColumn: Integer;
    FHeaderDropColumn: Integer;
    FHeaderDragActive: Boolean;
    FColumnChooserVisible: Boolean;
    FColumnChooserRect: TRectF;
    FColumnChooserScroll: Integer;
    FColumnChooserHotIndex: Integer;
    FColumnChooserColumnIndex: Integer;
    FActions: TUniCardActions;
    FActionVisibility: TUniActionVisibility;
    FActionItemIndex: Integer;
    FCardTemplate: TUniCardTemplate;
    FScrollMode: TUniScrollMode;
    FPanMode: TUniPanMode;
    FCardSizingMode: TUniCardSizingMode;
    FContentFlow: TUniContentFlow;
    FScrollBars: TUniScrollBarVisibility;
    FCardMinWidth: Single;
    FCardMaxWidth: Single;
    FCardWidth: Single;
    FCardHeight: Single;
    FHorizontalGap: Single;
    FVerticalGap: Single;
    FContentPadding: Single;
    FCornerRadius: Single;
    FFixedColumnCount: Integer;
    FPanThreshold: Single;
    FScrollX: Single;
    FScrollY: Single;
    FContentWidth: Single;
    FContentHeight: Single;
    FActualCardWidth: Single;
    FAutoTitleCardWidth: Single;
    FAutoTitleWidthDirty: Boolean;
    FAutoTitleSceneScale: Single;
    FColumnCount: Integer;
    FSelectedIndex: Integer;
    FHotHit: TUniCardHit;
    FPressedHit: TUniCardHit;
    FMouseDownPos: TPointF;
    FMouseDownScroll: TPointF;
    FPanning: Boolean;
    FMousePressed: Boolean;
    FSelectingText: Boolean;
    FSelectedTextHit: TUniCardHit;
    FSelectedText: string;
    FItemHeights: TArray<Single>;
    FTitleLayouts: TArray<TUniTextLayout>;
    FTextLayouts: TArray<TUniTextLayout>;
    FDetailLayouts: TArray<TUniTextLayout>;
    FPreparedCardWidth: Single;
    FPreparedTextWidth: Single;
    FResizeHeightTimer: TTimer;
    FResizeHeightPending: Boolean;
    FLastLayoutWidth: Single;
    FLastLayoutHeight: Single;
    FGeometryOnlyLayout: Boolean;
    FLayoutDirty: Boolean;
    FRowTops: TArray<Single>;
    FRowHeights: TArray<Single>;
    FOnItemClick: TUniItemClickEvent;
    FOnItemAction: TUniItemActionEvent;
    FOnItemCheckChanged: TUniItemCheckChangedEvent;
    FOnItemCheckChanging: TUniItemCheckChangingEvent;
    FOnTreeCheckPropagationCompleted: TNotifyEvent;
    FOnCheckedChanged: TNotifyEvent;
    FBackgroundColor: TAlphaColor;
    FCardColor: TAlphaColor;
    FCardHotColor: TAlphaColor;
    FCardSelectedColor: TAlphaColor;
    FTextColor: TAlphaColor;
    FSecondaryTextColor: TAlphaColor;
    FAccentColor: TAlphaColor;
    FUseStyleBook: Boolean;
    FStyleIconColor: TAlphaColor;
    FStyleCheckImages: array[Boolean] of TBitmap;
    FStyleCheckSource: TRectF;
    FStyleCheckScale: Single;
    FStyleCheckCacheReady: Boolean;
    FOwnThemeColors: TArray<TAlphaColor>;
    FOwnThemeVariant: TUniThemeVariant;
    FThemeName: string;
    FThemeVariant: TUniThemeVariant;
    FHeaderColor: TAlphaColor;
    FAlternateRowColor: TAlphaColor;
    FFooterColor: TAlphaColor;
    FGridColor: TAlphaColor;
    FColorRules: TUniColorRules;
    FSearchEngine: TUniSearchEngine;
    FSearchTreeExpandedKeys: TStringList;
    FSearchTreeSnapshotActive: Boolean;
    FOnSearchChanged: TNotifyEvent;
    FInitializing: Boolean;
    FFontFamily: string;
    FFontTypeface: IUniTypeface;
    FTitleMeasureFont: IUniFont;
    FRenderScale: Single;
    FFontSize: Single;
    FTitleFontSize: Single;
    FDetailFontSize: Single;
    FDesignPreviewMode: TUniDesignPreviewMode;
    FDesignPreviewRows: Integer;
    FDesignPreviewActive: Boolean;
    FUpdatingDesignPreview: Boolean;
    FDataSource: TDataSource;
    FDesignDataLink: TUniDesignPreviewDataLink;
    procedure ItemsChanged(Sender: TObject);
    procedure ItemChanged(Sender: TObject; const AItemIndex: Integer;
      const AFieldName: string);
    procedure ActionsChanged(Sender: TObject);
    procedure ColumnsChanged(Sender: TObject);
    procedure ColorRulesChanged(Sender: TObject);
    procedure TemplateChanged(Sender: TObject);
    procedure ResizeHeightTimer(Sender: TObject);
    procedure DoDraw(Sender: TObject; const ACanvas: IUniCanvas;
      const ADest: TRectF; const AOpacity: Single);
    procedure Redraw;
    procedure SetSelectedIndex(const Value: Integer);
    procedure SetUseStyleBook(const Value: Boolean);
    function ResolveIconColor(const ADefault: TAlphaColor): TAlphaColor;
    procedure ClearStyleCheckCache;
    procedure EnsureStyleCheckCache;
    procedure SaveOwnTheme;
    procedure RestoreOwnTheme;
    procedure StyleChangedHandler(const Sender: TObject; const Msg: TMessage);
    procedure ApplyPalette(const Background, Foreground, Accent, Selection, UI: TAlphaColor;
      const Variant: TUniThemeVariant);
    procedure SetThemeName(const Value: string);
    procedure SetFontFamily(const Value: string);
    procedure SetFontSize(const Value: Single);
    procedure SetTitleFontSize(const Value: Single);
    procedure SetDetailFontSize(const Value: Single);
    procedure SetDesignPreviewMode(const Value: TUniDesignPreviewMode);
    procedure SetDesignPreviewRows(const Value: Integer);
    procedure SetDataSource(const Value: TDataSource);
    procedure ApplyTheme(const ATheme: TUniThemeDefinition);
    procedure SetViewMode(const Value: TUniViewMode);
    procedure SetCardLayout(const Value: TUniCardLayout);
    procedure SetCardSizingMode(const Value: TUniCardSizingMode);
    procedure SetCardMinWidth(const Value: Single);
    procedure SetCardMaxWidth(const Value: Single);
    procedure SetColumns(const Value: TUniListColumns);
    procedure SetColorRules(const Value: TUniColorRules);
    procedure SetListFrozenColumnCount(const Value: Integer);
    procedure SetTreeMode(const Value: Boolean);
    procedure SetTreeKeyField(const Value: string);
    procedure SetTreeParentField(const Value: string);
    procedure SetTreeColumn(const Value: string);
    procedure SetTreeCheckBoxes(const Value: Boolean);
    procedure SetMultiCheck(const Value: Boolean);
    procedure SetTreeLazyLoad(const Value: Boolean);
    procedure SetTreeHasChildrenField(const Value: string);
    procedure SetShowCheckBoxes(const Value: Boolean);
    procedure RecalculateCheckedCount;
    procedure SetTreeCheckMode(const Value: TUniTreeCheckMode);
    procedure ExecuteCheckOperation(const AItemIndex: Integer;
      const AState: TUniCheckState; const ANotifyChanging: Boolean = True);
    procedure SetCheckStateInternal(const AItemIndex: Integer;
      const AState: TUniCheckState);
    procedure PropagateCheckDown(const AItemIndex: Integer;
      const AState: TUniCheckState);
    procedure AggregateCheckUp(const AItemIndex: Integer);
    procedure RecalculateTreeCheckStatesInternal;
    function GetCheckedItems: TUniCheckedItems;
    function CheckBoxesVisible: Boolean;
    procedure SetListAutoRowHeight(const Value: Boolean);
    procedure SetListRowHeight(const Value: Single);
    procedure SetListFilterVisible(const Value: Boolean);
    procedure SetListFilterHeight(const Value: Single);
    procedure SetListFooterVisible(const Value: Boolean);
    procedure SetListFooterHeight(const Value: Single);
    procedure SetActions(const Value: TUniCardActions);
    procedure SetActionVisibility(const Value: TUniActionVisibility);
    procedure SetCardTemplate(const Value: TUniCardTemplate);
    procedure SetScrollX(const Value: Single);
    procedure SetScrollY(const Value: Single);
    procedure SetSearchText(const Value: string);
    function GetSearchText: string;
    procedure SetSearchOptions(const Value: TUniSearchOptions);
    function GetSearchOptions: TUniSearchOptions;
    function GetSearchMatchCount: Integer;
    function GetSearchRunning: Boolean;
    procedure SearchChanged(Sender: TObject);
    procedure SearchCurrentChanged(Sender: TObject;
      const AItemIndex: Integer);
    procedure ConfigureSearch;
    procedure RefreshDesignPreview;
    procedure ClearDesignPreview;
    procedure BuildDesignSampleData;
    function BuildConnectedDesignData: Boolean;
    procedure DesignDataChanged;
    procedure PopulateDesignCardAliases(const AItem: TUniListItem);
    function DesignSampleText(const AColumn: TUniListColumn;
      const ARowIndex: Integer): string;
    function CreateTextFont(const ASize: Single): IUniFont;
    function GetTitleMeasureFont: IUniFont;
    function MeasureTitleTextWidth(const AText: string): Single;
    function CurrentSceneScale: Single;
    procedure RebuildSearchTree;
    procedure SaveSearchTreeState;
    procedure RestoreSearchTreeState;
    procedure ExpandTreePathToItem(const AItemIndex: Integer);
    function VisibleSearchFields: TArray<string>;
    procedure DrawSearchHighlights(const ACanvas: IUniCanvas;
      const AItemIndex: Integer; const AText: string; const AX,
      ABaseline, AFontSize: Single);
    function CardDisplayCount: Integer;
    function CardDisplayItemIndex(const ADisplayIndex: Integer): Integer;
    function CardDisplayIndexOf(const AItemIndex: Integer): Integer;
    procedure RecalculateLayout;
    procedure InvalidateLayout(
      const AGeometryOnly: Boolean = False);
    procedure EnsureLayout;
    procedure PrepareTextLayouts;
    procedure PrepareItemTextLayout(const AItemIndex: Integer;
      const ATextWidth: Single);
    function CardWidthForViewport(const AViewportWidth: Single): Single;
    function HasWrappingCardContent: Boolean;
    procedure ClampScroll;
    function CardRect(const AIndex: Integer): TRectF;
    function HitTestAt(const P: TPointF): TUniCardHit;
    function CanPanWithMouse: Boolean;
    function VScrollRect: TRectF;
    function HScrollRect: TRectF;
    procedure DrawScrollBars(const ACanvas: IUniCanvas);
    procedure DrawCard(const ACanvas: IUniCanvas; const AIndex: Integer;
      const R: TRectF);
    procedure DrawFullWidthCard(const ACanvas: IUniCanvas;
      const AItemIndex: Integer; const R: TRectF);
    function FullWidthUsesRoles: Boolean;
    procedure FullWidthValues(AItem: TUniListItem;
      out ATitle, ASubtitle, ADetail, ATrailing: string;
      out ATitleColumn, ASubtitleColumn, ADetailColumn,
      ATrailingColumn: TUniListColumn);
    function MeasureFullWidthCardHeight(const AItemIndex: Integer;
      const AAvailableWidth: Single = 0;
      const AForceContentHeight: Boolean = False): Single;
    procedure CalculateListColumns;
    procedure CalculateListRows;
    function MeasureListRowHeight(const ADisplayIndex: Integer): Single;
    function WrapCellText(const AText: string; const AWidth: Single;
      const AMaxLines: Integer): TArray<string>;
    function ListDisplayIndexAtY(const AY: Single): Integer;
    procedure DrawList(const ACanvas: IUniCanvas; const ADest: TRectF);
    procedure DrawListHeader(const ACanvas: IUniCanvas);
    procedure DrawListFilter(const ACanvas: IUniCanvas);
    procedure DrawListFooter(const ACanvas: IUniCanvas);
    function FooterDisplayText(const AColumn: TUniListColumn): string;
    procedure DrawListRow(const ACanvas: IUniCanvas; const AIndex: Integer;
      const R: TRectF);
    procedure DrawListActions(const ACanvas: IUniCanvas;
      const AItemIndex: Integer; const ARowRect: TRectF;
      const ABackgroundColor: TAlphaColor);
    function ListActionsWidth(AItem: TUniListItem): Single;
    function ListActionRect(AItem: TUniListItem; const ARowRect: TRectF;
      const AActionIndex: Integer): TRectF;
    function ListRowRect(const AIndex: Integer): TRectF;
    function ListBodyTop: Single;
    function FilterColumnHit(const P: TPointF): Integer;
    procedure RebuildFilter;
    procedure RebuildTree;
    procedure RebuildCardTreeVisibleSet;
    procedure BuildCardTreeBreadcrumbs;
    procedure CalculateCardTreeLayout;
    procedure DrawCardTreeChrome(const ACanvas: IUniCanvas);
    function CardTreeActive: Boolean;
    function CardTreeItemHasChildren(const AItemIndex: Integer): Boolean;
    function CardTreeItemIsParent(const AItemIndex: Integer): Boolean;
    function CardTreeItemVisualParent(const AItemIndex: Integer): Boolean;
    function CardTreeItemChildCount(const AItemIndex: Integer): Integer;
    function CardTreeNavigationPresentation: Boolean;
    function CardTreeItemVisible(const AItemIndex: Integer): Boolean;
    function CardTreeFindItem(const ANodeId: string): Integer;
    function CardTreeDepth(const AItemIndex: Integer): Integer;
    function GetCardTreeCurrentNodeId: string;
    function GetCardTreeCurrentDepth: Integer;
    function GetCardTreeCanNavigateBack: Boolean;
    function GetCardTreeNavigationActive: Boolean;
    procedure SetCardTreeEnabled(const Value: Boolean);
    procedure SetCardTreeMode(const Value: TUniCardTreeMode);
    procedure SetCardTreeExplorerShowChildCount(const Value: Boolean);
    procedure SetCardTreeExplorerNavigateOnCardClick(const Value: Boolean);
    procedure SetCardTreeExplorerParentEmphasis(const Value: Single);
    procedure SetCardTreeExplorerKeepFlatOrder(const Value: Boolean);
    function TreeItemKey(const AItemIndex: Integer): string;
    function TreeItemParentKey(const AItemIndex: Integer): string;
    function TreeHasChildren(const AItemIndex: Integer): Boolean;
    function TreeMayHaveChildren(const AItemIndex: Integer): Boolean;
    function TreeNodeCanExpand(const AItemIndex: Integer): Boolean;
    function TreeChildrenLoaded(const AItemIndex: Integer): Boolean;
    procedure RequestTreeChildren(const AItemIndex: Integer; out AHandled: Boolean);
    function TreeIsExpanded(const AItemIndex: Integer): Boolean;
    function TreeLevel(const ADisplayIndex: Integer): Integer;
    function TreeToggleRect(const ADisplayIndex, AColumnIndex: Integer; const ARowRect: TRectF): TRectF;
    function TreeToggleAt(const P: TPointF; out ADisplayIndex: Integer): Boolean;
    function TreeCheckRect(const ADisplayIndex, AColumnIndex: Integer; const ARowRect: TRectF): TRectF;
    function TreeCheckAt(const P: TPointF; out ADisplayIndex: Integer): Boolean;
    function TreeCheckState(const AItemIndex: Integer): TUniCheckState;
    function ItemCheckKey(const AItemIndex: Integer): string;
    function FirstVisibleColumnIndex: Integer;
    function IsLastVisibleColumn(const AColumnIndex: Integer): Boolean;
    function ListCheckRect(const ADisplayIndex, AColumnIndex: Integer;
      const ARowRect: TRectF): TRectF;
    function ListCheckAt(const P: TPointF; out ADisplayIndex: Integer): Boolean;
    function CardCheckRect(const AItemIndex: Integer): TRectF;
    function CardCheckAt(const P: TPointF; out AItemIndex: Integer): Boolean;
    procedure DrawCheckBox(const ACanvas: IUniCanvas; const ARect: TRectF;
      const AState: TUniCheckState);
    procedure ToggleTreeCheck(const ADisplayIndex: Integer);
    procedure ToggleTreeNode(const ADisplayIndex: Integer);
    function ItemMatchesFilters(AItem: TUniListItem): Boolean;
    function ItemMatchesFilter(AItem: TUniListItem;
      AColumn: TUniListColumn): Boolean;
    function DisplayItemCount: Integer;
    function DisplayItemIndex(const ADisplayIndex: Integer): Integer;
    function ListHeaderHit(const P: TPointF): Integer;
    function ListHeaderDividerHit(const P: TPointF): Integer;
    function IsColumnFrozen(const AColumnIndex: Integer): Boolean;
    function FrozenColumnsRight: Single;
    function ColumnScreenLeft(const AColumnIndex: Integer): Single;
    procedure AutoFitColumn(const AColumnIndex: Integer);
    procedure MoveColumn(const AFromIndex, AToIndex: Integer);
    procedure ShowColumnsMenu(const X, Y: Single);
    procedure HideColumnChooser;
    procedure UpdateColumnChooserRect(const X, Y: Single);
    procedure DrawColumnChooser(const ACanvas: IUniCanvas);
    function ColumnChooserHit(const P: TPointF): Integer;
    function VisibleColumnCount: Integer;
    procedure ResetColumnLayout;
    procedure SortByColumn(const AColumnIndex: Integer;
      const AAddToSort: Boolean = False);
    procedure ApplyCurrentSort;
    function SortCriterionIndex(const AColumnIndex: Integer): Integer;
    procedure SyncPrimarySort;
    procedure AdjustSortAfterColumnMove(const AFromIndex, AToIndex: Integer);
    function ColumnDisplayText(AItem: TUniListItem;
      AColumn: TUniListColumn): string;
    procedure ResolveColorRules(AItem: TUniListItem; const AColumnName: string;
      var ABackgroundColor, ATextColor: TAlphaColor;
      var AUseBackgroundColor, AUseTextColor: Boolean);
    procedure ResolveThemeRuleColors(const ARule: TUniColorRule;
      out ABackgroundColor, ATextColor: TAlphaColor);
    function MeasureCardHeight(const AIndex: Integer): Single;
    function MeasureAutoTitleCardWidth: Single;
    function CardChromeWidth: Single;
    procedure InvalidateAutoTitleWidth;
    procedure InvalidateCardHeightCache;
    function TextAvailableWidth(const R: TRectF): Single;
    function TextRect(const AIndex: Integer; const APart: TUniTextPart): TRectF;
    function TextValue(const AHit: TUniCardHit): string;
    function ItemTitle(AItem: TUniListItem): string; overload;
    function ItemTitle(AItem: TUniListItem;
      ATitleColumn: TUniListColumn): string; overload;
    function CardTitleColumn: TUniListColumn;
    function MeasureWidestTitleWord(const ATitle: string;
      const AFont: IUniFont): Single;
    function ItemText(AItem: TUniListItem): string;
    function ItemDetail(AItem: TUniListItem): string;
    function ItemIcon(AItem: TUniListItem): TUniVectorIcon;
    function ItemSecondaryIcon(AItem: TUniListItem): TUniVectorIcon;
    function ActionVisible(AItem: TUniListItem; AAction: TUniCardAction): Boolean;
    function ActionDisplayed(const AItemIndex: Integer;
      AAction: TUniCardAction): Boolean;
    function ActionEnabled(AItem: TUniListItem; AAction: TUniCardAction): Boolean;
    function AreActionsVisibleForItem(const AItemIndex: Integer): Boolean;
    procedure ClearHoverState;
    procedure SelectTextHit(const AHit: TUniCardHit);
    procedure CopySelectedText;
    function FirstVisibleIndex: Integer;
    function LastVisibleIndex: Integer;
  protected
    procedure Paint; override;
    procedure DoItemClick(const AItemIndex: Integer); virtual;
    procedure DoItemDoubleClick(const AItemIndex: Integer); virtual;
    procedure DoSearchChanged; virtual;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
    procedure ReadState(Reader: TReader); override;
    procedure Resize; override;
    procedure Loaded; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseWheel(Shift: TShiftState; WheelDelta: Integer;
      var Handled: Boolean); override;
    procedure DoMouseLeave; override;
    procedure DblClick; override;
    procedure KeyDown(var Key: Word; var KeyChar: WideChar;
      Shift: TShiftState); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function AddItem(const ATitle, AText: string;
      const ADetail: string = ''): TUniListItem;
    procedure BeginUpdate; reintroduce;
    procedure EndUpdate; reintroduce;
    procedure Clear;
    procedure ExpandAll;
    procedure CollapseAll;
    procedure ExpandToLevel(const ALevel: Integer);
    procedure CardTreeNavigateToRoot;
    procedure CardTreeNavigateToParent;
    procedure CardTreeExitNavigation;
    procedure CardTreeNavigateToNode(const ANodeId: string);
    function CardTreeTryNavigateToNode(const ANodeId: string): Boolean;
    procedure CardTreeRefresh;
    procedure CardTreeExpandAll;
    procedure CardTreeCollapseAll;
    procedure CardTreeExpandNode(const ANodeId: string);
    procedure CardTreeCollapseNode(const ANodeId: string);
    function CardTreeIsNodeExpanded(const ANodeId: string): Boolean;
    procedure MarkChildrenLoaded(const AParentKey: string);
    procedure ReloadChildren(const AParentKey: string);
    function ChildrenLoaded(const AParentKey: string): Boolean;
    procedure CheckAll; overload;
    procedure CheckAll(const AScope: TUniCheckScope); overload;
    procedure UncheckAll; overload;
    procedure UncheckAll(const AScope: TUniCheckScope); overload;
    procedure InvertChecks; overload;
    procedure InvertChecks(const AScope: TUniCheckScope); overload;
    function IsItemChecked(const AIndex: Integer): Boolean;
    procedure SetItemChecked(const AIndex: Integer;
      const AChecked: Boolean);
    procedure ToggleItemChecked(const AIndex: Integer);
    procedure SetItemCheckState(const AItemId: string;
      const AState: TUniCheckState);
    function GetItemCheckState(const AItemId: string): TUniCheckState;
    procedure CheckItem(const AItemId: string; const AChecked: Boolean);
    procedure RecalculateTreeCheckStates;
    function FirstCheckedItem: TUniListItem;
    function LastCheckedItem: TUniListItem;
    function CheckedTreeKeys: TArray<string>;
    function CheckedKeys: TArray<string>;
    procedure ScrollToItem(const AIndex: Integer);
    procedure ClearTextSelection;
    procedure AutoFitAllColumns;
    procedure SetColumnVisible(const AColumnID: string; const AVisible: Boolean);
    procedure ShowColumnChooser;
    procedure ClearFilters;
    procedure FindNext;
    procedure FindPrevious;
    procedure ClearSearch;
    function NavigationItemCount: Integer;
    function NavigationItemIndex(const ADisplayIndex: Integer): Integer;
    function NavigationIndexOfItem(const AItemIndex: Integer): Integer;
    function NavigationPageSize: Integer;
    function ItemColumnDisplayText(const AItemIndex: Integer;
      const AColumnName: string): string;
    function ItemIndexAt(const APoint: TPointF): Integer;
    function SaveLayoutToJSON: string;
    procedure LoadLayoutFromJSON(const AJSON: string);
    procedure SaveLayoutToFile(const AFileName: string);
    procedure LoadLayoutFromFile(const AFileName: string);
    procedure SetNewScene(AScene: IScene); override;
    procedure RefreshStyleBook;
    procedure LoadThemeFromFile(const AFileName: string);
    function AvailableThemeNames: TArray<string>;
    procedure ResetPerformanceCounters;
    function GetPerformanceSnapshot: TUniPerformanceSnapshot;
    function PerformanceReport: string;
    property Items: TUniListItems read FItems;
    property ContentWidth: Single read FContentWidth;
    property ContentHeight: Single read FContentHeight;
    property ActualCardWidth: Single read FActualCardWidth;
    property ColumnCount: Integer read FColumnCount;
    property SelectedText: string read FSelectedText;
    property SearchMatchCount: Integer read GetSearchMatchCount;
    property SearchRunning: Boolean read GetSearchRunning;
    property CheckedCount: Integer read FCheckedCount;
    property CheckedItems: TUniCheckedItems read GetCheckedItems;
    property CardTreeCurrentNodeId: string read GetCardTreeCurrentNodeId;
    property CardTreeCurrentDepth: Integer read GetCardTreeCurrentDepth;
    property CardTreeCanNavigateBack: Boolean read GetCardTreeCanNavigateBack;
    property CardTreeNavigationActive: Boolean
      read GetCardTreeNavigationActive;
    (* Индекс строки, на время выполнения TUniCardAction.Action.Execute
       (вызванного кликом по кнопке в карточке); -1 вне этого контекста. *)
    property ActionItemIndex: Integer read FActionItemIndex;
  published
    property Align;
    property Anchors;
    property Position;
    property Size;
    property Visible;
    property Enabled;
    property HitTest;
    property Opacity;
    property ViewMode: TUniViewMode read FViewMode write SetViewMode
      default uvmCards;
    property CardLayout: TUniCardLayout read FCardLayout write SetCardLayout
      default uclGrid;
    property Columns: TUniListColumns read FColumns write SetColumns;
    property ColorRules: TUniColorRules read FColorRules write SetColorRules;
    property Actions: TUniCardActions read FActions write SetActions;
    property ActionVisibility: TUniActionVisibility read FActionVisibility
      write SetActionVisibility default uavAlways;
    property CardTemplate: TUniCardTemplate read FCardTemplate write SetCardTemplate;
    property ListHeaderHeight: Single read FListHeaderHeight write FListHeaderHeight;
    property ListRowHeight: Single read FListRowHeight write SetListRowHeight;
    property ListAutoRowHeight: Boolean read FListAutoRowHeight
      write SetListAutoRowHeight default False;
    property ListGridLines: Boolean read FListGridLines write FListGridLines
      default True;
    property ListHorizontalGridLines: Boolean read FListHorizontalGridLines
      write FListHorizontalGridLines default True;
    property ListFilterVisible: Boolean read FListFilterVisible
      write SetListFilterVisible default False;
    property ListFilterHeight: Single read FListFilterHeight
      write SetListFilterHeight;
    property ListFooterVisible: Boolean read FListFooterVisible
      write SetListFooterVisible default False;
    property ListFooterHeight: Single read FListFooterHeight
      write SetListFooterHeight;
    property ListFrozenColumnCount: Integer read FListFrozenColumnCount
      write SetListFrozenColumnCount default 0;
    property TreeMode: Boolean read FTreeMode write SetTreeMode default False;
    property CardTreeEnabled: Boolean read FCardTreeEnabled
      write SetCardTreeEnabled default False;
    property CardTreeMode: TUniCardTreeMode read FCardTreeMode
      write SetCardTreeMode default ctmNavigate;
    property CardTreeShowBreadcrumbs: Boolean read FCardTreeShowBreadcrumbs
      write FCardTreeShowBreadcrumbs default True;
    property CardTreeShowRootBreadcrumb: Boolean read FCardTreeShowRootBreadcrumb
      write FCardTreeShowRootBreadcrumb default True;
    property CardTreeRootCaption: string read FCardTreeRootCaption
      write FCardTreeRootCaption;
    property CardTreeShowBackButton: Boolean read FCardTreeShowBackButton
      write FCardTreeShowBackButton default True;
    property CardTreeExplorerShowChildCount: Boolean
      read FCardTreeExplorerShowChildCount
      write SetCardTreeExplorerShowChildCount default True;
    property CardTreeExplorerNavigateOnCardClick: Boolean
      read FCardTreeExplorerNavigateOnCardClick
      write SetCardTreeExplorerNavigateOnCardClick default False;
    property CardTreeExplorerParentEmphasis: Single
      read FCardTreeExplorerParentEmphasis
      write SetCardTreeExplorerParentEmphasis;
    property CardTreeExplorerKeepFlatOrder: Boolean
      read FCardTreeExplorerKeepFlatOrder
      write SetCardTreeExplorerKeepFlatOrder default True;
    property CardTreeParentBackgroundColor: TAlphaColor
      read FCardTreeParentBackgroundColor write FCardTreeParentBackgroundColor;
    property CardTreeNavigationIconColor: TAlphaColor
      read FCardTreeNavigationIconColor write FCardTreeNavigationIconColor;
    property CardTreeNavigationIconSize: Single read FCardTreeNavigationIconSize
      write FCardTreeNavigationIconSize;
    property CardTreeHierarchyIndent: Single read FCardTreeHierarchyIndent
      write FCardTreeHierarchyIndent;
    property CardTreeHierarchySpacing: Single read FCardTreeHierarchySpacing
      write FCardTreeHierarchySpacing;
    property CardTreeBreadcrumbHeight: Single read FCardTreeBreadcrumbHeight
      write FCardTreeBreadcrumbHeight;
    property CardTreeBreadcrumbSpacing: Single read FCardTreeBreadcrumbSpacing
      write FCardTreeBreadcrumbSpacing;
    property CardTreeBreadcrumbTextColor: TAlphaColor
      read FCardTreeBreadcrumbTextColor write FCardTreeBreadcrumbTextColor;
    property CardTreeBreadcrumbHotColor: TAlphaColor
      read FCardTreeBreadcrumbHotColor write FCardTreeBreadcrumbHotColor;
    property CardTreeBreadcrumbSeparator: string read FCardTreeBreadcrumbSeparator
      write FCardTreeBreadcrumbSeparator;
    property TreeKeyField: string read FTreeKeyField write SetTreeKeyField;
    property TreeParentField: string read FTreeParentField write SetTreeParentField;
    property TreeColumn: string read FTreeColumn write SetTreeColumn;
    property TreeIndent: Single read FTreeIndent write FTreeIndent;
    property TreeLazyLoad: Boolean read FTreeLazyLoad write SetTreeLazyLoad default False;
    property TreeHasChildrenField: string read FTreeHasChildrenField
      write SetTreeHasChildrenField;
    property MultiCheck: Boolean read FMultiCheck write SetMultiCheck default False;
    property ShowCheckBoxes: Boolean read FShowCheckBoxes
      write SetShowCheckBoxes default True;
    property TreeCheckBoxes: Boolean read FMultiCheck
      write SetTreeCheckBoxes default False;
    property TreeCheckMode: TUniTreeCheckMode read FTreeCheckMode
      write SetTreeCheckMode default tcmIndependent;
    property OnTreeLoadChildren: TUniTreeLoadChildrenEvent read FOnTreeLoadChildren
      write FOnTreeLoadChildren;
    property ScrollMode: TUniScrollMode read FScrollMode write FScrollMode default usmVertical;
    property PanMode: TUniPanMode read FPanMode write FPanMode default upmMouseAndTouch;
    property CardSizingMode: TUniCardSizingMode read FCardSizingMode
      write SetCardSizingMode default ucsmResponsive;
    property ContentFlow: TUniContentFlow read FContentFlow write FContentFlow default ucfWrap;
    property ScrollBars: TUniScrollBarVisibility read FScrollBars write FScrollBars default usbAuto;
    property CardMinWidth: Single read FCardMinWidth write SetCardMinWidth;
    property CardMaxWidth: Single read FCardMaxWidth write SetCardMaxWidth;
    property CardWidth: Single read FCardWidth write FCardWidth;
    property CardHeight: Single read FCardHeight write FCardHeight;
    property HorizontalGap: Single read FHorizontalGap write FHorizontalGap;
    property VerticalGap: Single read FVerticalGap write FVerticalGap;
    property ContentPadding: Single read FContentPadding write FContentPadding;
    property CornerRadius: Single read FCornerRadius write FCornerRadius;
    property FixedColumnCount: Integer read FFixedColumnCount write FFixedColumnCount default 3;
    property PanThreshold: Single read FPanThreshold write FPanThreshold;
    property ScrollX: Single read FScrollX write SetScrollX;
    property ScrollY: Single read FScrollY write SetScrollY;
    property SelectedIndex: Integer read FSelectedIndex write SetSelectedIndex default -1;
    property SearchText: string read GetSearchText write SetSearchText;
    property SearchOptions: TUniSearchOptions read GetSearchOptions
      write SetSearchOptions;
    property UseStyleBook: Boolean read FUseStyleBook write SetUseStyleBook default False;
    property ThemeName: string read FThemeName write SetThemeName;
    property FontFamily: string read FFontFamily write SetFontFamily;
    property FontSize: Single read FFontSize write SetFontSize;
    property TitleFontSize: Single read FTitleFontSize
      write SetTitleFontSize;
    property DetailFontSize: Single read FDetailFontSize
      write SetDetailFontSize;
    property DesignPreviewMode: TUniDesignPreviewMode
      read FDesignPreviewMode write SetDesignPreviewMode
      default dpmSampleData;
    property DesignPreviewRows: Integer read FDesignPreviewRows
      write SetDesignPreviewRows default 8;
    property DataSource: TDataSource read FDataSource write SetDataSource;
    property ThemeVariant: TUniThemeVariant read FThemeVariant;
    property BackgroundColor: TAlphaColor read FBackgroundColor write FBackgroundColor default $FFF2F4F7;
    property CardColor: TAlphaColor read FCardColor write FCardColor default $FFFFFFFF;
    property CardHotColor: TAlphaColor read FCardHotColor write FCardHotColor default $FFF8FAFC;
    property CardSelectedColor: TAlphaColor read FCardSelectedColor write FCardSelectedColor default $FFE8F1FF;
    property TextColor: TAlphaColor read FTextColor write FTextColor default $FF202124;
    property SecondaryTextColor: TAlphaColor read FSecondaryTextColor write FSecondaryTextColor default $FF6B7280;
    property AccentColor: TAlphaColor read FAccentColor write FAccentColor default $FF3B82F6;
    property HeaderColor: TAlphaColor read FHeaderColor write FHeaderColor;
    property AlternateRowColor: TAlphaColor read FAlternateRowColor write FAlternateRowColor;
    property FooterColor: TAlphaColor read FFooterColor write FFooterColor;
    property GridColor: TAlphaColor read FGridColor write FGridColor;
    property OnItemClick: TUniItemClickEvent read FOnItemClick write FOnItemClick;
    property OnItemAction: TUniItemActionEvent read FOnItemAction write FOnItemAction;
    property OnItemCheckChanged: TUniItemCheckChangedEvent
      read FOnItemCheckChanged write FOnItemCheckChanged;
    property OnItemCheckChanging: TUniItemCheckChangingEvent
      read FOnItemCheckChanging write FOnItemCheckChanging;
    property OnTreeCheckPropagationCompleted: TNotifyEvent
      read FOnTreeCheckPropagationCompleted
      write FOnTreeCheckPropagationCompleted;
    property OnCheckedChanged: TNotifyEvent read FOnCheckedChanged
      write FOnCheckedChanged;
    property OnSearchChanged: TNotifyEvent read FOnSearchChanged
      write FOnSearchChanged;
    property OnCardTreeNavigating: TUniCardTreeNavigatingEvent
      read FCardTreeOnNavigating write FCardTreeOnNavigating;
    property OnCardTreeNavigated: TUniCardTreeNodeEvent
      read FCardTreeOnNavigated write FCardTreeOnNavigated;
    property OnCardTreeLevelChanged: TNotifyEvent
      read FCardTreeOnLevelChanged write FCardTreeOnLevelChanged;
    property OnCardTreeNodeExpand: TUniCardTreeNodeEvent
      read FCardTreeOnNodeExpand write FCardTreeOnNodeExpand;
    property OnCardTreeNodeCollapse: TUniCardTreeNodeEvent
      read FCardTreeOnNodeCollapse write FCardTreeOnNodeCollapse;
    property OnCardTreeBreadcrumbClick: TUniCardTreeNodeEvent
      read FCardTreeOnBreadcrumbClick write FCardTreeOnBreadcrumbClick;
  end;

procedure Register;

implementation

const
  DEFAULT_TITLE_FONT_SIZE = 15.0;
  DEFAULT_BODY_FONT_SIZE = 12.0;
  DEFAULT_DETAIL_FONT_SIZE = 12.0;
  MIN_FONT_SIZE = 6.0;
  MAX_FONT_SIZE = 96.0;
  DEFAULT_DESIGN_PREVIEW_ROWS = 8;
  MAX_DESIGN_PREVIEW_ROWS = 100;
  GRID_CARD_CHECKBOX_SIZE = 16.0;
  GRID_CARD_CHECKBOX_GAP = 8.0;
  GRID_CARD_ICON_GAP = 12.0;
  GRID_CARD_ACTION_GAP = 4.0;
  LIST_CHECKBOX_AREA_WIDTH = 32.0;
  CARD_TREE_DEFAULT_ICON_SIZE = 18.0;
  CARD_TREE_DEFAULT_INDENT = 24.0;
  CARD_TREE_DEFAULT_SPACING = 8.0;
  CARD_TREE_DEFAULT_BREADCRUMB_HEIGHT = 36.0;
  CARD_TREE_DEFAULT_BREADCRUMB_SPACING = 8.0;
  CARD_TREE_ICON_PADDING = 8.0;
  CARD_TREE_BADGE_WIDTH = 30.0;
  CARD_TREE_BADGE_GAP = 4.0;
  CARD_TREE_BADGE_RADIUS = 6.0;
  RESIZE_HEIGHT_DELAY_MS = 100;
  FULL_WIDTH_CARD_HORIZONTAL_PADDING = 12.0;
  FULL_WIDTH_CARD_VERTICAL_PADDING = 10.0;
  FULL_WIDTH_CARD_GAP = 8.0;
  FULL_WIDTH_CARD_TITLE_GAP = 4.0;
  FULL_WIDTH_CARD_TRAILING_MIN_WIDTH = 80.0;
  FULL_WIDTH_CARD_TRAILING_MAX_RATIO = 0.35;
  FULL_WIDTH_CARD_SCROLLBAR_RESERVE = 10.0;
  FULL_WIDTH_CARD_CHECKBOX_SPACE = 24.0;
  FULL_WIDTH_CARD_ICON_GAP = 12.0;
  FULL_WIDTH_CARD_ACTION_GAP = 4.0;
  FULL_WIDTH_CARD_ACTION_ICON_INSET = 5.0;
  FULL_WIDTH_CARD_ACTION_RADIUS = 6.0;
  FULL_WIDTH_CARD_TITLE_MAX_LINES = 1;
  FULL_WIDTH_CARD_SUBTITLE_MAX_LINES = 2;
  FULL_WIDTH_CARD_DETAIL_MAX_LINES = 2;
  LIST_ACTION_HORIZONTAL_PADDING = 8.0;
  LIST_ACTION_VERTICAL_PADDING = 3.0;
  LIST_ACTION_GAP = 4.0;
  LIST_ACTION_ICON_INSET = 7.0;
  LIST_ACTION_RADIUS = 6.0;
  LIST_ACTION_SCROLLBAR_RESERVE = 10.0;
  ACTION_HOVER_BLEND = 0.18;
  ACTION_PRESSED_BLEND = 0.28;
  ACTION_DISABLED_BLEND = 0.45;

function UniColor(const C: TAlphaColor): TAlphaColor;
begin
  Result := C;
end;

procedure TUniListView.Redraw;
begin
  Repaint;
end;

constructor TUniDesignPreviewDataLink.Create(const AListView: TUniListView);
begin
  inherited Create;
  FListView := AListView;
  VisualControl := True;
end;

procedure TUniDesignPreviewDataLink.ActiveChanged;
begin
  inherited;
  if Assigned(FListView) then
    FListView.DesignDataChanged;
end;

procedure TUniDesignPreviewDataLink.DataSetChanged;
begin
  inherited;
  if Assigned(FListView) then
    FListView.DesignDataChanged;
end;

procedure TUniDesignPreviewDataLink.LayoutChanged;
begin
  inherited;
  if Assigned(FListView) then
    FListView.DesignDataChanged;
end;

constructor TUniListView.Create(AOwner: TComponent);
var
  A: TUniCardAction;
  C: TUniListColumn;
begin
  inherited;
  FInitializing := True;
  FResizeHeightTimer := TTimer.Create(Self);
  FResizeHeightTimer.Enabled := False;
  FResizeHeightTimer.Interval := RESIZE_HEIGHT_DELAY_MS;
  FResizeHeightTimer.OnTimer := ResizeHeightTimer;
  FResizeHeightPending := False;
  FLastLayoutWidth := -1;
  FLastLayoutHeight := -1;
  FActionItemIndex := -1;
  FGeometryOnlyLayout := False;
  FItems := TUniListItems.Create;
  FViewMode := uvmCards;
  FCardLayout := uclGrid;
  FColumns := TUniListColumns.Create(Self);
  FColumns.OnChanged := ColumnsChanged;
  FColorRules := TUniColorRules.Create(Self);
  FColorRules.OnChanged := ColorRulesChanged;
  FListHeaderHeight := 36;
  FListRowHeight := 34;
  FListAutoRowHeight := False;
  FListGridLines := True;
  FListHorizontalGridLines := True;
  FListFilterVisible := False;
  FListFilterHeight := 28;
  FFilterEditColumn := -1;
  FListFooterVisible := False;
  FListFooterHeight := 32;
  FListFrozenColumnCount := 0;
  FTreeMode := False;
  FTreeKeyField := 'id';
  FTreeParentField := 'parent_id';
  FTreeColumn := 'name';
  FTreeIndent := 18;
  FCardTreeEnabled := False;
  FCardTreeMode := ctmNavigate;
  FCardTreeShowBreadcrumbs := True;
  FCardTreeShowRootBreadcrumb := True;
  FCardTreeRootCaption := 'Root';
  FCardTreeShowBackButton := True;
  FCardTreeExplorerShowChildCount := True;
  FCardTreeExplorerNavigateOnCardClick := False;
  FCardTreeExplorerParentEmphasis := 0.08;
  FCardTreeExplorerKeepFlatOrder := True;
  FCardTreeNavigationActive := False;
  FCardTreeExplorerSelectedIndex := -1;
  FCardTreeNavigationIconSize := CARD_TREE_DEFAULT_ICON_SIZE;
  FCardTreeHierarchyIndent := CARD_TREE_DEFAULT_INDENT;
  FCardTreeHierarchySpacing := CARD_TREE_DEFAULT_SPACING;
  FCardTreeBreadcrumbHeight := CARD_TREE_DEFAULT_BREADCRUMB_HEIGHT;
  FCardTreeBreadcrumbSpacing := CARD_TREE_DEFAULT_BREADCRUMB_SPACING;
  FCardTreeBreadcrumbSeparator := '›';
  FCardTreeCurrentNodeIndex := -1;
  FCardTreeHotBreadcrumb := -1;
  FTreeKeyToIndex := TDictionary<string, Integer>.Create;
  FTreeExpandedKeys := TStringList.Create;
  FTreeExpandedKeys.CaseSensitive := False;
  FTreeExpandedKeys.Duplicates := dupIgnore;
  FMultiCheck := False;
  FShowCheckBoxes := True;
  FCheckedCount := 0;
  FCheckBatch := False;
  FApplyingCheckEngine := False;
  FTreeCheckMode := tcmIndependent;
  FTreeLazyLoad := False;
  FTreeHasChildrenField := 'has_children';
  FTreeLoadedKeys := TStringList.Create;
  FTreeLoadedKeys.CaseSensitive := False;
  FTreeLoadedKeys.Sorted := True;
  FTreeLoadedKeys.Duplicates := dupIgnore;
  FTreeLoadingKeys := TStringList.Create;
  FTreeLoadingKeys.CaseSensitive := False;
  FTreeLoadingKeys.Sorted := True;
  FTreeLoadingKeys.Duplicates := dupIgnore;
  FTreeExpandedKeys.Sorted := True;
  FTreeExpandedKeys.Duplicates := dupIgnore;
  FSearchTreeExpandedKeys := TStringList.Create;
  FSearchTreeExpandedKeys.CaseSensitive := False;
  FSearchTreeExpandedKeys.Sorted := True;
  FSearchTreeExpandedKeys.Duplicates := dupIgnore;
  FSearchTreeSnapshotActive := False;
  FSortColumnIndex := -1;
  FSortAscending := True;
  SetLength(FSortColumnIndices, 0);
  SetLength(FSortAscendingValues, 0);
  FApplyingSort := False;
  FUpdateCount := 0;
  FHeaderResizeColumn := -1;
  FHeaderDragColumn := -1;
  FHeaderDropColumn := -1;
  FColumnChooserVisible := False;
  FColumnChooserRect := TRectF.Empty;
  FColumnChooserScroll := 0;
  FColumnChooserHotIndex := -1;
  FColumnChooserColumnIndex := -1;
  FItems.OnChanged := ItemsChanged;
  FItems.OnItemChanged := ItemChanged;
  FActions := TUniCardActions.Create(Self);
  FActions.OnChanged := ActionsChanged;
  FActionVisibility := uavAlways;
  FCardTemplate := TUniCardTemplate.Create(Self);
  FCardTemplate.OnChanged := TemplateChanged;
  FSearchEngine := TUniSearchEngine.Create;
  FSearchEngine.OnChanged := SearchChanged;
  FSearchEngine.OnCurrentChanged := SearchCurrentChanged;
  FScrollMode := usmVertical;
  FPanMode := upmMouseAndTouch;
  FCardSizingMode := ucsmResponsive;
  FContentFlow := ucfWrap;
  FScrollBars := usbAuto;
  FCardMinWidth := 260;
  FCardMaxWidth := 420;
  FCardWidth := 300;
  FAutoTitleCardWidth := 0;
  FAutoTitleWidthDirty := True;
  FAutoTitleSceneScale := 1;
  FCardHeight := 72;
  FHorizontalGap := 10;
  FVerticalGap := 10;
  FContentPadding := 10;
  FCornerRadius := 8;
  FFixedColumnCount := 3;
  FPanThreshold := 5;
  FSelectedIndex := -1;
  FLayoutDirty := True;
  FHotHit := TUniCardHit.None;
  FPressedHit := TUniCardHit.None;
  FSelectedTextHit := TUniCardHit.None;
  FPreparedCardWidth := -1;
  FPreparedTextWidth := -1;
  FBackgroundColor := $FFF2F4F7;
  FCardColor := $FFFFFFFF;
  FCardHotColor := $FFF8FAFC;
  FCardSelectedColor := $FFE8F1FF;
  FTextColor := $FF202124;
  FSecondaryTextColor := $FF6B7280;
  FAccentColor := $FF3B82F6;
  FThemeName := 'Termius Light';
  FFontFamily := '';
  FFontTypeface := nil;
  FTitleMeasureFont := nil;
  FFontSize := DEFAULT_BODY_FONT_SIZE;
  FTitleFontSize := DEFAULT_TITLE_FONT_SIZE;
  FDetailFontSize := DEFAULT_DETAIL_FONT_SIZE;
  FDesignPreviewMode := dpmSampleData;
  FDesignPreviewRows := DEFAULT_DESIGN_PREVIEW_ROWS;
  FDesignPreviewActive := False;
  FUpdatingDesignPreview := False;
  FDataSource := nil;
  FDesignDataLink := TUniDesignPreviewDataLink.Create(Self);
  FHeaderColor := $FFF8FAFC;
  FAlternateRowColor := $FFFBFCFD;
  FFooterColor := $FFF8FAFC;
  FGridColor := $22000000;
  ApplyTheme(TUniThemeManager.Find(FThemeName));
  C := FColumns.Add;
  C.FieldName := 'name';
  C.Caption := 'Name';
  C.WidthMode := ucwmFill;
  C.MinWidth := 180;
  C := FColumns.Add;
  C.FieldName := 'status';
  C.Caption := 'Status';
  C.Width := 140;
  C := FColumns.Add;
  C.FieldName := 'latency_ms';
  C.Caption := 'Latency';
  C.Width := 90;
  C.DataType := ucdtInteger;
  C.Alignment := TTextAlign.Trailing;
  A := FActions.Add;
  A.Name := 'edit'; A.Caption := 'Edit'; A.Icon := uviEdit;
  A := FActions.Add;
  A.Name := 'delete'; A.Caption := 'Delete'; A.Icon := uviDelete;
  ClipChildren := True;
  HitTest := True;
  AutoCapture := True;
  CanFocus := True;
  SetBounds(Position.X, Position.Y, 640, 360);
  FLastLayoutWidth := Width;
  FLastLayoutHeight := Height;
  FInitializing := False;
  TMessageManager.DefaultManager.SubscribeToMessage(TStyleChangedMessage, StyleChangedHandler);
  RebuildFilter;
  InvalidateLayout;
  EnsureLayout;
end;

destructor TUniListView.Destroy;
begin
  ClearStyleCheckCache;
  TMessageManager.DefaultManager.Unsubscribe(TStyleChangedMessage, StyleChangedHandler);
  FInitializing := True;
  if FResizeHeightTimer <> nil then
  begin
    FResizeHeightTimer.Enabled := False;
    FResizeHeightTimer.OnTimer := nil;
  end;
  FDesignDataLink.DataSource := nil;

  inherited;

  FDesignDataLink.Free;
  FSearchEngine.Free;
  FSearchTreeExpandedKeys.Free;
  FTreeLoadingKeys.Free;
  FTreeLoadedKeys.Free;
  FTreeExpandedKeys.Free;
  FTreeKeyToIndex.Free;
  FColorRules.Free;
  FColumns.Free;
  FCardTemplate.Free;
  FActions.Free;
  FItems.Free;
end;

procedure TUniListView.ColorRulesChanged(Sender: TObject);
begin
  Redraw;
end;

procedure TUniListView.ActionsChanged(Sender: TObject);
begin
  InvalidateCardHeightCache;
  InvalidateAutoTitleWidth;
  InvalidateLayout;
end;

procedure TUniListView.ColumnsChanged(Sender: TObject);
begin
  if not FUpdatingDesignPreview then
    RefreshDesignPreview;
  InvalidateCardHeightCache;
  InvalidateAutoTitleWidth;
  RebuildFilter;
  InvalidateLayout;
end;

procedure TUniListView.TemplateChanged(Sender: TObject);
begin
  if not FUpdatingDesignPreview then
    RefreshDesignPreview;
  InvalidateCardHeightCache;
  InvalidateAutoTitleWidth;
  ConfigureSearch;
  InvalidateLayout;
end;

procedure TUniListView.Notification(AComponent: TComponent;
  Operation: TOperation);
var
  I: Integer;
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FDataSource) then
    DataSource := nil;
  if (Operation = opRemove) and Assigned(FActions) then
    for I := 0 to FActions.Count - 1 do
      if FActions[I].Action = AComponent then
        FActions[I].Action := nil;
end;

procedure TUniListView.SetDataSource(const Value: TDataSource);
begin
  if FDataSource = Value then
    Exit;
  if Assigned(FDataSource) then
    FDataSource.RemoveFreeNotification(Self);
  FDataSource := Value;
  FDesignDataLink.DataSource := FDataSource;
  if Assigned(FDataSource) then
    FDataSource.FreeNotification(Self);
  RefreshDesignPreview;
end;

procedure TUniListView.SetDesignPreviewMode(
  const Value: TUniDesignPreviewMode);
begin
  if FDesignPreviewMode = Value then
    Exit;
  FDesignPreviewMode := Value;
  RefreshDesignPreview;
end;

procedure TUniListView.SetDesignPreviewRows(const Value: Integer);
var
  NewValue: Integer;
begin
  NewValue := EnsureRange(Value, 1, MAX_DESIGN_PREVIEW_ROWS);
  if FDesignPreviewRows = NewValue then
    Exit;
  FDesignPreviewRows := NewValue;
  RefreshDesignPreview;
end;

procedure TUniListView.SetFontFamily(const Value: string);
begin
  if SameText(FFontFamily, Trim(Value)) then
    Exit;
  FFontFamily := Trim(Value);
  FFontTypeface := nil;
  FTitleMeasureFont := nil;
  InvalidateCardHeightCache;
  InvalidateAutoTitleWidth;
  InvalidateLayout;
end;

procedure TUniListView.SetFontSize(const Value: Single);
var
  NewValue: Single;
begin
  NewValue := EnsureRange(Value, MIN_FONT_SIZE, MAX_FONT_SIZE);
  if SameValue(FFontSize, NewValue) then
    Exit;
  FFontSize := NewValue;
  InvalidateCardHeightCache;
  InvalidateAutoTitleWidth;
  InvalidateLayout;
end;

procedure TUniListView.SetTitleFontSize(const Value: Single);
var
  NewValue: Single;
begin
  NewValue := EnsureRange(Value, MIN_FONT_SIZE, MAX_FONT_SIZE);
  if SameValue(FTitleFontSize, NewValue) then
    Exit;
  FTitleFontSize := NewValue;
  FTitleMeasureFont := nil;
  InvalidateCardHeightCache;
  InvalidateAutoTitleWidth;
  InvalidateLayout;
end;

procedure TUniListView.SetDetailFontSize(const Value: Single);
var
  NewValue: Single;
begin
  NewValue := EnsureRange(Value, MIN_FONT_SIZE, MAX_FONT_SIZE);
  if SameValue(FDetailFontSize, NewValue) then
    Exit;
  FDetailFontSize := NewValue;
  InvalidateCardHeightCache;
  InvalidateLayout;
end;

function TUniListView.CreateTextFont(const ASize: Single): IUniFont;
var
  DrawSize: Single;
begin
  if not Assigned(FFontTypeface) and (FFontFamily <> '') then
    FFontTypeface := TUniTypefaceFactory.MakeFromName(FFontFamily,
      TUniFontStyle.Normal);
  if not Assigned(FFontTypeface) then
    FFontTypeface := TUniTypefaceFactory.MakeDefault;
  if FRenderScale > 0 then
    DrawSize := Max(1, Round(ASize * FRenderScale)) / FRenderScale
  else
    DrawSize := ASize;
  Result := TUniFontFactory.Create(FFontTypeface, DrawSize);
end;

function TUniListView.GetTitleMeasureFont: IUniFont;
begin
  if not Assigned(FTitleMeasureFont) then
    FTitleMeasureFont := CreateTextFont(FTitleFontSize);
  Result := FTitleMeasureFont;
end;

function TUniListView.MeasureTitleTextWidth(const AText: string): Single;
begin
  Result := GetTitleMeasureFont.MeasureText(AText);
end;

function TUniListView.CurrentSceneScale: Single;
begin
  if Assigned(Scene) then
    Result := Scene.GetSceneScale
  else
    Result := 1;
end;

procedure TUniListView.DesignDataChanged;
begin
  if (csDesigning in ComponentState) and
     (FDesignPreviewMode = dpmConnectedData) then
    RefreshDesignPreview;
end;

procedure TUniListView.ClearDesignPreview;
begin
  if not FDesignPreviewActive then
    Exit;
  FUpdatingDesignPreview := True;
  try
    FItems.Clear;
    FDesignPreviewActive := False;
  finally
    FUpdatingDesignPreview := False;
  end;
end;

procedure TUniListView.RefreshDesignPreview;
begin
  if FInitializing or FUpdatingDesignPreview then
    Exit;
  if not (csDesigning in ComponentState) then
    Exit;
  if FDesignPreviewMode = dpmNone then
  begin
    ClearDesignPreview;
    Exit;
  end;
  if (FDesignPreviewMode = dpmConnectedData) and
     BuildConnectedDesignData then
    Exit;
  BuildDesignSampleData;
end;

function TUniListView.DesignSampleText(const AColumn: TUniListColumn;
  const ARowIndex: Integer): string;
const
  NAMES: array[0..7] of string = ('John Smith', 'Anna Brown',
    'Michael Chen', 'Sara Wilson', 'David Miller', 'Olivia Martin',
    'Daniel Garcia', 'Emma Davis');
  STATUSES: array[0..3] of string = ('Active', 'Pending', 'Offline',
    'Maintenance');
var
  Name: string;
begin
  Name := LowerCase(AColumn.FieldName + ' ' + AColumn.Caption);
  if ContainsText(Name, 'email') then
    Exit(LowerCase(StringReplace(NAMES[ARowIndex mod Length(NAMES)], ' ',
      '.', [rfReplaceAll])) + '@example.com');
  if ContainsText(Name, 'name') or ContainsText(Name, 'title') then
    Exit(NAMES[ARowIndex mod Length(NAMES)]);
  if ContainsText(Name, 'status') or ContainsText(Name, 'state') then
    Exit(STATUSES[ARowIndex mod Length(STATUSES)]);
  if ContainsText(Name, 'date') or ContainsText(Name, 'time') then
    Exit(FormatDateTime('yyyy-mm-dd', EncodeDate(2026, 1, 15) + ARowIndex));
  if ContainsText(Name, 'amount') or ContainsText(Name, 'price') then
    Exit(FormatFloat('0.00', 1250.50 + ARowIndex * 125.25));
  Result := Format('Value %d', [ARowIndex + 1]);
end;

procedure TUniListView.PopulateDesignCardAliases(
  const AItem: TUniListItem);
var
  Column: TUniListColumn;
  I, RoleIndex: Integer;
  Values: array[0..2] of string;
begin
  RoleIndex := 0;
  for I := 0 to FColumns.Count - 1 do
  begin
    Column := FColumns[I];
    if not Column.VisibleInCards or (Column.CardRole = ucrHidden) then
      Continue;
    Values[RoleIndex] := AItem.FieldAsString(Column.FieldName);
    Inc(RoleIndex);
    if RoleIndex > High(Values) then
      Break;
  end;
  if (FCardTemplate.TitleField <> '') and
     not AItem.ContainsField(FCardTemplate.TitleField) then
    AItem.SetField(FCardTemplate.TitleField, Values[0]);
  if (FCardTemplate.TextField <> '') and
     not AItem.ContainsField(FCardTemplate.TextField) then
    AItem.SetField(FCardTemplate.TextField, Values[1]);
  if (FCardTemplate.DetailField <> '') and
     not AItem.ContainsField(FCardTemplate.DetailField) then
    AItem.SetField(FCardTemplate.DetailField, Values[2]);
end;

procedure TUniListView.BuildDesignSampleData;
const
  TREE_NAMES: array[0..7] of string = ('Servers', 'PostgreSQL', 'Redis',
    'MongoDB', 'Infrastructure', 'API Gateway', 'Workers', 'Backups');
  TREE_PARENTS: array[0..7] of string = ('', 'node-1', 'node-1', 'node-1',
    '', 'node-5', 'node-5', 'node-5');
var
  Column: TUniListColumn;
  Item: TUniListItem;
  I, J: Integer;
  FieldName, TextValue: string;
begin
  FUpdatingDesignPreview := True;
  FItems.BeginUpdate;
  try
    FItems.Clear;
    for I := 0 to FDesignPreviewRows - 1 do
    begin
      Item := FItems.Add;
      for J := 0 to FColumns.Count - 1 do
      begin
        Column := FColumns[J];
        FieldName := Trim(Column.FieldName);
        if FieldName = '' then
          Continue;
        TextValue := DesignSampleText(Column, I);
        case Column.DataType of
          ucdtInteger:
            Item.SetField(FieldName, 10 + I);
          ucdtFloat:
            Item.SetField(FieldName, 1250.50 + I * 125.25);
          ucdtDateTime:
            Item.SetFieldDateTime(FieldName, EncodeDate(2026, 1, 15) + I);
          ucdtBoolean:
            Item.SetField(FieldName, Odd(I));
        else
          Item.SetField(FieldName, TextValue);
        end;
      end;
      if FTreeMode then
      begin
        Item.SetField(FTreeKeyField, Format('node-%d', [I + 1]));
        if I <= High(TREE_PARENTS) then
          Item.SetField(FTreeParentField, TREE_PARENTS[I])
        else
          Item.SetField(FTreeParentField, '');
        if I <= High(TREE_NAMES) then
          Item.SetField(FTreeColumn, TREE_NAMES[I]);
        Item.SetField(FTreeHasChildrenField,
          (I = 0) or (I = 4));
      end;
      PopulateDesignCardAliases(Item);
      if FMultiCheck then
        Item.Checked := Odd(I);
    end;
    FDesignPreviewActive := True;
  finally
    FItems.EndUpdate;
    FUpdatingDesignPreview := False;
  end;
  if FTreeMode then
    ExpandAll;
end;

function TUniListView.BuildConnectedDesignData: Boolean;
var
  Bookmark: TBookmark;
  Column: TUniListColumn;
  DataSet: TDataSet;
  Field: TField;
  Item: TUniListItem;
  I, RowIndex: Integer;
begin
  Result := False;
  DataSet := nil;
  if Assigned(FDataSource) then
    DataSet := FDataSource.DataSet;
  if not Assigned(DataSet) or not DataSet.Active or DataSet.IsEmpty or
     (DataSet.State in dsEditModes) then
    Exit;

  FUpdatingDesignPreview := True;
  DataSet.DisableControls;
  try
    try
      try
        Bookmark := DataSet.Bookmark;
        if Length(Bookmark) = 0 then
          Exit;
        FItems.BeginUpdate;
        try
          FItems.Clear;
          DataSet.First;
          RowIndex := 0;
          while not DataSet.Eof and (RowIndex < FDesignPreviewRows) do
          begin
            Item := FItems.Add;
            for I := 0 to FColumns.Count - 1 do
            begin
              Column := FColumns[I];
              Field := DataSet.FindField(Column.FieldName);
              if not Assigned(Field) or Field.IsNull then
                Continue;
              case Column.DataType of
                ucdtInteger:
                  Item.SetField(Column.FieldName, Field.AsLargeInt);
                ucdtFloat:
                  Item.SetField(Column.FieldName, Field.AsFloat);
                ucdtDateTime:
                  Item.SetFieldDateTime(Column.FieldName, Field.AsDateTime);
                ucdtBoolean:
                  Item.SetField(Column.FieldName, Field.AsBoolean);
              else
                Item.SetField(Column.FieldName, Field.AsString);
              end;
            end;
            PopulateDesignCardAliases(Item);
            if FMultiCheck then
              Item.Checked := Odd(RowIndex);
            Inc(RowIndex);
            DataSet.Next;
          end;
          FDesignPreviewActive := FItems.Count > 0;
          Result := FDesignPreviewActive;
        finally
          FItems.EndUpdate;
        end;
      finally
        if DataSet.Active and (Length(Bookmark) > 0) then
          DataSet.Bookmark := Bookmark;
      end;
    except
      Result := False;
    end;
  finally
    DataSet.EnableControls;
    FUpdatingDesignPreview := False;
  end;
end;

procedure TUniListView.ItemChanged(Sender: TObject; const AItemIndex: Integer;
  const AFieldName: string);
var
  CriterionIndex: Integer;
  TitleColumn: TUniListColumn;
begin
  if SameText(AFieldName, 'checked') and
     (AItemIndex >= 0) and (AItemIndex < FItems.Count) then
  begin
    if FCheckBatch or FApplyingCheckEngine then
      Exit;
    if FTreeCheckMode <> tcmIndependent then
    begin
      ExecuteCheckOperation(AItemIndex, FItems[AItemIndex].CheckState, False);
      Exit;
    end;
    RecalculateCheckedCount;
    Redraw;
    if Assigned(FOnItemCheckChanged) then
      FOnItemCheckChanged(Self, FItems[AItemIndex],
        FItems[AItemIndex].Checked);
    if Assigned(FOnCheckedChanged) then
      FOnCheckedChanged(Self);
    Exit;
  end;
  if (AItemIndex >= 0) and (AItemIndex < Length(FTitleLayouts)) then
  begin
    FTitleLayouts[AItemIndex] := Default(TUniTextLayout);
    FTextLayouts[AItemIndex] := Default(TUniTextLayout);
    FDetailLayouts[AItemIndex] := Default(TUniTextLayout);
  end;
  TitleColumn := CardTitleColumn;
  if SameText(AFieldName, FCardTemplate.TitleField) or
     (Assigned(TitleColumn) and
      SameText(AFieldName, TitleColumn.FieldName)) then
    InvalidateAutoTitleWidth;
  for CriterionIndex := 0 to High(FSortColumnIndices) do
    if (FSortColumnIndices[CriterionIndex] >= 0) and
       (FSortColumnIndices[CriterionIndex] < FColumns.Count) and
       SameText(AFieldName,
         FColumns[FSortColumnIndices[CriterionIndex]].FieldName) then
    begin
      ApplyCurrentSort;
      Break;
    end;
  if (FSearchEngine <> nil) and (FUpdateCount = 0) then
    FSearchEngine.InvalidateItem(AItemIndex);
  if SameText(AFieldName, FTreeKeyField) or
     SameText(AFieldName, FTreeParentField) then
    RebuildTree;
  InvalidateLayout;
end;

function TUniListView.CardTitleColumn: TUniListColumn;
var
  ColumnIndex: Integer;
  Column: TUniListColumn;
begin
  Result := nil;
  for ColumnIndex := 0 to FColumns.Count - 1 do
  begin
    Column := FColumns[ColumnIndex];
    if Column.VisibleInCards and (Column.CardRole = ucrTitle) then
      Exit(Column);
  end;
end;

function TUniListView.ItemTitle(AItem: TUniListItem): string;
var
  Column: TUniListColumn;
begin
  Column := CardTitleColumn;
  Result := ItemTitle(AItem, Column);
end;

function TUniListView.ItemTitle(AItem: TUniListItem;
  ATitleColumn: TUniListColumn): string;
begin
  if Assigned(ATitleColumn) then
    Exit(ColumnDisplayText(AItem, ATitleColumn));
  Result := AItem.FieldAsString(FCardTemplate.TitleField, '');
end;

function TUniListView.ItemText(AItem: TUniListItem): string;
begin
  Result := AItem.FieldAsString(FCardTemplate.TextField, '');
end;

function TUniListView.ItemDetail(AItem: TUniListItem): string;
begin
  Result := AItem.FieldAsString(FCardTemplate.DetailField, '');
end;

function TUniListView.VisibleSearchFields: TArray<string>;
var
  Fields: TList<string>;
  ColumnIndex: Integer;

  procedure AddField(const AFieldName: string);
  var
    ExistingField: string;
  begin
    if AFieldName = '' then
      Exit;
    for ExistingField in Fields do
      if SameText(ExistingField, AFieldName) then
        Exit;
    Fields.Add(AFieldName);
  end;

begin
  Fields := TList<string>.Create;
  try
    if FViewMode = uvmList then
    begin
      for ColumnIndex := 0 to FColumns.Count - 1 do
        if FColumns[ColumnIndex].Visible then
          AddField(FColumns[ColumnIndex].FieldName);
    end
    else if FCardLayout = uclFullWidth then
    begin
      for ColumnIndex := 0 to FColumns.Count - 1 do
        if FColumns[ColumnIndex].VisibleInCards and
           (FColumns[ColumnIndex].CardRole <> ucrHidden) then
          AddField(FColumns[ColumnIndex].FieldName);
    end
    else
    begin
      if FCardTemplate.ShowTitle then
        AddField(FCardTemplate.TitleField);
      if FCardTemplate.ShowText then
        AddField(FCardTemplate.TextField);
      if FCardTemplate.ShowDetail then
        AddField(FCardTemplate.DetailField);
    end;
    Result := Fields.ToArray;
  finally
    Fields.Free;
  end;
end;

procedure TUniListView.ConfigureSearch;
begin
  if (FSearchEngine = nil) or (FItems = nil) then
    Exit;
  FSearchEngine.Configure(FItems, VisibleSearchFields, FFilteredIndices);
end;

function TUniListView.CardDisplayCount: Integer;
begin
  if CardTreeActive then
    Exit(Length(FCardTreeVisibleIndices));
  if (FSearchEngine <> nil) and (FSearchEngine.SearchText <> '') then
    Exit(FSearchEngine.MatchCount);
  Result := FItems.Count;
end;

function TUniListView.CardDisplayItemIndex(
  const ADisplayIndex: Integer): Integer;
begin
  if CardTreeActive then
  begin
    if (ADisplayIndex < 0) or
       (ADisplayIndex >= Length(FCardTreeVisibleIndices)) then
      Exit(-1);
    Exit(FCardTreeVisibleIndices[ADisplayIndex]);
  end;
  if (FSearchEngine <> nil) and (FSearchEngine.SearchText <> '') then
    Exit(FSearchEngine.MatchItemIndex(ADisplayIndex));
  if (ADisplayIndex < 0) or (ADisplayIndex >= FItems.Count) then
    Exit(-1);
  Result := ADisplayIndex;
end;

function TUniListView.CardDisplayIndexOf(const AItemIndex: Integer): Integer;
var
  DisplayIndex: Integer;
begin
  if CardTreeActive then
  begin
    for DisplayIndex := 0 to High(FCardTreeVisibleIndices) do
      if FCardTreeVisibleIndices[DisplayIndex] = AItemIndex then
        Exit(DisplayIndex);
    Exit(-1);
  end;
  if (FSearchEngine = nil) or (FSearchEngine.SearchText = '') then
    Exit(AItemIndex);
  Result := FSearchEngine.MatchIndexOf(AItemIndex);
end;

procedure TUniListView.RebuildSearchTree;
var
  Children: TObjectDictionary<string, TList<Integer>>;
  Included: TDictionary<Integer, Byte>;
  KeyToIndex: TDictionary<string, Integer>;
  LevelList, VisibleList: TList<Integer>;
  Visited: TDictionary<Integer, Byte>;
  ChildList: TList<Integer>;
  ItemIndex, MatchIndex, ParentIndex: Integer;
  KeyValue, ParentKey: string;

  procedure AddBranch(const AItemIndex, ALevel: Integer);
  var
    BranchChildren: TList<Integer>;
    ChildIndex: Integer;
  begin
    if Visited.ContainsKey(AItemIndex) then
      Exit;
    Visited.Add(AItemIndex, 0);
    VisibleList.Add(AItemIndex);
    LevelList.Add(ALevel);
    KeyValue := LowerCase(TreeItemKey(AItemIndex));
    if not Children.TryGetValue(KeyValue, BranchChildren) then
      Exit;
    for ChildIndex in BranchChildren do
      AddBranch(ChildIndex, ALevel + 1);
  end;

begin
  SetLength(FTreeVisibleIndices, 0);
  SetLength(FTreeLevels, 0);
  if (FSearchEngine = nil) or (FItems = nil) or
     (FSearchEngine.SearchText = '') then
    Exit;

  Children := TObjectDictionary<string, TList<Integer>>.Create([doOwnsValues]);
  Included := TDictionary<Integer, Byte>.Create;
  KeyToIndex := TDictionary<string, Integer>.Create;
  LevelList := TList<Integer>.Create;
  VisibleList := TList<Integer>.Create;
  Visited := TDictionary<Integer, Byte>.Create;
  try
    for ItemIndex := 0 to FItems.Count - 1 do
    begin
      KeyValue := LowerCase(TreeItemKey(ItemIndex));
      if KeyValue <> '' then
        KeyToIndex.AddOrSetValue(KeyValue, ItemIndex);
    end;

    for MatchIndex := 0 to FSearchEngine.MatchCount - 1 do
    begin
      ItemIndex := FSearchEngine.MatchItemIndex(MatchIndex);
      while (ItemIndex >= 0) and not Included.ContainsKey(ItemIndex) do
      begin
        Included.Add(ItemIndex, 0);
        ParentKey := LowerCase(TreeItemParentKey(ItemIndex));
        if (ParentKey = '') or
           not KeyToIndex.TryGetValue(ParentKey, ParentIndex) then
          Break;
        ItemIndex := ParentIndex;
      end;
    end;

    for ItemIndex := 0 to FItems.Count - 1 do
    begin
      if not Included.ContainsKey(ItemIndex) then
        Continue;
      ParentKey := LowerCase(TreeItemParentKey(ItemIndex));
      if not KeyToIndex.TryGetValue(ParentKey, ParentIndex) or
         not Included.ContainsKey(ParentIndex) then
        ParentKey := '';
      if not Children.TryGetValue(ParentKey, ChildList) then
      begin
        ChildList := TList<Integer>.Create;
        Children.Add(ParentKey, ChildList);
      end;
      ChildList.Add(ItemIndex);
    end;

    if Children.TryGetValue('', ChildList) then
      for ItemIndex in ChildList do
        AddBranch(ItemIndex, 0);
    for ItemIndex := 0 to FItems.Count - 1 do
      if Included.ContainsKey(ItemIndex) and
         not Visited.ContainsKey(ItemIndex) then
        AddBranch(ItemIndex, 0);
    FTreeVisibleIndices := VisibleList.ToArray;
    FTreeLevels := LevelList.ToArray;
    RebuildCardTreeVisibleSet;
  finally
    Visited.Free;
    VisibleList.Free;
    LevelList.Free;
    KeyToIndex.Free;
    Included.Free;
    Children.Free;
  end;
end;

procedure TUniListView.SaveSearchTreeState;
begin
  if FSearchTreeSnapshotActive or not FTreeMode or
     (FViewMode <> uvmList) then
    Exit;
  FSearchTreeExpandedKeys.Assign(FTreeExpandedKeys);
  FSearchTreeSnapshotActive := True;
end;

procedure TUniListView.RestoreSearchTreeState;
begin
  if not FSearchTreeSnapshotActive then
    Exit;
  FTreeExpandedKeys.Assign(FSearchTreeExpandedKeys);
  FSearchTreeExpandedKeys.Clear;
  FSearchTreeSnapshotActive := False;
  RebuildTree;
end;

procedure TUniListView.ExpandTreePathToItem(const AItemIndex: Integer);
var
  ParentKey, ParentParentKey: string;
  ParentIndex, ItemIndex: Integer;
  VisitedKeys: TStringList;
begin
  if not FTreeMode or (FViewMode <> uvmList) or
     (AItemIndex < 0) or (AItemIndex >= FItems.Count) then
    Exit;
  SaveSearchTreeState;
  ParentKey := TreeItemParentKey(AItemIndex);
  VisitedKeys := TStringList.Create;
  try
    VisitedKeys.CaseSensitive := False;
    while ParentKey <> '' do
    begin
      if VisitedKeys.IndexOf(ParentKey) >= 0 then
        Break;
      VisitedKeys.Add(ParentKey);
      if FTreeExpandedKeys.IndexOf(ParentKey) < 0 then
        FTreeExpandedKeys.Add(ParentKey);
      ParentIndex := -1;
      for ItemIndex := 0 to FItems.Count - 1 do
        if SameText(TreeItemKey(ItemIndex), ParentKey) then
        begin
          ParentIndex := ItemIndex;
          Break;
        end;
      if ParentIndex < 0 then
        Break;
      ParentParentKey := TreeItemParentKey(ParentIndex);
      ParentKey := ParentParentKey;
    end;
  finally
    VisitedKeys.Free;
  end;
  RebuildTree;
  InvalidateLayout;
end;

procedure TUniListView.SearchChanged(Sender: TObject);
begin
  if FTreeMode and (FViewMode = uvmList) then
    RebuildTree;
  InvalidateLayout;
  DoSearchChanged;
  if Assigned(FOnSearchChanged) then
    FOnSearchChanged(Self);
end;

procedure TUniListView.DoSearchChanged;
begin
end;

procedure TUniListView.SearchCurrentChanged(Sender: TObject;
  const AItemIndex: Integer);
begin
  if AItemIndex < 0 then
    Exit;
  ExpandTreePathToItem(AItemIndex);
  SelectedIndex := AItemIndex;
  ScrollToItem(AItemIndex);
end;

procedure TUniListView.SetSearchText(const Value: string);
begin
  if FSearchEngine.SearchText = Value then
    Exit;
  if (FSearchEngine.SearchText = '') and (Value <> '') then
    SaveSearchTreeState;
  FSearchEngine.SearchText := Value;
  if Value = '' then
    RestoreSearchTreeState;
end;

function TUniListView.GetSearchText: string;
begin
  Result := FSearchEngine.SearchText;
end;

procedure TUniListView.SetSearchOptions(const Value: TUniSearchOptions);
begin
  FSearchEngine.Options := Value;
end;

function TUniListView.GetSearchOptions: TUniSearchOptions;
begin
  Result := FSearchEngine.Options;
end;

function TUniListView.GetSearchMatchCount: Integer;
begin
  Result := FSearchEngine.MatchCount;
end;

function TUniListView.GetSearchRunning: Boolean;
begin
  Result := FSearchEngine.Running;
end;

procedure TUniListView.FindNext;
begin
  FSearchEngine.FindNext;
end;

procedure TUniListView.FindPrevious;
begin
  FSearchEngine.FindPrevious;
end;

procedure TUniListView.ClearSearch;
begin
  SearchText := '';
end;

procedure TUniListView.DrawSearchHighlights(const ACanvas: IUniCanvas;
  const AItemIndex: Integer; const AText: string; const AX, ABaseline,
  AFontSize: Single);
const
  HIGHLIGHT_BLEND = 0.50;
  HIGHLIGHT_HORIZONTAL_PADDING = 1.0;
  HIGHLIGHT_VERTICAL_PADDING = 2.0;
var
  Font: IUniFont;
  Haystack, Needle: string;
  MatchLeft, MatchRight: Single;
  MatchPosition, SearchPosition: Integer;
  Paint: IUniPaint;
begin
  if (FSearchEngine = nil) or (FSearchEngine.SearchText = '') or
     not FSearchEngine.IsMatch(AItemIndex) or (AText = '') then
    Exit;
  Haystack := AText;
  Needle := FSearchEngine.SearchText;
  if soIgnoreCase in FSearchEngine.Options then
  begin
    Haystack := LowerCase(Haystack);
    Needle := LowerCase(Needle);
  end;
  SearchPosition := 1;
  MatchPosition := PosEx(Needle, Haystack, SearchPosition);
  if MatchPosition = 0 then
    Exit;

  Font := CreateTextFont(AFontSize);
  Paint := TUniPaintFactory.Create;
  Paint.AntiAlias := True;
  Paint.Style := TUniPaintStyle.Fill;
  Paint.Color := UniBlendColor(FCardColor, FAccentColor, HIGHLIGHT_BLEND);
  while MatchPosition > 0 do
  begin
    MatchLeft := AX + Font.MeasureText(
      Copy(AText, 1, MatchPosition - 1));
    MatchRight := AX + Font.MeasureText(
      Copy(AText, 1, MatchPosition + Length(Needle) - 1));
    ACanvas.DrawRoundRect(RectF(
      MatchLeft - HIGHLIGHT_HORIZONTAL_PADDING,
      ABaseline - AFontSize - HIGHLIGHT_VERTICAL_PADDING,
      MatchRight + HIGHLIGHT_HORIZONTAL_PADDING,
      ABaseline + HIGHLIGHT_VERTICAL_PADDING),
      HIGHLIGHT_VERTICAL_PADDING, HIGHLIGHT_VERTICAL_PADDING, Paint);
    SearchPosition := MatchPosition + Max(1, Length(Needle));
    MatchPosition := PosEx(Needle, Haystack, SearchPosition);
  end;
end;

function TUniListView.ItemIcon(AItem: TUniListItem): TUniVectorIcon;
var
  IconName: string;
  IconValue: Integer;
begin
  Result := FCardTemplate.Icon;
  if FCardTemplate.IconField = '' then
    Exit;
  IconName := LowerCase(AItem.FieldAsString(FCardTemplate.IconField, ''));
  if IconName = '' then Exit;
  if TryStrToInt(IconName, IconValue) and
     (IconValue >= Ord(Low(TUniVectorIcon))) and
     (IconValue <= Ord(High(TUniVectorIcon))) then
    Exit(TUniVectorIcon(IconValue));
  if IconName = 'edit' then Result := uviEdit
  else if IconName = 'delete' then Result := uviDelete
  else if IconName = 'open' then Result := uviOpen
  else if IconName = 'more' then Result := uviMore
  else if IconName = 'server' then Result := uviServer
  else if IconName = 'check' then Result := uviCheck
  else if (IconName = 'database') or (IconName = 'db') then
    Result := uviDatabase
  else if IconName = 'chevronright' then Result := uviChevronRight
  else if IconName = 'chevrondown' then Result := uviChevronDown;
end;

function TUniListView.ItemSecondaryIcon(AItem: TUniListItem): TUniVectorIcon;
var
  IconName: string;
  IconValue: Integer;
begin
  Result := uviNone;
  IconName := LowerCase(AItem.FieldAsString('icon2', ''));
  if IconName = '' then Exit;
  if TryStrToInt(IconName, IconValue) and
     (IconValue >= Ord(Low(TUniVectorIcon))) and
     (IconValue <= Ord(High(TUniVectorIcon))) then
    Exit(TUniVectorIcon(IconValue));
  if IconName = 'edit' then Result := uviEdit
  else if IconName = 'delete' then Result := uviDelete
  else if IconName = 'open' then Result := uviOpen
  else if IconName = 'more' then Result := uviMore
  else if IconName = 'server' then Result := uviServer
  else if IconName = 'check' then Result := uviCheck
  else if (IconName = 'database') or (IconName = 'db') then
    Result := uviDatabase
  else if IconName = 'chevronright' then Result := uviChevronRight
  else if IconName = 'chevrondown' then Result := uviChevronDown
  else if IconName = 'chevronup' then Result := uviChevronUp
  else if IconName = 'chevronleft' then Result := uviChevronLeft;
end;
function TUniListView.ActionVisible(AItem: TUniListItem;
  AAction: TUniCardAction): Boolean;
begin
  Result := AAction.Visible;
  if Result and (AAction.VisibleField <> '') then
    Result := AItem.FieldAsBoolean(AAction.VisibleField, True);
end;

function TUniListView.ActionDisplayed(const AItemIndex: Integer;
  AAction: TUniCardAction): Boolean;
begin
  Result := (AItemIndex >= 0) and (AItemIndex < FItems.Count) and
    ActionVisible(FItems[AItemIndex], AAction);
  if not Result then
    Exit;
  case AAction.Visibility of
    ucavAlways:
      Exit(True);
    ucavOnHover:
      Exit(FHotHit.ItemIndex = AItemIndex);
  end;
  if FActionVisibility = uavOnHover then
    Result := FHotHit.ItemIndex = AItemIndex;
end;
function TUniListView.ActionEnabled(AItem: TUniListItem;
  AAction: TUniCardAction): Boolean;
begin
  Result := AAction.Enabled and AItem.Enabled;
  if Result and (AAction.EnabledField <> '') then
    Result := AItem.FieldAsBoolean(AAction.EnabledField, True);
  if Result and Assigned(AAction.Action) then
    Result := AAction.Action.Enabled;
end;

function TUniListView.AreActionsVisibleForItem(
  const AItemIndex: Integer): Boolean;
var
  ActionIndex: Integer;
begin
  if not FCardTemplate.ShowActions or (AItemIndex < 0) or
     (AItemIndex >= FItems.Count) then
    Exit(False);
  Result := False;
  for ActionIndex := 0 to FActions.Count - 1 do
    if ActionDisplayed(AItemIndex, FActions[ActionIndex]) then
      Exit(True);
end;

procedure TUniListView.ClearHoverState;
var
  NeedsRedraw: Boolean;
begin
  NeedsRedraw := (FHotHit.ItemIndex >= 0) or
    (FHotHit.Kind = uchAction);
  FHotHit := TUniCardHit.None;
  if FPressedHit.Kind = uchAction then
  begin
    FPressedHit := TUniCardHit.None;
    FMousePressed := False;
  end;
  if NeedsRedraw and (FUpdateCount = 0) then
    Redraw;
end;

function TUniListView.AddItem(const ATitle, AText, ADetail: string): TUniListItem;
begin
  Result := FItems.Add;
  Result.SetField(FCardTemplate.TitleField, ATitle);
  Result.SetField(FCardTemplate.TextField, AText);
  Result.SetField(FCardTemplate.DetailField, ADetail);
  InvalidateAutoTitleWidth;
  InvalidateLayout;
end;

procedure TUniListView.BeginUpdate;
begin
  Inc(FUpdateCount);
  FItems.BeginUpdate;
end;

procedure TUniListView.EndUpdate;
begin
  if FUpdateCount = 0 then
    Exit;

  try
    FItems.EndUpdate;
  finally
    Dec(FUpdateCount);
    if FUpdateCount = 0 then
    begin
      EnsureLayout;
      Redraw;
    end;
  end;
end;

procedure TUniListView.Clear;
begin
  FItems.Clear;
  FSelectedIndex := -1;
  ClearTextSelection;
end;

procedure TUniListView.ClearTextSelection;
begin
  FSelectedTextHit := TUniCardHit.None;
  FSelectedText := '';
  if FUpdateCount = 0 then
    Redraw;
end;

function TUniListView.CanPanWithMouse: Boolean;
begin
  Result := FPanMode in [upmMouse, upmMouseAndTouch];
end;

function TUniListView.CardChromeWidth: Single;
var
  ActionIndex: Integer;
  ActionWidth, MaximumActionWidth: Single;
  Item: TUniListItem;
begin
  Result := FCardTemplate.InnerPadding * 2;
  if CheckBoxesVisible then
    Result := Result + GRID_CARD_CHECKBOX_SIZE + GRID_CARD_CHECKBOX_GAP;
  if FCardTemplate.ShowIcon then
    Result := Result + FCardTemplate.IconBoxSize + GRID_CARD_ICON_GAP;
  if not FCardTemplate.ShowActions then
    Exit;

  MaximumActionWidth := 0;
  if Assigned(FItems) and (FItems.Count > 0) then
  begin
    for Item in FItems do
    begin
      ActionWidth := 0;
      for ActionIndex := 0 to FActions.Count - 1 do
        if ActionVisible(Item, FActions[ActionIndex]) then
          ActionWidth := ActionWidth + FActions[ActionIndex].Width +
            GRID_CARD_ACTION_GAP;
      MaximumActionWidth := Max(MaximumActionWidth, ActionWidth);
    end;
  end
  else
    for ActionIndex := 0 to FActions.Count - 1 do
      if FActions[ActionIndex].Visible and
         (FActions[ActionIndex].VisibleField = '') then
        MaximumActionWidth := MaximumActionWidth +
          FActions[ActionIndex].Width + GRID_CARD_ACTION_GAP;
  Result := Result + MaximumActionWidth;
end;

procedure TUniListView.InvalidateAutoTitleWidth;
begin
  FAutoTitleWidthDirty := True;
end;

procedure TUniListView.InvalidateCardHeightCache;
begin
  FResizeHeightPending := False;
  if Assigned(FResizeHeightTimer) then
    FResizeHeightTimer.Enabled := False;
  FPreparedCardWidth := -1;
  FPreparedTextWidth := -1;
end;

procedure TUniListView.ResizeHeightTimer(Sender: TObject);
begin
  FResizeHeightTimer.Enabled := False;
  if not FResizeHeightPending then
    Exit;
  FResizeHeightPending := False;
  FPreparedCardWidth := -1;
  FPreparedTextWidth := -1;
  InvalidateLayout;
end;

procedure TUniListView.InvalidateLayout(const AGeometryOnly: Boolean);
begin
  UniPerfInc(upcRequestRepaint);
  if FLayoutDirty then
    FGeometryOnlyLayout := FGeometryOnlyLayout and AGeometryOnly
  else
    FGeometryOnlyLayout := AGeometryOnly;
  FLayoutDirty := True;
  if FUpdateCount = 0 then
    Redraw;
end;

procedure TUniListView.EnsureLayout;
begin
  if FInitializing or (FItems = nil) then
    Exit;
  if (FCardSizingMode = ucsmAutoByTitle) and
     not SameValue(FAutoTitleSceneScale, CurrentSceneScale) then
  begin
    InvalidateAutoTitleWidth;
    FLayoutDirty := True;
  end;
  if not FLayoutDirty then
    Exit;

  RecalculateLayout;
  FLayoutDirty := False;
end;

procedure TUniListView.PrepareTextLayouts;
var
  ItemIndex: Integer;
  TextWidth: Single;
  RebuildAll: Boolean;
begin
  if FCardLayout = uclFullWidth then
    Exit;
  if FResizeHeightPending and
     (FPreparedCardWidth >= 0) and
     (Length(FTitleLayouts) = FItems.Count) and
     (Length(FTextLayouts) = FItems.Count) and
     (Length(FDetailLayouts) = FItems.Count) then
    Exit;
  TextWidth := TextAvailableWidth(RectF(0, 0, FActualCardWidth, FCardHeight));
  RebuildAll := (Length(FTitleLayouts) <> FItems.Count) or
    not SameValue(FPreparedCardWidth, FActualCardWidth) or
    not SameValue(FPreparedTextWidth, TextWidth);

  if RebuildAll then
  begin
    if Length(FTitleLayouts) <> FItems.Count then
      SetLength(FTitleLayouts, FItems.Count);
    if Length(FTextLayouts) <> FItems.Count then
      SetLength(FTextLayouts, FItems.Count);
    if Length(FDetailLayouts) <> FItems.Count then
      SetLength(FDetailLayouts, FItems.Count);
    for ItemIndex := 0 to FItems.Count - 1 do
    begin
      FTitleLayouts[ItemIndex] := Default(TUniTextLayout);
      FTextLayouts[ItemIndex] := Default(TUniTextLayout);
      FDetailLayouts[ItemIndex] := Default(TUniTextLayout);
    end;
    FPreparedCardWidth := FActualCardWidth;
    FPreparedTextWidth := TextWidth;
  end;

  if not FCardTemplate.AutoCardHeight then
    Exit;
  for ItemIndex := 0 to FItems.Count - 1 do
    PrepareItemTextLayout(ItemIndex, TextWidth);
end;

procedure TUniListView.PrepareItemTextLayout(const AItemIndex: Integer;
  const ATextWidth: Single);
var
  DetailValue, TextValueLocal, TitleValue: string;
  Item: TUniListItem;
begin
  if (AItemIndex < 0) or (AItemIndex >= FItems.Count) or
     (AItemIndex >= Length(FTitleLayouts)) then
    Exit;
  Item := FItems[AItemIndex];
  TitleValue := ItemTitle(Item);
  TextValueLocal := ItemText(Item);
  DetailValue := ItemDetail(Item);

  if FCardTemplate.ShowTitle and (TitleValue <> '') and
     (Length(FTitleLayouts[AItemIndex].Lines) = 0) then
    FTitleLayouts[AItemIndex] := BuildMeasuredTextLayout(TitleValue,
      ATextWidth, FTitleFontSize, FCardTemplate.WordWrap,
      FCardTemplate.Ellipsis, FCardTemplate.TitleMaxLines,
      MeasureTitleTextWidth);

  if FCardTemplate.ShowText and (TextValueLocal <> '') and
     (Length(FTextLayouts[AItemIndex].Lines) = 0) then
    FTextLayouts[AItemIndex] := BuildTextLayout(TextValueLocal, ATextWidth,
      FFontSize, FCardTemplate.WordWrap, FCardTemplate.Ellipsis,
      FCardTemplate.TextMaxLines);

  if FCardTemplate.ShowDetail and (DetailValue <> '') and
     (Length(FDetailLayouts[AItemIndex].Lines) = 0) then
    FDetailLayouts[AItemIndex] := BuildTextLayout(DetailValue, ATextWidth,
      FDetailFontSize, FCardTemplate.WordWrap, FCardTemplate.Ellipsis,
      FCardTemplate.DetailMaxLines);
end;

function TUniListView.MeasureWidestTitleWord(const ATitle: string;
  const AFont: IUniFont): Single;
var
  CharacterIndex, WordStart: Integer;
  WordValue: string;
begin
  Result := 0;
  if (ATitle = '') or not Assigned(AFont) then
    Exit;
  WordStart := 1;
  for CharacterIndex := 1 to Length(ATitle) do
    if CharInSet(ATitle[CharacterIndex], [#9, #10, #13, ' ', '-']) then
    begin
      if CharacterIndex > WordStart then
      begin
        WordValue := Copy(ATitle, WordStart, CharacterIndex - WordStart);
        Result := Max(Result, AFont.MeasureText(WordValue));
      end;
      WordStart := CharacterIndex + 1;
    end;
  if WordStart <= Length(ATitle) then
  begin
    WordValue := Copy(ATitle, WordStart, MaxInt);
    Result := Max(Result, AFont.MeasureText(WordValue));
  end;
end;

function TUniListView.MeasureAutoTitleCardWidth: Single;
var
  TextFont, TitleFont: IUniFont;
  Item: TUniListItem;
  TextValueLocal, TitleValue: string;
  MaximumWidth, MinimumWidth, RequiredTextWidth: Single;
  TitleColumn: TUniListColumn;
begin
  if not FAutoTitleWidthDirty then
    Exit(FAutoTitleCardWidth);

  MinimumWidth := Max(1, FCardMinWidth);
  MaximumWidth := Max(MinimumWidth, FCardMaxWidth);
  RequiredTextWidth := 0;
  TitleFont := GetTitleMeasureFont;
  TextFont := CreateTextFont(FFontSize);
  TitleColumn := CardTitleColumn;
  for Item in FItems do
  begin
    if FCardTemplate.ShowTitle then
    begin
      TitleValue := ItemTitle(Item, TitleColumn);
      RequiredTextWidth := Max(RequiredTextWidth,
        MeasureWidestTitleWord(TitleValue, TitleFont));
    end;

    if FCardTemplate.ShowText then
    begin
      TextValueLocal := ItemText(Item);
      RequiredTextWidth := Max(RequiredTextWidth,
        MeasureWidestTitleWord(TextValueLocal, TextFont));
    end;

  end;

  if RequiredTextWidth <= 0 then
    FAutoTitleCardWidth := MinimumWidth
  else
    FAutoTitleCardWidth := EnsureRange(
      RequiredTextWidth + CardChromeWidth,
      MinimumWidth, MaximumWidth);
  FAutoTitleWidthDirty := False;
  FAutoTitleSceneScale := CurrentSceneScale;
  Result := FAutoTitleCardWidth;
end;

function TUniListView.TextAvailableWidth(const R: TRectF): Single;
begin
  Result := Max(20, R.Width - CardChromeWidth);
end;

function TUniListView.FullWidthUsesRoles: Boolean;
var
  ColumnIndex: Integer;
  Column: TUniListColumn;
begin
  for ColumnIndex := 0 to FColumns.Count - 1 do
  begin
    Column := FColumns[ColumnIndex];
    if Column.VisibleInCards and (Column.CardRole = ucrTitle) then
      Exit(True);
  end;
  Result := False;
end;

procedure TUniListView.FullWidthValues(AItem: TUniListItem;
  out ATitle, ASubtitle, ADetail, ATrailing: string;
  out ATitleColumn, ASubtitleColumn, ADetailColumn,
  ATrailingColumn: TUniListColumn);
var
  ColumnIndex: Integer;
  Column: TUniListColumn;
  ValueText: string;

  procedure AppendValue(var ATarget: string; const AValue: string);
  begin
    if AValue = '' then
      Exit;
    if ATarget <> '' then
      ATarget := ATarget + ' · ';
    ATarget := ATarget + AValue;
  end;

begin
  ATitle := '';
  ASubtitle := '';
  ADetail := '';
  ATrailing := '';
  ATitleColumn := nil;
  ASubtitleColumn := nil;
  ADetailColumn := nil;
  ATrailingColumn := nil;
  if not FullWidthUsesRoles then
  begin
    ATitle := ItemTitle(AItem);
    ASubtitle := ItemText(AItem);
    ADetail := ItemDetail(AItem);
    Exit;
  end;

  for ColumnIndex := 0 to FColumns.Count - 1 do
  begin
    Column := FColumns[ColumnIndex];
    if not Column.VisibleInCards or
       (Column.CardRole in [ucrAuto, ucrHidden]) then
      Continue;
    ValueText := ColumnDisplayText(AItem, Column);
    if ValueText = '' then
      Continue;
    case Column.CardRole of
      ucrTitle:
        if ATitleColumn = nil then
        begin
          ATitle := ValueText;
          ATitleColumn := Column;
        end;
      ucrSubtitle:
        begin
          AppendValue(ASubtitle, ValueText);
          if ASubtitleColumn = nil then
            ASubtitleColumn := Column;
        end;
      ucrDetail:
        begin
          if Column.Caption <> '' then
            ValueText := Column.Caption + ': ' + ValueText;
          AppendValue(ADetail, ValueText);
          if ADetailColumn = nil then
            ADetailColumn := Column;
        end;
      ucrTrailing:
        if ATrailingColumn = nil then
        begin
          ATrailing := ValueText;
          ATrailingColumn := Column;
        end;
    end;
  end;
end;

function TUniListView.MeasureFullWidthCardHeight(
  const AItemIndex: Integer; const AAvailableWidth: Single;
  const AForceContentHeight: Boolean): Single;
var
  ActionWidth, AvailableTextWidth, ContentHeight, TrailingWidth: Single;
  ActionIndex: Integer;
  DetailLayout, SubtitleLayout, TitleLayout: TUniTextLayout;
  TitleValue, SubtitleValue, DetailValue, TrailingValue: string;
  TitleColumn, SubtitleColumn, DetailColumn, TrailingColumn: TUniListColumn;
begin
  if not FCardTemplate.AutoCardHeight and not AForceContentHeight then
    Exit(FCardHeight);
  if (AItemIndex < 0) or (AItemIndex >= FItems.Count) then
    Exit(FCardHeight);

  FullWidthValues(FItems[AItemIndex], TitleValue, SubtitleValue, DetailValue,
    TrailingValue, TitleColumn, SubtitleColumn, DetailColumn, TrailingColumn);
  if AAvailableWidth > 0 then
    AvailableTextWidth := AAvailableWidth
  else
    AvailableTextWidth := FActualCardWidth;
  AvailableTextWidth := AvailableTextWidth -
    FULL_WIDTH_CARD_HORIZONTAL_PADDING * 2;
  if CheckBoxesVisible then
    AvailableTextWidth := AvailableTextWidth - FULL_WIDTH_CARD_CHECKBOX_SPACE;
  if FCardTemplate.ShowIcon then
    AvailableTextWidth := AvailableTextWidth -
      FCardTemplate.IconBoxSize - FULL_WIDTH_CARD_ICON_GAP;
  ActionWidth := 0;
  if FCardTemplate.ShowActions then
    for ActionIndex := 0 to FActions.Count - 1 do
      if ActionVisible(FItems[AItemIndex], FActions[ActionIndex]) then
      begin
        if ActionWidth > 0 then
          ActionWidth := ActionWidth + FULL_WIDTH_CARD_ACTION_GAP;
        ActionWidth := ActionWidth + FActions[ActionIndex].Width;
      end;
  if ActionWidth > 0 then
    AvailableTextWidth := AvailableTextWidth -
      ActionWidth - FULL_WIDTH_CARD_GAP;
  if TrailingValue <> '' then
  begin
    TrailingWidth := EnsureRange(
      EstimateTextWidth(TrailingValue, FFontSize),
      FULL_WIDTH_CARD_TRAILING_MIN_WIDTH,
      FActualCardWidth * FULL_WIDTH_CARD_TRAILING_MAX_RATIO);
    AvailableTextWidth := AvailableTextWidth -
      TrailingWidth - FULL_WIDTH_CARD_GAP;
  end;
  AvailableTextWidth := Max(1, AvailableTextWidth);

  ContentHeight := 0;
  if TitleValue <> '' then
  begin
    TitleLayout := BuildTextLayout(TitleValue, AvailableTextWidth,
      FTitleFontSize, False, True, FULL_WIDTH_CARD_TITLE_MAX_LINES);
    ContentHeight := TitleLayout.Height;
  end;
  if SubtitleValue <> '' then
  begin
    SubtitleLayout := BuildTextLayout(SubtitleValue, AvailableTextWidth,
      FFontSize, FCardTemplate.WordWrap, FCardTemplate.Ellipsis,
      FULL_WIDTH_CARD_SUBTITLE_MAX_LINES);
    if ContentHeight > 0 then
      ContentHeight := ContentHeight + FULL_WIDTH_CARD_TITLE_GAP;
    ContentHeight := ContentHeight + SubtitleLayout.Height;
  end;
  if DetailValue <> '' then
  begin
    DetailLayout := BuildTextLayout(DetailValue, AvailableTextWidth,
      FDetailFontSize, FCardTemplate.WordWrap, FCardTemplate.Ellipsis,
      FULL_WIDTH_CARD_DETAIL_MAX_LINES);
    if ContentHeight > 0 then
      ContentHeight := ContentHeight + FULL_WIDTH_CARD_TITLE_GAP;
    ContentHeight := ContentHeight + DetailLayout.Height;
  end;
  if FCardTemplate.ShowIcon then
    ContentHeight := Max(ContentHeight, FCardTemplate.IconBoxSize);
  Result := Max(20, ContentHeight) +
    FULL_WIDTH_CARD_VERTICAL_PADDING * 2;
  if FCardTemplate.MaxCardHeight > 0 then
    Result := Min(Result, FCardTemplate.MaxCardHeight);
end;

function TUniListView.MeasureCardHeight(const AIndex: Integer): Single;
var
  Item: TUniListItem;
  H: Single;
begin
  if FCardLayout = uclFullWidth then
    Exit(MeasureFullWidthCardHeight(AIndex));
  if not FCardTemplate.AutoCardHeight then
    Exit(FCardHeight);

  Item := FItems[AIndex];
  H := FCardTemplate.InnerPadding * 2;

  if FCardTemplate.ShowTitle and (ItemTitle(Item) <> '') then
    H := H + FTitleLayouts[AIndex].Height;

  if FCardTemplate.ShowText and (ItemText(Item) <> '') then
  begin
    if H > FCardTemplate.InnerPadding * 2 then
      H := H + FCardTemplate.TextGap;
    H := H + FTextLayouts[AIndex].Height;
  end;

  if FCardTemplate.ShowDetail and (ItemDetail(Item) <> '') then
  begin
    if H > FCardTemplate.InnerPadding * 2 then
      H := H + FCardTemplate.TextGap;
    H := H + FDetailLayouts[AIndex].Height;
  end;

  if FCardTemplate.ShowIcon then
    H := Max(H, FCardTemplate.IconBoxSize + FCardTemplate.InnerPadding * 2);

  Result := Max(FCardHeight, H);
  if FCardTemplate.MaxCardHeight > 0 then
    Result := Min(Result, FCardTemplate.MaxCardHeight);
end;

function TUniListView.CardWidthForViewport(
  const AViewportWidth: Single): Single;
var
  Available: Single;
  Candidate, NextCandidate: Single;
  ColumnCount: Integer;
begin
  Available := Max(1, AViewportWidth - FContentPadding * 2);
  if FCardLayout = uclFullWidth then
    Exit(Max(1, Available - FULL_WIDTH_CARD_SCROLLBAR_RESERVE));

  case FCardSizingMode of
    ucsmFixed:
      Result := FCardWidth;
    ucsmStretchColumns:
      begin
        ColumnCount := Max(1, FFixedColumnCount);
        Result := (Available - (ColumnCount - 1) * FHorizontalGap) /
          ColumnCount;
      end;
    ucsmAutoByTitle:
      begin
        Candidate := MeasureAutoTitleCardWidth;
        if FContentFlow = ucfWrap then
        begin
          ColumnCount := Max(1, Floor((Available + FHorizontalGap) /
            (Candidate + FHorizontalGap)));
          Result := (Available - (ColumnCount - 1) * FHorizontalGap) /
            ColumnCount;
          while Result > FCardMaxWidth do
          begin
            NextCandidate := (Available - ColumnCount * FHorizontalGap) /
              (ColumnCount + 1);
            if NextCandidate < FCardMinWidth then
              Break;
            Inc(ColumnCount);
            Result := NextCandidate;
          end;
          Result := Min(Result, FCardMaxWidth);
        end
        else
          Result := Min(Available, Max(Candidate, FCardWidth));
      end;
  else
    if FContentFlow = ucfNoWrap then
      Result := EnsureRange(FCardWidth, FCardMinWidth, FCardMaxWidth)
    else
    begin
      ColumnCount := Max(1, Floor((Available + FHorizontalGap) /
        (FCardMinWidth + FHorizontalGap)));
      Candidate := (Available - (ColumnCount - 1) * FHorizontalGap) /
        ColumnCount;
      while (ColumnCount > 1) and (Candidate > FCardMaxWidth) do
      begin
        Inc(ColumnCount);
        Candidate := (Available - (ColumnCount - 1) * FHorizontalGap) /
          ColumnCount;
      end;
      Result := Min(FCardMaxWidth, Max(FCardMinWidth, Candidate));
    end;
  end;
end;

function TUniListView.HasWrappingCardContent: Boolean;
begin
  Result := (FItems <> nil) and (FItems.Count > 0) and
    FCardTemplate.AutoCardHeight and FCardTemplate.WordWrap and
    (FCardTemplate.ShowTitle or FCardTemplate.ShowText or
      FCardTemplate.ShowDetail);
end;

procedure TUniListView.RecalculateLayout;
var
  Available, Candidate, NextCandidate, TextWidth, X, TopValue: Single;
  DisplayCount, I, ItemIndex, Row, RowCount: Integer;
  GeometryOnly: Boolean;
  ReuseItemHeights: Boolean;
  CacheSizeChanged: Boolean;
  TextMetricsChanged: Boolean;
begin
  if FInitializing or (FItems = nil) then
    Exit;
  GeometryOnly := FGeometryOnlyLayout;
  FGeometryOnlyLayout := False;
  if FViewMode = uvmList then
  begin
    CalculateListColumns;
    FColumnCount := 1;
    FActualCardWidth := Width;
    if not GeometryOnly or FListAutoRowHeight then
      CalculateListRows;
    if DisplayItemCount > 0 then
      FContentHeight := ListBodyTop + FContentPadding +
        FListRowTops[High(FListRowTops)] + FListRowHeights[High(FListRowHeights)]
    else
      FContentHeight := ListBodyTop + FContentPadding * 2;
    ClampScroll;
    Exit;
  end;
  Available := Max(1, Width - FContentPadding * 2);
  if FCardLayout = uclFullWidth then
  begin
    FColumnCount := 1;
    FActualCardWidth := Max(1, Available - FULL_WIDTH_CARD_SCROLLBAR_RESERVE);
  end
  else case FCardSizingMode of
    ucsmFixed:
      begin
        FActualCardWidth := FCardWidth;
        if FContentFlow = ucfWrap then
          FColumnCount := Max(1, Floor((Available + FHorizontalGap) /
            (FActualCardWidth + FHorizontalGap)))
        else
          FColumnCount := 1;
      end;
    ucsmStretchColumns:
      begin
        FColumnCount := Max(1, FFixedColumnCount);
        FActualCardWidth := (Available - (FColumnCount - 1) * FHorizontalGap) /
          FColumnCount;
      end;
    ucsmAutoByTitle:
      begin
        { The measured title width is the responsive grid minimum only.
          The actual card width still fills the complete available row. }
        Candidate := MeasureAutoTitleCardWidth;
        if FContentFlow = ucfWrap then
        begin
          FColumnCount := Max(1, Floor((Available + FHorizontalGap) /
            (Candidate + FHorizontalGap)));
          FActualCardWidth :=
            (Available - (FColumnCount - 1) * FHorizontalGap) / FColumnCount;
          while FActualCardWidth > FCardMaxWidth do
          begin
            NextCandidate := (Available - FColumnCount * FHorizontalGap) /
              (FColumnCount + 1);
            if NextCandidate < FCardMinWidth then
              Break;
            Inc(FColumnCount);
            FActualCardWidth := NextCandidate;
          end;
          FActualCardWidth := Min(FActualCardWidth, FCardMaxWidth);
        end
        else
        begin
          FColumnCount := 1;
          FActualCardWidth := Min(Available,
            Max(Candidate, FCardWidth));
        end;
      end;
  else
    if FContentFlow = ucfNoWrap then
    begin
      FColumnCount := 1;
      FActualCardWidth := EnsureRange(FCardWidth, FCardMinWidth, FCardMaxWidth);
    end
    else
    begin
      FColumnCount := Max(1, Floor((Available + FHorizontalGap) /
        (FCardMinWidth + FHorizontalGap)));
      Candidate := (Available - (FColumnCount - 1) * FHorizontalGap) /
        FColumnCount;
      while (FColumnCount > 1) and (Candidate > FCardMaxWidth) do
      begin
        Inc(FColumnCount);
        Candidate := (Available - (FColumnCount - 1) * FHorizontalGap) /
          FColumnCount;
      end;
      FActualCardWidth := Min(FCardMaxWidth, Max(FCardMinWidth, Candidate));
    end;
  end;

  TextWidth := TextAvailableWidth(RectF(0, 0, FActualCardWidth,
    FCardHeight));
  CacheSizeChanged := (Length(FTitleLayouts) <> FItems.Count) or
    (Length(FTextLayouts) <> FItems.Count) or
    (Length(FDetailLayouts) <> FItems.Count);
  TextMetricsChanged := CacheSizeChanged or
    (FPreparedCardWidth < 0) or
    not SameValue(FPreparedCardWidth, FActualCardWidth,
      TEpsilon.Position) or
    not SameValue(FPreparedTextWidth, TextWidth, TEpsilon.Position);
  if TextMetricsChanged and
     (CacheSizeChanged or not FResizeHeightPending) then
    PrepareTextLayouts;

  DisplayCount := CardDisplayCount;
  ReuseItemHeights := (Length(FItemHeights) = FItems.Count) and
    (FResizeHeightPending or not TextMetricsChanged);
  if Length(FItemHeights) <> FItems.Count then
  begin
    SetLength(FItemHeights, FItems.Count);
    ReuseItemHeights := False;
  end;
  for I := 0 to DisplayCount - 1 do
  begin
    ItemIndex := CardDisplayItemIndex(I);
    if (ItemIndex >= 0) and
       (not ReuseItemHeights or (FItemHeights[ItemIndex] <= 0)) then
      FItemHeights[ItemIndex] := MeasureCardHeight(ItemIndex);
  end;

  if (FContentFlow = ucfNoWrap) and (FCardLayout = uclGrid) then
  begin
    FContentWidth := FContentPadding * 2 + DisplayCount * FActualCardWidth +
      Max(0, DisplayCount - 1) * FHorizontalGap;
    FContentHeight := FContentPadding * 2 + FCardHeight;
    for I := 0 to DisplayCount - 1 do
    begin
      ItemIndex := CardDisplayItemIndex(I);
      if ItemIndex >= 0 then
        FContentHeight := Max(FContentHeight,
          FContentPadding * 2 + FItemHeights[ItemIndex]);
    end;
    if Length(FRowTops) <> 1 then
      SetLength(FRowTops, 1);
    if Length(FRowHeights) <> 1 then
      SetLength(FRowHeights, 1);
    FRowTops[0] := FContentPadding;
    FRowHeights[0] := Max(FCardHeight, FContentHeight - FContentPadding * 2);
  end
  else
  begin
    RowCount := Ceil(DisplayCount / Max(1, FColumnCount));
    if Length(FRowTops) <> RowCount then
      SetLength(FRowTops, RowCount);
    if Length(FRowHeights) <> RowCount then
      SetLength(FRowHeights, RowCount);
    for Row := 0 to RowCount - 1 do
    begin
      if FCardLayout = uclFullWidth then
        FRowHeights[Row] := 0
      else
        FRowHeights[Row] := FCardHeight;
      for I := Row * FColumnCount to
        Min(DisplayCount - 1, Row * FColumnCount + FColumnCount - 1) do
      begin
        ItemIndex := CardDisplayItemIndex(I);
        if ItemIndex >= 0 then
          FRowHeights[Row] := Max(FRowHeights[Row],
            FItemHeights[ItemIndex]);
      end;
    end;
    TopValue := FContentPadding;
    for Row := 0 to RowCount - 1 do
    begin
      FRowTops[Row] := TopValue;
      TopValue := TopValue + FRowHeights[Row] + FVerticalGap;
    end;
    if RowCount > 0 then
      FContentHeight := TopValue - FVerticalGap + FContentPadding
    else
      FContentHeight := FContentPadding * 2;
    X := FContentPadding + FColumnCount * FActualCardWidth +
      Max(0, FColumnCount - 1) * FHorizontalGap + FContentPadding;
    FContentWidth := Max(Width, X);
  end;
  CalculateCardTreeLayout;
  ClampScroll;
end;

function TUniListView.CardRect(const AIndex: Integer): TRectF;
var
  ItemIndex, Row, Col: Integer;
  TopValue, HeightValue: Single;
begin
  if CardTreeActive and (FCardTreeMode = ctmHierarchy) and
     (AIndex >= 0) and (AIndex < Length(FCardTreeLayoutItems)) then
  begin
    Result := FCardTreeLayoutItems[AIndex].Bounds;
    Result.Offset(-FScrollX, -FScrollY);
    Exit;
  end;
  if (FContentFlow = ucfNoWrap) and (FCardLayout = uclGrid) then
  begin
    Col := AIndex;
    TopValue := FContentPadding;
    ItemIndex := CardDisplayItemIndex(AIndex);
    if (ItemIndex >= 0) and (ItemIndex < Length(FItemHeights)) then
      HeightValue := FItemHeights[ItemIndex]
    else
      HeightValue := FCardHeight;
  end
  else
  begin
    Row := AIndex div Max(1, FColumnCount);
    Col := AIndex mod Max(1, FColumnCount);
    TopValue := FRowTops[Row];
    HeightValue := FRowHeights[Row];
  end;
  Result := RectF(
    FContentPadding + Col * (FActualCardWidth + FHorizontalGap) - FScrollX,
    TopValue - FScrollY,
    FContentPadding + Col * (FActualCardWidth + FHorizontalGap) +
      FActualCardWidth - FScrollX,
    TopValue + HeightValue - FScrollY);
end;

procedure TUniListView.ClampScroll;
var
  ViewportHeight: Single;
begin
  if FCardLayout = uclFullWidth then
    FScrollX := 0
  else
    FScrollX := EnsureRange(FScrollX, 0, Max(0, FContentWidth - Width));
  ViewportHeight := Height;
  if (FViewMode = uvmList) and FListFooterVisible then
    ViewportHeight := Max(1, ViewportHeight - FListFooterHeight);
  FScrollY := EnsureRange(FScrollY, 0, Max(0, FContentHeight - ViewportHeight));
end;

function TUniListView.FirstVisibleIndex: Integer;
var
  LowRow, HighRow, MidRow, VisibleRow: Integer;
  ItemStep: Single;
  PerfTimer: TUniPerfScope;
begin
  PerfTimer := TUniPerfScope.Start(upcVisibleRange);
  try
    UniPerfInc(upcVisibleRange);
  if (FViewMode = uvmList) and (DisplayItemCount = 0) then
    Exit(0);
  if (FViewMode <> uvmList) and (CardDisplayCount = 0) then
    Exit(0);

  if FViewMode = uvmList then
    Exit(Max(0, ListDisplayIndexAtY(FScrollY)));

  if CardTreeActive and (FCardTreeMode = ctmHierarchy) and
     (Length(FCardTreeLayoutItems) > 0) then
  begin
    LowRow := 0;
    HighRow := High(FCardTreeLayoutItems);
    VisibleRow := 0;
    while LowRow <= HighRow do
    begin
      MidRow := LowRow + (HighRow - LowRow) div 2;
      if FCardTreeLayoutItems[MidRow].Bounds.Bottom < FScrollY then
        LowRow := MidRow + 1
      else
      begin
        VisibleRow := MidRow;
        HighRow := MidRow - 1;
      end;
    end;
    Exit(VisibleRow);
  end;

  if (FContentFlow = ucfNoWrap) and (FCardLayout = uclGrid) then
  begin
    ItemStep := Max(1, FActualCardWidth + FHorizontalGap);
    Exit(EnsureRange(Floor(FScrollX / ItemStep), 0, CardDisplayCount - 1));
  end;

  if Length(FRowTops) = 0 then
    Exit(0);

  LowRow := 0;
  HighRow := High(FRowTops);
  VisibleRow := 0;
  while LowRow <= HighRow do
  begin
    MidRow := LowRow + (HighRow - LowRow) div 2;
    if FRowTops[MidRow] + FRowHeights[MidRow] < FScrollY then
      LowRow := MidRow + 1
    else
    begin
      VisibleRow := MidRow;
      HighRow := MidRow - 1;
    end;
  end;

    Result := Min(CardDisplayCount - 1, VisibleRow * Max(1, FColumnCount));
  finally
    PerfTimer.Stop;
  end;
end;

function TUniListView.LastVisibleIndex: Integer;
var
  LowRow, HighRow, MidRow, VisibleRow: Integer;
  ItemStep: Single;
  PerfTimer: TUniPerfScope;
begin
  PerfTimer := TUniPerfScope.Start(upcVisibleRange);
  try
    UniPerfInc(upcVisibleRange);
  if (FViewMode = uvmList) and (DisplayItemCount = 0) then
    Exit(-1);
  if (FViewMode <> uvmList) and (CardDisplayCount = 0) then
    Exit(-1);

  if FViewMode = uvmList then
  begin
    ItemStep := Height - ListBodyTop;
    if FListFooterVisible then
      ItemStep := ItemStep - FListFooterHeight;
    Exit(EnsureRange(ListDisplayIndexAtY(FScrollY + Max(1, ItemStep)) + 1,
      0, DisplayItemCount - 1));
  end;

  if CardTreeActive and (FCardTreeMode = ctmHierarchy) and
     (Length(FCardTreeLayoutItems) > 0) then
  begin
    LowRow := 0;
    HighRow := High(FCardTreeLayoutItems);
    VisibleRow := High(FCardTreeLayoutItems);
    while LowRow <= HighRow do
    begin
      MidRow := LowRow + (HighRow - LowRow) div 2;
      if FCardTreeLayoutItems[MidRow].Bounds.Top <= FScrollY + Height then
      begin
        VisibleRow := MidRow;
        LowRow := MidRow + 1;
      end
      else
        HighRow := MidRow - 1;
    end;
    Exit(VisibleRow);
  end;

  if (FContentFlow = ucfNoWrap) and (FCardLayout = uclGrid) then
  begin
    ItemStep := Max(1, FActualCardWidth + FHorizontalGap);
    Exit(EnsureRange(Ceil((FScrollX + Width) / ItemStep),
      0, CardDisplayCount - 1));
  end;

  if Length(FRowTops) = 0 then
    Exit(CardDisplayCount - 1);

  LowRow := 0;
  HighRow := High(FRowTops);
  VisibleRow := High(FRowTops);
  while LowRow <= HighRow do
  begin
    MidRow := LowRow + (HighRow - LowRow) div 2;
    if FRowTops[MidRow] <= FScrollY + Height then
    begin
      VisibleRow := MidRow;
      LowRow := MidRow + 1;
    end
    else
      HighRow := MidRow - 1;
  end;

    Result := Min(CardDisplayCount - 1,
      (VisibleRow + 1) * Max(1, FColumnCount) - 1);
  finally
    PerfTimer.Stop;
  end;
end;

procedure TUniListView.Paint;
var
  NativeCanvas: IUniCanvas;
  NewRenderScale, ScaleX, ScaleY: Single;
begin
  inherited;
  ScaleX := Max(0.001, Abs(AbsoluteScale.X) * CurrentSceneScale);
  ScaleY := Max(0.001, Abs(AbsoluteScale.Y) * CurrentSceneScale);
  NewRenderScale := Max(ScaleX, ScaleY);
  if not SameValue(FRenderScale, NewRenderScale, 0.001) then
  begin
    FRenderScale := NewRenderScale;
    FTitleMeasureFont := nil;
    InvalidateCardHeightCache;
    InvalidateAutoTitleWidth;
    InvalidateLayout;
  end;
  NativeCanvas := WrapCanvas(Canvas, ScaleX, ScaleY);
  DoDraw(Self, NativeCanvas, LocalRect, AbsoluteOpacity);
end;

procedure TUniListView.DoDraw(Sender: TObject; const ACanvas: IUniCanvas;
  const ADest: TRectF; const AOpacity: Single);
var
  Paint: IUniPaint;
  I, ItemIndex, FirstIndex, LastIndex: Integer;
  DrawnCount: Int64;
  PerfTimer, ModeTimer: TUniPerfScope;
  R: TRectF;
begin
  PerfTimer := TUniPerfScope.Start(upcPaint);
  try
  EnsureLayout;
  Paint := TUniPaintFactory.Create;
  Paint.Color := UniColor(FBackgroundColor);
  Paint.Style := TUniPaintStyle.Fill;
  if CardTreeActive then
    ACanvas.DrawRect(RectF(0, 0, Width, Height), Paint)
  else
    ACanvas.DrawRect(ADest, Paint);
  if FViewMode = uvmList then
  begin
    ModeTimer := TUniPerfScope.Start(upcPaintList);
    try
      DrawList(ACanvas, ADest);
    finally
      ModeTimer.Stop;
    end;
    DrawScrollBars(ACanvas);
    if FColumnChooserVisible then
      DrawColumnChooser(ACanvas);
    UniPerfSetContext(FItems.Count, Max(0, LastVisibleIndex - FirstVisibleIndex + 1));
    Exit;
  end;
  if CardDisplayCount = 0 then Exit;
  FirstIndex := FirstVisibleIndex;
  LastIndex := LastVisibleIndex;
  DrawnCount := 0;
  ModeTimer := TUniPerfScope.Start(upcPaintCards);
  try
  for I := FirstIndex to LastIndex do
  begin
    R := CardRect(I);
    if R.IntersectsWith(RectF(0, 0, Width, Height)) then
    begin
      ItemIndex := CardDisplayItemIndex(I);
      if ItemIndex >= 0 then
      begin
        DrawCard(ACanvas, ItemIndex, R);
        Inc(DrawnCount);
      end;
    end;
  end;
  finally
    ModeTimer.Stop;
  end;
  UniPerfSetContext(FItems.Count, Max(0, LastIndex - FirstIndex + 1));
  UniPerfSetLastPaint(Max(0, LastIndex - FirstIndex + 1), DrawnCount,
    Max(0, LastIndex - FirstIndex + 1));
  DrawCardTreeChrome(ACanvas);
  DrawScrollBars(ACanvas);
  finally
    PerfTimer.Stop;
  end;
end;

function TUniListView.TextRect(const AIndex: Integer;
  const APart: TUniTextPart): TRectF;
var
  R: TRectF;
  Item: TUniListItem;
  DisplayIndex: Integer;
  X, Y, W: Single;
  L: TUniTextLayout;
  procedure Advance(const Text: string; const Part: TUniTextPart);
  begin
    if Text = '' then
      Exit;

    case Part of
      utpTitle: L := FTitleLayouts[AIndex];
      utpText: L := FTextLayouts[AIndex];
      utpDetail: L := FDetailLayouts[AIndex];
    else
      L := Default(TUniTextLayout);
    end;

    if Part = APart then
      Result := RectF(X, Y, X + W, Y + L.Height);
    Y := Y + L.Height + FCardTemplate.TextGap;
  end;
begin
  Result := TRectF.Empty;
  if FCardLayout = uclFullWidth then
    Exit;
  if (AIndex < 0) or (AIndex >= FItems.Count) then Exit;
  DisplayIndex := CardDisplayIndexOf(AIndex);
  if DisplayIndex < 0 then
    Exit;
  R := CardRect(DisplayIndex);
  Item := FItems[AIndex];
  X := R.Left + FCardTemplate.InnerPadding;
  if FCardTemplate.ShowIcon then
    X := X + FCardTemplate.IconBoxSize + 12;
  Y := R.Top + FCardTemplate.InnerPadding;
  W := TextAvailableWidth(R);
  if FCardTemplate.ShowTitle then
    Advance(ItemTitle(Item), utpTitle);
  if FCardTemplate.ShowText then
    Advance(ItemText(Item), utpText);
  if FCardTemplate.ShowDetail then
    Advance(ItemDetail(Item), utpDetail);
end;

procedure TUniListView.ResolveThemeRuleColors(const ARule: TUniColorRule;
  out ABackgroundColor, ATextColor: TAlphaColor);
const
  ACCENT_FALLBACK_COLOR: TAlphaColor = $FF5B8DEF;
  SUCCESS_COLOR: TAlphaColor = $FF22A06B;
  WARNING_COLOR: TAlphaColor = $FFE2A100;
  DANGER_COLOR: TAlphaColor = $FFE5484D;
  INFO_COLOR: TAlphaColor = $FF3B82F6;
  BACKGROUND_BLEND = 0.22;
  TEXT_BLEND = 0.78;
var
  ToneColor: TAlphaColor;
begin
  case ARule.ThemeTone of
    ucrttSuccess: ToneColor := SUCCESS_COLOR;
    ucrttWarning: ToneColor := WARNING_COLOR;
    ucrttDanger: ToneColor := DANGER_COLOR;
    ucrttInfo: ToneColor := INFO_COLOR;
  else
    ToneColor := FAccentColor;
    if ToneColor = 0 then
      ToneColor := ACCENT_FALLBACK_COLOR;
  end;

  ABackgroundColor := UniBlendColor(FCardColor, ToneColor, BACKGROUND_BLEND);
  ATextColor := UniBlendColor(FTextColor, ToneColor, TEXT_BLEND);
end;

procedure TUniListView.ResolveColorRules(AItem: TUniListItem;
  const AColumnName: string; var ABackgroundColor, ATextColor: TAlphaColor;
  var AUseBackgroundColor, AUseTextColor: Boolean);
var
  RuleIndex: Integer;
  Rule: TUniColorRule;
  ColumnMatches: Boolean;
  ThemeBackground, ThemeText: TAlphaColor;
begin
  AUseBackgroundColor := False;
  AUseTextColor := False;
  if (AItem = nil) or (FColorRules = nil) then
    Exit;

  for RuleIndex := 0 to FColorRules.Count - 1 do
  begin
    Rule := FColorRules[RuleIndex];
    if not Rule.Matches(AItem) then
      Continue;

    ColumnMatches := Rule.Scope = ucrsRow;
    if Rule.Scope = ucrsCell then
      ColumnMatches := (Trim(Rule.TargetColumn) = '') or
        SameText(Rule.TargetColumn, AColumnName);
    if not ColumnMatches then
      Continue;

    if Rule.UseThemeColors then
      ResolveThemeRuleColors(Rule, ThemeBackground, ThemeText)
    else
    begin
      ThemeBackground := Rule.BackgroundColor;
      ThemeText := Rule.TextColor;
    end;

    if Rule.UseBackgroundColor then
    begin
      ABackgroundColor := ThemeBackground;
      AUseBackgroundColor := True;
    end;
    if Rule.UseTextColor then
    begin
      ATextColor := ThemeText;
      AUseTextColor := True;
    end;
  end;
end;

procedure TUniListView.DrawFullWidthCard(const ACanvas: IUniCanvas;
  const AItemIndex: Integer; const R: TRectF);
const
  RULE_INDICATOR_WIDTH = 4.0;
  RULE_INDICATOR_INSET = 8.0;
var
  ActionIndex: Integer;
  ActionX, TextX, TextY, TextRight, TrailingLeft, TrailingRight,
    TrailingWidth: Single;
  ActionRect, BlockRect, CheckRect, IconBox, IconRect, IndicatorRect: TRectF;
  BackgroundColor, CardTextColor, IconColor, RuleBackground,
    RuleText: TAlphaColor;
  CheckState: TUniCheckState;
  DetailColumn, SubtitleColumn, TitleColumn, TrailingColumn: TUniListColumn;
  DetailLayout, SubtitleLayout, TitleLayout, TrailingLayout: TUniTextLayout;
  DetailValue, SubtitleValue, TitleValue, TrailingValue: string;
  Font: IUniFont;
  Item: TUniListItem;
  SecondaryIcon: TUniVectorIcon;
  IsHot, IsPressed, UseRuleBackground, UseRuleText,
    UseText: Boolean;
  Paint: IUniPaint;

    BlockTimer: TUniPerfScope;

  procedure ResolveBlockColors(AColumn: TUniListColumn;
    const ADefaultTextColor: TAlphaColor; out ABlockTextColor,
    ABlockBackgroundColor: TAlphaColor; out AUseBlockBackground: Boolean);
  var
    CellBackground, CellText: TAlphaColor;
    ColumnName: string;
    RuleIndex: Integer;
    Rule: TUniColorRule;
  begin
    ABlockTextColor := ADefaultTextColor;
    ABlockBackgroundColor := FCardColor;
    AUseBlockBackground := False;
    if AColumn <> nil then
      ColumnName := AColumn.FieldName
    else
      ColumnName := '';
    ResolveColorRules(Item, ColumnName, ABlockBackgroundColor,
      ABlockTextColor, AUseBlockBackground, UseText);
    { Row rules are represented by the card indicator. A background behind an
      individual text block is valid only for an explicitly matching cell rule. }
    AUseBlockBackground := False;
    if AColumn <> nil then
      for RuleIndex := 0 to FColorRules.Count - 1 do
      begin
        Rule := FColorRules[RuleIndex];
        if (Rule.Scope = ucrsCell) and Rule.UseBackgroundColor and
           Rule.Matches(Item) and
           ((Trim(Rule.TargetColumn) = '') or
            SameText(Rule.TargetColumn, ColumnName)) then
        begin
          if Rule.UseThemeColors then
            ResolveThemeRuleColors(Rule, CellBackground, CellText)
          else
            CellBackground := Rule.BackgroundColor;
          ABlockBackgroundColor := CellBackground;
          AUseBlockBackground := True;
        end;
      end;
    if not UseText then
      ABlockTextColor := ADefaultTextColor;
  end;

  procedure DrawBlock(const AText: string; const ALayout: TUniTextLayout;
    AColumn: TUniListColumn; const AFontSize: Single;
    const ADefaultColor: TAlphaColor; const AX, AY, AWidth: Single;
    const ARightAligned: Boolean);
  var
    BlockBackground, BlockText: TAlphaColor;
    DrawX, LineWidth: Single;
    LocalLineIndex: Integer;
    UseBlockBackground: Boolean;
  begin
    if AText = '' then
      Exit;
    ResolveBlockColors(AColumn, ADefaultColor, BlockText, BlockBackground,
      UseBlockBackground);
    BlockRect := RectF(AX, AY, AX + AWidth, AY + ALayout.Height);
    if UseBlockBackground then
    begin
      Paint.Style := TUniPaintStyle.Fill;
      Paint.Color := BlockBackground;
      ACanvas.DrawRoundRect(BlockRect, 4, 4, Paint);
    end;
    Paint.Style := TUniPaintStyle.Fill;
    Paint.Color := BlockText;
    Font := CreateTextFont(AFontSize);
    for LocalLineIndex := 0 to High(ALayout.Lines) do
    begin
      if ARightAligned then
      begin
        LineWidth := Font.MeasureText(ALayout.Lines[LocalLineIndex]);
        DrawX := Max(AX, AX + AWidth - LineWidth);
      end
      else
        DrawX := AX;
      DrawSearchHighlights(ACanvas, AItemIndex,
        ALayout.Lines[LocalLineIndex], DrawX,
        AY + AFontSize + LocalLineIndex * ALayout.LineHeight, AFontSize);
      ACanvas.DrawSimpleText(ALayout.Lines[LocalLineIndex], DrawX,
        AY + AFontSize + LocalLineIndex * ALayout.LineHeight, Font, Paint);
    end;
  end;

begin
  if (AItemIndex < 0) or (AItemIndex >= FItems.Count) then
    Exit;
  Item := FItems[AItemIndex];
  FullWidthValues(Item, TitleValue, SubtitleValue, DetailValue, TrailingValue,
    TitleColumn, SubtitleColumn, DetailColumn, TrailingColumn);

  RuleBackground := FCardColor;
  RuleText := FTextColor;
  ResolveColorRules(Item, '', RuleBackground, RuleText,
    UseRuleBackground, UseRuleText);
  if UseRuleText then
    CardTextColor := RuleText
  else
    CardTextColor := FTextColor;
  if AItemIndex = FSelectedIndex then
    BackgroundColor := FCardSelectedColor
  else if FHotHit.ItemIndex = AItemIndex then
    BackgroundColor := FCardHotColor
  else if CardTreeActive and CardTreeItemVisualParent(AItemIndex) then
    BackgroundColor := FCardTreeParentBackgroundColor
  else
    BackgroundColor := FCardColor;

  Paint := TUniPaintFactory.Create;
  Paint.AntiAlias := True;
  Paint.Style := TUniPaintStyle.Fill;
  Paint.Color := BackgroundColor;
  ACanvas.DrawRoundRect(R, FCornerRadius, FCornerRadius, Paint);
  if UseRuleBackground then
  begin
    Paint.Color := RuleBackground;
    IndicatorRect := RectF(R.Left + RULE_INDICATOR_INSET,
      R.Top + RULE_INDICATOR_INSET,
      R.Left + RULE_INDICATOR_INSET + RULE_INDICATOR_WIDTH,
      R.Bottom - RULE_INDICATOR_INSET);
    ACanvas.DrawRoundRect(IndicatorRect, RULE_INDICATOR_WIDTH * 0.5,
      RULE_INDICATOR_WIDTH * 0.5, Paint);
  end;
  if AItemIndex = FSelectedIndex then
  begin
    Paint.Style := TUniPaintStyle.Stroke;
    Paint.StrokeWidth := 1;
    Paint.Color := (FAccentColor and $00FFFFFF) or $80000000;
    ACanvas.DrawRoundRect(R, FCornerRadius, FCornerRadius, Paint);
  end;

  TextX := R.Left + FULL_WIDTH_CARD_HORIZONTAL_PADDING;
  if CheckBoxesVisible then
  begin
    CheckRect := CardCheckRect(AItemIndex);
    CheckState := TreeCheckState(AItemIndex);
    BlockTimer := TUniPerfScope.Start(upcDrawCardCheckBox);
    try
      DrawCheckBox(ACanvas, CheckRect, CheckState);
    finally
      BlockTimer.Stop;
    end;
    TextX := TextX + FULL_WIDTH_CARD_CHECKBOX_SPACE;
  end;
  if FCardTemplate.ShowIcon then
  begin
    IconBox := RectF(TextX, R.Top + FULL_WIDTH_CARD_VERTICAL_PADDING,
      TextX + FCardTemplate.IconBoxSize,
      R.Top + FULL_WIDTH_CARD_VERTICAL_PADDING + FCardTemplate.IconBoxSize);
    Paint.Style := TUniPaintStyle.Fill;
    Paint.Color := (FAccentColor and $00FFFFFF) or $12000000;
    BlockTimer := TUniPerfScope.Start(upcDrawCardIcon);
    try
      ACanvas.DrawRoundRect(IconBox, 8, 8, Paint);
    IconRect := RectF(IconBox.CenterPoint.X - FCardTemplate.IconSize * 0.5,
      IconBox.CenterPoint.Y - FCardTemplate.IconSize * 0.5,
      IconBox.CenterPoint.X + FCardTemplate.IconSize * 0.5,
      IconBox.CenterPoint.Y + FCardTemplate.IconSize * 0.5);
      DrawVectorIcon(ACanvas, ItemIcon(Item), IconRect, ResolveIconColor(FAccentColor), 1.7);
      SecondaryIcon := ItemSecondaryIcon(Item);
      if SecondaryIcon <> uviNone then
      begin
        IconRect := RectF(IconBox.CenterPoint.X - FCardTemplate.IconSize * 0.32,
          IconBox.Bottom + 4,
          IconBox.CenterPoint.X + FCardTemplate.IconSize * 0.32,
          IconBox.Bottom + 4 + FCardTemplate.IconSize * 0.64);
        DrawVectorIcon(ACanvas, SecondaryIcon, IconRect, ResolveIconColor(FAccentColor), 1.4);
      end;
    finally
      BlockTimer.Stop;
    end;
    TextX := IconBox.Right + FULL_WIDTH_CARD_ICON_GAP;
  end;

  ActionX := R.Right - FULL_WIDTH_CARD_HORIZONTAL_PADDING;
  if CardTreeActive and CardTreeItemHasChildren(AItemIndex) then
    ActionX := ActionX - FCardTreeNavigationIconSize -
      CARD_TREE_ICON_PADDING;
  if CardTreeActive and (FCardTreeMode = ctmExplorer) and
     FCardTreeExplorerShowChildCount and
     CardTreeItemIsParent(AItemIndex) then
    ActionX := ActionX - CARD_TREE_BADGE_WIDTH - CARD_TREE_BADGE_GAP;
  if FCardTemplate.ShowActions then
    for ActionIndex := FActions.Count - 1 downto 0 do
      if ActionVisible(Item, FActions[ActionIndex]) then
        ActionX := ActionX - FActions[ActionIndex].Width -
          FULL_WIDTH_CARD_ACTION_GAP;
  if ActionX < R.Right - FULL_WIDTH_CARD_HORIZONTAL_PADDING then
    ActionX := ActionX - FULL_WIDTH_CARD_GAP
  else
    ActionX := R.Right - FULL_WIDTH_CARD_HORIZONTAL_PADDING;

  TrailingRight := ActionX;
  TrailingWidth := 0;
  if TrailingValue <> '' then
  begin
    TrailingWidth := EnsureRange(
      EstimateTextWidth(TrailingValue, FFontSize),
      FULL_WIDTH_CARD_TRAILING_MIN_WIDTH,
      R.Width * FULL_WIDTH_CARD_TRAILING_MAX_RATIO);
    TrailingLeft := TrailingRight - TrailingWidth;
    TextRight := TrailingLeft - FULL_WIDTH_CARD_GAP;
  end
  else
  begin
    TrailingLeft := TrailingRight;
    TextRight := TrailingRight;
  end;
  TextRight := Max(TextX + 1, TextRight);
  TitleLayout := BuildTextLayout(TitleValue, TextRight - TextX,
    FTitleFontSize, False, True, FULL_WIDTH_CARD_TITLE_MAX_LINES);
  SubtitleLayout := BuildTextLayout(SubtitleValue, TextRight - TextX,
    FFontSize, FCardTemplate.WordWrap, FCardTemplate.Ellipsis,
    FULL_WIDTH_CARD_SUBTITLE_MAX_LINES);
  DetailLayout := BuildTextLayout(DetailValue, TextRight - TextX,
    FDetailFontSize, FCardTemplate.WordWrap, FCardTemplate.Ellipsis,
    FULL_WIDTH_CARD_DETAIL_MAX_LINES);
  TrailingLayout := BuildTextLayout(TrailingValue, Max(1, TrailingWidth),
    FFontSize, False, True, 1);

  TextY := R.Top + FULL_WIDTH_CARD_VERTICAL_PADDING;
  if TitleValue <> '' then
  begin
    DrawBlock(TitleValue, TitleLayout, TitleColumn, FTitleFontSize,
      CardTextColor, TextX, TextY, TextRight - TextX, False);
    TextY := TextY + TitleLayout.Height;
  end;
  if SubtitleValue <> '' then
  begin
    if TextY > R.Top + FULL_WIDTH_CARD_VERTICAL_PADDING then
      TextY := TextY + FULL_WIDTH_CARD_TITLE_GAP;
    DrawBlock(SubtitleValue, SubtitleLayout, SubtitleColumn, FFontSize,
      FSecondaryTextColor, TextX, TextY, TextRight - TextX, False);
    TextY := TextY + SubtitleLayout.Height;
  end;
  if DetailValue <> '' then
  begin
    if TextY > R.Top + FULL_WIDTH_CARD_VERTICAL_PADDING then
      TextY := TextY + FULL_WIDTH_CARD_TITLE_GAP;
    DrawBlock(DetailValue, DetailLayout, DetailColumn, FDetailFontSize,
      FSecondaryTextColor, TextX, TextY, TextRight - TextX, False);
  end;
  if TrailingValue <> '' then
    DrawBlock(TrailingValue, TrailingLayout, TrailingColumn, FFontSize,
      CardTextColor, TrailingLeft, R.Top + FULL_WIDTH_CARD_VERTICAL_PADDING,
      TrailingWidth, True);

  if not AreActionsVisibleForItem(AItemIndex) then
    Exit;
  ActionX := R.Right - FULL_WIDTH_CARD_HORIZONTAL_PADDING;
  if CardTreeActive and CardTreeItemHasChildren(AItemIndex) then
    ActionX := ActionX - FCardTreeNavigationIconSize -
      CARD_TREE_ICON_PADDING;
  if CardTreeActive and (FCardTreeMode = ctmExplorer) and
     FCardTreeExplorerShowChildCount and
     CardTreeItemIsParent(AItemIndex) then
    ActionX := ActionX - CARD_TREE_BADGE_WIDTH - CARD_TREE_BADGE_GAP;
  for ActionIndex := FActions.Count - 1 downto 0 do
    if ActionDisplayed(AItemIndex, FActions[ActionIndex]) then
    begin
      ActionRect := RectF(ActionX - FActions[ActionIndex].Width,
        R.Top + FULL_WIDTH_CARD_VERTICAL_PADDING, ActionX,
        R.Top + FULL_WIDTH_CARD_VERTICAL_PADDING +
          FActions[ActionIndex].Width);
      IsHot := (FHotHit.Kind = uchAction) and
        (FHotHit.ItemIndex = AItemIndex) and
        (FHotHit.ActionIndex = ActionIndex);
      IsPressed := (FPressedHit.Kind = uchAction) and
        (FPressedHit.ItemIndex = AItemIndex) and
        (FPressedHit.ActionIndex = ActionIndex) and FMousePressed;
      if IsHot or IsPressed then
      begin
        Paint.Style := TUniPaintStyle.Fill;
        if IsPressed then
          Paint.Color := UniBlendColor(BackgroundColor, FAccentColor,
            ACTION_PRESSED_BLEND)
        else
          Paint.Color := UniBlendColor(BackgroundColor, FAccentColor,
            ACTION_HOVER_BLEND);
        ACanvas.DrawRoundRect(ActionRect, FULL_WIDTH_CARD_ACTION_RADIUS,
          FULL_WIDTH_CARD_ACTION_RADIUS, Paint);
      end;
      if ActionEnabled(Item, FActions[ActionIndex]) then
        IconColor := ResolveIconColor(FAccentColor)
      else
        IconColor := UniBlendColor(BackgroundColor, ResolveIconColor(FAccentColor),
          ACTION_DISABLED_BLEND);
      IconRect := ActionRect;
      IconRect.Inflate(-FULL_WIDTH_CARD_ACTION_ICON_INSET,
        -FULL_WIDTH_CARD_ACTION_ICON_INSET);
      if FActions[ActionIndex].Icon <> uviNone then
        DrawVectorIcon(ACanvas, FActions[ActionIndex].Icon, IconRect,
          IconColor, 1.8);
      ActionX := ActionRect.Left - FULL_WIDTH_CARD_ACTION_GAP;
    end;
end;

procedure TUniListView.DrawCard(const ACanvas: IUniCanvas;
  const AIndex: Integer; const R: TRectF);
const
  RULE_INDICATOR_WIDTH = 4.0;
  RULE_INDICATOR_INSET = 8.0;
var
  Paint: IUniPaint;
  Font: IUniFont;
  Item: TUniListItem;
  SecondaryIcon: TUniVectorIcon;
  Bg, IconColor, RuleBackground, RuleText, CardTextColor: TAlphaColor;
  UseRuleBackground, UseRuleText: Boolean;
  TextX, TextY, ActionX, W: Single;
  I: Integer;
  AR, IconBox, IconRect, LR, CheckRect: TRectF;
  IsHot, IsPressed: Boolean;
  CheckState: TUniCheckState;
  L: TUniTextLayout;
    PerfTimer, BlockTimer: TUniPerfScope;
  procedure DrawTextBlock(const Text: string; const FontSize: Single;
    const Part: TUniTextPart; const Color: TAlphaColor);
  var
    LineIndex: Integer;
  begin
    if Text = '' then
      Exit;

    case Part of
      utpTitle: L := FTitleLayouts[AIndex];
      utpText: L := FTextLayouts[AIndex];
      utpDetail: L := FDetailLayouts[AIndex];
    else
      L := Default(TUniTextLayout);
    end;
    LR := RectF(TextX, TextY, TextX + W, TextY + L.Height);
    if (FSelectedTextHit.Kind = uchText) and
       (FSelectedTextHit.ItemIndex = AIndex) and
       (FSelectedTextHit.TextPart = Part) then
    begin
      Paint.Style := TUniPaintStyle.Fill;
      Paint.Color := (FAccentColor and $00FFFFFF) or $55000000;
      ACanvas.DrawRoundRect(LR, 3, 3, Paint);
    end;
    Paint.Style := TUniPaintStyle.Fill;
    Paint.Color := Color;
    Font := CreateTextFont(FontSize);
    for LineIndex := 0 to High(L.Lines) do
    begin
      DrawSearchHighlights(ACanvas, AIndex, L.Lines[LineIndex], TextX,
        TextY + FontSize + LineIndex * L.LineHeight, FontSize);
      ACanvas.DrawSimpleText(L.Lines[LineIndex], TextX,
        TextY + FontSize + LineIndex * L.LineHeight, Font, Paint);
    end;
    TextY := TextY + L.Height + FCardTemplate.TextGap;
  end;
begin
  UniPerfInc(upcDrawCard);
  PerfTimer := TUniPerfScope.Start(upcDrawCard);
  try
  if FCardLayout = uclFullWidth then
  begin
    DrawFullWidthCard(ACanvas, AIndex, R);
    Exit;
  end;
  PrepareItemTextLayout(AIndex, TextAvailableWidth(R));
  Item := FItems[AIndex];
  RuleBackground := FCardColor;
  RuleText := FTextColor;
  ResolveColorRules(Item, '', RuleBackground, RuleText,
    UseRuleBackground, UseRuleText);
  if UseRuleText then CardTextColor := RuleText else CardTextColor := FTextColor;
  if AIndex = FSelectedIndex then Bg := FCardSelectedColor
  else if FHotHit.ItemIndex = AIndex then Bg := FCardHotColor
  else if CardTreeActive and CardTreeItemVisualParent(AIndex) then
    Bg := FCardTreeParentBackgroundColor
  else Bg := FCardColor;
  Paint := TUniPaintFactory.Create;
  Paint.AntiAlias := True;
  Paint.Style := TUniPaintStyle.Fill;
  Paint.Color := Bg;
  ACanvas.DrawRoundRect(R, FCornerRadius, FCornerRadius, Paint);
  if UseRuleBackground then
  begin
    Paint.Style := TUniPaintStyle.Fill;
    Paint.Color := RuleBackground;
    AR := RectF(R.Left + RULE_INDICATOR_INSET,
      R.Top + RULE_INDICATOR_INSET,
      R.Left + RULE_INDICATOR_INSET + RULE_INDICATOR_WIDTH,
      R.Bottom - RULE_INDICATOR_INSET);
    ACanvas.DrawRoundRect(AR, RULE_INDICATOR_WIDTH * 0.5,
      RULE_INDICATOR_WIDTH * 0.5, Paint);
  end;
  if AIndex = FSelectedIndex then
  begin
    Paint.Style := TUniPaintStyle.Stroke;
    Paint.StrokeWidth := 1;
    Paint.Color := (FAccentColor and $00FFFFFF) or $80000000;
    ACanvas.DrawRoundRect(R, FCornerRadius, FCornerRadius, Paint);
  end;
  TextX := R.Left + FCardTemplate.InnerPadding;
  if CheckBoxesVisible then
  begin
    CheckRect := CardCheckRect(AIndex);
    CheckState := TreeCheckState(AIndex);
    BlockTimer := TUniPerfScope.Start(upcDrawCardCheckBox);
    try
      DrawCheckBox(ACanvas, CheckRect, CheckState);
    finally
      BlockTimer.Stop;
    end;
    TextX := TextX + GRID_CARD_CHECKBOX_SIZE +
      GRID_CARD_CHECKBOX_GAP;
  end;
  if FCardTemplate.ShowIcon then
  begin
    IconBox := RectF(TextX,
      R.Top + FCardTemplate.InnerPadding,
      TextX + FCardTemplate.IconBoxSize,
      R.Top + FCardTemplate.InnerPadding + FCardTemplate.IconBoxSize);
    Paint.Style := TUniPaintStyle.Fill;
    Paint.Color := (FAccentColor and $00FFFFFF) or $12000000;
    BlockTimer := TUniPerfScope.Start(upcDrawCardIcon);
    try
      ACanvas.DrawRoundRect(IconBox, 8, 8, Paint);
    IconRect := RectF(IconBox.CenterPoint.X - FCardTemplate.IconSize * 0.5,
      IconBox.CenterPoint.Y - FCardTemplate.IconSize * 0.5,
      IconBox.CenterPoint.X + FCardTemplate.IconSize * 0.5,
      IconBox.CenterPoint.Y + FCardTemplate.IconSize * 0.5);
      DrawVectorIcon(ACanvas, ItemIcon(Item), IconRect, ResolveIconColor(FAccentColor), 1.7);
      SecondaryIcon := ItemSecondaryIcon(Item);
      if SecondaryIcon <> uviNone then
      begin
        IconRect := RectF(IconBox.CenterPoint.X - FCardTemplate.IconSize * 0.32,
          IconBox.Bottom + 4,
          IconBox.CenterPoint.X + FCardTemplate.IconSize * 0.32,
          IconBox.Bottom + 4 + FCardTemplate.IconSize * 0.64);
        DrawVectorIcon(ACanvas, SecondaryIcon, IconRect, ResolveIconColor(FAccentColor), 1.4);
      end;
    finally
      BlockTimer.Stop;
    end;
    TextX := IconBox.Right + GRID_CARD_ICON_GAP;
  end;
  TextY := R.Top + FCardTemplate.InnerPadding;
  W := TextAvailableWidth(R);
  ACanvas.Save;
  try
    ACanvas.ClipRect(RectF(TextX, TextY, TextX + W,
      Max(TextY, R.Bottom - FCardTemplate.InnerPadding)));
    if FCardTemplate.ShowTitle then
      DrawTextBlock(ItemTitle(Item), FTitleFontSize, utpTitle, CardTextColor);
    if FCardTemplate.ShowText then
      DrawTextBlock(ItemText(Item), FFontSize, utpText, FSecondaryTextColor);
    if FCardTemplate.ShowDetail then
      DrawTextBlock(ItemDetail(Item), FDetailFontSize, utpDetail,
        FSecondaryTextColor);
  finally
    ACanvas.Restore;
  end;
  if not AreActionsVisibleForItem(AIndex) then Exit;
  ActionX := R.Right - FCardTemplate.InnerPadding;
  if CardTreeActive and CardTreeItemHasChildren(AIndex) then
    ActionX := ActionX - FCardTreeNavigationIconSize -
      CARD_TREE_ICON_PADDING;
  if CardTreeActive and (FCardTreeMode = ctmExplorer) and
     FCardTreeExplorerShowChildCount and
     CardTreeItemIsParent(AIndex) then
    ActionX := ActionX - CARD_TREE_BADGE_WIDTH - CARD_TREE_BADGE_GAP;
  for I := FActions.Count - 1 downto 0 do
    if ActionDisplayed(AIndex, FActions[I]) then
    begin
      AR := RectF(ActionX - FActions[I].Width,
        R.Top + FCardTemplate.InnerPadding,
        ActionX, R.Top + FCardTemplate.InnerPadding + FActions[I].Width);
      IsHot := (FHotHit.Kind = uchAction) and
        (FHotHit.ItemIndex = AIndex) and (FHotHit.ActionIndex = I);
      IsPressed := (FPressedHit.Kind = uchAction) and
        (FPressedHit.ItemIndex = AIndex) and
        (FPressedHit.ActionIndex = I) and FMousePressed;
      if IsHot or IsPressed then
      begin
        Paint.Style := TUniPaintStyle.Fill;
        if IsPressed then
          Paint.Color := UniBlendColor(Bg, FAccentColor,
            ACTION_PRESSED_BLEND)
        else
          Paint.Color := UniBlendColor(Bg, FAccentColor,
            ACTION_HOVER_BLEND);
        ACanvas.DrawRoundRect(AR, 6, 6, Paint);
      end;
      if ActionEnabled(Item, FActions[I]) then IconColor := ResolveIconColor(FAccentColor)
      else
        IconColor := UniBlendColor(Bg, ResolveIconColor(FAccentColor),
          ACTION_DISABLED_BLEND);
      IconRect := AR; IconRect.Inflate(-5, -5);
      if FActions[I].Icon <> uviNone then
        DrawVectorIcon(ACanvas, FActions[I].Icon, IconRect, IconColor, 1.8);
      ActionX := AR.Left - GRID_CARD_ACTION_GAP;
    end;
  finally
    PerfTimer.Stop;
  end;
end;

procedure TUniListView.CalculateListColumns;
var
  ColumnIndex, FillCount: Integer;
  FixedWidth, FillWidth, AvailableWidth, AutoWidth, CheckAreaWidth: Single;
  Column: TUniListColumn;
  Item: TUniListItem;
begin
  CheckAreaWidth := 0;
  if CheckBoxesVisible and not FTreeMode then
    CheckAreaWidth := LIST_CHECKBOX_AREA_WIDTH;
  if Length(FColumnWidths) <> FColumns.Count then
    SetLength(FColumnWidths, FColumns.Count);
  if Length(FColumnLefts) <> FColumns.Count then
    SetLength(FColumnLefts, FColumns.Count);
  FixedWidth := 0;
  FillCount := 0;
  for ColumnIndex := 0 to FColumns.Count - 1 do
  begin
    Column := FColumns[ColumnIndex];
    if not Column.Visible then
    begin
      FColumnWidths[ColumnIndex] := 0;
      Continue;
    end;
    if Column.WidthMode = ucwmFill then
      Inc(FillCount);
    case Column.WidthMode of
      ucwmAuto:
        begin
          AutoWidth := EstimateTextWidth(Column.Caption, FFontSize) + 24;
          for Item in FItems do
            AutoWidth := Max(AutoWidth,
              EstimateTextWidth(ColumnDisplayText(Item, Column), FFontSize) + 24);
          FColumnWidths[ColumnIndex] := EnsureRange(AutoWidth,
            Column.MinWidth, Column.MaxWidth);
          FixedWidth := FixedWidth + FColumnWidths[ColumnIndex];
        end;
      ucwmFill:
        FColumnWidths[ColumnIndex] := 0;
    else
      FColumnWidths[ColumnIndex] := EnsureRange(Column.Width,
        Column.MinWidth, Column.MaxWidth);
      FixedWidth := FixedWidth + FColumnWidths[ColumnIndex];
    end;
  end;

  AvailableWidth := Max(0, Width - FContentPadding * 2 -
    CheckAreaWidth - FixedWidth);
  if FillCount > 0 then
    FillWidth := AvailableWidth / FillCount
  else
    FillWidth := 0;
  for ColumnIndex := 0 to FColumns.Count - 1 do
    if FColumns[ColumnIndex].Visible and
       (FColumns[ColumnIndex].WidthMode = ucwmFill) then
      FColumnWidths[ColumnIndex] := EnsureRange(FillWidth,
        FColumns[ColumnIndex].MinWidth, FColumns[ColumnIndex].MaxWidth);

  AvailableWidth := FContentPadding + CheckAreaWidth;
  for ColumnIndex := 0 to FColumns.Count - 1 do
  begin
    FColumnLefts[ColumnIndex] := AvailableWidth;
    AvailableWidth := AvailableWidth + FColumnWidths[ColumnIndex];
  end;
  FContentWidth := Max(Width, AvailableWidth + FContentPadding);
end;

procedure TUniListView.CalculateListRows;
var
  I: Integer;
  TopValue: Single;
begin
  if Length(FListRowTops) <> DisplayItemCount then
    SetLength(FListRowTops, DisplayItemCount);
  if Length(FListRowHeights) <> DisplayItemCount then
    SetLength(FListRowHeights, DisplayItemCount);
  TopValue := 0;
  for I := 0 to DisplayItemCount - 1 do
  begin
    FListRowTops[I] := TopValue;
    FListRowHeights[I] := MeasureListRowHeight(I);
    TopValue := TopValue + FListRowHeights[I];
  end;
end;

function TUniListView.MeasureListRowHeight(const ADisplayIndex: Integer): Single;
const
  CELL_VERTICAL_PADDING = 16.0;
var
  ColumnIndex, ItemIndex, LineCount: Integer;
  LineHeight: Single;
  Lines: TArray<string>;
  TextValueLocal: string;
  PerfTimer: TUniPerfScope;
begin
  UniPerfInc(upcCalculateRowHeight);
  PerfTimer := TUniPerfScope.Start(upcCalculateRowHeight);
  try
    LineHeight := FFontSize + 4.0;
    Result := FListRowHeight;
    if not FListAutoRowHeight then
      Exit;
    ItemIndex := DisplayItemIndex(ADisplayIndex);
    if ItemIndex < 0 then
      Exit;
    for ColumnIndex := 0 to FColumns.Count - 1 do
      if FColumns[ColumnIndex].Visible and FColumns[ColumnIndex].WrapText then
      begin
        TextValueLocal := ColumnDisplayText(FItems[ItemIndex], FColumns[ColumnIndex]);
        Lines := WrapCellText(TextValueLocal, Max(1, FColumnWidths[ColumnIndex] - 20),
          FColumns[ColumnIndex].MaxLines);
        LineCount := Max(1, Length(Lines));
        Result := Max(Result, CELL_VERTICAL_PADDING + LineCount * LineHeight);
      end;
  finally
    PerfTimer.Stop;
  end;
end;

function TUniListView.WrapCellText(const AText: string; const AWidth: Single;
  const AMaxLines: Integer): TArray<string>;
var
  Words, Lines: TList<string>;
  Parts: TArray<string>;
  Part, Current, Candidate: string;
  I: Integer;
begin
  Words := TList<string>.Create;
  Lines := TList<string>.Create;
  try
    Parts := AText.Replace(#13, '').Split([#10, ' ']);
    for Part in Parts do
      Words.Add(Part);
    Current := '';
    for I := 0 to Words.Count - 1 do
    begin
      if Current = '' then
        Candidate := Words[I]
      else
        Candidate := Current + ' ' + Words[I];
      if (Current <> '') and (EstimateTextWidth(Candidate, FFontSize) > AWidth) then
      begin
        Lines.Add(Current);
        Current := Words[I];
        if (AMaxLines > 0) and (Lines.Count >= AMaxLines) then
          Break;
      end
      else
        Current := Candidate;
    end;
    if ((AMaxLines = 0) or (Lines.Count < AMaxLines)) and (Current <> '') then
      Lines.Add(Current);
    Result := Lines.ToArray;
  finally
    Lines.Free;
    Words.Free;
  end;
end;

function TUniListView.ListDisplayIndexAtY(const AY: Single): Integer;
var
  L, H, M: Integer;
begin
  Result := -1;
  L := 0;
  H := High(FListRowTops);
  while L <= H do
  begin
    M := L + (H - L) div 2;
    if AY < FListRowTops[M] then
      H := M - 1
    else if AY >= FListRowTops[M] + FListRowHeights[M] then
      L := M + 1
    else
      Exit(M);
  end;
  if Length(FListRowTops) > 0 then
    Result := EnsureRange(L, 0, High(FListRowTops));
end;

function TUniListView.ColumnDisplayText(AItem: TUniListItem;
  AColumn: TUniListColumn): string;
var
  DateValue: TDateTime;
begin
  case AColumn.DataType of
    ucdtInteger:
      Result := AItem.FieldAsInt64(AColumn.FieldName, 0).ToString;
    ucdtFloat:
      if AColumn.Format <> '' then
        Result := FormatFloat(AColumn.Format,
          AItem.FieldAsFloat(AColumn.FieldName, 0))
      else
        Result := FloatToStr(AItem.FieldAsFloat(AColumn.FieldName, 0));
    ucdtDateTime:
      begin
        DateValue := AItem.FieldAsDateTime(AColumn.FieldName, 0);
        if AColumn.Format <> '' then
          Result := FormatDateTime(AColumn.Format, DateValue)
        else
          Result := DateTimeToStr(DateValue);
      end;
    ucdtBoolean:
      if AItem.FieldAsBoolean(AColumn.FieldName, False) then
        Result := 'True'
      else
        Result := 'False';
  else
    Result := AItem.FieldAsString(AColumn.FieldName, '');
  end;
end;

function TUniListView.ListRowRect(const AIndex: Integer): TRectF;
var
  TopValue, HeightValue: Single;
begin
  if (AIndex < 0) or (AIndex >= Length(FListRowTops)) then
    Exit(TRectF.Empty);
  TopValue := ListBodyTop + FContentPadding + FListRowTops[AIndex] - FScrollY;
  HeightValue := FListRowHeights[AIndex];
  Result := RectF(FContentPadding - FScrollX, TopValue,
    FContentWidth - FContentPadding - FScrollX, TopValue + HeightValue);
end;

function TUniListView.IsColumnFrozen(const AColumnIndex: Integer): Boolean;
begin
  Result := (AColumnIndex >= 0) and (AColumnIndex < FColumns.Count) and
    FColumns[AColumnIndex].Visible and FColumns[AColumnIndex].Frozen;
end;

function TUniListView.FrozenColumnsRight: Single;
var
  ColumnIndex: Integer;
begin
  Result := FContentPadding;
  if CheckBoxesVisible and not FTreeMode then
    Result := Result + LIST_CHECKBOX_AREA_WIDTH;
  for ColumnIndex := 0 to FColumns.Count - 1 do
    if IsColumnFrozen(ColumnIndex) then
      Result := Result + FColumnWidths[ColumnIndex];
end;

function TUniListView.ColumnScreenLeft(const AColumnIndex: Integer): Single;
var
  ColumnIndex: Integer;
begin
  Result := FContentPadding;
  if CheckBoxesVisible and not FTreeMode then
    Result := Result + LIST_CHECKBOX_AREA_WIDTH;
  if IsColumnFrozen(AColumnIndex) then
  begin
    for ColumnIndex := 0 to AColumnIndex - 1 do
      if IsColumnFrozen(ColumnIndex) then
        Result := Result + FColumnWidths[ColumnIndex];
    Exit;
  end;

  Result := FrozenColumnsRight - FScrollX;
  for ColumnIndex := 0 to AColumnIndex - 1 do
    if FColumns[ColumnIndex].Visible and not IsColumnFrozen(ColumnIndex) then
      Result := Result + FColumnWidths[ColumnIndex];
end;

function TUniListView.ListHeaderHit(const P: TPointF): Integer;
var
  ColumnIndex: Integer;
  R: TRectF;
begin
  Result := -1;
  if (P.Y < 0) or (P.Y > FListHeaderHeight) then
    Exit;
  for ColumnIndex := 0 to FColumns.Count - 1 do
    if FColumns[ColumnIndex].Visible then
    begin
      R := RectF(ColumnScreenLeft(ColumnIndex), 0,
        ColumnScreenLeft(ColumnIndex) + FColumnWidths[ColumnIndex],
        FListHeaderHeight);
      if R.Contains(P) then
        Exit(ColumnIndex);
    end;
end;

function TUniListView.ListHeaderDividerHit(const P: TPointF): Integer;
const
  DIVIDER_TOLERANCE = 5.0;
var
  ColumnIndex: Integer;
  DividerX: Single;
begin
  Result := -1;
  if (P.Y < 0) or (P.Y > FListHeaderHeight) then
    Exit;
  for ColumnIndex := 0 to FColumns.Count - 1 do
    if FColumns[ColumnIndex].Visible then
    begin
      DividerX := ColumnScreenLeft(ColumnIndex) + FColumnWidths[ColumnIndex];
      if Abs(P.X - DividerX) <= DIVIDER_TOLERANCE then
        Exit(ColumnIndex);
    end;
end;

procedure TUniListView.AutoFitColumn(const AColumnIndex: Integer);
var
  Column: TUniListColumn;
  Item: TUniListItem;
  NewWidth: Single;
begin
  if (AColumnIndex < 0) or (AColumnIndex >= FColumns.Count) then
    Exit;
  Column := FColumns[AColumnIndex];
  NewWidth := EstimateTextWidth(Column.Caption, FFontSize) + 30;
  for Item in FItems do
    NewWidth := Max(NewWidth, EstimateTextWidth(
      ColumnDisplayText(Item, Column), FFontSize) + 24);
  Column.WidthMode := ucwmFixed;
  Column.Width := EnsureRange(NewWidth, Column.MinWidth, Column.MaxWidth);
  InvalidateLayout;
end;

procedure TUniListView.AutoFitAllColumns;
var
  ColumnIndex: Integer;
begin
  FColumns.BeginUpdate;
  try
    for ColumnIndex := 0 to FColumns.Count - 1 do
      if FColumns[ColumnIndex].Visible then
        AutoFitColumn(ColumnIndex);
  finally
    FColumns.EndUpdate;
  end;
  InvalidateLayout;
end;

procedure TUniListView.MoveColumn(const AFromIndex, AToIndex: Integer);
begin
  if (AFromIndex < 0) or (AToIndex < 0) or
     (AFromIndex >= FColumns.Count) or (AToIndex >= FColumns.Count) or
     (AFromIndex = AToIndex) then
    Exit;
  FColumns[AFromIndex].Index := AToIndex;
  AdjustSortAfterColumnMove(AFromIndex, AToIndex);
  InvalidateLayout;
end;

function TUniListView.VisibleColumnCount: Integer;
var
  ColumnIndex: Integer;
begin
  Result := 0;
  for ColumnIndex := 0 to FColumns.Count - 1 do
    if FColumns[ColumnIndex].Visible then
      Inc(Result);
end;

procedure TUniListView.ResetColumnLayout;
var
  ColumnIndex: Integer;
  Column: TUniListColumn;
begin
  FColumns.BeginUpdate;
  try
    for ColumnIndex := 0 to FColumns.Count - 1 do
    begin
      Column := FColumns[ColumnIndex];
      Column.Visible := True;
      Column.Frozen := False;
      Column.Index := ColumnIndex;
      case ColumnIndex of
        0:
          begin
            Column.WidthMode := ucwmFill;
            Column.Width := Max(Column.MinWidth, 180);
          end;
        1: Column.Width := 140;
        2: Column.Width := 90;
      end;
    end;
  finally
    FColumns.EndUpdate;
  end;
  FSortColumnIndex := -1;
  FSortAscending := True;
  SetLength(FSortColumnIndices, 0);
  SetLength(FSortAscendingValues, 0);
  FScrollX := 0;
  InvalidateLayout;
end;

procedure TUniListView.UpdateColumnChooserRect(const X, Y: Single);
const
  MENU_WIDTH = 250.0;
  ITEM_HEIGHT = 30.0;
  MENU_PADDING = 6.0;
  EDGE_MARGIN = 6.0;
  EXTRA_ITEM_COUNT = 3;
var
  DesiredHeight, MenuHeight, LeftPos, TopPos: Single;
begin
  DesiredHeight := MENU_PADDING * 2 +
    (FColumns.Count + EXTRA_ITEM_COUNT) * ITEM_HEIGHT;
  MenuHeight := Min(DesiredHeight, Max(ITEM_HEIGHT * 3, Height - EDGE_MARGIN * 2));

  LeftPos := X;
  if LeftPos + MENU_WIDTH > Width - EDGE_MARGIN then
    LeftPos := Width - EDGE_MARGIN - MENU_WIDTH;
  LeftPos := Max(EDGE_MARGIN, LeftPos);

  if Y + MenuHeight <= Height - EDGE_MARGIN then
    TopPos := Y
  else
    TopPos := Y - MenuHeight;
  TopPos := EnsureRange(TopPos, EDGE_MARGIN, Max(EDGE_MARGIN, Height - EDGE_MARGIN - MenuHeight));

  FColumnChooserRect := RectF(LeftPos, TopPos,
    LeftPos + Min(MENU_WIDTH, Width - EDGE_MARGIN * 2), TopPos + MenuHeight);
end;

procedure TUniListView.ShowColumnsMenu(const X, Y: Single);
begin
  if (FViewMode <> uvmList) or (FColumns.Count = 0) then
    Exit;
  FColumnChooserScroll := 0;
  FColumnChooserHotIndex := -1;
  FColumnChooserColumnIndex := ListHeaderHit(PointF(X - 4, Y - 4));
  UpdateColumnChooserRect(X, Y);
  FColumnChooserVisible := True;
  Redraw;
end;

procedure TUniListView.HideColumnChooser;
begin
  if not FColumnChooserVisible then
    Exit;
  FColumnChooserVisible := False;
  FColumnChooserHotIndex := -1;
  FColumnChooserColumnIndex := -1;
  Redraw;
end;

function TUniListView.ColumnChooserHit(const P: TPointF): Integer;
const
  ITEM_HEIGHT = 30.0;
  MENU_PADDING = 6.0;
var
  LocalY: Single;
begin
  Result := -1;
  if not FColumnChooserVisible or not FColumnChooserRect.Contains(P) then
    Exit;
  LocalY := P.Y - FColumnChooserRect.Top - MENU_PADDING;
  if LocalY < 0 then
    Exit;
  Result := Trunc(LocalY / ITEM_HEIGHT) + FColumnChooserScroll;
  if Result > FColumns.Count + 2 then
    Result := -1;
end;

procedure TUniListView.DrawColumnChooser(const ACanvas: IUniCanvas);
const
  ITEM_HEIGHT = 30.0;
  MENU_PADDING = 6.0;
  TEXT_PADDING = 34.0;
  CHECK_SIZE = 14.0;
  POPUP_RADIUS = 7.0;
  ITEM_RADIUS = 4.0;
  SHADOW_OFFSET_X = 2.0;
  SHADOW_OFFSET_Y = 3.0;
var
  Paint: IUniPaint;
  Font: IUniFont;
  ItemIndex, FirstItem, LastItem: Integer;
  ItemRect, CheckRect, ShadowRect, CheckIconRect: TRectF;
  Caption: string;
  Baseline: Single;
  IsChecked: Boolean;
  PopupColor: TAlphaColor;
  PopupBorderColor: TAlphaColor;
  PopupHoverColor: TAlphaColor;
  PopupShadowColor: TAlphaColor;
  CheckBorderColor: TAlphaColor;
  CheckMarkColor: TAlphaColor;
begin
  PopupColor := UniBlendColor(FCardColor, FBackgroundColor, 0.18);
  PopupBorderColor := UniBlendColor(FGridColor, FTextColor, 0.20);
  PopupHoverColor := UniBlendColor(PopupColor, FAccentColor, 0.16);
  PopupShadowColor := UniBlendColor($66000000, FBackgroundColor, 0.18);
  CheckBorderColor := UniBlendColor(FSecondaryTextColor, FTextColor, 0.18);
  if FThemeVariant = utvDark then
    CheckMarkColor := FBackgroundColor
  else
    CheckMarkColor := $FFFFFFFF;

  Paint := TUniPaintFactory.Create;
  Paint.AntiAlias := True;
  Paint.Style := TUniPaintStyle.Fill;
  Paint.Color := PopupShadowColor;
  ShadowRect := FColumnChooserRect;
  ShadowRect.Offset(SHADOW_OFFSET_X, SHADOW_OFFSET_Y);
  ACanvas.DrawRoundRect(ShadowRect, POPUP_RADIUS, POPUP_RADIUS, Paint);
  Paint.Color := PopupColor;
  ACanvas.DrawRoundRect(FColumnChooserRect, POPUP_RADIUS, POPUP_RADIUS, Paint);
  Paint.Style := TUniPaintStyle.Stroke;
  Paint.StrokeWidth := 1;
  Paint.Color := PopupBorderColor;
  ACanvas.DrawRoundRect(FColumnChooserRect, POPUP_RADIUS, POPUP_RADIUS, Paint);

  Font := CreateTextFont(FFontSize);
  FirstItem := FColumnChooserScroll;
  LastItem := Min(FColumns.Count + 2, FirstItem +
    Max(1, Trunc((FColumnChooserRect.Height - MENU_PADDING * 2) / ITEM_HEIGHT)) - 1);
  ACanvas.Save;
  ACanvas.ClipRect(FColumnChooserRect);
  for ItemIndex := FirstItem to LastItem do
  begin
    ItemRect := RectF(FColumnChooserRect.Left + MENU_PADDING,
      FColumnChooserRect.Top + MENU_PADDING + (ItemIndex - FirstItem) * ITEM_HEIGHT,
      FColumnChooserRect.Right - MENU_PADDING,
      FColumnChooserRect.Top + MENU_PADDING + (ItemIndex - FirstItem + 1) * ITEM_HEIGHT);
    if ItemIndex = FColumnChooserHotIndex then
    begin
      Paint.Style := TUniPaintStyle.Fill;
      Paint.Color := PopupHoverColor;
      ACanvas.DrawRoundRect(ItemRect, ITEM_RADIUS, ITEM_RADIUS, Paint);
    end;

    if ItemIndex < FColumns.Count then
    begin
      Caption := FColumns[ItemIndex].Caption;
      IsChecked := FColumns[ItemIndex].Visible;
      CheckRect := RectF(ItemRect.Left + 7,
        ItemRect.CenterPoint.Y - CHECK_SIZE * 0.5,
        ItemRect.Left + 7 + CHECK_SIZE,
        ItemRect.CenterPoint.Y + CHECK_SIZE * 0.5);
      Paint.Style := TUniPaintStyle.Stroke;
      Paint.StrokeWidth := 1.4;
      Paint.Color := CheckBorderColor;
      ACanvas.DrawRoundRect(CheckRect, 2, 2, Paint);
      if IsChecked then
      begin
        Paint.Style := TUniPaintStyle.Fill;
        Paint.Color := FAccentColor;
        ACanvas.DrawRoundRect(CheckRect, 2, 2, Paint);
        CheckIconRect := CheckRect;
        CheckIconRect.Inflate(-2, -2);
        DrawVectorIcon(ACanvas, uviCheck, CheckIconRect, CheckMarkColor, 1.5);
      end;
    end
    else if ItemIndex = FColumns.Count then
    begin
      if (FColumnChooserColumnIndex >= 0) and
         (FColumnChooserColumnIndex < FColumns.Count) and
         FColumns[FColumnChooserColumnIndex].Frozen then
        Caption := 'Открепить колонку'
      else
        Caption := 'Закрепить колонку слева';
    end
    else if ItemIndex = FColumns.Count + 1 then
      Caption := 'Показать все колонки'
    else
      Caption := 'Сбросить расположение';

    Paint.Style := TUniPaintStyle.Fill;
    Paint.Color := FTextColor;
    Baseline := ItemRect.Top + (ITEM_HEIGHT + FFontSize) * 0.5 - 1;
    if ItemIndex < FColumns.Count then
      ACanvas.DrawSimpleText(Caption, ItemRect.Left + TEXT_PADDING, Baseline, Font, Paint)
    else
      ACanvas.DrawSimpleText(Caption, ItemRect.Left + 10, Baseline, Font, Paint);
  end;
  ACanvas.Restore;
end;

procedure TUniListView.DrawListHeader(const ACanvas: IUniCanvas);
var
  Paint: IUniPaint;
  Font: IUniFont;
  ColumnIndex, DrawPass, SortIndex: Integer;
  R, PassClip: TRectF;
  TextX, Baseline, FrozenRight: Single;
begin
  Paint := TUniPaintFactory.Create;
  Paint.AntiAlias := True;
  Paint.Style := TUniPaintStyle.Fill;
  Paint.Color := FHeaderColor;
  ACanvas.DrawRect(RectF(0, 0, Width, FListHeaderHeight), Paint);
  Font := CreateTextFont(FFontSize);
  Baseline := (FListHeaderHeight + FFontSize) * 0.5 - 1;
  FrozenRight := Min(Width, FrozenColumnsRight);

  for DrawPass := 0 to 1 do
  begin
    if DrawPass = 0 then
      PassClip := RectF(FrozenRight, 0, Width, FListHeaderHeight)
    else
      PassClip := RectF(0, 0, FrozenRight, FListHeaderHeight);
    ACanvas.Save;
    ACanvas.ClipRect(PassClip);
    for ColumnIndex := 0 to FColumns.Count - 1 do
      if FColumns[ColumnIndex].Visible and
         (IsColumnFrozen(ColumnIndex) = (DrawPass = 1)) then
      begin
        R := RectF(ColumnScreenLeft(ColumnIndex), 0,
          ColumnScreenLeft(ColumnIndex) + FColumnWidths[ColumnIndex],
          FListHeaderHeight);
        Paint.Style := TUniPaintStyle.Fill;
        Paint.Color := FHeaderColor;
        ACanvas.DrawRect(R, Paint);
        Paint.Color := FTextColor;
        TextX := R.Left + 10;
        ACanvas.Save;
        ACanvas.ClipRect(R);
        ACanvas.DrawSimpleText(FColumns[ColumnIndex].Caption, TextX, Baseline,
          Font, Paint);
        SortIndex := SortCriterionIndex(ColumnIndex);
        if SortIndex >= 0 then
        begin
          if FSortAscendingValues[SortIndex] then
            DrawVectorIcon(ACanvas, uviChevronDown,
              RectF(R.Right - 27, 10, R.Right - 15, 22), ResolveIconColor(FAccentColor), 1.5)
          else
            DrawVectorIcon(ACanvas, uviChevronUp,
              RectF(R.Right - 27, 10, R.Right - 15, 22), ResolveIconColor(FAccentColor), 1.5);
          ACanvas.DrawSimpleText(IntToStr(SortIndex + 1), R.Right - 13,
            Baseline, Font, Paint);
        end;
        if FColumns[ColumnIndex].FilterValue <> '' then
        begin
          Paint.Style := TUniPaintStyle.Fill;
          Paint.Color := FAccentColor;
          ACanvas.DrawCircle(R.Right - 7, 7, 3, Paint);
        end;
        ACanvas.Restore;
        if FListGridLines and not IsLastVisibleColumn(ColumnIndex) then
        begin
          Paint.Style := TUniPaintStyle.Stroke;
          Paint.StrokeWidth := 1;
          Paint.Color := FGridColor;
          ACanvas.DrawLine(R.Right, 0, R.Right, FListHeaderHeight, Paint);
        end;
      end;
    ACanvas.Restore;
  end;

  if FListHorizontalGridLines then
  begin
    Paint.Style := TUniPaintStyle.Stroke;
    Paint.StrokeWidth := 1;
    Paint.Color := FGridColor;
    ACanvas.DrawLine(0, FListHeaderHeight - 0.5, Width,
      FListHeaderHeight - 0.5, Paint);
  end;
  if FrozenColumnsRight > FContentPadding then
  begin
    Paint.Color := FGridColor;
    ACanvas.DrawLine(FrozenRight - 0.5, 0, FrozenRight - 0.5,
      Height, Paint);
  end;
  if FHeaderDragActive and (FHeaderDropColumn >= 0) and
     (FHeaderDropColumn < FColumns.Count) then
  begin
    Paint.Color := FAccentColor;
    Paint.StrokeWidth := 2;
    ACanvas.DrawLine(ColumnScreenLeft(FHeaderDropColumn), 2,
      ColumnScreenLeft(FHeaderDropColumn), FListHeaderHeight - 2, Paint);
  end;
end;

function TUniListView.ListActionsWidth(AItem: TUniListItem): Single;
var
  ActionIndex, VisibleCount: Integer;
begin
  Result := 0;
  if (AItem = nil) or not FCardTemplate.ShowActions then
    Exit;
  VisibleCount := 0;
  for ActionIndex := 0 to FActions.Count - 1 do
    if ActionVisible(AItem, FActions[ActionIndex]) then
    begin
      Result := Result + FActions[ActionIndex].Width;
      Inc(VisibleCount);
    end;
  if VisibleCount = 0 then
    Exit(0);
  Result := Result + LIST_ACTION_HORIZONTAL_PADDING * 2 +
    Max(0, VisibleCount - 1) * LIST_ACTION_GAP +
    LIST_ACTION_SCROLLBAR_RESERVE;
end;

function TUniListView.ListActionRect(AItem: TUniListItem;
  const ARowRect: TRectF; const AActionIndex: Integer): TRectF;
var
  ActionIndex: Integer;
  ActionRight, ActionTop: Single;
begin
  Result := TRectF.Empty;
  if (AItem = nil) or (AActionIndex < 0) or
     (AActionIndex >= FActions.Count) or
     not ActionVisible(AItem, FActions[AActionIndex]) then
    Exit;
  ActionRight := Width - LIST_ACTION_SCROLLBAR_RESERVE -
    LIST_ACTION_HORIZONTAL_PADDING;
  for ActionIndex := FActions.Count - 1 downto 0 do
    if ActionVisible(AItem, FActions[ActionIndex]) then
    begin
      ActionTop := ARowRect.Top +
        Max(LIST_ACTION_VERTICAL_PADDING,
          (ARowRect.Height - FActions[ActionIndex].Width) * 0.5);
      if ActionIndex = AActionIndex then
        Exit(RectF(ActionRight - FActions[ActionIndex].Width,
          ActionTop, ActionRight, ActionTop + FActions[ActionIndex].Width));
      ActionRight := ActionRight - FActions[ActionIndex].Width -
        LIST_ACTION_GAP;
    end;
end;

procedure TUniListView.DrawListActions(const ACanvas: IUniCanvas;
  const AItemIndex: Integer; const ARowRect: TRectF;
  const ABackgroundColor: TAlphaColor);
var
  ActionIndex: Integer;
  ActionRect, IconRect, PanelRect: TRectF;
  IconColor: TAlphaColor;
  IsHot, IsPressed: Boolean;
  Item: TUniListItem;
  Paint: IUniPaint;
  PanelWidth: Single;
begin
  if (AItemIndex < 0) or (AItemIndex >= FItems.Count) then
    Exit;
  Item := FItems[AItemIndex];
  PanelWidth := ListActionsWidth(Item);
  if PanelWidth <= 0 then
    Exit;

  Paint := TUniPaintFactory.Create;
  Paint.AntiAlias := True;
  Paint.Style := TUniPaintStyle.Fill;
  Paint.Color := ABackgroundColor;
  PanelRect := RectF(Width - PanelWidth, ARowRect.Top,
    Width, ARowRect.Bottom);
  ACanvas.DrawRect(PanelRect, Paint);
  if not AreActionsVisibleForItem(AItemIndex) then
    Exit;

  for ActionIndex := FActions.Count - 1 downto 0 do
    if ActionDisplayed(AItemIndex, FActions[ActionIndex]) then
    begin
      ActionRect := ListActionRect(Item, ARowRect, ActionIndex);
      IsHot := (FHotHit.Kind = uchAction) and
        (FHotHit.ItemIndex = AItemIndex) and
        (FHotHit.ActionIndex = ActionIndex);
      IsPressed := (FPressedHit.Kind = uchAction) and
        (FPressedHit.ItemIndex = AItemIndex) and
        (FPressedHit.ActionIndex = ActionIndex) and FMousePressed;
      if IsHot or IsPressed then
      begin
        if IsPressed then
          Paint.Color := UniBlendColor(ABackgroundColor, FAccentColor,
            ACTION_PRESSED_BLEND)
        else
          Paint.Color := UniBlendColor(ABackgroundColor, FAccentColor,
            ACTION_HOVER_BLEND);
        ACanvas.DrawRoundRect(ActionRect, LIST_ACTION_RADIUS,
          LIST_ACTION_RADIUS, Paint);
      end;
      if ActionEnabled(Item, FActions[ActionIndex]) then
        IconColor := ResolveIconColor(FSecondaryTextColor)
      else
        IconColor := UniBlendColor(ABackgroundColor, ResolveIconColor(FSecondaryTextColor),
          ACTION_DISABLED_BLEND);
      IconRect := ActionRect;
      IconRect.Inflate(-LIST_ACTION_ICON_INSET, -LIST_ACTION_ICON_INSET);
      if FActions[ActionIndex].Icon <> uviNone then
        DrawVectorIcon(ACanvas, FActions[ActionIndex].Icon, IconRect,
          IconColor, 1.6);
    end;
end;

procedure TUniListView.DrawListRow(const ACanvas: IUniCanvas;
  const AIndex: Integer; const R: TRectF);
const
  TREE_TOGGLE_STROKE_WIDTH = 1.8;
  TREE_TOGGLE_INSET = 5.0;
var
  Paint: IUniPaint;
  Font: IUniFont;
  ColumnIndex, DrawPass, ItemIndex: Integer;
  CellRect, PassClip, TextClipRect: TRectF;
  TextValueLocal: string;
  TextX, Baseline, TextWidth, FrozenRight, LineHeight,
    ActionPanelWidth, ActionsLeft: Single;
  Lines: TArray<string>;
  LineIndex: Integer;
  TreeToggle, TreeCheck: TRectF;
  TreeColumnName: string;
  CheckState: TUniCheckState;
  TreeTextOffset: Single;
  RowBackground, RowText, CellBackground, CellText,
    EffectiveRowBackground: TAlphaColor;
  UseRowBackground, UseRowText, UseCellBackground, UseCellText: Boolean;
begin
  ItemIndex := DisplayItemIndex(AIndex);
  if ItemIndex < 0 then
    Exit;
  RowBackground := FCardColor;
  RowText := FTextColor;
  ResolveColorRules(FItems[ItemIndex], '', RowBackground, RowText,
    UseRowBackground, UseRowText);
  Paint := TUniPaintFactory.Create;
  Paint.AntiAlias := True;
  Paint.Style := TUniPaintStyle.Fill;
  if ItemIndex = FSelectedIndex then
    Paint.Color := FCardSelectedColor
  else if FHotHit.ItemIndex = ItemIndex then
    Paint.Color := FCardHotColor
  else if UseRowBackground then
    Paint.Color := RowBackground
  else if Odd(AIndex) then
    Paint.Color := FAlternateRowColor
  else
    Paint.Color := FCardColor;
  EffectiveRowBackground := Paint.Color;
  UniPerfInc(upcDrawRowBackground);
  ACanvas.DrawRect(RectF(0, R.Top, Width, R.Bottom), Paint);
  ActionPanelWidth := ListActionsWidth(FItems[ItemIndex]);
  if ActionPanelWidth > 0 then
    ActionsLeft := Width - ActionPanelWidth
  else
    ActionsLeft := Width;
  Font := CreateTextFont(FFontSize);
  LineHeight := FFontSize + 4;
  FrozenRight := Min(Width, FrozenColumnsRight);
  if CheckBoxesVisible and not FTreeMode then
  begin
    TreeCheck := ListCheckRect(AIndex, FirstVisibleColumnIndex, R);
    CheckState := TreeCheckState(ItemIndex);
    DrawCheckBox(ACanvas, TreeCheck, CheckState);
  end;

  for DrawPass := 0 to 1 do
  begin
    if DrawPass = 0 then
      PassClip := RectF(FrozenRight, R.Top, Width, R.Bottom)
    else
      PassClip := RectF(0, R.Top, FrozenRight, R.Bottom);
    ACanvas.Save;
    ACanvas.ClipRect(PassClip);
    for ColumnIndex := 0 to FColumns.Count - 1 do
      if FColumns[ColumnIndex].Visible and
         (IsColumnFrozen(ColumnIndex) = (DrawPass = 1)) then
      begin
        CellRect := RectF(ColumnScreenLeft(ColumnIndex), R.Top,
          ColumnScreenLeft(ColumnIndex) + FColumnWidths[ColumnIndex], R.Bottom);
        TextValueLocal := ColumnDisplayText(FItems[ItemIndex],
          FColumns[ColumnIndex]);
        TreeTextOffset := 0;
        TreeColumnName := FColumns[ColumnIndex].FieldName;
        if FTreeMode and SameText(TreeColumnName, FTreeColumn) then
        begin
          TreeTextOffset := TreeLevel(AIndex) * FTreeIndent + FTreeIndent;
          TreeToggle := TreeToggleRect(AIndex, ColumnIndex, R);
          if CheckBoxesVisible then
            TreeTextOffset := TreeTextOffset + FTreeIndent;
        end;
        CellBackground := RowBackground;
        if UseRowText then CellText := RowText else CellText := FTextColor;
        ResolveColorRules(FItems[ItemIndex], FColumns[ColumnIndex].FieldName,
          CellBackground, CellText, UseCellBackground, UseCellText);
        Paint.Style := TUniPaintStyle.Fill;
        if ItemIndex = FSelectedIndex then
          Paint.Color := FCardSelectedColor
        else if FHotHit.ItemIndex = ItemIndex then
          Paint.Color := FCardHotColor
        else if UseCellBackground then
          Paint.Color := CellBackground
        else if UseRowBackground then
          Paint.Color := RowBackground
        else if Odd(AIndex) then
          Paint.Color := FAlternateRowColor
        else
          Paint.Color := FCardColor;
        UniPerfInc(upcDrawRowColumns);
        ACanvas.DrawRect(CellRect, Paint);
        if UseCellText or UseRowText then
          Paint.Color := CellText
        else
          Paint.Color := FTextColor;
        if FTreeMode and SameText(TreeColumnName, FTreeColumn) and
           TreeNodeCanExpand(ItemIndex) then
        begin
          Paint.Style := TUniPaintStyle.Stroke;
          Paint.StrokeWidth := TREE_TOGGLE_STROKE_WIDTH;
          Paint.Color := FAccentColor;
          if TreeIsExpanded(ItemIndex) then
          begin
            ACanvas.DrawLine(TreeToggle.Left + TREE_TOGGLE_INSET,
              TreeToggle.Top + 6, (TreeToggle.Left + TreeToggle.Right) * 0.5,
              TreeToggle.Bottom - TREE_TOGGLE_INSET, Paint);
            ACanvas.DrawLine((TreeToggle.Left + TreeToggle.Right) * 0.5,
              TreeToggle.Bottom - TREE_TOGGLE_INSET,
              TreeToggle.Right - TREE_TOGGLE_INSET, TreeToggle.Top + 6, Paint);
          end
          else
          begin
            ACanvas.DrawLine(TreeToggle.Left + 6,
              TreeToggle.Top + TREE_TOGGLE_INSET,
              TreeToggle.Right - TREE_TOGGLE_INSET, (TreeToggle.Top + TreeToggle.Bottom) * 0.5, Paint);
            ACanvas.DrawLine(TreeToggle.Right - TREE_TOGGLE_INSET,
              (TreeToggle.Top + TreeToggle.Bottom) * 0.5, TreeToggle.Left + 6,
              TreeToggle.Bottom - TREE_TOGGLE_INSET, Paint);
          end;
          Paint.Style := TUniPaintStyle.Fill;
        end;
        if FTreeMode and CheckBoxesVisible and SameText(TreeColumnName, FTreeColumn) then
        begin
          TreeCheck := TreeCheckRect(AIndex, ColumnIndex, R);
          CheckState := TreeCheckState(ItemIndex);
          DrawCheckBox(ACanvas, TreeCheck, CheckState);
        end;
        TextWidth := EstimateTextWidth(TextValueLocal, FFontSize);
        case FColumns[ColumnIndex].Alignment of
          TTextAlign.Center:
            TextX := CellRect.Left + (CellRect.Width - TextWidth) * 0.5;
          TTextAlign.Trailing:
            TextX := CellRect.Right - TextWidth - 10;
        else
          TextX := CellRect.Left + 10 + TreeTextOffset;
        end;
        TextClipRect := CellRect;
        TextClipRect.Right := Max(TextClipRect.Left,
          Min(TextClipRect.Right, ActionsLeft));
        ACanvas.Save;
        ACanvas.ClipRect(TextClipRect);
        Baseline := R.Top + (R.Height + FFontSize) * 0.5 - 1;
        if FColumns[ColumnIndex].WrapText then
        begin
          Lines := WrapCellText(TextValueLocal, Max(1, CellRect.Width - 20 - TreeTextOffset),
            FColumns[ColumnIndex].MaxLines);
          Baseline := CellRect.Top + 8 + FFontSize;
          for LineIndex := 0 to High(Lines) do
          begin
            TextWidth := EstimateTextWidth(Lines[LineIndex], FFontSize);
            case FColumns[ColumnIndex].Alignment of
              TTextAlign.Center:
                TextX := CellRect.Left + (CellRect.Width - TextWidth) * 0.5;
              TTextAlign.Trailing:
                TextX := CellRect.Right - TextWidth - 10;
            else
              TextX := CellRect.Left + 10 + TreeTextOffset;
            end;
            DrawSearchHighlights(ACanvas, ItemIndex, Lines[LineIndex], TextX,
              Baseline, FFontSize);
            UniPerfInc(upcCanvasFillText);
            UniPerfInc(upcDrawRowText);
            ACanvas.DrawSimpleText(Lines[LineIndex], TextX, Baseline, Font, Paint);
            Baseline := Baseline + LineHeight;
          end;
        end
        else
        begin
          DrawSearchHighlights(ACanvas, ItemIndex, TextValueLocal, TextX,
            Baseline, FFontSize);
          UniPerfInc(upcCanvasFillText);
          UniPerfInc(upcDrawRowText);
          ACanvas.DrawSimpleText(TextValueLocal, TextX, Baseline, Font, Paint);
        end;
        ACanvas.Restore;
        if FListGridLines and not IsLastVisibleColumn(ColumnIndex) then
        begin
          Paint.Style := TUniPaintStyle.Stroke;
          Paint.StrokeWidth := 1;
          Paint.Color := FGridColor;
          UniPerfInc(upcDrawRowGridLines);
          ACanvas.DrawLine(CellRect.Right, R.Top, CellRect.Right, R.Bottom, Paint);
        end;
      end;
    ACanvas.Restore;
  end;
  DrawListActions(ACanvas, ItemIndex, R, EffectiveRowBackground);
  if FListGridLines and FListHorizontalGridLines then
  begin
    Paint.Style := TUniPaintStyle.Stroke;
    Paint.StrokeWidth := 1;
    Paint.Color := FGridColor;
    ACanvas.DrawLine(0, R.Bottom - 0.5, Width, R.Bottom - 0.5, Paint);
  end;
end;

function TUniListView.FooterDisplayText(
  const AColumn: TUniListColumn): string;
var
  Item: TUniListItem;
  Value, SumValue, MinValue, MaxValue: Double;
  HasValue: Boolean;
  CountValue, DisplayIndex, ItemIndex: Integer;
  FormatValue: string;
begin
  case AColumn.FooterAggregate of
    ufaNone:
      Exit('');
    ufaCustomText:
      Exit(AColumn.FooterText);
    ufaCount:
      Exit(IntToStr(DisplayItemCount));
  end;

  SumValue := 0;
  MinValue := 0;
  MaxValue := 0;
  CountValue := 0;
  HasValue := False;
  for DisplayIndex := 0 to DisplayItemCount - 1 do
  begin
    ItemIndex := DisplayItemIndex(DisplayIndex);
    Item := FItems[ItemIndex];
    Value := Item.FieldAsFloat(AColumn.FieldName, 0);
    if not HasValue then
    begin
      MinValue := Value;
      MaxValue := Value;
      HasValue := True;
    end
    else
    begin
      MinValue := Min(MinValue, Value);
      MaxValue := Max(MaxValue, Value);
    end;
    SumValue := SumValue + Value;
    Inc(CountValue);
  end;

  if not HasValue then
    Exit('');
  case AColumn.FooterAggregate of
    ufaSum: Value := SumValue;
    ufaMin: Value := MinValue;
    ufaMax: Value := MaxValue;
    ufaAverage:
      if CountValue > 0 then Value := SumValue / CountValue else Value := 0;
  else
    Value := 0;
  end;
  FormatValue := AColumn.FooterFormat;
  if FormatValue = '' then
    FormatValue := AColumn.Format;
  if FormatValue <> '' then
    Result := FormatFloat(FormatValue, Value)
  else
    Result := FloatToStr(Value);
end;

procedure TUniListView.DrawListFooter(const ACanvas: IUniCanvas);
var
  Paint: IUniPaint;
  Font: IUniFont;
  ColumnIndex, DrawPass: Integer;
  R, PassClip: TRectF;
  TextValueLocal: string;
  TextX, TextWidth, Baseline, FrozenRight, FooterTop: Single;
begin
  if not FListFooterVisible then
    Exit;
  FooterTop := Height - FListFooterHeight;
  Paint := TUniPaintFactory.Create;
  Paint.AntiAlias := True;
  Paint.Style := TUniPaintStyle.Fill;
  Paint.Color := FFooterColor;
  ACanvas.DrawRect(RectF(0, FooterTop, Width, Height), Paint);
  Font := CreateTextFont(FFontSize);
  Baseline := FooterTop + (FListFooterHeight + FFontSize) * 0.5 - 1;
  FrozenRight := Min(Width, FrozenColumnsRight);

  for DrawPass := 0 to 1 do
  begin
    if DrawPass = 0 then
      PassClip := RectF(FrozenRight, FooterTop, Width, Height)
    else
      PassClip := RectF(0, FooterTop, FrozenRight, Height);
    ACanvas.Save;
    ACanvas.ClipRect(PassClip);
    for ColumnIndex := 0 to FColumns.Count - 1 do
      if FColumns[ColumnIndex].Visible and
         (IsColumnFrozen(ColumnIndex) = (DrawPass = 1)) then
      begin
        R := RectF(ColumnScreenLeft(ColumnIndex), FooterTop,
          ColumnScreenLeft(ColumnIndex) + FColumnWidths[ColumnIndex], Height);
        Paint.Style := TUniPaintStyle.Fill;
        Paint.Color := FFooterColor;
        ACanvas.DrawRect(R, Paint);
        TextValueLocal := FooterDisplayText(FColumns[ColumnIndex]);
        Paint.Color := FTextColor;
        TextWidth := EstimateTextWidth(TextValueLocal, FFontSize);
        case FColumns[ColumnIndex].Alignment of
          TTextAlign.Center: TextX := R.Left + (R.Width - TextWidth) * 0.5;
          TTextAlign.Trailing: TextX := R.Right - TextWidth - 10;
        else
          TextX := R.Left + 10;
        end;
        ACanvas.Save;
        ACanvas.ClipRect(R);
        ACanvas.DrawSimpleText(TextValueLocal, TextX, Baseline, Font, Paint);
        ACanvas.Restore;
        if FListGridLines and not IsLastVisibleColumn(ColumnIndex) then
        begin
          Paint.Style := TUniPaintStyle.Stroke;
          Paint.StrokeWidth := 1;
          Paint.Color := FGridColor;
          ACanvas.DrawLine(R.Right, FooterTop, R.Right, Height, Paint);
        end;
      end;
    ACanvas.Restore;
  end;
  if FListHorizontalGridLines then
  begin
    Paint.Style := TUniPaintStyle.Stroke;
    Paint.StrokeWidth := 1;
    Paint.Color := FGridColor;
    ACanvas.DrawLine(0, FooterTop + 0.5, Width, FooterTop + 0.5, Paint);
  end;
end;

procedure TUniListView.DrawList(const ACanvas: IUniCanvas;
  const ADest: TRectF);
var
  ItemIndex, FirstIndex, LastIndex: Integer;
  DrawnCount: Int64;
  R: TRectF;
begin
  FirstIndex := 0;
  LastIndex := -1;
  DrawnCount := 0;
  if DisplayItemCount > 0 then
  begin
    FirstIndex := FirstVisibleIndex;
    LastIndex := LastVisibleIndex;
    for ItemIndex := FirstIndex to LastIndex do
    begin
      R := ListRowRect(ItemIndex);
      if (R.Bottom >= ListBodyTop) and
         (R.Top <= Height - IfThen(FListFooterVisible, FListFooterHeight, 0)) then
      begin
        DrawListRow(ACanvas, ItemIndex, R);
        Inc(DrawnCount);
        if FTreeMode then
          UniPerfInc(upcDrawTreeNode)
        else
          UniPerfInc(upcDrawRow);
      end;
    end;
  end;
  UniPerfSetContext(FItems.Count, Max(0, LastIndex - FirstIndex + 1));
  UniPerfSetLastPaint(Max(0, LastIndex - FirstIndex + 1), DrawnCount,
    Max(0, LastIndex - FirstIndex + 1));
  DrawListHeader(ACanvas);
  DrawListFilter(ACanvas);
  DrawListFooter(ACanvas);
end;

function TUniListView.SortCriterionIndex(
  const AColumnIndex: Integer): Integer;
var
  CriterionIndex: Integer;
begin
  Result := -1;
  for CriterionIndex := 0 to High(FSortColumnIndices) do
    if FSortColumnIndices[CriterionIndex] = AColumnIndex then
      Exit(CriterionIndex);
end;

procedure TUniListView.SyncPrimarySort;
begin
  if Length(FSortColumnIndices) = 0 then
  begin
    FSortColumnIndex := -1;
    FSortAscending := True;
    Exit;
  end;
  FSortColumnIndex := FSortColumnIndices[0];
  FSortAscending := FSortAscendingValues[0];
end;

procedure TUniListView.AdjustSortAfterColumnMove(const AFromIndex,
  AToIndex: Integer);
var
  CriterionIndex: Integer;
  ColumnIndex: Integer;
begin
  for CriterionIndex := 0 to High(FSortColumnIndices) do
  begin
    ColumnIndex := FSortColumnIndices[CriterionIndex];
    if ColumnIndex = AFromIndex then
      FSortColumnIndices[CriterionIndex] := AToIndex
    else if (AFromIndex < ColumnIndex) and (AToIndex >= ColumnIndex) then
      Dec(FSortColumnIndices[CriterionIndex])
    else if (AFromIndex > ColumnIndex) and (AToIndex <= ColumnIndex) then
      Inc(FSortColumnIndices[CriterionIndex]);
  end;
  SyncPrimarySort;
end;

procedure TUniListView.ApplyCurrentSort;
var
  CriterionIndex: Integer;
  FieldNames: TArray<string>;
  Ascending: TArray<Boolean>;
begin
  if FApplyingSort or (Length(FSortColumnIndices) = 0) or
     (FItems.Count < 2) then
    Exit;

  SetLength(FieldNames, Length(FSortColumnIndices));
  SetLength(Ascending, Length(FSortColumnIndices));
  for CriterionIndex := 0 to High(FSortColumnIndices) do
  begin
    if (FSortColumnIndices[CriterionIndex] < 0) or
       (FSortColumnIndices[CriterionIndex] >= FColumns.Count) or
       (FColumns[FSortColumnIndices[CriterionIndex]].FieldName = '') then
      Exit;
    FieldNames[CriterionIndex] :=
      FColumns[FSortColumnIndices[CriterionIndex]].FieldName;
    Ascending[CriterionIndex] := FSortAscendingValues[CriterionIndex];
  end;

  FApplyingSort := True;
  try
    FItems.SortByFields(FieldNames, Ascending);
  finally
    FApplyingSort := False;
  end;
end;

procedure TUniListView.SortByColumn(const AColumnIndex: Integer;
  const AAddToSort: Boolean);
var
  CriterionIndex: Integer;
  NewLength: Integer;
begin
  if (AColumnIndex < 0) or (AColumnIndex >= FColumns.Count) or
     not FColumns[AColumnIndex].Visible or
     not FColumns[AColumnIndex].Sortable then
    Exit;

  CriterionIndex := SortCriterionIndex(AColumnIndex);
  if not AAddToSort then
  begin
    if (CriterionIndex = 0) and (Length(FSortColumnIndices) = 1) then
      FSortAscendingValues[0] := not FSortAscendingValues[0]
    else
    begin
      SetLength(FSortColumnIndices, 1);
      SetLength(FSortAscendingValues, 1);
      FSortColumnIndices[0] := AColumnIndex;
      FSortAscendingValues[0] := True;
    end;
  end
  else if CriterionIndex >= 0 then
    FSortAscendingValues[CriterionIndex] :=
      not FSortAscendingValues[CriterionIndex]
  else
  begin
    NewLength := Length(FSortColumnIndices) + 1;
    SetLength(FSortColumnIndices, NewLength);
    SetLength(FSortAscendingValues, NewLength);
    FSortColumnIndices[NewLength - 1] := AColumnIndex;
    FSortAscendingValues[NewLength - 1] := True;
  end;

  SyncPrimarySort;
  ApplyCurrentSort;
  FSelectedIndex := -1;
  InvalidateLayout;
end;

procedure TUniListView.DrawScrollBars(const ACanvas: IUniCanvas);
var
  Paint: IUniPaint;
  R: TRectF;
begin
  if FScrollBars = usbNever then Exit;
  Paint := TUniPaintFactory.Create;
  Paint.AntiAlias := True;
  Paint.Color := FGridColor;
  Paint.Style := TUniPaintStyle.Fill;
  if ((FScrollBars = usbAlways) or (FContentHeight > Height)) and
     (FScrollMode in [usmVertical, usmBoth]) then
  begin
    R := VScrollRect;
    if not R.IsEmpty then ACanvas.DrawRoundRect(R, 3, 3, Paint);
  end;
  if ((FScrollBars = usbAlways) or (FContentWidth > Width)) and
     (FScrollMode in [usmHorizontal, usmBoth]) then
  begin
    R := HScrollRect;
    if not R.IsEmpty then ACanvas.DrawRoundRect(R, 3, 3, Paint);
  end;
end;

function TUniListView.HScrollRect: TRectF;
var
  Track, Thumb, MaxOffset: Single;
begin
  Result := TRectF.Empty;
  if FCardLayout = uclFullWidth then
    Exit;
  if FContentWidth <= Width then Exit;
  Track := Width - 16;
  Thumb := Max(24, Track * Width / FContentWidth);
  MaxOffset := FContentWidth - Width;
  Result := RectF(8 + (Track - Thumb) * (FScrollX / MaxOffset), Height - 7,
    8 + (Track - Thumb) * (FScrollX / MaxOffset) + Thumb, Height - 3);
end;

function TUniListView.VScrollRect: TRectF;
var
  Track, Thumb, MaxOffset: Single;
begin
  Result := TRectF.Empty;
  if FContentHeight <= Height then Exit;
  Track := Height - 16;
  Thumb := Max(24, Track * Height / FContentHeight);
  MaxOffset := FContentHeight - Height;
  Result := RectF(Width - 7, 8 + (Track - Thumb) * (FScrollY / MaxOffset),
    Width - 3, 8 + (Track - Thumb) * (FScrollY / MaxOffset) + Thumb);
end;

function TUniListView.HitTestAt(const P: TPointF): TUniCardHit;
var
  I, A, ItemIndex: Integer;
  R, AR, TR: TRectF;
  ActionGap, ActionPadding, ActionTop, ActionX: Single;
  Part: TUniTextPart;
  PerfTimer: TUniPerfScope;
begin
  UniPerfInc(upcHitTest);
  PerfTimer := TUniPerfScope.Start(upcHitTest);
  try
  EnsureLayout;
  Result := TUniCardHit.None;
  if VScrollRect.Contains(P) then begin Result.Kind := uchVScrollThumb; Exit; end;
  if HScrollRect.Contains(P) then begin Result.Kind := uchHScrollThumb; Exit; end;
  if CardTreeActive and CardTreeNavigationPresentation and
     FCardTreeShowBreadcrumbs and (P.Y <= FCardTreeBreadcrumbHeight) then
  begin
    if FCardTreeShowBackButton and CardTreeCanNavigateBack and
       (P.X <= FContentPadding + FCardTreeNavigationIconSize +
         CARD_TREE_ICON_PADDING) then
    begin
      Result.Kind := uchCardTreeBack;
      Exit;
    end;
    for I := 0 to High(FCardTreeBreadcrumbs) do
      if FCardTreeBreadcrumbs[I].Bounds.Contains(P) then
      begin
        Result.Kind := uchCardTreeBreadcrumb;
        Result.ActionIndex := I;
        Exit;
      end;
    Exit;
  end;
  if FViewMode = uvmList then
  begin
    A := ListHeaderHit(P);
    if A >= 0 then
    begin
      Result.Kind := uchHeader;
      Result.ActionIndex := A;
      Exit;
    end;
    if FListFilterVisible and (P.Y >= FListHeaderHeight) and
       (P.Y < ListBodyTop) then
    begin
      A := FilterColumnHit(P);
      if A >= 0 then
      begin
        Result.Kind := uchHeader;
        Result.ActionIndex := A;
      end;
      Exit;
    end;
    I := ListDisplayIndexAtY(P.Y - ListBodyTop - FContentPadding + FScrollY);
    if (I >= 0) and (I < DisplayItemCount) and ListRowRect(I).Contains(P) then
    begin
      ItemIndex := DisplayItemIndex(I);
      if AreActionsVisibleForItem(ItemIndex) then
        for A := FActions.Count - 1 downto 0 do
          if ActionDisplayed(ItemIndex, FActions[A]) then
          begin
            AR := ListActionRect(FItems[ItemIndex], ListRowRect(I), A);
            if AR.Contains(P) then
            begin
              Result.Kind := uchAction;
              Result.ItemIndex := ItemIndex;
              Result.ActionIndex := A;
              Exit;
            end;
          end;
      Result.Kind := uchItem;
      Result.ItemIndex := ItemIndex;
    end;
    Exit;
  end;
  for I := FirstVisibleIndex to LastVisibleIndex do
  begin
    R := CardRect(I);
    if not R.Contains(P) then Continue;
    ItemIndex := CardDisplayItemIndex(I);
    if ItemIndex < 0 then
      Continue;
    if CardTreeActive and CardTreeItemHasChildren(ItemIndex) then
    begin
      AR := R;
      AR.Left := AR.Right - FCardTreeNavigationIconSize -
        CARD_TREE_ICON_PADDING;
      AR.Top := AR.Top + CARD_TREE_ICON_PADDING;
      AR.Right := AR.Left + FCardTreeNavigationIconSize;
      AR.Bottom := AR.Top + FCardTreeNavigationIconSize;
      if AR.Contains(P) then
      begin
        if CardTreeNavigationPresentation then
          Result.Kind := uchCardTreeNavigate
        else
          Result.Kind := uchCardTreeExpand;
        Result.ItemIndex := ItemIndex;
        Exit;
      end;
    end;
    if AreActionsVisibleForItem(ItemIndex) then
    begin
      if FCardLayout = uclFullWidth then
      begin
        ActionPadding := FULL_WIDTH_CARD_HORIZONTAL_PADDING;
        ActionTop := FULL_WIDTH_CARD_VERTICAL_PADDING;
        ActionGap := FULL_WIDTH_CARD_ACTION_GAP;
      end
      else
      begin
        ActionPadding := FCardTemplate.InnerPadding;
        ActionTop := FCardTemplate.InnerPadding;
        ActionGap := GRID_CARD_ACTION_GAP;
      end;
      ActionX := R.Right - ActionPadding;
      if CardTreeActive and CardTreeItemHasChildren(ItemIndex) then
        ActionX := ActionX - FCardTreeNavigationIconSize -
          CARD_TREE_ICON_PADDING;
      for A := FActions.Count - 1 downto 0 do
        if ActionDisplayed(ItemIndex, FActions[A]) then
        begin
          AR := RectF(ActionX - FActions[A].Width,
            R.Top + ActionTop, ActionX,
            R.Top + ActionTop + FActions[A].Width);
          if AR.Contains(P) then
          begin
            Result.Kind := uchAction;
            Result.ItemIndex := ItemIndex;
            Result.ActionIndex := A;
            Exit;
          end;
          ActionX := AR.Left - ActionGap;
        end;
    end;
    if FCardTemplate.SelectableText then
      for Part := utpTitle to utpDetail do
      begin
        TR := TextRect(ItemIndex, Part);
        if (not TR.IsEmpty) and TR.Contains(P) then
        begin
          Result.Kind := uchText;
          Result.ItemIndex := ItemIndex;
          Result.TextPart := Part;
          Exit;
        end;
      end;
    Result.Kind := uchItem;
    Result.ItemIndex := ItemIndex;
    Exit;
  end;
  finally
    PerfTimer.Stop;
  end;
end;

function TUniListView.TextValue(const AHit: TUniCardHit): string;
begin
  Result := '';
  if (AHit.ItemIndex < 0) or (AHit.ItemIndex >= FItems.Count) then Exit;
  case AHit.TextPart of
    utpTitle: Result := ItemTitle(FItems[AHit.ItemIndex]);
    utpText: Result := ItemText(FItems[AHit.ItemIndex]);
    utpDetail: Result := ItemDetail(FItems[AHit.ItemIndex]);
  end;
end;

procedure TUniListView.SelectTextHit(const AHit: TUniCardHit);
begin
  if AHit.Kind <> uchText then Exit;
  FSelectedTextHit := AHit;
  FSelectedText := TextValue(AHit);
  Redraw;
end;

procedure TUniListView.CopySelectedText;
var
  Clipboard: IFMXClipboardService;
begin
  if FSelectedText = '' then Exit;
  if TPlatformServices.Current.SupportsPlatformService(
    IFMXClipboardService, Clipboard) then
    Clipboard.SetClipboard(TValue.From<string>(FSelectedText));
end;

procedure TUniListView.ItemsChanged(Sender: TObject);
var
  OldCheckedCount: Integer;
begin
  OldCheckedCount := FCheckedCount;
  RecalculateCheckedCount;
  if (not FCheckBatch) and (OldCheckedCount <> FCheckedCount) and
     Assigned(FOnCheckedChanged) then
    FOnCheckedChanged(Self);
  FHotHit := TUniCardHit.None;
  if FPressedHit.Kind = uchAction then
    FPressedHit := TUniCardHit.None;
  if not FApplyingSort then
    ApplyCurrentSort;
  RebuildFilter;
  if (FTreeCheckMode = tcmCascadeFull) and not FApplyingCheckEngine then
  begin
    FApplyingCheckEngine := True;
    FCheckBatch := True;
    try
      RecalculateTreeCheckStatesInternal;
    finally
      FCheckBatch := False;
      FApplyingCheckEngine := False;
    end;
    RecalculateCheckedCount;
  end;
  InvalidateAutoTitleWidth;
  InvalidateLayout;
end;

procedure TUniListView.DoItemClick(const AItemIndex: Integer);
begin
  if Assigned(FOnItemClick) then
    FOnItemClick(Self, AItemIndex);
end;

procedure TUniListView.DoItemDoubleClick(const AItemIndex: Integer);
begin
end;

procedure TUniListView.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Single);
var
  DividerColumn: Integer;
begin
  inherited;
  if Button <> TMouseButton.mbLeft then
    Exit;
  if FColumnChooserVisible then
  begin
    FMouseDownPos := PointF(X, Y);
    FMousePressed := True;
    Exit;
  end;
  SetFocus;
  EnsureLayout;
  FMousePressed := True;
  FMouseDownPos := PointF(X, Y);
  FMouseDownScroll := PointF(FScrollX, FScrollY);
  DividerColumn := -1;
  if FViewMode = uvmList then
    DividerColumn := ListHeaderDividerHit(FMouseDownPos);
  if DividerColumn >= 0 then
  begin
    FHeaderResizeColumn := DividerColumn;
    FHeaderResizeStartWidth := FColumnWidths[DividerColumn];
    FPressedHit := TUniCardHit.None;
    FPanning := False;
    FSelectingText := False;
    Exit;
  end;
  FPressedHit := HitTestAt(FMouseDownPos);
  FHeaderDragColumn := -1;
  FHeaderDropColumn := -1;
  FHeaderDragActive := False;
  if FPressedHit.Kind = uchHeader then
    FHeaderDragColumn := FPressedHit.ActionIndex;
  FPanning := False;
  FSelectingText := FPressedHit.Kind = uchText;
end;

procedure TUniListView.MouseMove(Shift: TShiftState; X, Y: Single);
var
  P, D: TPointF;
  NewHit: TUniCardHit;
  PerfTimer: TUniPerfScope;
begin
  UniPerfInc(upcMouseMove);
  PerfTimer := TUniPerfScope.Start(upcMouseMove);
  try
  inherited;
  P := PointF(X, Y);
  if FColumnChooserVisible then
  begin
    NewHit := TUniCardHit.None;
    if FColumnChooserHotIndex <> ColumnChooserHit(P) then
    begin
      FColumnChooserHotIndex := ColumnChooserHit(P);
      Redraw;
    end;
    Exit;
  end;
  if FMousePressed then
  begin
    D := P - FMouseDownPos;
    if FHeaderResizeColumn >= 0 then
    begin
      FColumns[FHeaderResizeColumn].WidthMode := ucwmFixed;
      FColumns[FHeaderResizeColumn].Width := EnsureRange(
        FHeaderResizeStartWidth + D.X,
        FColumns[FHeaderResizeColumn].MinWidth,
        FColumns[FHeaderResizeColumn].MaxWidth);
      InvalidateLayout;
      Exit;
    end;
    if FHeaderDragColumn >= 0 then
    begin
      if not FHeaderDragActive and (Abs(D.X) >= FPanThreshold) then
        FHeaderDragActive := True;
      if FHeaderDragActive then
      begin
        FHeaderDropColumn := ListHeaderHit(P);
        if FHeaderDropColumn < 0 then
          FHeaderDropColumn := FHeaderDragColumn;
        Cursor := crHandPoint;
        Redraw;
      end;
      Exit;
    end;
    if FPressedHit.Kind = uchVScrollThumb then
    begin
      FScrollY := FMouseDownScroll.Y + D.Y * (FContentHeight - Height) /
        Max(1, (Height - 16) - VScrollRect.Height);
      ClampScroll; Redraw; Exit;
    end;
    if FPressedHit.Kind = uchHScrollThumb then
    begin
      FScrollX := FMouseDownScroll.X + D.X * (FContentWidth - Width) /
        Max(1, (Width - 16) - HScrollRect.Width);
      ClampScroll; Redraw; Exit;
    end;
    if FSelectingText then
    begin
      if Sqrt(Sqr(D.X) + Sqr(D.Y)) >= 2 then
        SelectTextHit(FPressedHit);
      Exit;
    end;
    if CanPanWithMouse and not FPanning and
       (Sqrt(Sqr(D.X) + Sqr(D.Y)) >= FPanThreshold) and
       (FPressedHit.Kind <> uchAction) then
      FPanning := True;
    if FPanning then
    begin
      if FScrollMode in [usmHorizontal, usmBoth] then
        FScrollX := FMouseDownScroll.X - D.X;
      if FScrollMode in [usmVertical, usmBoth] then
        FScrollY := FMouseDownScroll.Y - D.Y;
      ClampScroll; Redraw;
    end;
    Exit;
  end;
  NewHit := HitTestAt(P);
  if (NewHit.Kind <> FHotHit.Kind) or
     (NewHit.ItemIndex <> FHotHit.ItemIndex) or
     (NewHit.ActionIndex <> FHotHit.ActionIndex) or
     (NewHit.TextPart <> FHotHit.TextPart) then
  begin
    UniPerfAddHoverChanged;
    if NewHit.Kind = uchCardTreeBreadcrumb then
      FCardTreeHotBreadcrumb := NewHit.ActionIndex
    else
      FCardTreeHotBreadcrumb := -1;
    FHotHit := NewHit;
    if (FViewMode = uvmList) and (ListHeaderDividerHit(P) >= 0) then
      Cursor := crSizeWE
    else if NewHit.Kind = uchText then
      Cursor := crIBeam
    else
      Cursor := crDefault;
    UniPerfAddHoverRepaint;
    UniPerfInc(upcRequestRepaint);
    Redraw;
  end
  else
    UniPerfAddHoverUnchanged;
  finally
    PerfTimer.Stop;
  end;
end;

procedure TUniListView.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Single);
var
  Hit: TUniCardHit;
  ColumnIndex, TreeDisplayIndex: Integer;
  CardAction: TUniCardAction;
begin
  inherited;
  if FColumnChooserVisible then
  begin
    if Button = TMouseButton.mbLeft then
    begin
      FColumnChooserHotIndex := ColumnChooserHit(PointF(X, Y));
      if FColumnChooserHotIndex < 0 then
        HideColumnChooser
      else if FColumnChooserHotIndex < FColumns.Count then
      begin
        if FColumns[FColumnChooserHotIndex].Visible and
           (VisibleColumnCount <= 1) then
          Exit;
        FColumns[FColumnChooserHotIndex].Visible :=
          not FColumns[FColumnChooserHotIndex].Visible;
        InvalidateLayout;
        UpdateColumnChooserRect(FColumnChooserRect.Left, FColumnChooserRect.Top);
      end
      else if FColumnChooserHotIndex = FColumns.Count then
      begin
        if (FColumnChooserColumnIndex >= 0) and
           (FColumnChooserColumnIndex < FColumns.Count) then
        begin
          FColumns[FColumnChooserColumnIndex].Frozen :=
            not FColumns[FColumnChooserColumnIndex].Frozen;
          FScrollX := 0;
          InvalidateLayout;
        end;
        HideColumnChooser;
      end
      else if FColumnChooserHotIndex = FColumns.Count + 1 then
      begin
        FColumns.BeginUpdate;
        try
          for ColumnIndex := 0 to FColumns.Count - 1 do
            FColumns[ColumnIndex].Visible := True;
        finally
          FColumns.EndUpdate;
        end;
        InvalidateLayout;
      end
      else
      begin
        ResetColumnLayout;
        HideColumnChooser;
      end;
      FMousePressed := False;
      Redraw;
    end;
    Exit;
  end;
  if Button = TMouseButton.mbRight then
  begin
    if (FViewMode = uvmList) and (Y >= 0) and (Y <= FListHeaderHeight) then
      ShowColumnsMenu(X + 4, Y + 4);
    Exit;
  end;
  if Button <> TMouseButton.mbLeft then
    Exit;
  Hit := HitTestAt(PointF(X, Y));
  if Hit.Kind = uchCardTreeBack then
  begin
    CardTreeNavigateToParent;
    FMousePressed := False;
    Exit;
  end;
  if Hit.Kind = uchCardTreeBreadcrumb then
  begin
    if (Hit.ActionIndex >= 0) and
       (Hit.ActionIndex < Length(FCardTreeBreadcrumbs)) then
    begin
      if Assigned(FCardTreeOnBreadcrumbClick) then
        FCardTreeOnBreadcrumbClick(Self,
          FCardTreeBreadcrumbs[Hit.ActionIndex].NodeId);
      if FCardTreeBreadcrumbs[Hit.ActionIndex].NodeId = '' then
        CardTreeNavigateToRoot
      else
        CardTreeNavigateToNode(FCardTreeBreadcrumbs[Hit.ActionIndex].NodeId);
    end;
    FMousePressed := False;
    Exit;
  end;
  if Hit.Kind = uchCardTreeNavigate then
  begin
    CardTreeNavigateToNode(TreeItemKey(Hit.ItemIndex));
    FMousePressed := False;
    Exit;
  end;
  if Hit.Kind = uchCardTreeExpand then
  begin
    if CardTreeIsNodeExpanded(TreeItemKey(Hit.ItemIndex)) then
      CardTreeCollapseNode(TreeItemKey(Hit.ItemIndex))
    else
      CardTreeExpandNode(TreeItemKey(Hit.ItemIndex));
    FMousePressed := False;
    Exit;
  end;
  if CheckBoxesVisible then
  begin
    if (FViewMode = uvmCards) and CardCheckAt(PointF(X, Y), TreeDisplayIndex) then
    begin
      ToggleItemChecked(TreeDisplayIndex);
      FMousePressed := False;
      FPressedHit := TUniCardHit.None;
      Exit;
    end;
    if (FViewMode = uvmList) and (not FTreeMode) and
       ListCheckAt(PointF(X, Y), TreeDisplayIndex) then
    begin
      ToggleItemChecked(DisplayItemIndex(TreeDisplayIndex));
      FMousePressed := False;
      FPressedHit := TUniCardHit.None;
      Exit;
    end;
  end;
  if FTreeMode and (FViewMode = uvmList) then
  begin
    if CheckBoxesVisible and TreeCheckAt(PointF(X, Y), TreeDisplayIndex) then
    begin
      ToggleTreeCheck(TreeDisplayIndex);
      FMousePressed := False;
      FPressedHit := TUniCardHit.None;
      Exit;
    end;
    if TreeToggleAt(PointF(X, Y), TreeDisplayIndex) then
    begin
      ToggleTreeNode(TreeDisplayIndex);
      FMousePressed := False;
      FPressedHit := TUniCardHit.None;
      Exit;
    end;
  end;
  if FHeaderResizeColumn >= 0 then
  begin
    FHeaderResizeColumn := -1;
    FMousePressed := False;
    Cursor := crDefault;
    InvalidateLayout;
    Exit;
  end;
  if FHeaderDragActive then
  begin
    MoveColumn(FHeaderDragColumn, FHeaderDropColumn);
    FHeaderDragColumn := -1;
    FHeaderDropColumn := -1;
    FHeaderDragActive := False;
    FMousePressed := False;
    Cursor := crDefault;
    Redraw;
    Exit;
  end;
  if not FPanning then
  begin
    if FListFilterVisible and (Y >= FListHeaderHeight) and
       (Y < ListBodyTop) and (Hit.Kind = uchHeader) then
    begin
      FFilterEditColumn := Hit.ActionIndex;
      Redraw;
    end
    else if (FPressedHit.Kind = uchHeader) and (Hit.Kind = uchHeader) and
       (Hit.ActionIndex = FPressedHit.ActionIndex) then
      SortByColumn(Hit.ActionIndex, ssCtrl in Shift)
    else if (FPressedHit.Kind = uchText) and
       (Hit.ItemIndex = FPressedHit.ItemIndex) and
       (Hit.TextPart = FPressedHit.TextPart) then
      SelectTextHit(FPressedHit)
    else if (FPressedHit.Kind = uchAction) and
      (Hit.Kind = uchAction) and
      (Hit.ItemIndex = FPressedHit.ItemIndex) and
      (Hit.ActionIndex = FPressedHit.ActionIndex) and
      ActionEnabled(FItems[Hit.ItemIndex], FActions[Hit.ActionIndex]) then
    begin
      CardAction := FActions[Hit.ActionIndex];
      if Assigned(CardAction.Action) then
      begin
        (* Ведём себя как обычный клик по строке (выбор + OnItemClick),
           чтобы обработчики, читающие текущее выделение (а не ActionItemIndex
           напрямую), продолжали работать без переделки. *)
        SetSelectedIndex(Hit.ItemIndex);
        DoItemClick(Hit.ItemIndex);
        FActionItemIndex := Hit.ItemIndex;
        try
          CardAction.Action.Execute;
        finally
          FActionItemIndex := -1;
        end;
      end
      else if Assigned(FOnItemAction) then
        FOnItemAction(Self, Hit.ItemIndex, CardAction.Name);
    end
    else if Hit.ItemIndex >= 0 then
    begin
      if (FCardTreeMode = ctmExplorer) and
         FCardTreeExplorerNavigateOnCardClick and
         CardTreeItemHasChildren(Hit.ItemIndex) then
        CardTreeNavigateToNode(TreeItemKey(Hit.ItemIndex))
      else
      begin
        SetSelectedIndex(Hit.ItemIndex);
        DoItemClick(Hit.ItemIndex);
      end;
    end;
  end;
  FMousePressed := False;
  FPanning := False;
  FSelectingText := False;
  FPressedHit := TUniCardHit.None;
  FHeaderDragColumn := -1;
  FHeaderDropColumn := -1;
  FHeaderDragActive := False;
  Redraw;
end;

procedure TUniListView.MouseWheel(Shift: TShiftState; WheelDelta: Integer;
  var Handled: Boolean);
const
  STEP = 48;
var
  PerfTimer: TUniPerfScope;
begin
  PerfTimer := TUniPerfScope.Start(upcScroll);
  try
  inherited;
  ClearHoverState;
  if FColumnChooserVisible then
  begin
    FColumnChooserScroll := EnsureRange(FColumnChooserScroll - Sign(WheelDelta),
      0, Max(0, FColumns.Count + 2 -
      Max(1, Trunc((FColumnChooserRect.Height - 12) / 30))));
    FColumnChooserHotIndex := -1;
    Redraw;
    Handled := True;
    Exit;
  end;
  if (ssShift in Shift) or (FScrollMode = usmHorizontal) then
    FScrollX := FScrollX - Sign(WheelDelta) * STEP
  else
    FScrollY := FScrollY - Sign(WheelDelta) * STEP;
  ClampScroll;
  Redraw;
  Handled := True;
  finally
    PerfTimer.Stop;
  end;
end;

procedure TUniListView.DoMouseLeave;
begin
  inherited;
  ClearHoverState;
end;

procedure TUniListView.DblClick;
var
  ColumnIndex: Integer;
  MousePos: TPointF;
begin
  inherited;
  MousePos := FMouseDownPos;
  ColumnIndex := -1;
  if FViewMode = uvmList then
    ColumnIndex := ListHeaderDividerHit(MousePos);
  if ColumnIndex >= 0 then
    AutoFitColumn(ColumnIndex)
  else
  begin
    if FHotHit.Kind = uchText then
      SelectTextHit(FHotHit);
    if FHotHit.ItemIndex >= 0 then
      DoItemDoubleClick(FHotHit.ItemIndex);
  end;
end;

procedure TUniListView.KeyDown(var Key: Word; var KeyChar: WideChar;
  Shift: TShiftState);
begin
  inherited;
  if (FFilterEditColumn >= 0) and (FFilterEditColumn < FColumns.Count) then
  begin
    if Key = vkBack then
    begin
      FColumns[FFilterEditColumn].FilterValue :=
        Copy(FColumns[FFilterEditColumn].FilterValue, 1,
        Max(0, Length(FColumns[FFilterEditColumn].FilterValue) - 1));
      Key := 0;
      KeyChar := #0;
      Exit;
    end;
    if Key = vkReturn then
    begin
      FFilterEditColumn := -1;
      Redraw;
      Key := 0;
      KeyChar := #0;
      Exit;
    end;
    if (KeyChar >= #32) and not (ssCtrl in Shift) then
    begin
      FColumns[FFilterEditColumn].FilterValue :=
        FColumns[FFilterEditColumn].FilterValue + KeyChar;
      Key := 0;
      KeyChar := #0;
      Exit;
    end;
  end;
  if CardTreeActive then
  begin
    if (FCardTreeMode <> ctmHierarchy) and (Key = vkRight) and
       (FSelectedIndex >= 0) and
       CardTreeItemHasChildren(FSelectedIndex) then
    begin
      CardTreeNavigateToNode(TreeItemKey(FSelectedIndex));
      Key := 0;
      KeyChar := #0;
      Exit;
    end;
    if CardTreeNavigationPresentation and
       ((Key = vkLeft) or (Key = vkBack)) and CardTreeCanNavigateBack then
    begin
      CardTreeNavigateToParent;
      Key := 0;
      KeyChar := #0;
      Exit;
    end;
    if (FCardTreeMode = ctmHierarchy) and
       (FSelectedIndex >= 0) and CardTreeItemHasChildren(FSelectedIndex) and
       (Key = vkRight) and
       not CardTreeIsNodeExpanded(TreeItemKey(FSelectedIndex)) then
    begin
      CardTreeExpandNode(TreeItemKey(FSelectedIndex));
      Key := 0;
      KeyChar := #0;
      Exit;
    end;
    if (FCardTreeMode = ctmHierarchy) and
       (FSelectedIndex >= 0) and CardTreeItemHasChildren(FSelectedIndex) and
       (Key = vkLeft) and
       CardTreeIsNodeExpanded(TreeItemKey(FSelectedIndex)) then
    begin
      CardTreeCollapseNode(TreeItemKey(FSelectedIndex));
      Key := 0;
      KeyChar := #0;
      Exit;
    end;
  end;
  if FMultiCheck and (Key = vkSpace) and
     (FSelectedIndex >= 0) and (FSelectedIndex < FItems.Count) then
  begin
    ToggleItemChecked(FSelectedIndex);
    Key := 0;
    KeyChar := #0;
    Exit;
  end;
  if (ssCtrl in Shift) and ((Key = Ord('C')) or (Key = Ord('c'))) then
  begin
    CopySelectedText;
    Key := 0;
    KeyChar := #0;
  end
  else if Key = vkEscape then
  begin
    if FColumnChooserVisible then
      HideColumnChooser
    else if FFilterEditColumn >= 0 then
    begin
      FFilterEditColumn := -1;
      Redraw;
    end
    else
      ClearTextSelection;
  end;
end;

procedure TUniListView.Resize;
var
  CanDeferHeightRebuild: Boolean;
  EffectiveTextWidth: Single;
  HeightChanged: Boolean;
  WidthChanged: Boolean;
begin
  inherited;
  if FInitializing or (FItems = nil) then
    Exit;

  WidthChanged := not SameValue(FLastLayoutWidth, Width,
    TEpsilon.Position);
  HeightChanged := not SameValue(FLastLayoutHeight, Height,
    TEpsilon.Position);
  if not WidthChanged and not HeightChanged then
    Exit;

  FLastLayoutWidth := Width;
  FLastLayoutHeight := Height;
  if FColumnChooserVisible then
    HideColumnChooser;

  if not WidthChanged then
  begin
    ClampScroll;
    Redraw;
    Exit;
  end;

  EffectiveTextWidth := TextAvailableWidth(RectF(0, 0,
    CardWidthForViewport(Width), FCardHeight));
  CanDeferHeightRebuild := (FViewMode <> uvmList) and
    (FCardLayout = uclGrid) and HasWrappingCardContent and
    (FPreparedCardWidth >= 0) and
    (Length(FTitleLayouts) = FItems.Count) and
    (Length(FItemHeights) = FItems.Count) and
    not SameValue(FPreparedTextWidth, EffectiveTextWidth,
      TEpsilon.Position);
  FResizeHeightPending := CanDeferHeightRebuild;
  if CanDeferHeightRebuild then
  begin
    FResizeHeightTimer.Enabled := False;
    FResizeHeightTimer.Enabled := True;
  end
  else if FResizeHeightTimer.Enabled then
    FResizeHeightTimer.Enabled := False;
  InvalidateLayout(True);
end;

procedure TUniListView.ReadState(Reader: TReader);
begin
  FColumns.Clear;
  FActions.Clear;
  inherited ReadState(Reader);
end;

procedure TUniListView.Loaded;
begin
  inherited;
  if FUseStyleBook then
  begin
    SaveOwnTheme;
    RefreshStyleBook;
  end;
  RefreshDesignPreview;
  InvalidateLayout;
end;

procedure TUniListView.ScrollToItem(const AIndex: Integer);
var
  R: TRectF;
  DisplayIndex, CandidateDisplayIndex: Integer;
begin
  if (AIndex < 0) or (AIndex >= FItems.Count) then
    Exit;
  EnsureLayout;
  if FViewMode = uvmList then
  begin
    DisplayIndex := -1;
    for CandidateDisplayIndex := 0 to DisplayItemCount - 1 do
      if DisplayItemIndex(CandidateDisplayIndex) = AIndex then
      begin
        DisplayIndex := CandidateDisplayIndex;
        Break;
      end;
    if DisplayIndex < 0 then
      Exit;
    R := ListRowRect(DisplayIndex);
  end
  else
  begin
    DisplayIndex := CardDisplayIndexOf(AIndex);
    if DisplayIndex < 0 then
      Exit;
    R := CardRect(DisplayIndex);
  end;
  if R.Top < 0 then FScrollY := FScrollY + R.Top
  else if R.Bottom > Height then FScrollY := FScrollY + R.Bottom - Height;
  if R.Left < 0 then FScrollX := FScrollX + R.Left
  else if R.Right > Width then FScrollX := FScrollX + R.Right - Width;
  ClampScroll;
  Redraw;
end;

function TUniListView.NavigationItemCount: Integer;
begin
  if FViewMode = uvmList then
    Result := DisplayItemCount
  else
    Result := CardDisplayCount;
end;

function TUniListView.NavigationItemIndex(
  const ADisplayIndex: Integer): Integer;
begin
  if FViewMode = uvmList then
    Result := DisplayItemIndex(ADisplayIndex)
  else
    Result := CardDisplayItemIndex(ADisplayIndex);
end;

function TUniListView.NavigationIndexOfItem(
  const AItemIndex: Integer): Integer;
var
  DisplayIndex: Integer;
begin
  Result := -1;
  if FViewMode <> uvmList then
    Exit(CardDisplayIndexOf(AItemIndex));
  for DisplayIndex := 0 to DisplayItemCount - 1 do
    if DisplayItemIndex(DisplayIndex) = AItemIndex then
      Exit(DisplayIndex);
end;

function TUniListView.NavigationPageSize: Integer;
begin
  Result := 1;
  if NavigationItemCount = 0 then
    Exit;
  EnsureLayout;
  Result := Max(1, LastVisibleIndex - FirstVisibleIndex + 1);
end;

function TUniListView.ItemColumnDisplayText(const AItemIndex: Integer;
  const AColumnName: string): string;
var
  ColumnIndex: Integer;
  Column: TUniListColumn;
begin
  Result := '';
  if (AItemIndex < 0) or (AItemIndex >= FItems.Count) or
     (Trim(AColumnName) = '') then
    Exit;
  for ColumnIndex := 0 to FColumns.Count - 1 do
  begin
    Column := FColumns[ColumnIndex];
    if SameText(Column.FieldName, AColumnName) then
      Exit(ColumnDisplayText(FItems[AItemIndex], Column));
  end;
end;

procedure TUniListView.SetViewMode(const Value: TUniViewMode);
begin
  if FViewMode = Value then
    Exit;
  FViewMode := Value;
  FHotHit := TUniCardHit.None;
  FPressedHit := TUniCardHit.None;
  FScrollX := 0;
  FScrollY := 0;
  HideColumnChooser;
  ClearTextSelection;
  ConfigureSearch;
  InvalidateCardHeightCache;
  InvalidateLayout;
end;

procedure TUniListView.SetCardLayout(const Value: TUniCardLayout);
begin
  if FCardLayout = Value then
    Exit;
  FCardLayout := Value;
  FHotHit := TUniCardHit.None;
  FPressedHit := TUniCardHit.None;
  FScrollX := 0;
  FScrollY := 0;
  ClearTextSelection;
  ConfigureSearch;
  InvalidateCardHeightCache;
  InvalidateLayout;
end;

procedure TUniListView.SetCardSizingMode(const Value: TUniCardSizingMode);
begin
  if FCardSizingMode = Value then
    Exit;
  FCardSizingMode := Value;
  FScrollX := 0;
  InvalidateCardHeightCache;
  InvalidateLayout;
  if FUpdateCount = 0 then
    EnsureLayout;
end;

procedure TUniListView.SetCardMinWidth(const Value: Single);
begin
  if SameValue(FCardMinWidth, Value) then
    Exit;
  FCardMinWidth := Value;
  InvalidateAutoTitleWidth;
  InvalidateLayout;
end;

procedure TUniListView.SetCardMaxWidth(const Value: Single);
begin
  if SameValue(FCardMaxWidth, Value) then
    Exit;
  FCardMaxWidth := Value;
  InvalidateAutoTitleWidth;
  InvalidateLayout;
end;

procedure TUniListView.ShowColumnChooser;
begin
  ShowColumnsMenu(Width * 0.5, Min(FListHeaderHeight, Height) * 0.5);
end;

procedure TUniListView.SetColumnVisible(const AColumnID: string;
  const AVisible: Boolean);
var
  Column: TUniListColumn;
  ColumnIndex: Integer;
begin
  for ColumnIndex := 0 to FColumns.Count - 1 do
  begin
    Column := FColumns[ColumnIndex];
    if SameText(Column.LayoutID, AColumnID) or
       SameText(Column.FieldName, AColumnID) then
    begin
      Column.Visible := AVisible;
      InvalidateLayout;
      Exit;
    end;
  end;
end;

function TUniListView.ItemIndexAt(const APoint: TPointF): Integer;
var
  Hit: TUniCardHit;
begin
  Hit := HitTestAt(APoint);
  Result := Hit.ItemIndex;
end;

function TUniListView.SaveLayoutToJSON: string;
var
  Root: TJSONObject;
  ColumnsArray, SortsArray, ExpandedArray, CheckedArray, LoadedArray: TJSONArray;
  ColumnObject, SortObject: TJSONObject;
  Column: TUniListColumn;
  ColumnIndex, CriterionIndex, ExpandedIndex, CheckedIndex, LoadedIndex: Integer;
  ActionVisibilityText, CardLayoutText, CardRoleText: string;
begin
  Root := TJSONObject.Create;
  try
    Root.AddPair('version', TJSONNumber.Create(6));
    Root.AddPair('viewMode', TJSONNumber.Create(Ord(FViewMode)));
    if FCardLayout = uclFullWidth then
      CardLayoutText := 'fullWidth'
    else
      CardLayoutText := 'grid';
    Root.AddPair('cardLayout', CardLayoutText);
    if FActionVisibility = uavOnHover then
      ActionVisibilityText := 'onHover'
    else
      ActionVisibilityText := 'always';
    Root.AddPair('actionVisibility', ActionVisibilityText);
    Root.AddPair('themeName', FThemeName);
    Root.AddPair('useStyleBook', TJSONBool.Create(FUseStyleBook));
    Root.AddPair('sortColumn', TJSONNumber.Create(FSortColumnIndex));
    Root.AddPair('sortAscending', TJSONBool.Create(FSortAscending));
    Root.AddPair('footerVisible', TJSONBool.Create(FListFooterVisible));
    Root.AddPair('footerHeight', TJSONNumber.Create(FListFooterHeight));
    Root.AddPair('filterVisible', TJSONBool.Create(FListFilterVisible));
    Root.AddPair('filterHeight', TJSONNumber.Create(FListFilterHeight));
    Root.AddPair('treeMode', TJSONBool.Create(FTreeMode));
    Root.AddPair('treeKeyField', FTreeKeyField);
    Root.AddPair('treeParentField', FTreeParentField);
    Root.AddPair('treeColumn', FTreeColumn);
    Root.AddPair('treeLazyLoad', TJSONBool.Create(FTreeLazyLoad));
    Root.AddPair('treeHasChildrenField', FTreeHasChildrenField);
    Root.AddPair('multiCheck', TJSONBool.Create(FMultiCheck));
    Root.AddPair('showCheckBoxes', TJSONBool.Create(FShowCheckBoxes));
    Root.AddPair('treeCheckBoxes', TJSONBool.Create(FMultiCheck));
    Root.AddPair('treeCheckMode', TJSONNumber.Create(Ord(FTreeCheckMode)));
    ExpandedArray := TJSONArray.Create;
    Root.AddPair('treeExpanded', ExpandedArray);
    for ExpandedIndex := 0 to FTreeExpandedKeys.Count - 1 do
      ExpandedArray.AddElement(TJSONString.Create(FTreeExpandedKeys[ExpandedIndex]));
    CheckedArray := TJSONArray.Create;
    Root.AddPair('treeChecked', CheckedArray);
    for CheckedIndex := 0 to FItems.Count - 1 do
      if FItems[CheckedIndex].Checked then
        CheckedArray.AddElement(TJSONString.Create(
          ItemCheckKey(CheckedIndex)));
    LoadedArray := TJSONArray.Create;
    Root.AddPair('treeLoaded', LoadedArray);
    for LoadedIndex := 0 to FTreeLoadedKeys.Count - 1 do
      LoadedArray.AddElement(TJSONString.Create(FTreeLoadedKeys[LoadedIndex]));

    SortsArray := TJSONArray.Create;
    Root.AddPair('sorts', SortsArray);
    for CriterionIndex := 0 to High(FSortColumnIndices) do
    begin
      ColumnIndex := FSortColumnIndices[CriterionIndex];
      if (ColumnIndex < 0) or (ColumnIndex >= FColumns.Count) then
        Continue;
      Column := FColumns[ColumnIndex];
      SortObject := TJSONObject.Create;
      SortObject.AddPair('id', Column.LayoutID);
      SortObject.AddPair('field', Column.FieldName);
      SortObject.AddPair('ascending',
        TJSONBool.Create(FSortAscendingValues[CriterionIndex]));
      SortsArray.AddElement(SortObject);
    end;

    ColumnsArray := TJSONArray.Create;
    Root.AddPair('columns', ColumnsArray);
    for ColumnIndex := 0 to FColumns.Count - 1 do
    begin
      Column := FColumns[ColumnIndex];
      ColumnObject := TJSONObject.Create;
      ColumnObject.AddPair('id', Column.LayoutID);
      ColumnObject.AddPair('field', Column.FieldName);
      ColumnObject.AddPair('position', TJSONNumber.Create(Column.Index));
      ColumnObject.AddPair('width', TJSONNumber.Create(Column.Width));
      ColumnObject.AddPair('widthMode', TJSONNumber.Create(Ord(Column.WidthMode)));
      ColumnObject.AddPair('visible', TJSONBool.Create(Column.Visible));
      ColumnObject.AddPair('visibleInCards',
        TJSONBool.Create(Column.VisibleInCards));
      case Column.CardRole of
        ucrTitle: CardRoleText := 'title';
        ucrSubtitle: CardRoleText := 'subtitle';
        ucrDetail: CardRoleText := 'detail';
        ucrTrailing: CardRoleText := 'trailing';
        ucrHidden: CardRoleText := 'hidden';
      else
        CardRoleText := 'auto';
      end;
      ColumnObject.AddPair('cardRole', CardRoleText);
      ColumnObject.AddPair('frozen', TJSONBool.Create(Column.Frozen));
      ColumnObject.AddPair('footerAggregate',
        TJSONNumber.Create(Ord(Column.FooterAggregate)));
      ColumnObject.AddPair('footerText', Column.FooterText);
      ColumnObject.AddPair('footerFormat', Column.FooterFormat);
      ColumnObject.AddPair('filterOperator',
        TJSONNumber.Create(Ord(Column.FilterOperator)));
      ColumnObject.AddPair('filterValue', Column.FilterValue);
      ColumnObject.AddPair('wrapText', TJSONBool.Create(Column.WrapText));
      ColumnObject.AddPair('maxLines', TJSONNumber.Create(Column.MaxLines));
      ColumnsArray.AddElement(ColumnObject);
    end;
    Result := Root.Format(2);
  finally
    Root.Free;
  end;
end;

procedure TUniListView.LoadLayoutFromJSON(const AJSON: string);
var
  Root: TJSONObject;
  ColumnsArray, SortsArray, ExpandedArray, CheckedArray, LoadedArray: TJSONArray;
  ColumnObject, SortObject: TJSONObject;
  Column, Candidate: TUniListColumn;
  CandidateIndex, SortCount, ItemIndex, OldCheckedCount: Integer;
  Element: TJSONValue;
  ID, FieldName: string;
  Position, WidthModeValue, FooterAggregateValue, FilterOperatorValue,
    LegacySortColumn, MaxLinesValue, TreeCheckModeValue: Integer;
  WidthValue, FooterHeightValue, FilterHeightValue: Double;
  VisibleValue, VisibleInCardsValue, FrozenValue, AscendingValue, LegacyAscending,
    FooterVisibleValue, FilterVisibleValue, WrapTextValue, TreeModeValue,
    TreeCheckBoxesValue, TreeLazyLoadValue, MultiCheckValue,
    ShowCheckBoxesValue: Boolean;
  ActionVisibilityText, CardLayoutText, CardRoleText, FooterTextValue,
    FooterFormatValue, FilterValueText, ThemeNameValue: string;
begin
  Root := TJSONObject.ParseJSONValue(AJSON) as TJSONObject;
  if Root = nil then
    raise EConvertError.Create('Invalid UniListView layout JSON');
  try
    ThemeNameValue := Root.GetValue<string>('themeName', '');
    if ThemeNameValue <> '' then
      SetThemeName(ThemeNameValue);
    SetUseStyleBook(Root.GetValue<Boolean>('useStyleBook', False));
    CardLayoutText := Root.GetValue<string>('cardLayout', '');
    if SameText(CardLayoutText, 'fullWidth') then
      FCardLayout := uclFullWidth
    else if SameText(CardLayoutText, 'grid') then
      FCardLayout := uclGrid;
    FActionVisibility := uavAlways;
    ActionVisibilityText := Root.GetValue<string>('actionVisibility', '');
    if SameText(ActionVisibilityText, 'onHover') then
      FActionVisibility := uavOnHover;
    LegacySortColumn := -1;
    LegacyAscending := True;
    Root.TryGetValue<Integer>('sortColumn', LegacySortColumn);
    Root.TryGetValue<Boolean>('sortAscending', LegacyAscending);
    if Root.TryGetValue<Boolean>('footerVisible', FooterVisibleValue) then
      FListFooterVisible := FooterVisibleValue;
    if Root.TryGetValue<Double>('footerHeight', FooterHeightValue) then
      FListFooterHeight := Max(18, FooterHeightValue);
    if Root.TryGetValue<Boolean>('filterVisible', FilterVisibleValue) then
      FListFilterVisible := FilterVisibleValue;
    if Root.TryGetValue<Double>('filterHeight', FilterHeightValue) then
      FListFilterHeight := Max(20, FilterHeightValue);
    if Root.TryGetValue<Boolean>('treeMode', TreeModeValue) then
      FTreeMode := TreeModeValue;
    FTreeKeyField := Root.GetValue<string>('treeKeyField', FTreeKeyField);
    FTreeParentField := Root.GetValue<string>('treeParentField', FTreeParentField);
    FTreeColumn := Root.GetValue<string>('treeColumn', FTreeColumn);
    if Root.TryGetValue<Boolean>('treeLazyLoad', TreeLazyLoadValue) then
      FTreeLazyLoad := TreeLazyLoadValue;
    FTreeHasChildrenField := Root.GetValue<string>('treeHasChildrenField', FTreeHasChildrenField);
    if Root.TryGetValue<Boolean>('multiCheck', MultiCheckValue) then
      FMultiCheck := MultiCheckValue
    else if Root.TryGetValue<Boolean>('treeCheckBoxes', TreeCheckBoxesValue) then
      FMultiCheck := TreeCheckBoxesValue
    else if Root.TryGetValue<Boolean>('showCheckBoxes', TreeCheckBoxesValue) then
      FMultiCheck := TreeCheckBoxesValue;
    if Root.TryGetValue<Boolean>('showCheckBoxes', ShowCheckBoxesValue) and
       Root.TryGetValue<Boolean>('multiCheck', MultiCheckValue) then
      FShowCheckBoxes := ShowCheckBoxesValue;
    TreeCheckModeValue := Ord(tcmIndependent);
    if Root.TryGetValue<Integer>('treeCheckMode', TreeCheckModeValue) and
       (TreeCheckModeValue >= Ord(Low(TUniTreeCheckMode))) and
       (TreeCheckModeValue <= Ord(High(TUniTreeCheckMode))) then
      FTreeCheckMode := TUniTreeCheckMode(TreeCheckModeValue);
    FTreeExpandedKeys.Clear;
    ExpandedArray := Root.GetValue<TJSONArray>('treeExpanded');
    if ExpandedArray <> nil then
      for Element in ExpandedArray do
        FTreeExpandedKeys.Add(Element.Value);
    OldCheckedCount := FCheckedCount;
    CheckedArray := Root.GetValue<TJSONArray>('treeChecked');
    FCheckBatch := True;
    FItems.BeginUpdate;
    try
      for ItemIndex := 0 to FItems.Count - 1 do
        FItems[ItemIndex].Checked := False;
      if CheckedArray <> nil then
        for Element in CheckedArray do
          for ItemIndex := 0 to FItems.Count - 1 do
            if SameText(ItemCheckKey(ItemIndex), Element.Value) then
            begin
              FItems[ItemIndex].Checked := True;
              Break;
            end;
    finally
      FItems.EndUpdate;
      FCheckBatch := False;
    end;
    if (OldCheckedCount <> FCheckedCount) and Assigned(FOnCheckedChanged) then
      FOnCheckedChanged(Self);
    FTreeLoadedKeys.Clear;
    LoadedArray := Root.GetValue<TJSONArray>('treeLoaded');
    if LoadedArray <> nil then
      for Element in LoadedArray do
        FTreeLoadedKeys.Add(Element.Value);

    ColumnsArray := Root.GetValue<TJSONArray>('columns');
    if ColumnsArray <> nil then
    begin
      FColumns.BeginUpdate;
      try
        for Element in ColumnsArray do
        begin
          if not (Element is TJSONObject) then
            Continue;
          ColumnObject := TJSONObject(Element);
          ID := ColumnObject.GetValue<string>('id', '');
          FieldName := ColumnObject.GetValue<string>('field', '');
          Column := nil;
          for CandidateIndex := 0 to FColumns.Count - 1 do
          begin
            Candidate := FColumns[CandidateIndex];
            if ((ID <> '') and SameText(Candidate.LayoutID, ID)) or
               ((FieldName <> '') and SameText(Candidate.FieldName, FieldName)) then
            begin
              Column := Candidate;
              Break;
            end;
          end;
          if Column = nil then
            Continue;
          if ColumnObject.TryGetValue<Double>('width', WidthValue) then
            Column.Width := EnsureRange(WidthValue, Column.MinWidth,
              Column.MaxWidth);
          if ColumnObject.TryGetValue<Integer>('widthMode', WidthModeValue) and
             (WidthModeValue >= Ord(Low(TUniColumnWidthMode))) and
             (WidthModeValue <= Ord(High(TUniColumnWidthMode))) then
            Column.WidthMode := TUniColumnWidthMode(WidthModeValue);
          if ColumnObject.TryGetValue<Boolean>('visible', VisibleValue) then
            Column.Visible := VisibleValue;
          if ColumnObject.TryGetValue<Boolean>('visibleInCards',
             VisibleInCardsValue) then
            Column.VisibleInCards := VisibleInCardsValue;
          CardRoleText := ColumnObject.GetValue<string>('cardRole', '');
          if SameText(CardRoleText, 'title') then
            Column.CardRole := ucrTitle
          else if SameText(CardRoleText, 'subtitle') then
            Column.CardRole := ucrSubtitle
          else if SameText(CardRoleText, 'detail') then
            Column.CardRole := ucrDetail
          else if SameText(CardRoleText, 'trailing') then
            Column.CardRole := ucrTrailing
          else if SameText(CardRoleText, 'hidden') then
            Column.CardRole := ucrHidden
          else if SameText(CardRoleText, 'auto') then
            Column.CardRole := ucrAuto;
          if ColumnObject.TryGetValue<Boolean>('frozen', FrozenValue) then
            Column.Frozen := FrozenValue;
          if ColumnObject.TryGetValue<Integer>('footerAggregate',
             FooterAggregateValue) and
             (FooterAggregateValue >= Ord(Low(TUniFooterAggregate))) and
             (FooterAggregateValue <= Ord(High(TUniFooterAggregate))) then
            Column.FooterAggregate := TUniFooterAggregate(FooterAggregateValue);
          FooterTextValue := ColumnObject.GetValue<string>('footerText',
            Column.FooterText);
          Column.FooterText := FooterTextValue;
          FooterFormatValue := ColumnObject.GetValue<string>('footerFormat',
            Column.FooterFormat);
          Column.FooterFormat := FooterFormatValue;
          if ColumnObject.TryGetValue<Integer>('filterOperator',
             FilterOperatorValue) and
             (FilterOperatorValue >= Ord(Low(TUniFilterOperator))) and
             (FilterOperatorValue <= Ord(High(TUniFilterOperator))) then
            Column.FilterOperator := TUniFilterOperator(FilterOperatorValue);
          FilterValueText := ColumnObject.GetValue<string>('filterValue',
            Column.FilterValue);
          Column.FilterValue := FilterValueText;
          if ColumnObject.TryGetValue<Boolean>('wrapText', WrapTextValue) then
            Column.WrapText := WrapTextValue;
          if ColumnObject.TryGetValue<Integer>('maxLines', MaxLinesValue) then
            Column.MaxLines := MaxLinesValue;
          if ColumnObject.TryGetValue<Integer>('position', Position) then
            Column.Index := EnsureRange(Position, 0, FColumns.Count - 1);
        end;
      finally
        FColumns.EndUpdate;
      end;
    end;

    SetLength(FSortColumnIndices, 0);
    SetLength(FSortAscendingValues, 0);
    SortsArray := Root.GetValue<TJSONArray>('sorts');
    if SortsArray <> nil then
    begin
      for Element in SortsArray do
      begin
        if not (Element is TJSONObject) then
          Continue;
        SortObject := TJSONObject(Element);
        ID := SortObject.GetValue<string>('id', '');
        FieldName := SortObject.GetValue<string>('field', '');
        AscendingValue := SortObject.GetValue<Boolean>('ascending', True);
        CandidateIndex := -1;
        for Position := 0 to FColumns.Count - 1 do
        begin
          Candidate := FColumns[Position];
          if ((ID <> '') and SameText(Candidate.LayoutID, ID)) or
             ((FieldName <> '') and SameText(Candidate.FieldName, FieldName)) then
          begin
            CandidateIndex := Position;
            Break;
          end;
        end;
        if CandidateIndex < 0 then
          Continue;
        SortCount := Length(FSortColumnIndices);
        SetLength(FSortColumnIndices, SortCount + 1);
        SetLength(FSortAscendingValues, SortCount + 1);
        FSortColumnIndices[SortCount] := CandidateIndex;
        FSortAscendingValues[SortCount] := AscendingValue;
      end;
    end;

    if (Length(FSortColumnIndices) = 0) and
       (LegacySortColumn >= 0) and (LegacySortColumn < FColumns.Count) then
    begin
      SetLength(FSortColumnIndices, 1);
      SetLength(FSortAscendingValues, 1);
      FSortColumnIndices[0] := LegacySortColumn;
      FSortAscendingValues[0] := LegacyAscending;
    end;
    SyncPrimarySort;
  finally
    Root.Free;
  end;
  ApplyCurrentSort;
  RebuildFilter;
  InvalidateLayout;
end;

procedure TUniListView.SaveLayoutToFile(const AFileName: string);
begin
  TFile.WriteAllText(AFileName, SaveLayoutToJSON, TEncoding.UTF8);
end;

procedure TUniListView.LoadLayoutFromFile(const AFileName: string);
begin
  LoadLayoutFromJSON(TFile.ReadAllText(AFileName, TEncoding.UTF8));
end;


function TUniListView.ListBodyTop: Single;
begin
  Result := FListHeaderHeight;
  if FListFilterVisible then
    Result := Result + FListFilterHeight;
end;

function TUniListView.DisplayItemCount: Integer;
begin
  if FTreeMode and (FViewMode = uvmList) then
    Result := Length(FTreeVisibleIndices)
  else if (FSearchEngine <> nil) and (FSearchEngine.SearchText <> '') then
    Result := FSearchEngine.MatchCount
  else
    Result := Length(FFilteredIndices);
end;

function TUniListView.DisplayItemIndex(const ADisplayIndex: Integer): Integer;
begin
  if FTreeMode and (FViewMode = uvmList) then
  begin
    if (ADisplayIndex < 0) or (ADisplayIndex >= Length(FTreeVisibleIndices)) then
      Exit(-1);
    Exit(FTreeVisibleIndices[ADisplayIndex]);
  end;
  if (FSearchEngine <> nil) and (FSearchEngine.SearchText <> '') then
    Exit(FSearchEngine.MatchItemIndex(ADisplayIndex));
  if (ADisplayIndex < 0) or (ADisplayIndex >= Length(FFilteredIndices)) then
    Exit(-1);
  Result := FFilteredIndices[ADisplayIndex];
end;

function TUniListView.ItemMatchesFilter(AItem: TUniListItem;
  AColumn: TUniListColumn): Boolean;
var
  FilterText, ItemTextValue: string;
  FilterNumber, ItemNumber: Double;
  FilterDate, ItemDate: TDateTime;
begin
  FilterText := Trim(AColumn.FilterValue);
  if FilterText = '' then
    Exit(True);
  case AColumn.DataType of
    ucdtInteger, ucdtFloat:
      begin
        if not TryStrToFloat(FilterText, FilterNumber) then
          Exit(False);
        ItemNumber := AItem.FieldAsFloat(AColumn.FieldName, 0);
        case AColumn.FilterOperator of
          ufoEquals: Result := SameValue(ItemNumber, FilterNumber);
          ufoNotEqual: Result := not SameValue(ItemNumber, FilterNumber);
          ufoGreater: Result := ItemNumber > FilterNumber;
          ufoGreaterOrEqual: Result := ItemNumber >= FilterNumber;
          ufoLess: Result := ItemNumber < FilterNumber;
          ufoLessOrEqual: Result := ItemNumber <= FilterNumber;
        else
          Result := ContainsText(FloatToStr(ItemNumber), FilterText);
        end;
      end;
    ucdtDateTime:
      begin
        if not TryStrToDateTime(FilterText, FilterDate) then
          Exit(False);
        ItemDate := AItem.FieldAsDateTime(AColumn.FieldName, 0);
        case AColumn.FilterOperator of
          ufoNotEqual: Result := not SameValue(ItemDate, FilterDate);
          ufoGreater: Result := ItemDate > FilterDate;
          ufoGreaterOrEqual: Result := ItemDate >= FilterDate;
          ufoLess: Result := ItemDate < FilterDate;
          ufoLessOrEqual: Result := ItemDate <= FilterDate;
        else
          Result := SameValue(ItemDate, FilterDate);
        end;
      end;
  else
    begin
      ItemTextValue := AItem.FieldAsString(AColumn.FieldName, '');
      case AColumn.FilterOperator of
        ufoEquals: Result := SameText(ItemTextValue, FilterText);
        ufoNotEqual: Result := not SameText(ItemTextValue, FilterText);
        ufoStartsWith: Result := StartsText(FilterText, ItemTextValue);
      else
        Result := ContainsText(ItemTextValue, FilterText);
      end;
    end;
  end;
end;

function TUniListView.ItemMatchesFilters(AItem: TUniListItem): Boolean;
var
  ColumnIndex: Integer;
begin
  for ColumnIndex := 0 to FColumns.Count - 1 do
    if not ItemMatchesFilter(AItem, FColumns[ColumnIndex]) then
      Exit(False);
  Result := True;
end;

procedure TUniListView.RebuildFilter;
var
  ItemIndex, CountValue: Integer;
  PerfTimer: TUniPerfScope;
begin
  UniPerfInc(upcFilterRebuild);
  PerfTimer := TUniPerfScope.Start(upcFilterRebuild);
  try
  if (FItems = nil) or (FColumns = nil) then
    Exit;
  SetLength(FFilteredIndices, FItems.Count);
  CountValue := 0;
  UniPerfAddItemsScanned(FItems.Count);
  for ItemIndex := 0 to FItems.Count - 1 do
    if ItemMatchesFilters(FItems[ItemIndex]) then
    begin
      FFilteredIndices[CountValue] := ItemIndex;
      Inc(CountValue);
    end;
  SetLength(FFilteredIndices, CountValue);
  UniPerfSetFilterResultCount(CountValue);
  RebuildTree;
  ConfigureSearch;
  finally
    PerfTimer.Stop;
  end;
end;


function TUniListView.TreeItemKey(const AItemIndex: Integer): string;
begin
  if (AItemIndex < 0) or (AItemIndex >= FItems.Count) then
    Exit('');
  Result := FItems[AItemIndex].FieldAsString(FTreeKeyField, '');
end;

function TUniListView.TreeItemParentKey(const AItemIndex: Integer): string;
begin
  if (AItemIndex < 0) or (AItemIndex >= FItems.Count) then
    Exit('');
  Result := FItems[AItemIndex].FieldAsString(FTreeParentField, '');
end;

function TUniListView.TreeHasChildren(const AItemIndex: Integer): Boolean;
begin
  Result := (AItemIndex >= 0) and
    (AItemIndex < Length(FTreeChildFlags)) and
    FTreeChildFlags[AItemIndex];
end;

function TUniListView.TreeMayHaveChildren(const AItemIndex: Integer): Boolean;
begin
  Result := TreeHasChildren(AItemIndex);
  if Result or (not FTreeLazyLoad) or (FTreeHasChildrenField = '') then
    Exit;
  Result := FItems[AItemIndex].FieldAsBoolean(FTreeHasChildrenField, False);
end;

function TUniListView.TreeChildrenLoaded(const AItemIndex: Integer): Boolean;
var
  KeyValue: string;
begin
  if not FTreeLazyLoad then
    Exit(True);
  KeyValue := TreeItemKey(AItemIndex);
  Result := (KeyValue <> '') and
    ((FTreeLoadedKeys.IndexOf(KeyValue) >= 0) or TreeHasChildren(AItemIndex));
end;

function TUniListView.TreeNodeCanExpand(const AItemIndex: Integer): Boolean;
begin
  Result := TreeHasChildren(AItemIndex) or
    (FTreeLazyLoad and TreeMayHaveChildren(AItemIndex) and
      not TreeChildrenLoaded(AItemIndex));
end;

procedure TUniListView.RequestTreeChildren(const AItemIndex: Integer;
  out AHandled: Boolean);
var
  KeyValue: string;
  KeyIndex: Integer;
begin
  AHandled := False;
  if not FTreeLazyLoad or TreeChildrenLoaded(AItemIndex) then
    Exit;
  KeyValue := TreeItemKey(AItemIndex);
  if (KeyValue = '') or (FTreeLoadingKeys.IndexOf(KeyValue) >= 0) then
    Exit;
  FTreeLoadingKeys.Add(KeyValue);
  try
    if Assigned(FOnTreeLoadChildren) then
      FOnTreeLoadChildren(Self, KeyValue, AHandled);
    if AHandled then
      MarkChildrenLoaded(KeyValue);
  finally
    KeyIndex := FTreeLoadingKeys.IndexOf(KeyValue);
    if KeyIndex >= 0 then
      FTreeLoadingKeys.Delete(KeyIndex);
  end;
end;

function TUniListView.TreeIsExpanded(const AItemIndex: Integer): Boolean;
begin
  Result := FTreeExpandedKeys.IndexOf(TreeItemKey(AItemIndex)) >= 0;
end;

function TUniListView.TreeLevel(const ADisplayIndex: Integer): Integer;
begin
  if (ADisplayIndex < 0) or (ADisplayIndex >= Length(FTreeLevels)) then
    Exit(0);
  Result := FTreeLevels[ADisplayIndex];
end;

function TUniListView.GetCardTreeCurrentNodeId: string;
begin
  if (FCardTreeCurrentNodeIndex < 0) or
     (FCardTreeCurrentNodeIndex >= FItems.Count) then
    Exit('');
  Result := TreeItemKey(FCardTreeCurrentNodeIndex);
end;

function TUniListView.GetCardTreeCurrentDepth: Integer;
begin
  if not CardTreeNavigationPresentation or
     (FCardTreeCurrentNodeIndex < 0) then
    Exit(0);
  Result := CardTreeDepth(FCardTreeCurrentNodeIndex) + 1;
end;

function TUniListView.GetCardTreeCanNavigateBack: Boolean;
begin
  Result := CardTreeNavigationPresentation and
    (FCardTreeCurrentNodeIndex >= 0);
end;

function TUniListView.GetCardTreeNavigationActive: Boolean;
begin
  Result := CardTreeNavigationPresentation;
end;

procedure TUniListView.SetCardTreeEnabled(const Value: Boolean);
begin
  if FCardTreeEnabled = Value then
    Exit;
  FCardTreeEnabled := Value;
  RebuildCardTreeVisibleSet;
  InvalidateLayout;
end;

procedure TUniListView.SetCardTreeMode(const Value: TUniCardTreeMode);
begin
  if FCardTreeMode = Value then
    Exit;
  FCardTreeMode := Value;
  FCardTreeNavigationActive := Value = ctmNavigate;
  FCardTreeCurrentNodeIndex := -1;
  FScrollX := 0;
  FScrollY := 0;
  FHotHit := TUniCardHit.None;
  RebuildCardTreeVisibleSet;
  InvalidateLayout;
end;

procedure TUniListView.SetCardTreeExplorerShowChildCount(
  const Value: Boolean);
begin
  if FCardTreeExplorerShowChildCount = Value then
    Exit;
  FCardTreeExplorerShowChildCount := Value;
  Redraw;
end;

procedure TUniListView.SetCardTreeExplorerNavigateOnCardClick(
  const Value: Boolean);
begin
  FCardTreeExplorerNavigateOnCardClick := Value;
end;

procedure TUniListView.SetCardTreeExplorerParentEmphasis(
  const Value: Single);
var
  NewValue: Single;
begin
  NewValue := EnsureRange(Value, 0, 1);
  if SameValue(FCardTreeExplorerParentEmphasis, NewValue) then
    Exit;
  FCardTreeExplorerParentEmphasis := NewValue;
  FCardTreeParentBackgroundColor := UniBlendColor(FCardColor,
    FCardTreeNavigationIconColor, NewValue);
  Redraw;
end;

procedure TUniListView.SetCardTreeExplorerKeepFlatOrder(
  const Value: Boolean);
begin
  if FCardTreeExplorerKeepFlatOrder = Value then
    Exit;
  FCardTreeExplorerKeepFlatOrder := Value;
  if (FCardTreeMode = ctmExplorer) and
     not FCardTreeNavigationActive then
  begin
    RebuildCardTreeVisibleSet;
    InvalidateLayout;
  end;
end;

function TUniListView.CardTreeTryNavigateToNode(
  const ANodeId: string): Boolean;
var
  Allow: Boolean;
  ItemIndex: Integer;
begin
  Result := False;
  if not CardTreeActive or (FCardTreeMode = ctmHierarchy) then
    Exit;
  ItemIndex := CardTreeFindItem(ANodeId);
  if (ItemIndex < 0) or not CardTreeItemHasChildren(ItemIndex) then
    Exit;
  Allow := True;
  if Assigned(FCardTreeOnNavigating) then
    FCardTreeOnNavigating(Self, ANodeId, Allow);
  if not Allow then
    Exit;
  if (FCardTreeMode = ctmExplorer) and
     not FCardTreeNavigationActive then
  begin
    FCardTreeExplorerScrollX := FScrollX;
    FCardTreeExplorerScrollY := FScrollY;
    FCardTreeExplorerSelectedIndex := FSelectedIndex;
    FCardTreeNavigationActive := True;
  end;
  FCardTreeCurrentNodeIndex := ItemIndex;
  FScrollX := 0;
  FScrollY := 0;
  FHotHit := TUniCardHit.None;
  RebuildCardTreeVisibleSet;
  if Length(FCardTreeVisibleIndices) > 0 then
    FSelectedIndex := FCardTreeVisibleIndices[0]
  else
    FSelectedIndex := -1;
  InvalidateLayout;
  if Assigned(FCardTreeOnNavigated) then
    FCardTreeOnNavigated(Self, ANodeId);
  if Assigned(FCardTreeOnLevelChanged) then
    FCardTreeOnLevelChanged(Self);
  Result := True;
end;

procedure TUniListView.CardTreeNavigateToNode(const ANodeId: string);
begin
  CardTreeTryNavigateToNode(ANodeId);
end;

procedure TUniListView.CardTreeNavigateToRoot;
var
  Allow: Boolean;
begin
  if (FCardTreeMode = ctmExplorer) and FCardTreeNavigationActive then
  begin
    CardTreeExitNavigation;
    Exit;
  end;
  if FCardTreeCurrentNodeIndex < 0 then
    Exit;
  Allow := True;
  if Assigned(FCardTreeOnNavigating) then
    FCardTreeOnNavigating(Self, '', Allow);
  if not Allow then
    Exit;
  FCardTreeCurrentNodeIndex := -1;
  FScrollX := 0;
  FScrollY := 0;
  FHotHit := TUniCardHit.None;
  RebuildCardTreeVisibleSet;
  FSelectedIndex := -1;
  InvalidateLayout;
  if Assigned(FCardTreeOnNavigated) then
    FCardTreeOnNavigated(Self, '');
  if Assigned(FCardTreeOnLevelChanged) then
    FCardTreeOnLevelChanged(Self);
end;

procedure TUniListView.CardTreeNavigateToParent;
var
  ItemIndex: Integer;
  ParentIndex: Integer;
begin
  if FCardTreeCurrentNodeIndex < 0 then
    Exit;
  ParentIndex := FTreeParentIndices[FCardTreeCurrentNodeIndex];
  if ParentIndex < 0 then
  begin
    ItemIndex := FCardTreeCurrentNodeIndex;
    CardTreeNavigateToRoot;
    FSelectedIndex := ItemIndex;
  end
  else
  begin
    FSelectedIndex := FCardTreeCurrentNodeIndex;
    FCardTreeCurrentNodeIndex := ParentIndex;
    FScrollY := 0;
    RebuildCardTreeVisibleSet;
    InvalidateLayout;
    if Assigned(FCardTreeOnNavigated) then
      FCardTreeOnNavigated(Self, TreeItemKey(ParentIndex));
    if Assigned(FCardTreeOnLevelChanged) then
      FCardTreeOnLevelChanged(Self);
  end;
end;

procedure TUniListView.CardTreeExitNavigation;
begin
  if FCardTreeMode = ctmHierarchy then
    Exit;
  if FCardTreeMode = ctmNavigate then
  begin
    CardTreeNavigateToRoot;
    Exit;
  end;
  if not FCardTreeNavigationActive then
    Exit;
  FCardTreeNavigationActive := False;
  FCardTreeCurrentNodeIndex := -1;
  FScrollX := FCardTreeExplorerScrollX;
  FScrollY := FCardTreeExplorerScrollY;
  FHotHit := TUniCardHit.None;
  RebuildCardTreeVisibleSet;
  if (FCardTreeExplorerSelectedIndex >= 0) and
     (CardDisplayIndexOf(FCardTreeExplorerSelectedIndex) >= 0) then
    FSelectedIndex := FCardTreeExplorerSelectedIndex
  else
    FSelectedIndex := -1;
  InvalidateLayout;
  if Assigned(FCardTreeOnNavigated) then
    FCardTreeOnNavigated(Self, '');
  if Assigned(FCardTreeOnLevelChanged) then
    FCardTreeOnLevelChanged(Self);
end;

procedure TUniListView.CardTreeRefresh;
begin
  if (FCardTreeCurrentNodeIndex >= FItems.Count) or
     not CardTreeItemVisible(FCardTreeCurrentNodeIndex) then
    FCardTreeCurrentNodeIndex := -1;
  RebuildCardTreeVisibleSet;
  InvalidateLayout;
end;

function TUniListView.CardTreeIsNodeExpanded(
  const ANodeId: string): Boolean;
begin
  Result := (ANodeId <> '') and (FTreeExpandedKeys.IndexOf(ANodeId) >= 0);
end;

procedure TUniListView.CardTreeExpandNode(const ANodeId: string);
var
  ItemIndex: Integer;
begin
  ItemIndex := CardTreeFindItem(ANodeId);
  if (ItemIndex < 0) or not CardTreeItemHasChildren(ItemIndex) or
     CardTreeIsNodeExpanded(ANodeId) then
    Exit;
  FTreeExpandedKeys.Add(ANodeId);
  RebuildCardTreeVisibleSet;
  InvalidateLayout;
  if Assigned(FCardTreeOnNodeExpand) then
    FCardTreeOnNodeExpand(Self, ANodeId);
end;

procedure TUniListView.CardTreeCollapseNode(const ANodeId: string);
var
  KeyIndex: Integer;
  ItemIndex: Integer;
begin
  KeyIndex := FTreeExpandedKeys.IndexOf(ANodeId);
  if KeyIndex < 0 then
    Exit;
  ItemIndex := CardTreeFindItem(ANodeId);
  FTreeExpandedKeys.Delete(KeyIndex);
  RebuildCardTreeVisibleSet;
  if (ItemIndex >= 0) and (FSelectedIndex >= 0) then
    if CardDisplayIndexOf(FSelectedIndex) < 0 then
      FSelectedIndex := ItemIndex;
  InvalidateLayout;
  if Assigned(FCardTreeOnNodeCollapse) then
    FCardTreeOnNodeCollapse(Self, ANodeId);
end;

procedure TUniListView.CardTreeExpandAll;
var
  ItemIndex: Integer;
  NodeId: string;
begin
  FTreeExpandedKeys.BeginUpdate;
  try
    for ItemIndex := 0 to FItems.Count - 1 do
      if CardTreeItemHasChildren(ItemIndex) then
      begin
        NodeId := TreeItemKey(ItemIndex);
        if (NodeId <> '') and (FTreeExpandedKeys.IndexOf(NodeId) < 0) then
          FTreeExpandedKeys.Add(NodeId);
      end;
  finally
    FTreeExpandedKeys.EndUpdate;
  end;
  RebuildCardTreeVisibleSet;
  InvalidateLayout;
end;

procedure TUniListView.CardTreeCollapseAll;
begin
  if FTreeExpandedKeys.Count = 0 then
    Exit;
  FTreeExpandedKeys.Clear;
  RebuildCardTreeVisibleSet;
  FSelectedIndex := -1;
  InvalidateLayout;
end;
function TUniListView.CardTreeActive: Boolean;
begin
  Result := FCardTreeEnabled and (FViewMode = uvmCards);
end;

function TUniListView.CardTreeItemVisible(const AItemIndex: Integer): Boolean;
begin
  Result := (AItemIndex >= 0) and
    (AItemIndex < Length(FCardTreeFilteredFlags)) and
    FCardTreeFilteredFlags[AItemIndex];
end;

function TUniListView.CardTreeItemHasChildren(
  const AItemIndex: Integer): Boolean;
begin
  Result := (AItemIndex >= 0) and
    (AItemIndex < Length(FCardTreeHasVisibleChildren)) and
    FCardTreeHasVisibleChildren[AItemIndex];
end;

function TUniListView.CardTreeItemIsParent(
  const AItemIndex: Integer): Boolean;
begin
  Result := (AItemIndex >= 0) and
    (AItemIndex < Length(FCardTreeChildCounts)) and
    (FCardTreeChildCounts[AItemIndex] > 0);
end;

function TUniListView.CardTreeItemVisualParent(
  const AItemIndex: Integer): Boolean;
begin
  if FCardTreeMode = ctmExplorer then
    Result := CardTreeItemIsParent(AItemIndex)
  else
    Result := CardTreeItemHasChildren(AItemIndex);
end;

function TUniListView.CardTreeItemChildCount(
  const AItemIndex: Integer): Integer;
begin
  if (AItemIndex < 0) or
     (AItemIndex >= Length(FCardTreeChildCounts)) then
    Exit(0);
  Result := FCardTreeChildCounts[AItemIndex];
end;

function TUniListView.CardTreeNavigationPresentation: Boolean;
begin
  Result := (FCardTreeMode = ctmNavigate) or
    ((FCardTreeMode = ctmExplorer) and FCardTreeNavigationActive);
end;

function TUniListView.CardTreeFindItem(const ANodeId: string): Integer;
begin
  Result := -1;
  if ANodeId = '' then
    Exit;
  FTreeKeyToIndex.TryGetValue(LowerCase(ANodeId), Result);
end;

function TUniListView.CardTreeDepth(const AItemIndex: Integer): Integer;
var
  ItemIndex: Integer;
begin
  Result := 0;
  ItemIndex := AItemIndex;
  while (ItemIndex >= 0) and (ItemIndex < Length(FTreeParentIndices)) do
  begin
    ItemIndex := FTreeParentIndices[ItemIndex];
    if ItemIndex >= 0 then
      Inc(Result);
    if Result > FItems.Count then
      Exit(0);
  end;
end;

procedure TUniListView.RebuildCardTreeVisibleSet;
var
  Depths: TList<Integer>;
  Indices: TList<Integer>;
  ItemIndex: Integer;
  Visited: TArray<Boolean>;

  procedure AddHierarchy(const AItemIndex, ADepth: Integer);
  var
    ChildIndex: Integer;
  begin
    if (AItemIndex < 0) or (AItemIndex >= Length(Visited)) or
       Visited[AItemIndex] or not CardTreeItemVisible(AItemIndex) then
      Exit;
    Visited[AItemIndex] := True;
    Indices.Add(AItemIndex);
    Depths.Add(ADepth);
    if not CardTreeIsNodeExpanded(TreeItemKey(AItemIndex)) then
      Exit;
    ChildIndex := FTreeFirstChild[AItemIndex];
    while ChildIndex >= 0 do
    begin
      AddHierarchy(ChildIndex, ADepth + 1);
      ChildIndex := FTreeNextSibling[ChildIndex];
    end;
  end;

begin
  if (FCardTreeMode = ctmExplorer) and
     not FCardTreeNavigationActive then
    UniPerfInc(upcCardTreeExplorerVisibleSetBuild)
  else if CardTreeNavigationPresentation then
    UniPerfInc(upcCardTreeNavigateVisibleSetBuild)
  else
    UniPerfInc(upcCardTreeHierarchyVisibleSetBuild);
  SetLength(FCardTreeFilteredFlags, FItems.Count);
  for ItemIndex := 0 to High(FFilteredIndices) do
    if (FFilteredIndices[ItemIndex] >= 0) and
       (FFilteredIndices[ItemIndex] < FItems.Count) then
      FCardTreeFilteredFlags[FFilteredIndices[ItemIndex]] := True;
  SetLength(FCardTreeHasVisibleChildren, FItems.Count);
  SetLength(FCardTreeChildCounts, FItems.Count);
  SetLength(FCardTreeVisibleChildCounts, FItems.Count);
  for ItemIndex := 0 to FItems.Count - 1 do
    if (ItemIndex < Length(FTreeParentIndices)) and
       (FTreeParentIndices[ItemIndex] >= 0) then
    begin
      Inc(FCardTreeChildCounts[FTreeParentIndices[ItemIndex]]);
      if CardTreeItemVisible(ItemIndex) then
      begin
        Inc(FCardTreeVisibleChildCounts[FTreeParentIndices[ItemIndex]]);
        FCardTreeHasVisibleChildren[FTreeParentIndices[ItemIndex]] := True;
      end;
    end;
  while (FCardTreeCurrentNodeIndex >= 0) and
        not CardTreeItemVisible(FCardTreeCurrentNodeIndex) do
    if FCardTreeCurrentNodeIndex < Length(FTreeParentIndices) then
      FCardTreeCurrentNodeIndex :=
        FTreeParentIndices[FCardTreeCurrentNodeIndex]
    else
      FCardTreeCurrentNodeIndex := -1;
  Indices := TList<Integer>.Create;
  Depths := TList<Integer>.Create;
  try
    if (FSearchEngine <> nil) and (FSearchEngine.SearchText <> '') then
    begin
      for ItemIndex := 0 to FSearchEngine.MatchCount - 1 do
      begin
        Indices.Add(FSearchEngine.MatchItemIndex(ItemIndex));
        Depths.Add(0);
      end;
    end
    else if CardTreeNavigationPresentation then
    begin
      if FCardTreeCurrentNodeIndex < 0 then
      begin
        for ItemIndex := 0 to FItems.Count - 1 do
          if CardTreeItemVisible(ItemIndex) and
             ((ItemIndex >= Length(FTreeParentIndices)) or
              (FTreeParentIndices[ItemIndex] < 0) or
              not CardTreeItemVisible(FTreeParentIndices[ItemIndex])) then
          begin
            Indices.Add(ItemIndex);
            Depths.Add(0);
          end;
      end
      else if FCardTreeCurrentNodeIndex < Length(FTreeFirstChild) then
      begin
        ItemIndex := FTreeFirstChild[FCardTreeCurrentNodeIndex];
        while ItemIndex >= 0 do
        begin
          if CardTreeItemVisible(ItemIndex) then
          begin
            Indices.Add(ItemIndex);
            Depths.Add(CardTreeDepth(ItemIndex));
          end;
          ItemIndex := FTreeNextSibling[ItemIndex];
        end;
      end;
    end
    else if FCardTreeMode = ctmExplorer then
    begin
      for ItemIndex := 0 to High(FFilteredIndices) do
      begin
        Indices.Add(FFilteredIndices[ItemIndex]);
        Depths.Add(0);
      end;
    end
    else
    begin
      SetLength(Visited, FItems.Count);
      for ItemIndex := 0 to FItems.Count - 1 do
        if CardTreeItemVisible(ItemIndex) and
           ((FTreeParentIndices[ItemIndex] < 0) or
            not CardTreeItemVisible(FTreeParentIndices[ItemIndex])) then
          AddHierarchy(ItemIndex, 0);
    end;
    FCardTreeVisibleIndices := Indices.ToArray;
    FCardTreeVisibleDepths := Depths.ToArray;
  finally
    Depths.Free;
    Indices.Free;
  end;
  BuildCardTreeBreadcrumbs;
end;

procedure TUniListView.BuildCardTreeBreadcrumbs;
var
  Path: TList<Integer>;
  ItemIndex: Integer;
  BreadcrumbIndex: Integer;
  AvailableWidth: Single;
  TotalWidth: Single;
begin
  UniPerfInc(upcCardTreeBreadcrumbBuild);
  SetLength(FCardTreeBreadcrumbs, 0);
  if not FCardTreeShowBreadcrumbs or not CardTreeNavigationPresentation then
    Exit;
  if (FSearchEngine <> nil) and (FSearchEngine.SearchText <> '') then
  begin
    SetLength(FCardTreeBreadcrumbs, 1);
    FCardTreeBreadcrumbs[0].Caption := 'Search Results';
    Exit;
  end;
  Path := TList<Integer>.Create;
  try
    ItemIndex := FCardTreeCurrentNodeIndex;
    while ItemIndex >= 0 do
    begin
      Path.Insert(0, ItemIndex);
      if ItemIndex < Length(FTreeParentIndices) then
        ItemIndex := FTreeParentIndices[ItemIndex]
      else
        ItemIndex := -1;
      if Path.Count > FItems.Count then
        Break;
    end;
    SetLength(FCardTreeBreadcrumbs, Path.Count +
      Ord(FCardTreeShowRootBreadcrumb));
    BreadcrumbIndex := 0;
    if FCardTreeShowRootBreadcrumb then
    begin
      FCardTreeBreadcrumbs[0].NodeId := '';
      FCardTreeBreadcrumbs[0].Caption := FCardTreeRootCaption;
      Inc(BreadcrumbIndex);
    end;
    for ItemIndex in Path do
    begin
      FCardTreeBreadcrumbs[BreadcrumbIndex].NodeId := TreeItemKey(ItemIndex);
      FCardTreeBreadcrumbs[BreadcrumbIndex].Caption := ItemTitle(FItems[ItemIndex]);
      if FCardTreeBreadcrumbs[BreadcrumbIndex].Caption = '' then
        FCardTreeBreadcrumbs[BreadcrumbIndex].Caption := TreeItemKey(ItemIndex);
      Inc(BreadcrumbIndex);
    end;
    AvailableWidth := Width - FContentPadding * 2;
    if FCardTreeShowBackButton and CardTreeCanNavigateBack then
      AvailableWidth := AvailableWidth - FCardTreeNavigationIconSize -
        CARD_TREE_ICON_PADDING;
    TotalWidth := 0;
    for BreadcrumbIndex := 0 to High(FCardTreeBreadcrumbs) do
    begin
      TotalWidth := TotalWidth + EstimateTextWidth(
        FCardTreeBreadcrumbs[BreadcrumbIndex].Caption, FFontSize);
      if BreadcrumbIndex < High(FCardTreeBreadcrumbs) then
        TotalWidth := TotalWidth + EstimateTextWidth(
          FCardTreeBreadcrumbSeparator, FFontSize) +
          FCardTreeBreadcrumbSpacing * 2;
    end;
    if (TotalWidth > AvailableWidth) and
       (Length(FCardTreeBreadcrumbs) > 4) then
    begin
      FCardTreeBreadcrumbs[1].NodeId := '';
      FCardTreeBreadcrumbs[1].Caption := '...';
      FCardTreeBreadcrumbs[2] :=
        FCardTreeBreadcrumbs[High(FCardTreeBreadcrumbs) - 1];
      FCardTreeBreadcrumbs[3] :=
        FCardTreeBreadcrumbs[High(FCardTreeBreadcrumbs)];
      SetLength(FCardTreeBreadcrumbs, 4);
    end;
  finally
    Path.Free;
  end;
end;
procedure TUniListView.CalculateCardTreeLayout;
var
  AvailableWidth: Single;
  CardWidth: Single;
  ColumnCount: Integer;
  ColumnIndex: Integer;
  CurrentDepth: Integer;
  CurrentParent: Integer;
  DisplayIndex: Integer;
  EffectiveIndent: Single;
  ItemHeight: Single;
  ItemIndex: Integer;
  MaximumIndent: Single;
  RowHeight: Single;
  RowTop: Single;
begin
  if not CardTreeActive then
    Exit;
  UniPerfInc(upcCardTreeLayoutRecalculate);
  case FCardTreeMode of
    ctmExplorer:
      UniPerfInc(upcCardTreeExplorerLayoutRecalculate);
    ctmNavigate:
      UniPerfInc(upcCardTreeNavigateLayoutRecalculate);
    ctmHierarchy:
      UniPerfInc(upcCardTreeHierarchyLayoutRecalculate);
  end;
  SetLength(FCardTreeLayoutItems, CardDisplayCount);
  if FCardTreeMode <> ctmHierarchy then
  begin
    if CardTreeNavigationPresentation and FCardTreeShowBreadcrumbs then
    begin
      for DisplayIndex := 0 to High(FRowTops) do
        FRowTops[DisplayIndex] := FRowTops[DisplayIndex] +
          FCardTreeBreadcrumbHeight;
      FContentHeight := FContentHeight + FCardTreeBreadcrumbHeight;
    end;
    Exit;
  end;
  RowTop := FContentPadding;
  CurrentDepth := -1;
  CurrentParent := -2;
  ColumnIndex := 0;
  RowHeight := 0;
  for DisplayIndex := 0 to CardDisplayCount - 1 do
  begin
    ItemIndex := CardDisplayItemIndex(DisplayIndex);
    FCardTreeLayoutItems[DisplayIndex].ItemIndex := ItemIndex;
    FCardTreeLayoutItems[DisplayIndex].Depth :=
      FCardTreeVisibleDepths[DisplayIndex];
    FCardTreeLayoutItems[DisplayIndex].HasChildren :=
      CardTreeItemHasChildren(ItemIndex);
    FCardTreeLayoutItems[DisplayIndex].IsExpanded :=
      CardTreeIsNodeExpanded(TreeItemKey(ItemIndex));
    MaximumIndent := Max(0, Width - FContentPadding * 2 - FCardMinWidth);
    EffectiveIndent := Min(FCardTreeVisibleDepths[DisplayIndex] *
      FCardTreeHierarchyIndent, MaximumIndent);
    AvailableWidth := Max(1, Width - FContentPadding * 2 -
      EffectiveIndent - FULL_WIDTH_CARD_SCROLLBAR_RESERVE);
    ItemHeight := FCardHeight;
    if (ItemIndex >= 0) and (ItemIndex < Length(FItemHeights)) then
      ItemHeight := FItemHeights[ItemIndex];
    if FCardTreeLayoutItems[DisplayIndex].HasChildren then
    begin
      ItemHeight := MeasureFullWidthCardHeight(ItemIndex, AvailableWidth, True);
      if ColumnIndex > 0 then
      begin
        RowTop := RowTop + RowHeight + FVerticalGap;
        ColumnIndex := 0;
        RowHeight := 0;
      end;
      FCardTreeLayoutItems[DisplayIndex].IsFullWidthParent := True;
      FCardTreeLayoutItems[DisplayIndex].Bounds := RectF(
        FContentPadding + EffectiveIndent, RowTop,
        FContentPadding + EffectiveIndent + AvailableWidth,
        RowTop + ItemHeight);
      RowTop := RowTop + ItemHeight + FCardTreeHierarchySpacing;
      CurrentDepth := -1;
      CurrentParent := -2;
      Continue;
    end;
    if (CurrentDepth <> FCardTreeVisibleDepths[DisplayIndex]) or
       (CurrentParent <> FTreeParentIndices[ItemIndex]) then
    begin
      if ColumnIndex > 0 then
        RowTop := RowTop + RowHeight + FVerticalGap;
      ColumnIndex := 0;
      RowHeight := 0;
      CurrentDepth := FCardTreeVisibleDepths[DisplayIndex];
      CurrentParent := FTreeParentIndices[ItemIndex];
    end;
    ColumnCount := Max(1, Floor((AvailableWidth + FHorizontalGap) /
      (FCardMinWidth + FHorizontalGap)));
    CardWidth := (AvailableWidth - (ColumnCount - 1) * FHorizontalGap) /
      ColumnCount;
    FCardTreeLayoutItems[DisplayIndex].Bounds := RectF(
      FContentPadding + EffectiveIndent +
        ColumnIndex * (CardWidth + FHorizontalGap), RowTop,
      FContentPadding + EffectiveIndent +
        ColumnIndex * (CardWidth + FHorizontalGap) + CardWidth,
      RowTop + ItemHeight);
    RowHeight := Max(RowHeight, ItemHeight);
    Inc(ColumnIndex);
    if ColumnIndex >= ColumnCount then
    begin
      ColumnIndex := 0;
      RowTop := RowTop + RowHeight + FVerticalGap;
      RowHeight := 0;
    end;
  end;
  if ColumnIndex > 0 then
    RowTop := RowTop + RowHeight + FVerticalGap;
  FContentHeight := RowTop + FContentPadding;
  FContentWidth := Width;
end;

procedure TUniListView.DrawCardTreeChrome(const ACanvas: IUniCanvas);
var
  BadgeRect: TRectF;
  BadgeText: string;
  BadgeTextWidth: Single;
  BreadcrumbIndex: Integer;
  ChildCount: Integer;
  Font: IUniFont;
  Icon: TUniVectorIcon;
  IconRect: TRectF;
  ItemIndex: Integer;
  Paint: IUniPaint;
  TextX: Single;
begin
  if not CardTreeActive then
    Exit;
  Paint := TUniPaintFactory.Create;
  Paint.AntiAlias := True;
  Font := CreateTextFont(FFontSize);
  if CardTreeNavigationPresentation and FCardTreeShowBreadcrumbs then
  begin
    Paint.Color := FCardTreeBreadcrumbTextColor;
    TextX := FContentPadding;
    if FCardTreeShowBackButton and CardTreeCanNavigateBack then
    begin
      IconRect := RectF(TextX,
        (FCardTreeBreadcrumbHeight - FCardTreeNavigationIconSize) * 0.5,
        TextX + FCardTreeNavigationIconSize,
        (FCardTreeBreadcrumbHeight + FCardTreeNavigationIconSize) * 0.5);
      DrawVectorIcon(ACanvas, uviChevronLeft, IconRect,
        ResolveIconColor(FCardTreeNavigationIconColor), 1.5);
      TextX := IconRect.Right + CARD_TREE_ICON_PADDING;
    end;
    for BreadcrumbIndex := 0 to High(FCardTreeBreadcrumbs) do
    begin
      FCardTreeBreadcrumbs[BreadcrumbIndex].Bounds := RectF(TextX, 0,
        TextX + EstimateTextWidth(FCardTreeBreadcrumbs[BreadcrumbIndex].Caption,
          FFontSize), FCardTreeBreadcrumbHeight);
      if BreadcrumbIndex = FCardTreeHotBreadcrumb then
        Paint.Color := FCardTreeBreadcrumbHotColor
      else
        Paint.Color := FCardTreeBreadcrumbTextColor;
      ACanvas.DrawSimpleText(FCardTreeBreadcrumbs[BreadcrumbIndex].Caption,
        TextX, (FCardTreeBreadcrumbHeight + FFontSize) * 0.5, Font, Paint);
      TextX := FCardTreeBreadcrumbs[BreadcrumbIndex].Bounds.Right +
        FCardTreeBreadcrumbSpacing;
      if BreadcrumbIndex < High(FCardTreeBreadcrumbs) then
      begin
        ACanvas.DrawSimpleText(FCardTreeBreadcrumbSeparator, TextX,
          (FCardTreeBreadcrumbHeight + FFontSize) * 0.5, Font, Paint);
        TextX := TextX + EstimateTextWidth(FCardTreeBreadcrumbSeparator,
          FFontSize) + FCardTreeBreadcrumbSpacing;
      end;
    end;
  end;
  for BreadcrumbIndex := FirstVisibleIndex to LastVisibleIndex do
  begin
    if (BreadcrumbIndex < 0) or (BreadcrumbIndex >= CardDisplayCount) then
      Continue;
    ItemIndex := CardDisplayItemIndex(BreadcrumbIndex);
    if not CardTreeItemVisualParent(ItemIndex) then
      Continue;
    IconRect := CardRect(BreadcrumbIndex);
    IconRect.Left := IconRect.Right - FCardTreeNavigationIconSize -
      CARD_TREE_ICON_PADDING;
    IconRect.Top := IconRect.Top + CARD_TREE_ICON_PADDING;
    IconRect.Right := IconRect.Left + FCardTreeNavigationIconSize;
    IconRect.Bottom := IconRect.Top + FCardTreeNavigationIconSize;
    if CardTreeItemHasChildren(ItemIndex) then
    begin
      if CardTreeNavigationPresentation then
        Icon := uviChevronRight
      else if FCardTreeMode = ctmHierarchy then
        if CardTreeIsNodeExpanded(TreeItemKey(ItemIndex)) then
          Icon := uviChevronDown
        else
          Icon := uviChevronRight
      else
        Icon := uviChevronRight;
      if (FHotHit.Kind = uchCardTreeNavigate) and
         (FHotHit.ItemIndex = ItemIndex) then
        DrawVectorIcon(ACanvas, Icon, IconRect,
          ResolveIconColor(FCardTreeBreadcrumbHotColor), 1.5)
      else
        DrawVectorIcon(ACanvas, Icon, IconRect,
          ResolveIconColor(FCardTreeNavigationIconColor), 1.5);
    end;
    if (FCardTreeMode = ctmExplorer) and
       FCardTreeExplorerShowChildCount then
    begin
      ChildCount := CardTreeItemChildCount(ItemIndex);
      if ChildCount > 99 then
        BadgeText := '99+'
      else
        BadgeText := ChildCount.ToString;
      BadgeRect := IconRect;
      if CardTreeItemHasChildren(ItemIndex) then
        BadgeRect.Right := IconRect.Left - CARD_TREE_BADGE_GAP
      else
        BadgeRect.Right := CardRect(BreadcrumbIndex).Right -
          CARD_TREE_ICON_PADDING;
      BadgeRect.Left := BadgeRect.Right - CARD_TREE_BADGE_WIDTH;
      Paint.Style := TUniPaintStyle.Fill;
      Paint.Color := UniBlendColor(FCardTreeParentBackgroundColor,
        FCardTreeNavigationIconColor, 0.25);
      ACanvas.DrawRoundRect(BadgeRect, CARD_TREE_BADGE_RADIUS,
        CARD_TREE_BADGE_RADIUS, Paint);
      Paint.Color := FCardTreeNavigationIconColor;
      BadgeTextWidth := EstimateTextWidth(BadgeText, FFontSize);
      ACanvas.DrawSimpleText(BadgeText,
        BadgeRect.CenterPoint.X - BadgeTextWidth * 0.5,
        BadgeRect.CenterPoint.Y + FFontSize * 0.35, Font, Paint);
    end;
  end;
end;
procedure TUniListView.RebuildTree;
var
  VisibleList, LevelList: TList<Integer>;
  Visited: TDictionary<Integer, Byte>;
  AllKeyToIndex, FilteredKeyToIndex: TDictionary<string, Integer>;
  ParentKeys: TDictionary<string, Byte>;
  Children: TObjectDictionary<string, TList<Integer>>;
  ChildList: TList<Integer>;
  LastChild: TArray<Integer>;
  I, ItemIndex, ParentIndex: Integer;
  KeyValue, ParentKey: string;

  procedure AddBranch(const AItemIndex, ALevel: Integer);
  var
    BranchItems, BranchLevels: TStack<Integer>;
    BranchChildren: TList<Integer>;
    CurrentIndex, CurrentLevel, J: Integer;
    CurrentKey: string;
  begin
    BranchItems := TStack<Integer>.Create;
    BranchLevels := TStack<Integer>.Create;
    try
      BranchItems.Push(AItemIndex);
      BranchLevels.Push(ALevel);
      while BranchItems.Count > 0 do
      begin
        CurrentIndex := BranchItems.Pop;
        CurrentLevel := BranchLevels.Pop;
        if Visited.ContainsKey(CurrentIndex) then
          Continue;
        Visited.Add(CurrentIndex, 0);
        VisibleList.Add(CurrentIndex);
        LevelList.Add(CurrentLevel);
        if not TreeIsExpanded(CurrentIndex) then
          Continue;
        CurrentKey := LowerCase(TreeItemKey(CurrentIndex));
        if not Children.TryGetValue(CurrentKey, BranchChildren) then
          Continue;
        for J := BranchChildren.Count - 1 downto 0 do
        begin
          BranchItems.Push(BranchChildren[J]);
          BranchLevels.Push(CurrentLevel + 1);
        end;
      end;
    finally
      BranchLevels.Free;
      BranchItems.Free;
    end;
  end;

  function IsDisconnectedCycle(const AItemIndex: Integer): Boolean;
  var
    CurrentIndex, Step: Integer;
    CurrentParentKey: string;
  begin
    CurrentIndex := AItemIndex;
    for Step := 0 to Length(FFilteredIndices) do
    begin
      CurrentParentKey := LowerCase(TreeItemParentKey(CurrentIndex));
      if (CurrentParentKey = '') or
         not FilteredKeyToIndex.TryGetValue(CurrentParentKey, CurrentIndex) or
         Visited.ContainsKey(CurrentIndex) then
        Exit(False);
    end;
    Result := True;
  end;

begin
  UniPerfInc(upcCardTreeRebuild);
  SetLength(FTreeVisibleIndices, 0);
  SetLength(FTreeLevels, 0);
  SetLength(FTreeChildFlags, 0);
  SetLength(FTreeFirstChild, 0);
  SetLength(FTreeNextSibling, 0);
  SetLength(FTreeParentIndices, 0);
  if FItems = nil then
    Exit;

  SetLength(FTreeChildFlags, FItems.Count);
  SetLength(FTreeFirstChild, FItems.Count);
  SetLength(FTreeNextSibling, FItems.Count);
  SetLength(FTreeParentIndices, FItems.Count);
  SetLength(LastChild, FItems.Count);
  for I := 0 to FItems.Count - 1 do
  begin
    FTreeFirstChild[I] := -1;
    FTreeNextSibling[I] := -1;
    FTreeParentIndices[I] := -1;
    LastChild[I] := -1;
  end;

  FTreeKeyToIndex.Clear;
  AllKeyToIndex := TDictionary<string, Integer>.Create;
  try
    for I := 0 to FItems.Count - 1 do
    begin
      KeyValue := LowerCase(TreeItemKey(I));
      if (KeyValue <> '') and not AllKeyToIndex.ContainsKey(KeyValue) then
      begin
        AllKeyToIndex.Add(KeyValue, I);
        FTreeKeyToIndex.Add(KeyValue, I);
      end;
    end;
    for I := 0 to FItems.Count - 1 do
    begin
      ParentKey := LowerCase(TreeItemParentKey(I));
      if (ParentKey = '') or
         not AllKeyToIndex.TryGetValue(ParentKey, ParentIndex) then
        Continue;
      FTreeParentIndices[I] := ParentIndex;
      if FTreeFirstChild[ParentIndex] < 0 then
        FTreeFirstChild[ParentIndex] := I
      else
        FTreeNextSibling[LastChild[ParentIndex]] := I;
      LastChild[ParentIndex] := I;
    end;
  finally
    AllKeyToIndex.Free;
  end;

  if not FTreeMode then
  begin
    RebuildCardTreeVisibleSet;
    Exit;
  end;
  VisibleList := TList<Integer>.Create;
  LevelList := TList<Integer>.Create;
  Visited := TDictionary<Integer, Byte>.Create;
  FilteredKeyToIndex := TDictionary<string, Integer>.Create;
  ParentKeys := TDictionary<string, Byte>.Create;
  Children := TObjectDictionary<string, TList<Integer>>.Create([doOwnsValues]);
  try
    for I := 0 to High(FFilteredIndices) do
    begin
      ItemIndex := FFilteredIndices[I];
      KeyValue := LowerCase(TreeItemKey(ItemIndex));
      if (KeyValue <> '') and not FilteredKeyToIndex.ContainsKey(KeyValue) then
        FilteredKeyToIndex.Add(KeyValue, ItemIndex);
      ParentKey := LowerCase(TreeItemParentKey(ItemIndex));
      if ParentKey <> '' then
        ParentKeys.AddOrSetValue(ParentKey, 0);
      if not Children.TryGetValue(ParentKey, ChildList) then
      begin
        ChildList := TList<Integer>.Create;
        Children.Add(ParentKey, ChildList);
      end;
      ChildList.Add(ItemIndex);
    end;

    for I := 0 to High(FFilteredIndices) do
    begin
      ItemIndex := FFilteredIndices[I];
      KeyValue := LowerCase(TreeItemKey(ItemIndex));
      FTreeChildFlags[ItemIndex] :=
        (KeyValue <> '') and ParentKeys.ContainsKey(KeyValue);
    end;

    if (FSearchEngine <> nil) and (FSearchEngine.SearchText <> '') then
    begin
      RebuildSearchTree;
      Exit;
    end;

    for I := 0 to High(FFilteredIndices) do
    begin
      ItemIndex := FFilteredIndices[I];
      ParentKey := LowerCase(TreeItemParentKey(ItemIndex));
      if (ParentKey = '') or
         not FilteredKeyToIndex.ContainsKey(ParentKey) then
        AddBranch(ItemIndex, 0);
    end;
    { Only disconnected cycles need a synthetic root. Descendants of a
      collapsed node are intentionally unvisited and must remain hidden. }
    for I := 0 to High(FFilteredIndices) do
    begin
      ItemIndex := FFilteredIndices[I];
      if not Visited.ContainsKey(ItemIndex) and
         IsDisconnectedCycle(ItemIndex) then
        AddBranch(ItemIndex, 0);
    end;
    FTreeVisibleIndices := VisibleList.ToArray;
    FTreeLevels := LevelList.ToArray;
    RebuildCardTreeVisibleSet;
  finally
    Children.Free;
    ParentKeys.Free;
    FilteredKeyToIndex.Free;
    Visited.Free;
    LevelList.Free;
    VisibleList.Free;
  end;
end;

procedure TUniListView.ToggleTreeNode(const ADisplayIndex: Integer);
var
  ItemIndex, KeyIndex: Integer;
  KeyValue: string;
  Handled: Boolean;
begin
  ItemIndex := DisplayItemIndex(ADisplayIndex);
  if not TreeNodeCanExpand(ItemIndex) then
    Exit;
  KeyValue := TreeItemKey(ItemIndex);
  KeyIndex := FTreeExpandedKeys.IndexOf(KeyValue);
  if KeyIndex >= 0 then
    FTreeExpandedKeys.Delete(KeyIndex)
  else
  begin
    RequestTreeChildren(ItemIndex, Handled);
    if FTreeLazyLoad and (not TreeChildrenLoaded(ItemIndex)) and (not Handled) then
      Exit;
    FTreeExpandedKeys.Add(KeyValue);
  end;
  RebuildTree;
  InvalidateLayout;
end;

function TUniListView.TreeToggleRect(const ADisplayIndex,
  AColumnIndex: Integer; const ARowRect: TRectF): TRectF;
var
  LeftValue: Single;
begin
  LeftValue := ColumnScreenLeft(AColumnIndex) + 6 +
    TreeLevel(ADisplayIndex) * FTreeIndent;
  Result := RectF(LeftValue, ARowRect.Top + (ARowRect.Height - 18) * 0.5,
    LeftValue + 18, ARowRect.Top + (ARowRect.Height - 18) * 0.5 + 18);
end;

function TUniListView.TreeToggleAt(const P: TPointF;
  out ADisplayIndex: Integer): Boolean;
var
  ColumnIndex, I: Integer;
  RowRectValue, ToggleRectValue: TRectF;
begin
  Result := False;
  ADisplayIndex := ListDisplayIndexAtY(P.Y - ListBodyTop - FContentPadding + FScrollY);
  if (ADisplayIndex < 0) or (ADisplayIndex >= DisplayItemCount) then
    Exit;
  ColumnIndex := -1;
  for I := 0 to FColumns.Count - 1 do
    if FColumns[I].Visible and SameText(FColumns[I].FieldName, FTreeColumn) then
    begin
      ColumnIndex := I;
      Break;
    end;
  if ColumnIndex < 0 then
    Exit;
  RowRectValue := ListRowRect(ADisplayIndex);
  ToggleRectValue := TreeToggleRect(ADisplayIndex, ColumnIndex, RowRectValue);
  Result := ToggleRectValue.Contains(P) and TreeNodeCanExpand(DisplayItemIndex(ADisplayIndex));
end;

function TUniListView.TreeCheckRect(const ADisplayIndex,
  AColumnIndex: Integer; const ARowRect: TRectF): TRectF;
var
  LeftValue: Single;
begin
  LeftValue := ColumnScreenLeft(AColumnIndex) + 6 +
    TreeLevel(ADisplayIndex) * FTreeIndent + FTreeIndent;
  Result := RectF(LeftValue, ARowRect.Top + (ARowRect.Height - 16) * 0.5,
    LeftValue + 16, ARowRect.Top + (ARowRect.Height - 16) * 0.5 + 16);
end;

function TUniListView.TreeCheckAt(const P: TPointF;
  out ADisplayIndex: Integer): Boolean;
var
  ColumnIndex, I: Integer;
  RowRectValue: TRectF;
begin
  Result := False;
  ADisplayIndex := ListDisplayIndexAtY(P.Y - ListBodyTop - FContentPadding + FScrollY);
  if (ADisplayIndex < 0) or (ADisplayIndex >= DisplayItemCount) then
    Exit;
  ColumnIndex := -1;
  for I := 0 to FColumns.Count - 1 do
    if FColumns[I].Visible and SameText(FColumns[I].FieldName, FTreeColumn) then
    begin
      ColumnIndex := I;
      Break;
    end;
  if ColumnIndex < 0 then
    Exit;
  RowRectValue := ListRowRect(ADisplayIndex);
  Result := TreeCheckRect(ADisplayIndex, ColumnIndex, RowRectValue).Contains(P);
end;

function TUniListView.ItemCheckKey(const AItemIndex: Integer): string;
begin
  Result := TreeItemKey(AItemIndex);
  if Result = '' then
    Result := IntToStr(AItemIndex);
end;

procedure TUniListView.SetCheckStateInternal(const AItemIndex: Integer;
  const AState: TUniCheckState);
begin
  if (AItemIndex < 0) or (AItemIndex >= FItems.Count) or
     (FItems[AItemIndex].CheckState = AState) then
    Exit;
  FItems[AItemIndex].CheckState := AState;
end;

procedure TUniListView.PropagateCheckDown(const AItemIndex: Integer;
  const AState: TUniCheckState);
var
  ChildIndex: Integer;
  ItemIndex: Integer;
  Stack: TStack<Integer>;
  Visited: TArray<Boolean>;
begin
  if (AItemIndex < 0) or (AItemIndex >= Length(FTreeFirstChild)) or
     (AState = ucsIndeterminate) then
    Exit;
  SetLength(Visited, FItems.Count);
  Stack := TStack<Integer>.Create;
  try
    ChildIndex := FTreeFirstChild[AItemIndex];
    while ChildIndex >= 0 do
    begin
      Stack.Push(ChildIndex);
      ChildIndex := FTreeNextSibling[ChildIndex];
    end;
    while Stack.Count > 0 do
    begin
      ItemIndex := Stack.Pop;
      if (ItemIndex < 0) or (ItemIndex >= Length(Visited)) or
         Visited[ItemIndex] then
        Continue;
      Visited[ItemIndex] := True;
      SetCheckStateInternal(ItemIndex, AState);
      ChildIndex := FTreeFirstChild[ItemIndex];
      while ChildIndex >= 0 do
      begin
        Stack.Push(ChildIndex);
        ChildIndex := FTreeNextSibling[ChildIndex];
      end;
    end;
  finally
    Stack.Free;
  end;
end;

procedure TUniListView.AggregateCheckUp(const AItemIndex: Integer);
var
  AllChecked: Boolean;
  AllUnchecked: Boolean;
  ChildIndex: Integer;
  ItemIndex: Integer;
  NewState: TUniCheckState;
  ParentIndex: Integer;
  Visited: TArray<Boolean>;
begin
  if (AItemIndex < 0) or (AItemIndex >= Length(FTreeParentIndices)) then
    Exit;
  SetLength(Visited, FItems.Count);
  ItemIndex := AItemIndex;
  while (ItemIndex >= 0) and (ItemIndex < Length(FTreeParentIndices)) do
  begin
    ParentIndex := FTreeParentIndices[ItemIndex];
    if (ParentIndex < 0) or (ParentIndex >= Length(Visited)) or
       Visited[ParentIndex] then
      Exit;
    Visited[ParentIndex] := True;
    AllChecked := True;
    AllUnchecked := True;
    ChildIndex := FTreeFirstChild[ParentIndex];
    while ChildIndex >= 0 do
    begin
      AllChecked := AllChecked and
        (FItems[ChildIndex].CheckState = ucsChecked);
      AllUnchecked := AllUnchecked and
        (FItems[ChildIndex].CheckState = ucsUnchecked);
      ChildIndex := FTreeNextSibling[ChildIndex];
    end;
    if AllChecked then
      NewState := ucsChecked
    else if AllUnchecked then
      NewState := ucsUnchecked
    else
      NewState := ucsIndeterminate;
    SetCheckStateInternal(ParentIndex, NewState);
    ItemIndex := ParentIndex;
  end;
end;

procedure TUniListView.ExecuteCheckOperation(const AItemIndex: Integer;
  const AState: TUniCheckState; const ANotifyChanging: Boolean);
var
  Allow: Boolean;
  NewState: TUniCheckState;
  OldState: TUniCheckState;
begin
  if FApplyingCheckEngine or (AItemIndex < 0) or
     (AItemIndex >= FItems.Count) then
    Exit;
  NewState := AState;
  if (NewState = ucsIndeterminate) and
     ((FTreeCheckMode <> tcmCascadeFull) or
      (AItemIndex >= Length(FTreeFirstChild)) or
      (FTreeFirstChild[AItemIndex] < 0)) then
    NewState := ucsUnchecked;
  OldState := FItems[AItemIndex].CheckState;
  Allow := True;
  if ANotifyChanging and Assigned(FOnItemCheckChanging) then
    FOnItemCheckChanging(Self, ItemCheckKey(AItemIndex), OldState,
      NewState, Allow);
  if not Allow then
    Exit;
  if ANotifyChanging and (OldState = NewState) and
     ((FTreeCheckMode = tcmIndependent) or
      (AItemIndex >= Length(FTreeFirstChild)) or
      (FTreeFirstChild[AItemIndex] < 0)) then
    Exit;
  FApplyingCheckEngine := True;
  FCheckBatch := True;
  try
    SetCheckStateInternal(AItemIndex, NewState);
    if FTreeCheckMode in [tcmCascadeDown, tcmCascadeFull] then
      PropagateCheckDown(AItemIndex, NewState);
    if FTreeCheckMode = tcmCascadeFull then
      AggregateCheckUp(AItemIndex);
  finally
    FCheckBatch := False;
    FApplyingCheckEngine := False;
  end;
  RecalculateCheckedCount;
  Redraw;
  if Assigned(FOnItemCheckChanged) then
    FOnItemCheckChanged(Self, FItems[AItemIndex],
      FItems[AItemIndex].Checked);
  if Assigned(FOnCheckedChanged) then
    FOnCheckedChanged(Self);
  if Assigned(FOnTreeCheckPropagationCompleted) then
    FOnTreeCheckPropagationCompleted(Self);
end;

procedure TUniListView.ToggleItemChecked(const AIndex: Integer);
var
  NewState: TUniCheckState;
begin
  if (AIndex < 0) or (AIndex >= FItems.Count) then
    raise EArgumentOutOfRangeException.CreateFmt(
      'Item index %d is out of range.', [AIndex]);
  if not FItems[AIndex].Enabled then
    Exit;
  if FItems[AIndex].CheckState = ucsChecked then
    NewState := ucsUnchecked
  else
    NewState := ucsChecked;
  ExecuteCheckOperation(AIndex, NewState);
end;
function TUniListView.FirstVisibleColumnIndex: Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to FColumns.Count - 1 do
    if FColumns[I].Visible then
      Exit(I);
end;

function TUniListView.IsLastVisibleColumn(
  const AColumnIndex: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  if (AColumnIndex < 0) or (AColumnIndex >= FColumns.Count) or
     not FColumns[AColumnIndex].Visible then
    Exit;
  for I := AColumnIndex + 1 to FColumns.Count - 1 do
    if FColumns[I].Visible then
      Exit;
  Result := True;
end;

function TUniListView.ListCheckRect(const ADisplayIndex, AColumnIndex: Integer;
  const ARowRect: TRectF): TRectF;
var
  LeftValue: Single;
begin
  if FTreeMode then
    LeftValue := ColumnScreenLeft(AColumnIndex) + 8
  else
    LeftValue := FContentPadding +
      (LIST_CHECKBOX_AREA_WIDTH - GRID_CARD_CHECKBOX_SIZE) * 0.5;
  Result := RectF(LeftValue, ARowRect.Top + (ARowRect.Height - 16) * 0.5,
    LeftValue + 16, ARowRect.Top + (ARowRect.Height - 16) * 0.5 + 16);
end;

function TUniListView.ListCheckAt(const P: TPointF;
  out ADisplayIndex: Integer): Boolean;
var
  ColumnIndex: Integer;
  RowRectValue: TRectF;
begin
  Result := False;
  ADisplayIndex := ListDisplayIndexAtY(P.Y - ListBodyTop - FContentPadding + FScrollY);
  if (ADisplayIndex < 0) or (ADisplayIndex >= DisplayItemCount) then
    Exit;
  ColumnIndex := FirstVisibleColumnIndex;
  if ColumnIndex < 0 then
    Exit;
  RowRectValue := ListRowRect(ADisplayIndex);
  Result := ListCheckRect(ADisplayIndex, ColumnIndex, RowRectValue).Contains(P);
end;

function TUniListView.CardCheckRect(const AItemIndex: Integer): TRectF;
var
  DisplayIndex: Integer;
  R: TRectF;
begin
  DisplayIndex := CardDisplayIndexOf(AItemIndex);
  if DisplayIndex < 0 then
    Exit(TRectF.Empty);
  R := CardRect(DisplayIndex);
  if FCardLayout = uclFullWidth then
    Result := RectF(R.Left + FULL_WIDTH_CARD_HORIZONTAL_PADDING,
      R.Top + FULL_WIDTH_CARD_VERTICAL_PADDING,
      R.Left + FULL_WIDTH_CARD_HORIZONTAL_PADDING + 16,
      R.Top + FULL_WIDTH_CARD_VERTICAL_PADDING + 16)
  else
    Result := RectF(R.Left + FCardTemplate.InnerPadding,
      R.Top + FCardTemplate.InnerPadding,
      R.Left + FCardTemplate.InnerPadding + GRID_CARD_CHECKBOX_SIZE,
      R.Top + FCardTemplate.InnerPadding + GRID_CARD_CHECKBOX_SIZE);
end;

function TUniListView.CardCheckAt(const P: TPointF;
  out AItemIndex: Integer): Boolean;
var
  I, ItemIndex: Integer;
begin
  Result := False;
  AItemIndex := -1;
  for I := FirstVisibleIndex to LastVisibleIndex do
  begin
    ItemIndex := CardDisplayItemIndex(I);
    if (ItemIndex >= 0) and CardCheckRect(ItemIndex).Contains(P) then
    begin
      AItemIndex := ItemIndex;
      Exit(True);
    end;
  end;
end;

function TUniListView.ResolveIconColor(const ADefault: TAlphaColor): TAlphaColor;
begin
  if FUseStyleBook and (FStyleIconColor <> TAlphaColors.Null) then
    Result := FStyleIconColor
  else
    Result := ADefault;
end;

procedure TUniListView.ClearStyleCheckCache;
begin
  FreeAndNil(FStyleCheckImages[False]);
  FreeAndNil(FStyleCheckImages[True]);
  FStyleCheckCacheReady := False;
end;

procedure TUniListView.EnsureStyleCheckCache;
var
  Check: TCheckBox;
  Style: TFmxObject;
  Checked: Boolean;
  Data: TBitmapData;
  X, Y, LeftPixel, TopPixel, RightPixel, BottomPixel: Integer;
  procedure FinishAnimations(const Obj: TFmxObject);
  var
    Child: TFmxObject;
  begin
    if Obj is TAnimation then TAnimation(Obj).Stop;
    if Obj.ChildrenCount > 0 then
      for Child in Obj.Children do FinishAnimations(Child);
  end;
begin
  if FStyleCheckCacheReady and SameValue(FStyleCheckScale, CurrentSceneScale) then Exit;
  ClearStyleCheckCache;
  FStyleCheckCacheReady := True;
  FStyleCheckScale := CurrentSceneScale;
  if not FUseStyleBook or (Scene = nil) or (Scene.StyleBook = nil) then Exit;
  Style := Scene.StyleBook.GetStyle(Self);
  if (Style = nil) or (Style.FindStyleResource('checkboxstyle') = nil) then Exit;
  Check := TCheckBox.Create(nil);
  try
    // No Parent: the probe never enters the visual tree or the tab order.
    Check.SetNewScene(Scene);
    Check.Text := '';
    Check.StyleLookup := 'checkboxstyle';
    Check.SetBounds(0, 0, 32, 32);
    Check.ApplyStyleLookup;
    LeftPixel := MaxInt;
    TopPixel := MaxInt;
    RightPixel := 0;
    BottomPixel := 0;
    for Checked := False to True do
    begin
      Check.IsChecked := Checked;
      Check.StartTriggerAnimation(Check, 'IsChecked');
      FinishAnimations(Check);
      FStyleCheckImages[Checked] := Check.MakeScreenshot;
      if FStyleCheckImages[Checked].Map(TMapAccess.Read, Data) then
      try
        for Y := 0 to Data.Height - 1 do
          for X := 0 to Data.Width - 1 do
            if (Data.GetPixel(X, Y) shr 24) <> 0 then
            begin
              LeftPixel := Min(LeftPixel, X);
              TopPixel := Min(TopPixel, Y);
              RightPixel := Max(RightPixel, X + 1);
              BottomPixel := Max(BottomPixel, Y + 1);
            end;
      finally
        FStyleCheckImages[Checked].Unmap(Data);
      end;
    end;
    if (RightPixel > LeftPixel) and (BottomPixel > TopPixel) then
      FStyleCheckSource := RectF(LeftPixel, TopPixel, RightPixel, BottomPixel)
    else
    begin
      FreeAndNil(FStyleCheckImages[False]);
      FreeAndNil(FStyleCheckImages[True]);
    end;
  finally
    Check.Free;
  end;
end;

procedure TUniListView.DrawCheckBox(const ACanvas: IUniCanvas;
  const ARect: TRectF; const AState: TUniCheckState);
var
  Paint: IUniPaint;
  BitmapCanvas: IUniBitmapCanvas;
begin
  if FUseStyleBook and Supports(ACanvas, IUniBitmapCanvas, BitmapCanvas) then
  begin
    EnsureStyleCheckCache;
    if FStyleCheckImages[AState = ucsChecked] <> nil then
    begin
      BitmapCanvas.DrawBitmap(FStyleCheckImages[AState = ucsChecked], FStyleCheckSource, ARect);
      if AState = ucsIndeterminate then
      begin
        Paint := TUniPaintFactory.Create;
        Paint.Style := TUniPaintStyle.Fill;
        Paint.Color := FTextColor;
        ACanvas.DrawRect(RectF(ARect.Left + ARect.Width * 0.25,
          ARect.CenterPoint.Y - 1, ARect.Right - ARect.Width * 0.25,
          ARect.CenterPoint.Y + 1), Paint);
      end;
      Exit;
    end;
  end;
  Paint := TUniPaintFactory.Create;
  Paint.AntiAlias := True;
  Paint.Style := TUniPaintStyle.Stroke;
  Paint.StrokeWidth := 1.5;
  Paint.Color := FGridColor;
  ACanvas.DrawRoundRect(ARect, 3, 3, Paint);
  if AState = ucsUnchecked then
    Exit;
  Paint.Style := TUniPaintStyle.Fill;
  Paint.Color := FAccentColor;
  ACanvas.DrawRoundRect(ARect, 3, 3, Paint);
  Paint.Color := FBackgroundColor;
  Paint.StrokeWidth := 2;
  if AState = ucsChecked then
  begin
    Paint.Style := TUniPaintStyle.Stroke;
    ACanvas.DrawLine(ARect.Left + 3, ARect.Top + 7,
      ARect.Left + 6, ARect.Bottom - 3, Paint);
    ACanvas.DrawLine(ARect.Left + 6, ARect.Bottom - 3,
      ARect.Right - 3, ARect.Top + 3, Paint);
  end
  else
  begin
    Paint.Style := TUniPaintStyle.Fill;
    ACanvas.DrawRect(RectF(ARect.Left + 3, (ARect.Top + ARect.Bottom) * 0.5 - 1,
      ARect.Right - 3, (ARect.Top + ARect.Bottom) * 0.5 + 1), Paint);
  end;
end;

function TUniListView.TreeCheckState(const AItemIndex: Integer): TUniCheckState;
begin
  if (AItemIndex < 0) or (AItemIndex >= FItems.Count) then
    Exit(ucsUnchecked);
  Result := FItems[AItemIndex].CheckState;
end;

procedure TUniListView.ToggleTreeCheck(const ADisplayIndex: Integer);
var
  ItemIndex: Integer;
begin
  ItemIndex := DisplayItemIndex(ADisplayIndex);
  if ItemIndex < 0 then
    Exit;
  ToggleItemChecked(ItemIndex);
end;

procedure TUniListView.CheckAll;
begin
  CheckAll(ucsAllItems);
end;

procedure TUniListView.CheckAll(const AScope: TUniCheckScope);
var
  DisplayIndex: Integer;
  ItemIndex: Integer;
  VisibleItemIndex: Integer;
begin
  FApplyingCheckEngine := True;
  FCheckBatch := True;
  try
    if AScope = ucsAllItems then
      for ItemIndex := 0 to FItems.Count - 1 do
        SetCheckStateInternal(ItemIndex, ucsChecked)
    else
      for DisplayIndex := 0 to NavigationItemCount - 1 do
      begin
        VisibleItemIndex := NavigationItemIndex(DisplayIndex);
        SetCheckStateInternal(VisibleItemIndex, ucsChecked);
      end;
    if FTreeCheckMode = tcmCascadeFull then
      RecalculateTreeCheckStatesInternal;
  finally
    FCheckBatch := False;
    FApplyingCheckEngine := False;
  end;
  RecalculateCheckedCount;
  Redraw;
  if Assigned(FOnCheckedChanged) then
    FOnCheckedChanged(Self);
  if Assigned(FOnTreeCheckPropagationCompleted) then
    FOnTreeCheckPropagationCompleted(Self);
end;

procedure TUniListView.UncheckAll;
begin
  UncheckAll(ucsAllItems);
end;

procedure TUniListView.UncheckAll(const AScope: TUniCheckScope);
var
  DisplayIndex: Integer;
  ItemIndex: Integer;
  VisibleItemIndex: Integer;
begin
  FApplyingCheckEngine := True;
  FCheckBatch := True;
  try
    if AScope = ucsAllItems then
      for ItemIndex := 0 to FItems.Count - 1 do
        SetCheckStateInternal(ItemIndex, ucsUnchecked)
    else
      for DisplayIndex := 0 to NavigationItemCount - 1 do
      begin
        VisibleItemIndex := NavigationItemIndex(DisplayIndex);
        SetCheckStateInternal(VisibleItemIndex, ucsUnchecked);
      end;
    if FTreeCheckMode = tcmCascadeFull then
      RecalculateTreeCheckStatesInternal;
  finally
    FCheckBatch := False;
    FApplyingCheckEngine := False;
  end;
  RecalculateCheckedCount;
  Redraw;
  if Assigned(FOnCheckedChanged) then
    FOnCheckedChanged(Self);
  if Assigned(FOnTreeCheckPropagationCompleted) then
    FOnTreeCheckPropagationCompleted(Self);
end;

procedure TUniListView.InvertChecks;
begin
  InvertChecks(ucsAllItems);
end;

procedure TUniListView.InvertChecks(const AScope: TUniCheckScope);
var
  DisplayIndex: Integer;
  ItemIndex: Integer;
  NewState: TUniCheckState;
  VisibleItemIndex: Integer;

  procedure InvertItem(const AItemIndex: Integer);
  begin
    if (AItemIndex < 0) or (AItemIndex >= FItems.Count) then
      Exit;
    if FItems[AItemIndex].CheckState = ucsChecked then
      NewState := ucsUnchecked
    else
      NewState := ucsChecked;
    SetCheckStateInternal(AItemIndex, NewState);
  end;

begin
  FApplyingCheckEngine := True;
  FCheckBatch := True;
  try
    if AScope = ucsAllItems then
      for ItemIndex := 0 to FItems.Count - 1 do
        InvertItem(ItemIndex)
    else
      for DisplayIndex := 0 to NavigationItemCount - 1 do
      begin
        VisibleItemIndex := NavigationItemIndex(DisplayIndex);
        InvertItem(VisibleItemIndex);
      end;
    if FTreeCheckMode = tcmCascadeFull then
      RecalculateTreeCheckStatesInternal;
  finally
    FCheckBatch := False;
    FApplyingCheckEngine := False;
  end;
  RecalculateCheckedCount;
  Redraw;
  if Assigned(FOnCheckedChanged) then
    FOnCheckedChanged(Self);
  if Assigned(FOnTreeCheckPropagationCompleted) then
    FOnTreeCheckPropagationCompleted(Self);
end;
function TUniListView.IsItemChecked(const AIndex: Integer): Boolean;
begin
  if (AIndex < 0) or (AIndex >= FItems.Count) then
    raise EArgumentOutOfRangeException.CreateFmt(
      'Item index %d is out of range.', [AIndex]);
  Result := FItems[AIndex].Checked;
end;

procedure TUniListView.SetItemChecked(const AIndex: Integer;
  const AChecked: Boolean);
begin
  if (AIndex < 0) or (AIndex >= FItems.Count) then
    raise EArgumentOutOfRangeException.CreateFmt(
      'Item index %d is out of range.', [AIndex]);
  if AChecked then
    ExecuteCheckOperation(AIndex, ucsChecked)
  else
    ExecuteCheckOperation(AIndex, ucsUnchecked);
end;

function TUniListView.FirstCheckedItem: TUniListItem;
var
  Item: TUniListItem;
begin
  Result := nil;
  for Item in FItems do
    if Item.Checked then
      Exit(Item);
end;

function TUniListView.LastCheckedItem: TUniListItem;
var
  ItemIndex: Integer;
begin
  Result := nil;
  for ItemIndex := FItems.Count - 1 downto 0 do
    if FItems[ItemIndex].Checked then
      Exit(FItems[ItemIndex]);
end;

procedure TUniListView.RecalculateTreeCheckStatesInternal;
var
  AllChecked: Boolean;
  AllUnchecked: Boolean;
  ChildIndex: Integer;
  ChildCounts: TArray<Integer>;
  ItemIndex: Integer;
  NewState: TUniCheckState;
  ParentIndex: Integer;
  Queue: TQueue<Integer>;
begin
  if FItems.Count = 0 then
    Exit;
  SetLength(ChildCounts, FItems.Count);
  for ItemIndex := 0 to FItems.Count - 1 do
  begin
    ChildIndex := FTreeFirstChild[ItemIndex];
    while ChildIndex >= 0 do
    begin
      Inc(ChildCounts[ItemIndex]);
      ChildIndex := FTreeNextSibling[ChildIndex];
    end;
  end;
  Queue := TQueue<Integer>.Create;
  try
    for ItemIndex := 0 to FItems.Count - 1 do
      if ChildCounts[ItemIndex] = 0 then
      begin
        if FItems[ItemIndex].CheckState = ucsIndeterminate then
          SetCheckStateInternal(ItemIndex, ucsUnchecked);
        Queue.Enqueue(ItemIndex);
      end;
    while Queue.Count > 0 do
    begin
      ItemIndex := Queue.Dequeue;
      ParentIndex := FTreeParentIndices[ItemIndex];
      if ParentIndex < 0 then
        Continue;
      Dec(ChildCounts[ParentIndex]);
      if ChildCounts[ParentIndex] <> 0 then
        Continue;
      AllChecked := True;
      AllUnchecked := True;
      ChildIndex := FTreeFirstChild[ParentIndex];
      while ChildIndex >= 0 do
      begin
        AllChecked := AllChecked and
          (FItems[ChildIndex].CheckState = ucsChecked);
        AllUnchecked := AllUnchecked and
          (FItems[ChildIndex].CheckState = ucsUnchecked);
        ChildIndex := FTreeNextSibling[ChildIndex];
      end;
      if AllChecked then
        NewState := ucsChecked
      else if AllUnchecked then
        NewState := ucsUnchecked
      else
        NewState := ucsIndeterminate;
      SetCheckStateInternal(ParentIndex, NewState);
      Queue.Enqueue(ParentIndex);
    end;
  finally
    Queue.Free;
  end;
end;

procedure TUniListView.RecalculateTreeCheckStates;
var
  ItemIndex: Integer;
begin
  FApplyingCheckEngine := True;
  FCheckBatch := True;
  try
    if FTreeCheckMode = tcmCascadeFull then
      RecalculateTreeCheckStatesInternal
    else
      for ItemIndex := 0 to FItems.Count - 1 do
        if FItems[ItemIndex].CheckState = ucsIndeterminate then
          SetCheckStateInternal(ItemIndex, ucsUnchecked);
  finally
    FCheckBatch := False;
    FApplyingCheckEngine := False;
  end;
  RecalculateCheckedCount;
  Redraw;
end;

procedure TUniListView.SetTreeCheckMode(const Value: TUniTreeCheckMode);
begin
  if FTreeCheckMode = Value then
    Exit;
  FTreeCheckMode := Value;
  RecalculateTreeCheckStates;
end;

procedure TUniListView.SetItemCheckState(const AItemId: string;
  const AState: TUniCheckState);
var
  ItemIndex: Integer;
begin
  ItemIndex := CardTreeFindItem(AItemId);
  if ItemIndex >= 0 then
    ExecuteCheckOperation(ItemIndex, AState);
end;

function TUniListView.GetItemCheckState(
  const AItemId: string): TUniCheckState;
var
  ItemIndex: Integer;
begin
  ItemIndex := CardTreeFindItem(AItemId);
  if ItemIndex < 0 then
    Exit(ucsUnchecked);
  Result := FItems[ItemIndex].CheckState;
end;

procedure TUniListView.CheckItem(const AItemId: string;
  const AChecked: Boolean);
begin
  if AChecked then
    SetItemCheckState(AItemId, ucsChecked)
  else
    SetItemCheckState(AItemId, ucsUnchecked);
end;
procedure TUniListView.RecalculateCheckedCount;
var
  Item: TUniListItem;
begin
  FCheckedCount := 0;
  for Item in FItems do
    if Item.Checked then
      Inc(FCheckedCount);
end;

function TUniListView.GetCheckedItems: TUniCheckedItems;
begin
  Result := TUniCheckedItems.Create(FItems);
end;

function TUniListView.CheckBoxesVisible: Boolean;
begin
  Result := FMultiCheck and FShowCheckBoxes;
end;

function TUniListView.CheckedTreeKeys: TArray<string>;
var
  ItemIndex, ResultIndex: Integer;
begin
  SetLength(Result, FCheckedCount);
  ResultIndex := 0;
  for ItemIndex := 0 to FItems.Count - 1 do
    if FItems[ItemIndex].Checked then
    begin
      Result[ResultIndex] := ItemCheckKey(ItemIndex);
      Inc(ResultIndex);
    end;
end;

function TUniListView.CheckedKeys: TArray<string>;
begin
  Result := CheckedTreeKeys;
end;

procedure TUniListView.MarkChildrenLoaded(const AParentKey: string);
begin
  if AParentKey = '' then
    Exit;
  if FTreeLoadedKeys.IndexOf(AParentKey) < 0 then
    FTreeLoadedKeys.Add(AParentKey);
  RebuildTree;
  InvalidateLayout;
end;

procedure TUniListView.ReloadChildren(const AParentKey: string);
var
  IndexValue: Integer;
begin
  if AParentKey = '' then
    Exit;
  IndexValue := FTreeLoadedKeys.IndexOf(AParentKey);
  if IndexValue >= 0 then
    FTreeLoadedKeys.Delete(IndexValue);
  IndexValue := FTreeExpandedKeys.IndexOf(AParentKey);
  if IndexValue >= 0 then
    FTreeExpandedKeys.Delete(IndexValue);
  RebuildTree;
  InvalidateLayout;
end;

function TUniListView.ChildrenLoaded(const AParentKey: string): Boolean;
begin
  Result := (not FTreeLazyLoad) or
    ((AParentKey <> '') and (FTreeLoadedKeys.IndexOf(AParentKey) >= 0));
end;

procedure TUniListView.ExpandAll;
var
  ExpandedKeyLookup, ParentKeys: TDictionary<string, Byte>;
  ExpandedKeys: TStringList;
  I: Integer;
  KeyValue, ParentKey: string;
begin
  ExpandedKeyLookup := TDictionary<string, Byte>.Create;
  ParentKeys := TDictionary<string, Byte>.Create;
  ExpandedKeys := TStringList.Create;
  try
    ExpandedKeys.CaseSensitive := False;
    for I := 0 to FItems.Count - 1 do
    begin
      ParentKey := LowerCase(TreeItemParentKey(I));
      if ParentKey <> '' then
        ParentKeys.AddOrSetValue(ParentKey, 0);
    end;
    for I := 0 to FItems.Count - 1 do
    begin
      KeyValue := TreeItemKey(I);
      if (KeyValue = '') or
         not ParentKeys.ContainsKey(LowerCase(KeyValue)) or
         ExpandedKeyLookup.ContainsKey(LowerCase(KeyValue)) then
        Continue;
      ExpandedKeyLookup.Add(LowerCase(KeyValue), 0);
      ExpandedKeys.Add(KeyValue);
    end;
    ExpandedKeys.Sort;
    FTreeExpandedKeys.Assign(ExpandedKeys);
  finally
    ExpandedKeys.Free;
    ParentKeys.Free;
    ExpandedKeyLookup.Free;
  end;
  RebuildTree;
  InvalidateLayout;
end;

procedure TUniListView.CollapseAll;
begin
  FTreeExpandedKeys.Clear;
  RebuildTree;
  InvalidateLayout;
end;

procedure TUniListView.ExpandToLevel(const ALevel: Integer);
var
  I, J, LevelValue, ParentIndex: Integer;
  ParentKey: string;
begin
  FTreeExpandedKeys.Clear;
  if ALevel <= 0 then
  begin
    RebuildTree;
    InvalidateLayout;
    Exit;
  end;
  for I := 0 to FItems.Count - 1 do
  begin
    LevelValue := 0;
    ParentKey := TreeItemParentKey(I);
    while (ParentKey <> '') and (LevelValue < ALevel) do
    begin
      ParentIndex := -1;
      for J := 0 to FItems.Count - 1 do
        if SameText(TreeItemKey(J), ParentKey) then
        begin
          ParentIndex := J;
          Break;
        end;
      if ParentIndex < 0 then
        Break;
      Inc(LevelValue);
      ParentKey := TreeItemParentKey(ParentIndex);
    end;
    if (LevelValue < ALevel) and TreeHasChildren(I) then
      FTreeExpandedKeys.Add(TreeItemKey(I));
  end;
  RebuildTree;
  InvalidateLayout;
end;

procedure TUniListView.SetTreeLazyLoad(const Value: Boolean);
begin
  if FTreeLazyLoad = Value then
    Exit;
  FTreeLazyLoad := Value;
  if not FTreeLazyLoad then
  begin
    FTreeLoadedKeys.Clear;
    FTreeLoadingKeys.Clear;
  end;
  RebuildTree;
  InvalidateLayout;
end;

procedure TUniListView.SetTreeHasChildrenField(const Value: string);
begin
  if FTreeHasChildrenField = Value then
    Exit;
  FTreeHasChildrenField := Value;
  RefreshDesignPreview;
  RebuildTree;
  InvalidateLayout;
end;

procedure TUniListView.SetTreeCheckBoxes(const Value: Boolean);
begin
  SetMultiCheck(Value);
end;

procedure TUniListView.SetMultiCheck(const Value: Boolean);
begin
  if FMultiCheck = Value then
    Exit;
  FMultiCheck := Value;
  if csDesigning in ComponentState then
    RefreshDesignPreview;
  InvalidateAutoTitleWidth;
  InvalidateLayout;
end;

procedure TUniListView.SetShowCheckBoxes(const Value: Boolean);
begin
  if FShowCheckBoxes = Value then
    Exit;
  FShowCheckBoxes := Value;
  InvalidateAutoTitleWidth;
  InvalidateLayout;
end;

procedure TUniListView.SetTreeMode(const Value: Boolean);
begin
  if FTreeMode = Value then
    Exit;
  FTreeMode := Value;
  FHotHit := TUniCardHit.None;
  FPressedHit := TUniCardHit.None;
  if FTreeMode and (SearchText <> '') then
    SaveSearchTreeState;
  RefreshDesignPreview;
  RebuildTree;
  ConfigureSearch;
  InvalidateLayout;
end;

procedure TUniListView.SetTreeKeyField(const Value: string);
begin
  if FTreeKeyField = Value then
    Exit;
  FTreeKeyField := Value;
  FTreeExpandedKeys.Clear;
  RefreshDesignPreview;
  RebuildTree;
  InvalidateLayout;
end;

procedure TUniListView.SetTreeParentField(const Value: string);
begin
  if FTreeParentField = Value then Exit;
  FTreeParentField := Value;
  RefreshDesignPreview;
  RebuildTree;
  InvalidateLayout;
end;

procedure TUniListView.SetTreeColumn(const Value: string);
begin
  if FTreeColumn = Value then Exit;
  FTreeColumn := Value;
  RefreshDesignPreview;
  Redraw;
end;

function TUniListView.FilterColumnHit(const P: TPointF): Integer;
var
  ColumnIndex: Integer;
  R: TRectF;
begin
  Result := -1;
  if not FListFilterVisible then
    Exit;
  for ColumnIndex := 0 to FColumns.Count - 1 do
    if FColumns[ColumnIndex].Visible then
    begin
      R := RectF(ColumnScreenLeft(ColumnIndex), FListHeaderHeight,
        ColumnScreenLeft(ColumnIndex) + FColumnWidths[ColumnIndex],
        ListBodyTop);
      if R.Contains(P) then
        Exit(ColumnIndex);
    end;
end;

procedure TUniListView.DrawListFilter(const ACanvas: IUniCanvas);
var
  Paint: IUniPaint;
  Font: IUniFont;
  ColumnIndex: Integer;
  R: TRectF;
  TextValueLocal: string;
begin
  if not FListFilterVisible then
    Exit;
  Paint := TUniPaintFactory.Create;
  Paint.AntiAlias := True;
  Font := CreateTextFont(FFontSize);
  for ColumnIndex := 0 to FColumns.Count - 1 do
    if FColumns[ColumnIndex].Visible then
    begin
      R := RectF(ColumnScreenLeft(ColumnIndex), FListHeaderHeight,
        ColumnScreenLeft(ColumnIndex) + FColumnWidths[ColumnIndex],
        ListBodyTop);
      Paint.Style := TUniPaintStyle.Fill;
      if ColumnIndex = FFilterEditColumn then
        Paint.Color := $FFFFFFFF
      else
        Paint.Color := FFooterColor;
      ACanvas.DrawRect(R, Paint);
      TextValueLocal := FColumns[ColumnIndex].FilterValue;
      if TextValueLocal = '' then
        TextValueLocal := 'Фильтр...';
      if FColumns[ColumnIndex].FilterValue = '' then
        Paint.Color := $FF9CA3AF
      else
        Paint.Color := FTextColor;
      ACanvas.Save;
      ACanvas.ClipRect(R);
      ACanvas.DrawSimpleText(TextValueLocal, R.Left + 8,
        R.Top + (R.Height + FFontSize) * 0.5 - 1, Font, Paint);
      ACanvas.Restore;
      Paint.Style := TUniPaintStyle.Stroke;
      Paint.StrokeWidth := 1;
      Paint.Color := FGridColor;
      ACanvas.DrawLine(R.Left, R.Top, R.Right, R.Top, Paint);
      ACanvas.DrawLine(R.Left, R.Bottom, R.Right, R.Bottom, Paint);
      if ColumnIndex = FirstVisibleColumnIndex then
        ACanvas.DrawLine(R.Left, R.Top, R.Left, R.Bottom, Paint);
      if not IsLastVisibleColumn(ColumnIndex) then
        ACanvas.DrawLine(R.Right, R.Top, R.Right, R.Bottom, Paint);
    end;
end;

procedure TUniListView.ClearFilters;
var
  ColumnIndex: Integer;
begin
  FColumns.BeginUpdate;
  try
    for ColumnIndex := 0 to FColumns.Count - 1 do
      FColumns[ColumnIndex].FilterValue := '';
  finally
    FColumns.EndUpdate;
  end;
  FFilterEditColumn := -1;
  RebuildFilter;
  FScrollY := 0;
  InvalidateLayout;
end;

procedure TUniListView.SetListAutoRowHeight(const Value: Boolean);
begin
  if FListAutoRowHeight = Value then
    Exit;
  FListAutoRowHeight := Value;
  InvalidateLayout;
end;

procedure TUniListView.SetListRowHeight(const Value: Single);
begin
  if SameValue(FListRowHeight, Value) then
    Exit;
  FListRowHeight := Max(18, Value);
  InvalidateLayout;
end;

procedure TUniListView.SetListFilterVisible(const Value: Boolean);
begin
  if FListFilterVisible = Value then
    Exit;
  FListFilterVisible := Value;
  if not Value then
    FFilterEditColumn := -1;
  FScrollY := 0;
  RebuildFilter;
  InvalidateLayout;
end;

procedure TUniListView.SetListFilterHeight(const Value: Single);
var
  NewValue: Single;
begin
  NewValue := Max(20, Value);
  if SameValue(FListFilterHeight, NewValue) then
    Exit;
  FListFilterHeight := NewValue;
  InvalidateLayout;
end;

procedure TUniListView.SetListFooterVisible(const Value: Boolean);
begin
  if FListFooterVisible = Value then
    Exit;

  FListFooterVisible := Value;
  InvalidateLayout;
end;

procedure TUniListView.SetListFooterHeight(const Value: Single);
var
  NewValue: Single;
begin
  NewValue := Max(18, Value);
  if SameValue(FListFooterHeight, NewValue) then
    Exit;

  FListFooterHeight := NewValue;
  InvalidateLayout;
end;

procedure TUniListView.SetListFrozenColumnCount(const Value: Integer);
var
  ColumnIndex, VisibleIndex, NewValue: Integer;
begin
  NewValue := Max(0, Value);
  if FListFrozenColumnCount = NewValue then
    Exit;
  FListFrozenColumnCount := NewValue;
  VisibleIndex := 0;
  FColumns.BeginUpdate;
  try
    for ColumnIndex := 0 to FColumns.Count - 1 do
      if FColumns[ColumnIndex].Visible then
      begin
        FColumns[ColumnIndex].Frozen := VisibleIndex < NewValue;
        Inc(VisibleIndex);
      end
      else
        FColumns[ColumnIndex].Frozen := False;
  finally
    FColumns.EndUpdate;
  end;
  FScrollX := 0;
  InvalidateLayout;
end;

procedure TUniListView.SetColorRules(const Value: TUniColorRules);
begin
  FColorRules.Assign(Value);
end;

procedure TUniListView.SetColumns(const Value: TUniListColumns);
begin
  FColumns.Assign(Value);
end;

procedure TUniListView.SetActions(const Value: TUniCardActions);
begin
  FActions.Assign(Value);
end;

procedure TUniListView.SetActionVisibility(
  const Value: TUniActionVisibility);
begin
  if FActionVisibility = Value then
    Exit;
  FActionVisibility := Value;
  FHotHit := TUniCardHit.None;
  if FPressedHit.Kind = uchAction then
    FPressedHit := TUniCardHit.None;
  Redraw;
end;

procedure TUniListView.SetCardTemplate(const Value: TUniCardTemplate);
begin
  FCardTemplate.Assign(Value);
end;

procedure TUniListView.SetScrollX(const Value: Single);
begin
  FScrollX := Value;
  ClampScroll;
  Redraw;
end;

procedure TUniListView.SetScrollY(const Value: Single);
begin
  FScrollY := Value;
  ClampScroll;
  Redraw;
end;

procedure TUniListView.ApplyTheme(const ATheme: TUniThemeDefinition);
begin
  if ATheme = nil then Exit;
  if not (csLoading in ComponentState) then SetUseStyleBook(False);
  FThemeName := ATheme.Name;
  ApplyPalette(ATheme.Background, ATheme.Foreground, ATheme.Cursor,
    ATheme.Selection, ATheme.TerminalUI, ATheme.Variant);
end;

procedure TUniListView.ApplyPalette(const Background, Foreground, Accent,
  Selection, UI: TAlphaColor; const Variant: TUniThemeVariant);
begin
  FThemeVariant := Variant;
  FBackgroundColor := Background;
  FTextColor := Foreground;
  FAccentColor := Accent;
  FCardColor := UniBlendColor(Background, Foreground,
    IfThen(Variant = utvDark, 0.055, 0.025));
  FCardHotColor := UniBlendColor(FCardColor, Foreground,
    IfThen(Variant = utvDark, 0.09, 0.055));
  FCardSelectedColor := UniBlendColor(Background, Selection, 0.28);
  FSecondaryTextColor := UniBlendColor(Foreground, Background, 0.38);
  FHeaderColor := UniBlendColor(Background, UI,
    IfThen(Variant = utvDark, 0.22, 0.10));
  FAlternateRowColor := UniBlendColor(FCardColor, UI,
    IfThen(Variant = utvDark, 0.055, 0.025));
  FFooterColor := UniBlendColor(FHeaderColor, Background, 0.18);
  FGridColor := UniBlendColor(Background, UI, 0.48);
  FCardTreeParentBackgroundColor := UniBlendColor(FCardColor,
    Accent, FCardTreeExplorerParentEmphasis);
  FCardTreeNavigationIconColor := Accent;
  FCardTreeBreadcrumbTextColor := FSecondaryTextColor;
  FCardTreeBreadcrumbHotColor := Accent;
  Redraw;
end;

procedure TUniListView.SaveOwnTheme;
begin
  FOwnThemeVariant := FThemeVariant;
  FOwnThemeColors := TArray<TAlphaColor>.Create(FBackgroundColor, FTextColor,
    FAccentColor, FCardColor, FCardHotColor, FCardSelectedColor, FSecondaryTextColor,
    FHeaderColor, FAlternateRowColor, FFooterColor, FGridColor,
    FCardTreeParentBackgroundColor, FCardTreeNavigationIconColor,
    FCardTreeBreadcrumbTextColor, FCardTreeBreadcrumbHotColor);
end;

procedure TUniListView.RestoreOwnTheme;
begin
  if Length(FOwnThemeColors) = 0 then Exit;
  FThemeVariant := FOwnThemeVariant;
  FBackgroundColor := FOwnThemeColors[0];
  FTextColor := FOwnThemeColors[1];
  FAccentColor := FOwnThemeColors[2];
  FCardColor := FOwnThemeColors[3];
  FCardHotColor := FOwnThemeColors[4];
  FCardSelectedColor := FOwnThemeColors[5];
  FSecondaryTextColor := FOwnThemeColors[6];
  FHeaderColor := FOwnThemeColors[7];
  FAlternateRowColor := FOwnThemeColors[8];
  FFooterColor := FOwnThemeColors[9];
  FGridColor := FOwnThemeColors[10];
  FCardTreeParentBackgroundColor := FOwnThemeColors[11];
  FCardTreeNavigationIconColor := FOwnThemeColors[12];
  FCardTreeBreadcrumbTextColor := FOwnThemeColors[13];
  FCardTreeBreadcrumbHotColor := FOwnThemeColors[14];
end;

procedure TUniListView.SetUseStyleBook(const Value: Boolean);
begin
  if FUseStyleBook = Value then Exit;
  ClearStyleCheckCache;
  FStyleIconColor := TAlphaColors.Null;
  FUseStyleBook := Value;
  if Value then
  begin
    SaveOwnTheme;
    RefreshStyleBook;
  end
  else
  begin
    RestoreOwnTheme;
    FOwnThemeColors := nil;
    Redraw;
  end;
end;

procedure TUniListView.SetNewScene(AScene: IScene);
begin
  inherited;
  RefreshStyleBook;
end;

procedure TUniListView.StyleChangedHandler(const Sender: TObject; const Msg: TMessage);
begin
  if (TStyleChangedMessage(Msg).Scene <> nil) and
    (TStyleChangedMessage(Msg).Scene <> Scene) then Exit;
  if (TStyleChangedMessage(Msg).Value <> nil) and (Scene <> nil) and
    (Scene.StyleBook <> TStyleChangedMessage(Msg).Value) then Exit;
  RefreshStyleBook;
end;

// Read shared resources without modifying or reparenting the form's style.
function UniStyleColor(const AObject: TFmxObject; out AColor: TAlphaColor): Boolean;
var
  Bitmap: TBitmap;
  Data: TBitmapData;
begin
  Result := False;
  if AObject is TBrushObject then
  begin
    if TBrushObject(AObject).Brush.Kind <> TBrushKind.Solid then Exit;
    AColor := TBrushObject(AObject).Brush.Color;
  end
  else if AObject is TColorObject then
    AColor := TColorObject(AObject).Color
  else if AObject is TText then
    AColor := TText(AObject).TextSettings.FontColor
  else if AObject is TShape then
  begin
    if TShape(AObject).Fill.Kind <> TBrushKind.Solid then Exit;
    AColor := TShape(AObject).Fill.Color;
  end
  else if AObject is TCustomStyleObject then
  begin
    Bitmap := TBitmap.Create(16, 16);
    try
      Bitmap.Clear(TAlphaColors.Null);
      if not Bitmap.Canvas.BeginScene then Exit;
      try
        TCustomStyleObject(AObject).DrawToCanvas(Bitmap.Canvas, RectF(0, 0, 16, 16));
      finally
        Bitmap.Canvas.EndScene;
      end;
      if not Bitmap.Map(TMapAccess.Read, Data) then Exit;
      try
        AColor := Data.GetPixel(8, 8);
      finally
        Bitmap.Unmap(Data);
      end;
    finally
      Bitmap.Free;
    end;
  end
  else Exit;
  Result := (AColor shr 24) <> 0;
end;

procedure TUniListView.RefreshStyleBook;
var
  Style: TFmxObject;
  Background, Foreground, Accent, Selection, UI, Color, IconColor: TAlphaColor;
  Variant: TUniThemeVariant;
  FoundColor: Boolean;
  procedure ReadColor(const AStyleName, AResourceName: string; var AValue: TAlphaColor);
  var
    Obj: TFmxObject;
  begin
    Obj := Style.FindStyleResource(AStyleName);
    if (Obj <> nil) and (AResourceName <> '') then
      Obj := Obj.FindStyleResource(AResourceName);
    if UniStyleColor(Obj, Color) then
    begin
      AValue := Color;
      FoundColor := True;
    end;
  end;
begin
  if not FUseStyleBook or FInitializing or
    (csLoading in ComponentState) or (csDestroying in ComponentState) then Exit;
  ClearStyleCheckCache;
  FStyleIconColor := TAlphaColors.Null;
  RestoreOwnTheme;
  if (Scene = nil) or (Scene.StyleBook = nil) then
  begin
    Redraw;
    Exit;
  end;
  Style := Scene.StyleBook.GetStyle(Self);
  if Style = nil then
  begin
    Redraw;
    Exit;
  end;
  FoundColor := False;
  Background := FBackgroundColor;
  Foreground := FTextColor;
  Selection := FCardSelectedColor;
  ReadColor('backgroundstyle', '', Background);
  ReadColor('listboxstyle', 'background', Background);
  ReadColor('text', '', Foreground);
  ReadColor('labelstyle', 'text', Foreground);
  ReadColor('listboxitemstyle', 'text', Foreground);
  ReadColor('listboxstyle', 'selection', Selection);
  Accent := Selection or $FF000000;
  UI := Foreground;
  // Optional semantic resources take precedence over standard FMX resources.
  ReadColor('unilistbackground', '', Background);
  ReadColor('unilistforeground', '', Foreground);
  ReadColor('unilistselection', '', Selection);
  ReadColor('unilistaccent', '', Accent);
  ReadColor('unilistui', '', UI);
  // A selection brush is a background, not a foreground for small glyphs.
  IconColor := Foreground;
  ReadColor('buttonstyle', 'text', IconColor);
  ReadColor('unilisticon', '', IconColor);
  if not FoundColor then
  begin
    Redraw;
    Exit;
  end;
  if (((Background shr 16) and $FF) * 299 +
      ((Background shr 8) and $FF) * 587 + (Background and $FF) * 114) < 128000 then
    Variant := utvDark
  else
    Variant := utvLight;
  FStyleIconColor := IconColor;
  ApplyPalette(Background, Foreground, Accent, Selection, UI, Variant);
end;

procedure TUniListView.SetThemeName(const Value: string);
var Theme: TUniThemeDefinition;
begin
  if SameText(FThemeName, Value) then
  begin
    if not (csLoading in ComponentState) then SetUseStyleBook(False);
    Exit;
  end;
  Theme := TUniThemeManager.Find(Value);
  if Theme = nil then
  begin
    FThemeName := Value;
    Exit;
  end;
  ApplyTheme(Theme);
end;

procedure TUniListView.LoadThemeFromFile(const AFileName: string);
var Theme: TUniThemeDefinition;
begin
  Theme := TUniThemeManager.LoadFromYAMLFile(AFileName);
  try
    ApplyTheme(Theme);
  finally
    Theme.Free;
  end;
end;

function TUniListView.AvailableThemeNames: TArray<string>;
begin
  Result := TUniThemeManager.ThemeNames;
end;

procedure TUniListView.ResetPerformanceCounters;
begin
  UniPerfReset;
end;

function TUniListView.GetPerformanceSnapshot: TUniPerformanceSnapshot;
begin
  Result := UniPerfSnapshot;
  Result.TotalItems := FItems.Count;
  Result.VisibleItems := Max(0, LastVisibleIndex - FirstVisibleIndex + 1);
end;

function TUniListView.PerformanceReport: string;
var
  ModeName: string;
begin
  if FTreeMode then
    ModeName := 'Tree'
  else if FViewMode = uvmList then
    ModeName := 'List'
  else
    ModeName := 'Cards';
  Result := UniPerfReport(GetPerformanceSnapshot, ModeName);
end;

procedure TUniListView.SetSelectedIndex(const Value: Integer);
begin
  if FSelectedIndex = Value then Exit;
  FSelectedIndex := EnsureRange(Value, -1, FItems.Count - 1);
  Redraw;
end;

procedure Register;
begin
  RegisterComponents('UniListView', [TUniListView]);
end;

end.



