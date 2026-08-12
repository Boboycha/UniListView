unit UniList.Lookup;

interface

uses
  System.Classes,
  System.Types,
  System.UITypes,
  FMX.Types,
  FMX.Controls,
  FMX.Graphics,
  FMX.Objects,
  FMX.Layouts,
  FMX.Edit,
  FMX.StdCtrls,
  UniList.Types,
  UniList.Items,
  UniList.Columns,
  UniList.Search,
  UniList.Control,
  UniList.DropDown,
  UniList.Popup;

type
  TUniLookup = class;

  TUniLookupSelectionChangingEvent = procedure(Sender: TObject;
    const AOldIndex, ANewIndex: Integer; var AAllow: Boolean) of object;
  TUniLookupSelectionChangedEvent = procedure(Sender: TObject;
    const AItemIndex: Integer) of object;
  TUniLookupItemSelectedEvent = procedure(Sender: TObject;
    const AItem: TUniListItem) of object;

  TUniLookupNavigation = (
    ulnPrevious,
    ulnNext,
    ulnPagePrevious,
    ulnPageNext,
    ulnFirst,
    ulnLast
  );

  TUniLookupListView = class(TUniListView)
  private
    FLookup: TUniLookup;
  protected
    procedure DoItemClick(const AItemIndex: Integer); override;
    procedure DoItemDoubleClick(const AItemIndex: Integer); override;
    procedure DoSearchChanged; override;
    procedure KeyDown(var Key: Word; var KeyChar: WideChar;
      Shift: TShiftState); override;
  public
    constructor Create(AOwner: TComponent;
      const ALookup: TUniLookup); reintroduce;
  end;

  TUniLookup = class(TUniDropDown)
  private
    FPopupRoot: TLayout;
    FSearchLayout: TRectangle;
    FSearchIcon: TPaintBox;
    FSearchEdit: TEdit;
    FClearSearchButton: TPaintBox;
    FNoMatchesLabel: TLabel;
    FSearchTimer: TTimer;
    FListView: TUniLookupListView;
    FItemIndex: Integer;
    FDisplayColumn: string;
    FCommitOnClick: Boolean;
    FAllowClear: Boolean;
    FShowSearchBox: Boolean;
    FSearchPrompt: string;
    FSearchDelay: Integer;
    FAutoFocusSearch: Boolean;
    FClearSearchOnClose: Boolean;
    FNoMatchesText: string;
    FUpdatingSearchText: Boolean;
    FClearButtonHovered: Boolean;
    FSearchAreaColor: TAlphaColor;
    FSearchBorderColor: TAlphaColor;
    FSearchIconColor: TAlphaColor;
    FSearchClearHoverColor: TAlphaColor;
    FOpenItemIndex: Integer;
    FOpenText: string;
    FTemporaryDisplayIndex: Integer;
    FCommitClosing: Boolean;
    FCancelClosing: Boolean;
    FDestroying: Boolean;
    FOnSelectionChanging: TUniLookupSelectionChangingEvent;
    FOnSelectionChanged: TUniLookupSelectionChangedEvent;
    FOnItemSelected: TUniLookupItemSelectedEvent;
    procedure SetItemIndex(const Value: Integer);
    procedure SetDisplayColumn(const Value: string);
    procedure SetShowSearchBox(const Value: Boolean);
    procedure SetSearchPrompt(const Value: string);
    function GetSearchText: string;
    procedure SetSearchText(const Value: string);
    procedure SetSearchDelay(const Value: Integer);
    procedure SetNoMatchesText(const Value: string);
    function GetSearchOptions: TUniSearchOptions;
    procedure SetSearchOptions(const Value: TUniSearchOptions);
    function GetSelectedItem: TUniListItem;
    function GetSelectedText: string;
    function GetItems: TUniListItems;
    function GetListView: TUniListView;
    function GetColumns: TUniListColumns;
    procedure SetColumns(const Value: TUniListColumns);
    function GetCardTemplate: TUniCardTemplate;
    procedure SetCardTemplate(const Value: TUniCardTemplate);
    function GetPopupViewMode: TUniViewMode;
    procedure SetPopupViewMode(const Value: TUniViewMode);
    function GetPopupCardLayout: TUniCardLayout;
    procedure SetPopupCardLayout(const Value: TUniCardLayout);
    function ResolveDisplayColumn: string;
    function DisplayTextForIndex(const AIndex: Integer): string;
    function ApplyCommittedSelection(const AIndex: Integer;
      const AGenerateEvents: Boolean): Boolean;
    procedure SetSelectionSilent(const AIndex: Integer;
      const AText: string);
    procedure RestoreOpeningSelection;
    procedure Navigate(const ADirection: TUniLookupNavigation);
    function HandlePopupKey(var Key: Word; var KeyChar: WideChar;
      const Shift: TShiftState): Boolean;
    procedure ListItemClick(const AItemIndex: Integer);
    procedure ListItemDoubleClick(const AItemIndex: Integer);
    procedure ListSearchChanged;
    procedure SearchEditChangeTracking(Sender: TObject);
    procedure SearchEditKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: WideChar; Shift: TShiftState);
    procedure SearchTimerTick(Sender: TObject);
    procedure SearchIconPaint(Sender: TObject; Canvas: TCanvas);
    procedure ClearSearchButtonPaint(Sender: TObject; Canvas: TCanvas);
    procedure ClearSearchButtonClick(Sender: TObject);
    procedure ClearSearchButtonMouseEnter(Sender: TObject);
    procedure ClearSearchButtonMouseLeave(Sender: TObject);
    procedure ApplyPendingSearch;
    procedure ClearSearchInternal;
    procedure UpdateSearchLayout;
    procedure UpdateSearchState;
    procedure ApplySearchTheme;
    procedure FocusSearchEdit(const ASelectAll: Boolean);
    function HandleListTextInput(var Key: Word;
      var KeyChar: WideChar; const Shift: TShiftState): Boolean;
  protected
    procedure SetPopupContent(const Value: TControl); override;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
    procedure DoDropDownOpening(var AAllow: Boolean); override;
    procedure DoDropDownOpened; override;
    procedure DoDropDownClosed(
      const AReason: TUniPopupCloseReason); override;
    procedure DoThemeChanged; override;
    procedure KeyDown(var Key: Word; var KeyChar: WideChar;
      Shift: TShiftState); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SelectItem(const AIndex: Integer);
    procedure ClearSelection;
    procedure CommitSelection;
    procedure CancelSelection;
    property ListView: TUniListView read GetListView;
    property Items: TUniListItems read GetItems;
    property SelectedItem: TUniListItem read GetSelectedItem;
    property SelectedText: string read GetSelectedText;
  published
    property ItemIndex: Integer read FItemIndex write SetItemIndex default -1;
    property DisplayColumn: string read FDisplayColumn write SetDisplayColumn;
    property CommitOnClick: Boolean read FCommitOnClick
      write FCommitOnClick default True;
    property AllowClear: Boolean read FAllowClear write FAllowClear
      default True;
    property ShowSearchBox: Boolean read FShowSearchBox
      write SetShowSearchBox default True;
    property SearchPrompt: string read FSearchPrompt write SetSearchPrompt;
    property SearchText: string read GetSearchText write SetSearchText;
    property SearchDelay: Integer read FSearchDelay
      write SetSearchDelay default 250;
    property AutoFocusSearch: Boolean read FAutoFocusSearch
      write FAutoFocusSearch default True;
    property ClearSearchOnClose: Boolean read FClearSearchOnClose
      write FClearSearchOnClose default True;
    property NoMatchesText: string read FNoMatchesText
      write SetNoMatchesText;
    property SearchOptions: TUniSearchOptions read GetSearchOptions
      write SetSearchOptions;
    property Columns: TUniListColumns read GetColumns write SetColumns;
    property CardTemplate: TUniCardTemplate read GetCardTemplate
      write SetCardTemplate;
    property PopupViewMode: TUniViewMode read GetPopupViewMode
      write SetPopupViewMode default uvmList;
    property PopupCardLayout: TUniCardLayout read GetPopupCardLayout
      write SetPopupCardLayout default uclGrid;
    property OnSelectionChanging: TUniLookupSelectionChangingEvent
      read FOnSelectionChanging write FOnSelectionChanging;
    property OnSelectionChanged: TUniLookupSelectionChangedEvent
      read FOnSelectionChanged write FOnSelectionChanged;
    property OnItemSelected: TUniLookupItemSelectedEvent
      read FOnItemSelected write FOnItemSelected;
  end;

procedure Register;

implementation

uses
  System.Math,
  System.SysUtils,
  UniList.Theme;

const
  CLookupPopupWidth = 360.0;
  CLookupPopupHeight = 280.0;
  CLookupSearchHeight = 42.0;
  CLookupSearchHorizontalPadding = 8.0;
  CLookupSearchIconSize = 16.0;
  CLookupSearchButtonSize = 28.0;
  CLookupSearchGap = 6.0;
  CLookupSearchVerticalPadding = 5.0;
  CLookupSearchStrokeThickness = 1.5;
  CLookupSearchIconLineInset = 3.0;
  CLookupSearchIconHandleLength = 5.0;
  CLookupClearIconInset = 8.0;
  CLookupMinimumListHeight = 64.0;
  CLookupDefaultSearchDelay = 250;
  CLookupSearchAreaBlend = 0.08;
  CLookupSearchBorderBlend = 0.22;
  CLookupDefaultColumnWidth = 240.0;
  CLookupDefaultColumnMinWidth = 100.0;
  CLookupDefaultFieldName = 'title';
  CLookupDefaultCaption = 'Value';
  CLookupDefaultSearchPrompt = 'Search...';
  CLookupDefaultNoMatchesText = 'No matches';

constructor TUniLookupListView.Create(AOwner: TComponent;
  const ALookup: TUniLookup);
begin
  inherited Create(AOwner);
  FLookup := ALookup;
end;

procedure TUniLookupListView.DoItemClick(const AItemIndex: Integer);
begin
  if FLookup <> nil then
    FLookup.ListItemClick(AItemIndex);
  inherited;
end;

procedure TUniLookupListView.DoItemDoubleClick(
  const AItemIndex: Integer);
begin
  if FLookup <> nil then
    FLookup.ListItemDoubleClick(AItemIndex);
  inherited;
end;

procedure TUniLookupListView.DoSearchChanged;
begin
  inherited;
  if FLookup <> nil then
    FLookup.ListSearchChanged;
end;

procedure TUniLookupListView.KeyDown(var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  if (FLookup <> nil) and
     FLookup.HandlePopupKey(Key, KeyChar, Shift) then
    Exit;
  if (FLookup <> nil) and
     FLookup.HandleListTextInput(Key, KeyChar, Shift) then
    Exit;
  inherited;
end;

constructor TUniLookup.Create(AOwner: TComponent);
var
  Column: TUniListColumn;
begin
  inherited;
  FItemIndex := -1;
  FOpenItemIndex := -1;
  FTemporaryDisplayIndex := -1;
  FCommitOnClick := True;
  FAllowClear := True;
  FShowSearchBox := True;
  FSearchPrompt := CLookupDefaultSearchPrompt;
  FSearchDelay := CLookupDefaultSearchDelay;
  FAutoFocusSearch := True;
  FClearSearchOnClose := True;
  FNoMatchesText := CLookupDefaultNoMatchesText;
  FCommitClosing := False;
  FCancelClosing := False;
  FDestroying := False;

  FPopupRoot := TLayout.Create(Self);
  FPopupRoot.SetBounds(0, 0, CLookupPopupWidth,
    CLookupPopupHeight + CLookupSearchHeight);

  FSearchLayout := TRectangle.Create(Self);
  FSearchLayout.Parent := FPopupRoot;
  FSearchLayout.Align := TAlignLayout.Top;
  FSearchLayout.Height := CLookupSearchHeight;
  FSearchLayout.HitTest := True;
  FSearchLayout.Fill.Kind := TBrushKind.Solid;
  FSearchLayout.Stroke.Kind := TBrushKind.Solid;
  FSearchLayout.Stroke.Thickness := CLookupSearchStrokeThickness;

  FSearchIcon := TPaintBox.Create(Self);
  FSearchIcon.Parent := FSearchLayout;
  FSearchIcon.Align := TAlignLayout.Left;
  FSearchIcon.Width := CLookupSearchHorizontalPadding +
    CLookupSearchIconSize + CLookupSearchGap;
  FSearchIcon.HitTest := False;
  FSearchIcon.OnPaint := SearchIconPaint;

  FClearSearchButton := TPaintBox.Create(Self);
  FClearSearchButton.Parent := FSearchLayout;
  FClearSearchButton.Align := TAlignLayout.Right;
  FClearSearchButton.Margins.Right := CLookupSearchHorizontalPadding;
  FClearSearchButton.Width := CLookupSearchButtonSize;
  FClearSearchButton.HitTest := True;
  FClearSearchButton.Cursor := crHandPoint;
  FClearSearchButton.OnPaint := ClearSearchButtonPaint;
  FClearSearchButton.OnClick := ClearSearchButtonClick;
  FClearSearchButton.OnMouseEnter := ClearSearchButtonMouseEnter;
  FClearSearchButton.OnMouseLeave := ClearSearchButtonMouseLeave;

  FSearchEdit := TEdit.Create(Self);
  FSearchEdit.Parent := FSearchLayout;
  FSearchEdit.Align := TAlignLayout.Client;
  FSearchEdit.StyleLookup := 'transparentedit';
  FSearchEdit.Margins.Top := CLookupSearchVerticalPadding;
  FSearchEdit.Margins.Right := CLookupSearchGap;
  FSearchEdit.Margins.Bottom := CLookupSearchVerticalPadding;
  FSearchEdit.TabStop := True;
  FSearchEdit.TextPrompt := FSearchPrompt;
  FSearchEdit.OnChangeTracking := SearchEditChangeTracking;
  FSearchEdit.OnKeyDown := SearchEditKeyDown;

  FSearchTimer := TTimer.Create(Self);
  FSearchTimer.Enabled := False;
  FSearchTimer.Interval := FSearchDelay;
  FSearchTimer.OnTimer := SearchTimerTick;

  FListView := TUniLookupListView.Create(Self, Self);
  FListView.Parent := FPopupRoot;
  FListView.Align := TAlignLayout.Client;
  FListView.ViewMode := uvmList;
  FListView.CardLayout := uclGrid;
  FListView.ScrollMode := usmVertical;
  FListView.ThemeName := ThemeName;
  FListView.Actions.Clear;
  FListView.Columns.Clear;
  Column := FListView.Columns.Add;
  Column.FieldName := CLookupDefaultFieldName;
  Column.Caption := CLookupDefaultCaption;
  Column.Width := CLookupDefaultColumnWidth;
  Column.MinWidth := CLookupDefaultColumnMinWidth;
  Column.WidthMode := ucwmFill;
  Column.CardRole := ucrTitle;
  FListView.CardTemplate.ShowIcon := False;
  FListView.CardTemplate.ShowActions := False;
  FListView.CardTemplate.TitleField := CLookupDefaultFieldName;
  FListView.CardTemplate.SelectableText := False;

  FNoMatchesLabel := TLabel.Create(Self);
  FNoMatchesLabel.Parent := FPopupRoot;
  FNoMatchesLabel.Align := TAlignLayout.Client;
  FNoMatchesLabel.HitTest := False;
  FNoMatchesLabel.Text := FNoMatchesText;
  FNoMatchesLabel.TextSettings.HorzAlign := TTextAlign.Center;
  FNoMatchesLabel.TextSettings.VertAlign := TTextAlign.Center;
  FNoMatchesLabel.Visible := False;
  FNoMatchesLabel.BringToFront;

  PopupContent := FPopupRoot;
  DropDownWidthMode := upwAnchor;
  MinPopupHeight := CLookupSearchHeight + CLookupMinimumListHeight;
  UpdateSearchLayout;
  ApplySearchTheme;
end;

destructor TUniLookup.Destroy;
begin
  FDestroying := True;
  if FSearchTimer <> nil then
  begin
    FSearchTimer.Enabled := False;
    FSearchTimer.OnTimer := nil;
  end;
  if FSearchEdit <> nil then
  begin
    FSearchEdit.OnChangeTracking := nil;
    FSearchEdit.OnKeyDown := nil;
  end;
  if FClearSearchButton <> nil then
  begin
    FClearSearchButton.OnClick := nil;
    FClearSearchButton.OnMouseEnter := nil;
    FClearSearchButton.OnMouseLeave := nil;
  end;
  if FListView <> nil then
    FListView.FLookup := nil;
  inherited;
end;

procedure TUniLookup.SetPopupContent(const Value: TControl);
begin
  if (Value <> nil) and (Value <> FPopupRoot) then
    raise EArgumentException.Create(
      'TUniLookup PopupContent is managed internally');
  inherited;
end;

procedure TUniLookup.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if Operation <> opRemove then
    Exit;
  if AComponent = FListView then
    FListView := nil;
  if AComponent = FSearchEdit then
    FSearchEdit := nil;
  if AComponent = FSearchTimer then
    FSearchTimer := nil;
  if AComponent = FPopupRoot then
  begin
    FPopupRoot := nil;
    FSearchLayout := nil;
    FSearchIcon := nil;
    FClearSearchButton := nil;
    FNoMatchesLabel := nil;
  end;
end;

procedure TUniLookup.SetShowSearchBox(const Value: Boolean);
begin
  if FShowSearchBox = Value then
    Exit;
  FShowSearchBox := Value;
  UpdateSearchLayout;
end;

procedure TUniLookup.SetSearchPrompt(const Value: string);
begin
  if FSearchPrompt = Value then
    Exit;
  FSearchPrompt := Value;
  if FSearchEdit <> nil then
    FSearchEdit.TextPrompt := FSearchPrompt;
end;

function TUniLookup.GetSearchText: string;
begin
  if FSearchEdit = nil then
    Exit('');
  Result := FSearchEdit.Text;
end;

procedure TUniLookup.SetSearchText(const Value: string);
begin
  if FSearchEdit = nil then
    Exit;
  if FSearchEdit.Text <> Value then
  begin
    FUpdatingSearchText := True;
    try
      FSearchEdit.Text := Value;
      FSearchEdit.SelStart := Length(Value);
    finally
      FUpdatingSearchText := False;
    end;
  end;
  if csDesigning in ComponentState then
  begin
    UpdateSearchState;
    Exit;
  end;
  FSearchTimer.Enabled := False;
  if FSearchDelay = 0 then
    ApplyPendingSearch
  else
  begin
    FSearchTimer.Interval := FSearchDelay;
    FSearchTimer.Enabled := True;
  end;
  UpdateSearchState;
end;

procedure TUniLookup.SetSearchDelay(const Value: Integer);
begin
  FSearchDelay := Max(0, Value);
  if FSearchTimer = nil then
    Exit;
  FSearchTimer.Interval := Max(1, FSearchDelay);
  if FSearchTimer.Enabled and (FSearchDelay = 0) then
    ApplyPendingSearch;
end;

procedure TUniLookup.SetNoMatchesText(const Value: string);
begin
  if FNoMatchesText = Value then
    Exit;
  FNoMatchesText := Value;
  if FNoMatchesLabel <> nil then
    FNoMatchesLabel.Text := FNoMatchesText;
end;

function TUniLookup.GetSearchOptions: TUniSearchOptions;
begin
  Result := FListView.SearchOptions;
end;

procedure TUniLookup.SetSearchOptions(const Value: TUniSearchOptions);
begin
  FListView.SearchOptions := Value;
end;

procedure TUniLookup.SearchEditChangeTracking(Sender: TObject);
begin
  if FUpdatingSearchText or FDestroying then
    Exit;
  SetSearchText(FSearchEdit.Text);
end;

procedure TUniLookup.SearchTimerTick(Sender: TObject);
begin
  FSearchTimer.Enabled := False;
  if FDestroying then
    Exit;
  ApplyPendingSearch;
end;

procedure TUniLookup.ApplyPendingSearch;
begin
  if FSearchTimer <> nil then
    FSearchTimer.Enabled := False;
  if (FListView = nil) or (FSearchEdit = nil) or FDestroying then
    Exit;
  FListView.SearchText := FSearchEdit.Text;
  UpdateSearchState;
end;

procedure TUniLookup.ClearSearchInternal;
begin
  if FSearchTimer <> nil then
    FSearchTimer.Enabled := False;
  if FSearchEdit <> nil then
  begin
    FUpdatingSearchText := True;
    try
      FSearchEdit.Text := '';
      FSearchEdit.SelStart := 0;
    finally
      FUpdatingSearchText := False;
    end;
  end;
  if FListView <> nil then
    FListView.SearchText := '';
  UpdateSearchState;
end;

procedure TUniLookup.UpdateSearchLayout;
begin
  if FSearchLayout <> nil then
    FSearchLayout.Visible := FShowSearchBox;
  if FPopupRoot <> nil then
  begin
    if FShowSearchBox then
      FPopupRoot.Height := CLookupPopupHeight + CLookupSearchHeight
    else
      FPopupRoot.Height := CLookupPopupHeight;
  end;
  UpdateSearchState;
end;

procedure TUniLookup.UpdateSearchState;
begin
  if FClearSearchButton <> nil then
  begin
    FClearSearchButton.Visible :=
      FShowSearchBox and (GetSearchText <> '');
    FClearSearchButton.HitTest := FClearSearchButton.Visible;
    if FClearSearchButton.Visible then
          FClearSearchButton.Repaint;
  end;
  if FNoMatchesLabel <> nil then
  begin
    FNoMatchesLabel.Visible := FShowSearchBox and
      (GetSearchText <> '') and (FListView <> nil) and
      (FListView.SearchText = GetSearchText) and
      not FListView.SearchRunning and
      (FListView.SearchMatchCount = 0);
    if FNoMatchesLabel.Visible then
      FNoMatchesLabel.BringToFront;
  end;
end;

procedure TUniLookup.ListSearchChanged;
var
  SearchPending: Boolean;
begin
  if FListView = nil then
    Exit;
  SearchPending := (FSearchTimer <> nil) and FSearchTimer.Enabled;
  if (FSearchEdit <> nil) and not SearchPending and
     (FSearchEdit.Text <> FListView.SearchText) then
  begin
    FUpdatingSearchText := True;
    try
      FSearchEdit.Text := FListView.SearchText;
      FSearchEdit.SelStart := Length(FSearchEdit.Text);
    finally
      FUpdatingSearchText := False;
    end;
  end;
  FTemporaryDisplayIndex :=
    FListView.NavigationIndexOfItem(FListView.SelectedIndex);
  UpdateSearchState;
end;

procedure TUniLookup.FocusSearchEdit(const ASelectAll: Boolean);
begin
  if not FShowSearchBox or (FSearchEdit = nil) then
    Exit;
  if FSearchEdit.CanFocus then
    FSearchEdit.SetFocus;
  if ASelectAll and (FSearchEdit.Text <> '') then
    FSearchEdit.SelectAll;
end;

procedure TUniLookup.SearchEditKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
var
  CurrentVisible: Boolean;
begin
  if not IsDropDownOpen then
    Exit;
  if Key = vkDown then
  begin
    if FSearchTimer.Enabled then
      ApplyPendingSearch;
    CurrentVisible := FListView.NavigationIndexOfItem(
      FListView.SelectedIndex) >= 0;
    if FListView.CanFocus then
      FListView.SetFocus;
    if not CurrentVisible then
      Navigate(ulnFirst);
  end
  else if Key = vkUp then
  begin
    if FSearchTimer.Enabled then
      ApplyPendingSearch;
    CurrentVisible := FListView.NavigationIndexOfItem(
      FListView.SelectedIndex) >= 0;
    if FListView.CanFocus then
      FListView.SetFocus;
    if not CurrentVisible then
      Navigate(ulnLast);
  end
  else if Key = vkReturn then
  begin
    if FSearchTimer.Enabled then
      ApplyPendingSearch;
    CurrentVisible := FListView.NavigationIndexOfItem(
      FListView.SelectedIndex) >= 0;
    if CurrentVisible then
      CommitSelection
    else
      Exit;
  end
  else if Key = vkEscape then
  begin
    if GetSearchText <> '' then
    begin
      ClearSearchInternal;
      FocusSearchEdit(False);
    end
    else
      CancelSelection;
  end
  else if Key = vkF4 then
    CancelSelection
  else
    Exit;
  Key := 0;
  KeyChar := #0;
end;

function TUniLookup.HandleListTextInput(var Key: Word;
  var KeyChar: WideChar; const Shift: TShiftState): Boolean;
var
  InsertPosition: Integer;
  NewText: string;
begin
  Result := False;
  if not FShowSearchBox or (FSearchEdit = nil) then
    Exit;
  if (KeyChar < #32) or (ssCtrl in Shift) or (ssAlt in Shift) then
    Exit;
  NewText := FSearchEdit.Text;
  InsertPosition := EnsureRange(FSearchEdit.SelStart, 0, Length(NewText));
  if FSearchEdit.SelLength > 0 then
    Delete(NewText, InsertPosition + 1, FSearchEdit.SelLength);
  Insert(KeyChar, NewText, InsertPosition + 1);
  SetSearchText(NewText);
  FocusSearchEdit(False);
  FSearchEdit.SelStart := InsertPosition + 1;
  Key := 0;
  KeyChar := #0;
  Result := True;
end;

procedure TUniLookup.SearchIconPaint(Sender: TObject; Canvas: TCanvas);
var
  IconBounds: TRectF;
  IconCenter: TPointF;
begin
  IconCenter := PointF(CLookupSearchHorizontalPadding +
    CLookupSearchIconSize * 0.5, CLookupSearchHeight * 0.5);
  IconBounds := RectF(
    IconCenter.X - CLookupSearchIconSize * 0.5 +
      CLookupSearchIconLineInset,
    IconCenter.Y - CLookupSearchIconSize * 0.5 +
      CLookupSearchIconLineInset,
    IconCenter.X + CLookupSearchIconSize * 0.5 -
      CLookupSearchIconLineInset,
    IconCenter.Y + CLookupSearchIconSize * 0.5 -
      CLookupSearchIconLineInset);
  Canvas.Stroke.Kind := TBrushKind.Solid;
  Canvas.Stroke.Color := FSearchIconColor;
  Canvas.Stroke.Thickness := CLookupSearchStrokeThickness;
  Canvas.DrawEllipse(IconBounds, 1);
  Canvas.DrawLine(
    PointF(IconBounds.Right, IconBounds.Bottom),
    PointF(IconBounds.Right + CLookupSearchIconHandleLength,
      IconBounds.Bottom + CLookupSearchIconHandleLength), 1);
end;

procedure TUniLookup.ClearSearchButtonPaint(Sender: TObject;
  Canvas: TCanvas);
var
  IconHalfSize: Single;
  IconRect: TRectF;
begin
  IconHalfSize := (CLookupSearchButtonSize -
    CLookupClearIconInset * 2) * 0.5;
  IconRect := RectF(
    FClearSearchButton.Width * 0.5 - IconHalfSize,
    FClearSearchButton.Height * 0.5 - IconHalfSize,
    FClearSearchButton.Width * 0.5 + IconHalfSize,
    FClearSearchButton.Height * 0.5 + IconHalfSize);
  Canvas.Stroke.Kind := TBrushKind.Solid;
  if FClearButtonHovered then
    Canvas.Stroke.Color := FSearchClearHoverColor
  else
    Canvas.Stroke.Color := FSearchIconColor;
  Canvas.Stroke.Thickness := CLookupSearchStrokeThickness;
  Canvas.DrawLine(IconRect.TopLeft, IconRect.BottomRight, 1);
  Canvas.DrawLine(PointF(IconRect.Right, IconRect.Top),
    PointF(IconRect.Left, IconRect.Bottom), 1);
end;

procedure TUniLookup.ClearSearchButtonClick(Sender: TObject);
begin
  ClearSearchInternal;
  FocusSearchEdit(False);
end;

procedure TUniLookup.ClearSearchButtonMouseEnter(Sender: TObject);
begin
  FClearButtonHovered := True;
  FClearSearchButton.Repaint;
end;

procedure TUniLookup.ClearSearchButtonMouseLeave(Sender: TObject);
begin
  FClearButtonHovered := False;
  FClearSearchButton.Repaint;
end;

procedure TUniLookup.ApplySearchTheme;
var
  Theme: TUniThemeDefinition;
begin
  Theme := TUniThemeManager.Find(ThemeName);
  if Theme = nil then
  begin
    FSearchAreaColor := PopupHost.SurfaceColor;
    FSearchBorderColor := PopupHost.BorderColor;
    FSearchIconColor := PopupHost.TextContrastColor;
    FSearchClearHoverColor := PopupHost.TextContrastColor;
  end
  else
  begin
    FSearchAreaColor := UniBlendColor(Theme.Background,
      Theme.Foreground, CLookupSearchAreaBlend);
    FSearchBorderColor := UniBlendColor(Theme.Background,
      Theme.Foreground, CLookupSearchBorderBlend);
    FSearchIconColor := Theme.Foreground;
    FSearchClearHoverColor := Theme.Cursor;
  end;
  if FSearchLayout <> nil then
  begin
    FSearchLayout.Fill.Color := FSearchAreaColor;
    FSearchLayout.Stroke.Color := FSearchBorderColor;
  end;
  if FSearchEdit <> nil then
  begin
    FSearchEdit.StyledSettings := FSearchEdit.StyledSettings -
      [TStyledSetting.FontColor];
    FSearchEdit.TextSettings.FontColor := FSearchIconColor;
  end;
  if FNoMatchesLabel <> nil then
  begin
    FNoMatchesLabel.StyledSettings := FNoMatchesLabel.StyledSettings -
      [TStyledSetting.FontColor];
    FNoMatchesLabel.TextSettings.FontColor := FSearchIconColor;
  end;
  if FSearchIcon <> nil then
      FSearchIcon.Repaint;
  if FClearSearchButton <> nil then
      FClearSearchButton.Repaint;
end;

function TUniLookup.GetItems: TUniListItems;
begin
  Result := FListView.Items;
end;

function TUniLookup.GetListView: TUniListView;
begin
  Result := FListView;
end;

function TUniLookup.GetColumns: TUniListColumns;
begin
  Result := FListView.Columns;
end;

procedure TUniLookup.SetColumns(const Value: TUniListColumns);
begin
  if Value = nil then
    Exit;
  FListView.Columns.Assign(Value);
  SetDisplayColumn(FDisplayColumn);
end;

function TUniLookup.GetCardTemplate: TUniCardTemplate;
begin
  Result := FListView.CardTemplate;
end;

procedure TUniLookup.SetCardTemplate(const Value: TUniCardTemplate);
begin
  if Value = nil then
    Exit;
  FListView.CardTemplate.Assign(Value);
end;

function TUniLookup.GetPopupViewMode: TUniViewMode;
begin
  Result := FListView.ViewMode;
end;

procedure TUniLookup.SetPopupViewMode(const Value: TUniViewMode);
begin
  FListView.ViewMode := Value;
end;

function TUniLookup.GetPopupCardLayout: TUniCardLayout;
begin
  Result := FListView.CardLayout;
end;

procedure TUniLookup.SetPopupCardLayout(const Value: TUniCardLayout);
begin
  FListView.CardLayout := Value;
end;

function TUniLookup.ResolveDisplayColumn: string;
var
  ColumnIndex: Integer;
  Column: TUniListColumn;
begin
  Result := '';
  if Trim(FDisplayColumn) <> '' then
    for ColumnIndex := 0 to FListView.Columns.Count - 1 do
    begin
      Column := FListView.Columns[ColumnIndex];
      if SameText(Column.FieldName, FDisplayColumn) then
        Exit(Column.FieldName);
    end;

  for ColumnIndex := 0 to FListView.Columns.Count - 1 do
  begin
    Column := FListView.Columns[ColumnIndex];
    if Column.CardRole = ucrTitle then
      Exit(Column.FieldName);
  end;

  for ColumnIndex := 0 to FListView.Columns.Count - 1 do
  begin
    Column := FListView.Columns[ColumnIndex];
    if Column.Visible then
      Exit(Column.FieldName);
  end;
end;

function TUniLookup.DisplayTextForIndex(const AIndex: Integer): string;
var
  ColumnName: string;
begin
  Result := '';
  if (AIndex < 0) or (AIndex >= FListView.Items.Count) then
    Exit;
  ColumnName := ResolveDisplayColumn;
  if ColumnName = '' then
    Exit;
  Result := FListView.ItemColumnDisplayText(AIndex, ColumnName);
end;

function TUniLookup.GetSelectedItem: TUniListItem;
begin
  Result := nil;
  if (FItemIndex < 0) or (FItemIndex >= FListView.Items.Count) then
    Exit;
  Result := FListView.Items[FItemIndex];
end;

function TUniLookup.GetSelectedText: string;
begin
  Result := DisplayTextForIndex(FItemIndex);
end;

procedure TUniLookup.SetSelectionSilent(const AIndex: Integer;
  const AText: string);
begin
  FItemIndex := AIndex;
  Text := AText;
  if FListView = nil then
  begin
    FTemporaryDisplayIndex := -1;
    Exit;
  end;
  FListView.SelectedIndex := AIndex;
  FTemporaryDisplayIndex :=
    FListView.NavigationIndexOfItem(AIndex);
end;

function TUniLookup.ApplyCommittedSelection(const AIndex: Integer;
  const AGenerateEvents: Boolean): Boolean;
var
  AllowChange: Boolean;
  OldIndex: Integer;
begin
  Result := False;
  if FDestroying or (FListView = nil) or
     (csDestroying in FListView.ComponentState) or
     (FListView.Items = nil) then
    Exit;
  if (AIndex < -1) or (AIndex >= FListView.Items.Count) then
    Exit;
  OldIndex := FItemIndex;
  if OldIndex = AIndex then
  begin
    SetSelectionSilent(AIndex, DisplayTextForIndex(AIndex));
    Exit(True);
  end;

  AllowChange := True;
  if AGenerateEvents and Assigned(FOnSelectionChanging) then
    FOnSelectionChanging(Self, OldIndex, AIndex, AllowChange);
  if not AllowChange or FDestroying then
    Exit;
  if (AIndex >= FListView.Items.Count) or (AIndex < -1) then
    Exit;

  SetSelectionSilent(AIndex, DisplayTextForIndex(AIndex));
  if IsDropDownOpen then
  begin
    FOpenItemIndex := FItemIndex;
    FOpenText := Text;
  end;
  if AGenerateEvents and Assigned(FOnSelectionChanged) then
    FOnSelectionChanged(Self, FItemIndex);
  if AGenerateEvents and Assigned(FOnItemSelected) then
    FOnItemSelected(Self, GetSelectedItem);
  Result := True;
end;

procedure TUniLookup.SetItemIndex(const Value: Integer);
begin
  ApplyCommittedSelection(Value, True);
end;

procedure TUniLookup.SetDisplayColumn(const Value: string);
begin
  if SameText(FDisplayColumn, Trim(Value)) then
    Exit;
  FDisplayColumn := Trim(Value);
  SetSelectionSilent(FItemIndex, DisplayTextForIndex(FItemIndex));
  if IsDropDownOpen then
    FOpenText := Text;
end;

procedure TUniLookup.SelectItem(const AIndex: Integer);
begin
  ApplyCommittedSelection(AIndex, True);
end;

procedure TUniLookup.ClearSelection;
begin
  ApplyCommittedSelection(-1, True);
end;

procedure TUniLookup.CommitSelection;
var
  CandidateIndex: Integer;
begin
  if not IsDropDownOpen then
    Exit;
  CandidateIndex := FListView.SelectedIndex;
  if (CandidateIndex < 0) or
     (CandidateIndex >= FListView.Items.Count) then
    Exit;
  if FListView.NavigationIndexOfItem(CandidateIndex) < 0 then
    Exit;
  if not ApplyCommittedSelection(CandidateIndex, True) then
    Exit;

  FCommitClosing := True;
  try
    CloseDropDown;
  finally
    FCommitClosing := False;
  end;
end;

procedure TUniLookup.RestoreOpeningSelection;
begin
  SetSelectionSilent(FOpenItemIndex, FOpenText);
end;

procedure TUniLookup.CancelSelection;
begin
  if not IsDropDownOpen then
    Exit;
  RestoreOpeningSelection;
  FCancelClosing := True;
  try
    CloseDropDown;
  finally
    FCancelClosing := False;
  end;
end;

procedure TUniLookup.Navigate(const ADirection: TUniLookupNavigation);
var
  DisplayIndex, ItemCount, PageSize: Integer;
begin
  ItemCount := FListView.NavigationItemCount;
  if ItemCount <= 0 then
    Exit;

  DisplayIndex := FTemporaryDisplayIndex;
  if (DisplayIndex < 0) or (DisplayIndex >= ItemCount) then
    DisplayIndex := FListView.NavigationIndexOfItem(
      FListView.SelectedIndex);
  PageSize := FListView.NavigationPageSize;
  case ADirection of
    ulnPrevious:
      if DisplayIndex < 0 then
        DisplayIndex := ItemCount - 1
      else
        Dec(DisplayIndex);
    ulnNext:
      if DisplayIndex < 0 then
        DisplayIndex := 0
      else
        Inc(DisplayIndex);
    ulnPagePrevious:
      if DisplayIndex < 0 then
        DisplayIndex := ItemCount - 1
      else
        Dec(DisplayIndex, PageSize);
    ulnPageNext:
      if DisplayIndex < 0 then
        DisplayIndex := 0
      else
        Inc(DisplayIndex, PageSize);
    ulnFirst:
      DisplayIndex := 0;
    ulnLast:
      DisplayIndex := ItemCount - 1;
  end;
  DisplayIndex := EnsureRange(DisplayIndex, 0, ItemCount - 1);
  FTemporaryDisplayIndex := DisplayIndex;
  FListView.SelectedIndex :=
    FListView.NavigationItemIndex(DisplayIndex);
  FListView.ScrollToItem(FListView.SelectedIndex);
end;

function TUniLookup.HandlePopupKey(var Key: Word;
  var KeyChar: WideChar; const Shift: TShiftState): Boolean;
begin
  Result := True;
  if Key = vkUp then
  begin
    if ssAlt in Shift then
      CancelSelection
    else
      Navigate(ulnPrevious);
  end
  else if Key = vkDown then
    Navigate(ulnNext)
  else if Key = vkPrior then
    Navigate(ulnPagePrevious)
  else if Key = vkNext then
    Navigate(ulnPageNext)
  else if Key = vkHome then
    Navigate(ulnFirst)
  else if Key = vkEnd then
    Navigate(ulnLast)
  else if Key = vkReturn then
    CommitSelection
  else if Key = vkEscape then
  begin
    if GetSearchText <> '' then
    begin
      ClearSearchInternal;
      FocusSearchEdit(False);
    end
    else
      CancelSelection;
  end
  else if Key = vkF4 then
    CancelSelection
  else
    Result := False;

  if Result then
  begin
    Key := 0;
    KeyChar := #0;
  end;
end;

procedure TUniLookup.ListItemClick(const AItemIndex: Integer);
begin
  FTemporaryDisplayIndex :=
    FListView.NavigationIndexOfItem(AItemIndex);
  if FCommitOnClick then
    CommitSelection;
end;

procedure TUniLookup.ListItemDoubleClick(const AItemIndex: Integer);
begin
  if not IsDropDownOpen then
    Exit;
  FListView.SelectedIndex := AItemIndex;
  FTemporaryDisplayIndex :=
    FListView.NavigationIndexOfItem(AItemIndex);
  CommitSelection;
end;

procedure TUniLookup.DoDropDownOpening(var AAllow: Boolean);
begin
  inherited;
  if not AAllow then
    Exit;
  if FItemIndex >= FListView.Items.Count then
    SetSelectionSilent(-1, '');
  FOpenItemIndex := FItemIndex;
  FOpenText := Text;
  if FSearchTimer.Enabled or
     (FListView.SearchText <> GetSearchText) then
    ApplyPendingSearch;
  FListView.SelectedIndex := FItemIndex;
  FTemporaryDisplayIndex :=
    FListView.NavigationIndexOfItem(FItemIndex);
  if (GetSearchText <> '') and (FTemporaryDisplayIndex < 0) and
     (FListView.NavigationItemCount > 0) then
    Navigate(ulnFirst);
  if FItemIndex >= 0 then
    if FListView.NavigationIndexOfItem(FItemIndex) >= 0 then
      FListView.ScrollToItem(FItemIndex);
end;

procedure TUniLookup.DoDropDownOpened;
begin
  inherited;
  if (FItemIndex >= 0) and
     (FListView.NavigationIndexOfItem(FItemIndex) >= 0) then
    FListView.ScrollToItem(FItemIndex);
  if FShowSearchBox and FAutoFocusSearch then
    FocusSearchEdit(True)
  else if FListView.CanFocus then
    FListView.SetFocus;
end;

procedure TUniLookup.DoDropDownClosed(
  const AReason: TUniPopupCloseReason);
begin
  inherited;
  if not FCommitClosing and not FCancelClosing then
    RestoreOpeningSelection;
  FTemporaryDisplayIndex := -1;
  if FSearchTimer <> nil then
    FSearchTimer.Enabled := False;
  if FClearSearchOnClose then
    ClearSearchInternal;
  UpdateSearchLayout;
end;

procedure TUniLookup.DoThemeChanged;
begin
  inherited;
  if FListView <> nil then
    FListView.ThemeName := ThemeName;
  ApplySearchTheme;
end;

procedure TUniLookup.KeyDown(var Key: Word; var KeyChar: WideChar;
  Shift: TShiftState);
var
  TargetIndex: Integer;
begin
  if not IsDropDownOpen and AbsoluteEnabled then
  begin
    if (Key = vkDown) and not (ssAlt in Shift) then
    begin
      OpenDropDown;
      if IsDropDownOpen and (FListView.SelectedIndex < 0) then
        Navigate(ulnFirst);
      Key := 0;
      KeyChar := #0;
      Exit;
    end;
    if (Key = vkHome) or (Key = vkEnd) then
    begin
      if FListView.NavigationItemCount > 0 then
      begin
        if Key = vkHome then
          TargetIndex := FListView.NavigationItemIndex(0)
        else
          TargetIndex := FListView.NavigationItemIndex(
            FListView.NavigationItemCount - 1);
        SelectItem(TargetIndex);
      end;
      Key := 0;
      KeyChar := #0;
      Exit;
    end;
    if (Key = vkDelete) and FAllowClear then
    begin
      ClearSelection;
      Key := 0;
      KeyChar := #0;
      Exit;
    end;
  end;
  inherited;
end;

procedure Register;
begin
  RegisterComponents('UniListView', [TUniLookup]);
end;

end.
