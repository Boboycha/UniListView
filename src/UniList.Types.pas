unit UniList.Types;

interface

uses
  System.Classes, System.Types, System.UITypes, System.SysUtils, System.Math,
  System.Actions;

type
  TUniDesignPreviewMode = (dpmNone, dpmSampleData, dpmConnectedData);
  TUniCardLayout = (uclGrid, uclFullWidth);
  TUniCardTreeMode = (ctmNavigate, ctmHierarchy, ctmExplorer);
  TUniTreeCheckMode = (tcmIndependent, tcmCascadeDown, tcmCascadeFull);
  TUniActionVisibility = (uavAlways, uavOnHover);
  TUniScrollMode = (usmVertical, usmHorizontal, usmBoth);
  TUniPanMode = (upmDisabled, upmMouse, upmTouch, upmMouseAndTouch);
  TUniCardSizingMode = (ucsmFixed, ucsmResponsive, ucsmStretchColumns,
    ucsmAutoByTitle);
  TUniContentFlow = (ucfWrap, ucfNoWrap);
  TUniScrollBarVisibility = (usbNever, usbAuto, usbAlways);
  TUniTextPart = (utpNone, utpTitle, utpText, utpDetail);

  TUniVectorIcon = (
    uviNone,
    uviEdit,
    uviDelete,
    uviOpen,
    uviMore,
    uviServer,
    uviCheck,
    uviDatabase,
    uviChevronRight,
    uviChevronDown,
    uviChevronUp,
    uviChevronLeft
  );

  TUniItemActionEvent = procedure(Sender: TObject; const AItemIndex: Integer;
    const AActionName: string) of object;
  TUniItemClickEvent = procedure(Sender: TObject; const AItemIndex: Integer) of object;

  TUniCardAction = class(TCollectionItem)
  private
    FName: string;
    FCaption: string;
    FIcon: TUniVectorIcon;
    FWidth: Single;
    FVisible: Boolean;
    FEnabled: Boolean;
    FVisibleField: string;
    FEnabledField: string;
    FAction: TContainedAction;
    procedure SetWidth(const Value: Single);
    procedure SetVisible(const Value: Boolean);
    procedure SetAction(const Value: TContainedAction);
  published
    property Name: string read FName write FName;
    property Caption: string read FCaption write FCaption;
    property Icon: TUniVectorIcon read FIcon write FIcon default uviNone;
    property Width: Single read FWidth write SetWidth;
    property Visible: Boolean read FVisible write SetVisible default True;
    property Enabled: Boolean read FEnabled write FEnabled default True;
    property VisibleField: string read FVisibleField write FVisibleField;
    property EnabledField: string read FEnabledField write FEnabledField;
    (* Если назначен - клик по кнопке вызывает Action.Execute вместо/в
       дополнение к OnItemAction (см. TUniListView.ActionItemIndex,
       который на время Execute указывает на строку, по которой кликнули). *)
    property Action: TContainedAction read FAction write SetAction;
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  end;

  TUniCardActions = class(TOwnedCollection)
  private
    FOnChanged: TNotifyEvent;
    function GetItem(Index: Integer): TUniCardAction;
    function GetListOwner: TPersistent;
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TUniCardAction;
    property Items[Index: Integer]: TUniCardAction read GetItem; default;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
    (* Владелец коллекции (обычно TUniListView) - нужен TUniCardAction.SetAction
       для FreeNotification на привязанный Action. GetOwner в TCollection
       объявлен dynamic, напрямую как read-спецификатор свойства не годится -
       оборачиваем обычной функцией. *)
    property ListOwner: TPersistent read GetListOwner;
  end;

  TUniCardTemplate = class(TPersistent)
  private
    FOwner: TPersistent;
    FOnChanged: TNotifyEvent;
    FShowIcon: Boolean;
    FShowTitle: Boolean;
    FShowText: Boolean;
    FShowDetail: Boolean;
    FShowActions: Boolean;
    FIcon: TUniVectorIcon;
    FIconSize: Single;
    FIconBoxSize: Single;
    FInnerPadding: Single;
    FTextGap: Single;
    FWordWrap: Boolean;
    FEllipsis: Boolean;
    FAutoCardHeight: Boolean;
    FSelectableText: Boolean;
    FTitleMaxLines: Integer;
    FTextMaxLines: Integer;
    FDetailMaxLines: Integer;
    FMaxCardHeight: Single;
    FTitleField: string;
    FTextField: string;
    FDetailField: string;
    FIconField: string;
    FStatusField: string;
    procedure Changed;
    procedure SetShowIcon(const Value: Boolean);
    procedure SetShowTitle(const Value: Boolean);
    procedure SetShowText(const Value: Boolean);
    procedure SetShowDetail(const Value: Boolean);
    procedure SetShowActions(const Value: Boolean);
    procedure SetWordWrap(const Value: Boolean);
    procedure SetEllipsis(const Value: Boolean);
    procedure SetAutoCardHeight(const Value: Boolean);
    procedure SetSelectableText(const Value: Boolean);
    procedure SetIcon(const Value: TUniVectorIcon);
    procedure SetIconSize(const Value: Single);
    procedure SetIconBoxSize(const Value: Single);
    procedure SetInnerPadding(const Value: Single);
    procedure SetTextGap(const Value: Single);
    procedure SetTitleMaxLines(const Value: Integer);
    procedure SetTextMaxLines(const Value: Integer);
    procedure SetDetailMaxLines(const Value: Integer);
    procedure SetMaxCardHeight(const Value: Single);
    procedure SetTitleField(const Value: string);
    procedure SetTextField(const Value: string);
    procedure SetDetailField(const Value: string);
    procedure SetIconField(const Value: string);
    procedure SetStatusField(const Value: string);
  public
    constructor Create(AOwner: TPersistent);
    procedure Assign(Source: TPersistent); override;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  published
    property ShowIcon: Boolean read FShowIcon write SetShowIcon default True;
    property ShowTitle: Boolean read FShowTitle write SetShowTitle default True;
    property ShowText: Boolean read FShowText write SetShowText default True;
    property ShowDetail: Boolean read FShowDetail write SetShowDetail default True;
    property ShowActions: Boolean read FShowActions write SetShowActions default True;
    property Icon: TUniVectorIcon read FIcon write SetIcon default uviServer;
    property IconSize: Single read FIconSize write SetIconSize;
    property IconBoxSize: Single read FIconBoxSize write SetIconBoxSize;
    property InnerPadding: Single read FInnerPadding write SetInnerPadding;
    property TextGap: Single read FTextGap write SetTextGap;
    property WordWrap: Boolean read FWordWrap write SetWordWrap default True;
    property Ellipsis: Boolean read FEllipsis write SetEllipsis default True;
    property AutoCardHeight: Boolean read FAutoCardHeight write SetAutoCardHeight default True;
    property SelectableText: Boolean read FSelectableText write SetSelectableText default True;
    property TitleMaxLines: Integer read FTitleMaxLines write SetTitleMaxLines default 0;
    property TextMaxLines: Integer read FTextMaxLines write SetTextMaxLines default 3;
    property DetailMaxLines: Integer read FDetailMaxLines write SetDetailMaxLines default 2;
    property MaxCardHeight: Single read FMaxCardHeight write SetMaxCardHeight;
    property TitleField: string read FTitleField write SetTitleField;
    property TextField: string read FTextField write SetTextField;
    property DetailField: string read FDetailField write SetDetailField;
    property IconField: string read FIconField write SetIconField;
    property StatusField: string read FStatusField write SetStatusField;
  end;

  TUniCardHitKind = (uchNone, uchItem, uchText, uchAction, uchHeader,
    uchHScrollThumb, uchVScrollThumb, uchCardTreeNavigate,
    uchCardTreeExpand, uchCardTreeBreadcrumb, uchCardTreeBack);

  TUniCardHit = record
    Kind: TUniCardHitKind;
    ItemIndex: Integer;
    ActionIndex: Integer;
    TextPart: TUniTextPart;
    class function None: TUniCardHit; static;
  end;

implementation

constructor TUniCardAction.Create(Collection: TCollection);
begin
  inherited;
  FWidth := 30;
  FVisible := True;
  FEnabled := True;
  FIcon := uviNone;
end;

procedure TUniCardAction.Assign(Source: TPersistent);
var
  Action: TUniCardAction;
begin
  if not (Source is TUniCardAction) then
  begin
    inherited;
    Exit;
  end;
  Action := TUniCardAction(Source);
  FName := Action.FName;
  FCaption := Action.FCaption;
  FIcon := Action.FIcon;
  FWidth := Action.FWidth;
  FVisible := Action.FVisible;
  FEnabled := Action.FEnabled;
  FVisibleField := Action.FVisibleField;
  FEnabledField := Action.FEnabledField;
  SetAction(Action.FAction);
  Changed(False);
end;

procedure TUniCardAction.SetWidth(const Value: Single);
var
  NewValue: Single;
begin
  NewValue := Max(0, Value);
  if SameValue(FWidth, NewValue) then
    Exit;
  FWidth := NewValue;
  Changed(False);
end;

procedure TUniCardAction.SetVisible(const Value: Boolean);
begin
  if FVisible = Value then
    Exit;
  FVisible := Value;
  Changed(False);
end;

procedure TUniCardAction.SetAction(const Value: TContainedAction);
var
  OwnerComp: TComponent;
begin
  if FAction = Value then
    Exit;
  OwnerComp := nil;
  if (Collection is TUniCardActions) and
     (TUniCardActions(Collection).ListOwner is TComponent) then
    OwnerComp := TComponent(TUniCardActions(Collection).ListOwner);
  if Assigned(FAction) and Assigned(OwnerComp) then
    FAction.RemoveFreeNotification(OwnerComp);
  FAction := Value;
  if Assigned(FAction) and Assigned(OwnerComp) then
    FAction.FreeNotification(OwnerComp);
  Changed(False);
end;

constructor TUniCardActions.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TUniCardAction);
end;

function TUniCardActions.Add: TUniCardAction;
begin
  Result := inherited Add as TUniCardAction;
end;

function TUniCardActions.GetItem(Index: Integer): TUniCardAction;
begin
  Result := inherited GetItem(Index) as TUniCardAction;
end;

function TUniCardActions.GetListOwner: TPersistent;
begin
  Result := GetOwner;
end;

procedure TUniCardActions.Update(Item: TCollectionItem);
begin
  inherited;
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

constructor TUniCardTemplate.Create(AOwner: TPersistent);
begin
  inherited Create;
  FOwner := AOwner;
  FShowIcon := True;
  FShowTitle := True;
  FShowText := True;
  FShowDetail := True;
  FShowActions := True;
  FIcon := uviServer;
  FIconSize := 20;
  FIconBoxSize := 40;
  FInnerPadding := 12;
  FTextGap := 3;
  FWordWrap := True;
  FEllipsis := True;
  FAutoCardHeight := True;
  FSelectableText := True;
  FTitleMaxLines := 0;
  FTextMaxLines := 3;
  FDetailMaxLines := 2;
  FMaxCardHeight := 240;
  FTitleField := 'title';
  FTextField := 'text';
  FDetailField := 'detail';
  FIconField := 'icon';
  FStatusField := 'status';
end;

procedure TUniCardTemplate.Assign(Source: TPersistent);
var
  S: TUniCardTemplate;
begin
  if Source is TUniCardTemplate then
  begin
    S := TUniCardTemplate(Source);
    FShowIcon := S.FShowIcon;
    FShowTitle := S.FShowTitle;
    FShowText := S.FShowText;
    FShowDetail := S.FShowDetail;
    FShowActions := S.FShowActions;
    FIcon := S.FIcon;
    FIconSize := S.FIconSize;
    FIconBoxSize := S.FIconBoxSize;
    FInnerPadding := S.FInnerPadding;
    FTextGap := S.FTextGap;
    FWordWrap := S.FWordWrap;
    FEllipsis := S.FEllipsis;
    FAutoCardHeight := S.FAutoCardHeight;
    FSelectableText := S.FSelectableText;
    FTitleMaxLines := S.FTitleMaxLines;
    FTextMaxLines := S.FTextMaxLines;
    FDetailMaxLines := S.FDetailMaxLines;
    FMaxCardHeight := S.FMaxCardHeight;
    FTitleField := S.FTitleField;
    FTextField := S.FTextField;
    FDetailField := S.FDetailField;
    FIconField := S.FIconField;
    FStatusField := S.FStatusField;
    Changed;
  end
  else
    inherited;
end;

procedure TUniCardTemplate.Changed;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure TUniCardTemplate.SetAutoCardHeight(const Value: Boolean);
begin
  if FAutoCardHeight <> Value then begin FAutoCardHeight := Value; Changed; end;
end;

procedure TUniCardTemplate.SetDetailMaxLines(const Value: Integer);
begin
  if FDetailMaxLines <> Max(0, Value) then begin FDetailMaxLines := Max(0, Value); Changed; end;
end;

procedure TUniCardTemplate.SetEllipsis(const Value: Boolean);
begin
  if FEllipsis <> Value then begin FEllipsis := Value; Changed; end;
end;

procedure TUniCardTemplate.SetIcon(const Value: TUniVectorIcon);
begin
  if FIcon <> Value then begin FIcon := Value; Changed; end;
end;

procedure TUniCardTemplate.SetIconBoxSize(const Value: Single);
begin
  if not SameValue(FIconBoxSize, Value) then begin FIconBoxSize := Max(0, Value); Changed; end;
end;

procedure TUniCardTemplate.SetIconSize(const Value: Single);
begin
  if not SameValue(FIconSize, Value) then begin FIconSize := Max(0, Value); Changed; end;
end;

procedure TUniCardTemplate.SetInnerPadding(const Value: Single);
begin
  if not SameValue(FInnerPadding, Value) then begin FInnerPadding := Max(0, Value); Changed; end;
end;

procedure TUniCardTemplate.SetMaxCardHeight(const Value: Single);
begin
  if not SameValue(FMaxCardHeight, Value) then begin FMaxCardHeight := Max(0, Value); Changed; end;
end;

procedure TUniCardTemplate.SetSelectableText(const Value: Boolean);
begin
  if FSelectableText <> Value then begin FSelectableText := Value; Changed; end;
end;

procedure TUniCardTemplate.SetShowActions(const Value: Boolean);
begin
  if FShowActions <> Value then begin FShowActions := Value; Changed; end;
end;

procedure TUniCardTemplate.SetShowDetail(const Value: Boolean);
begin
  if FShowDetail <> Value then begin FShowDetail := Value; Changed; end;
end;

procedure TUniCardTemplate.SetShowIcon(const Value: Boolean);
begin
  if FShowIcon <> Value then begin FShowIcon := Value; Changed; end;
end;

procedure TUniCardTemplate.SetShowText(const Value: Boolean);
begin
  if FShowText <> Value then begin FShowText := Value; Changed; end;
end;

procedure TUniCardTemplate.SetShowTitle(const Value: Boolean);
begin
  if FShowTitle <> Value then begin FShowTitle := Value; Changed; end;
end;

procedure TUniCardTemplate.SetTextGap(const Value: Single);
begin
  if not SameValue(FTextGap, Value) then begin FTextGap := Max(0, Value); Changed; end;
end;

procedure TUniCardTemplate.SetTextMaxLines(const Value: Integer);
begin
  if FTextMaxLines <> Max(0, Value) then begin FTextMaxLines := Max(0, Value); Changed; end;
end;

procedure TUniCardTemplate.SetTitleMaxLines(const Value: Integer);
begin
  if FTitleMaxLines <> Max(0, Value) then begin FTitleMaxLines := Max(0, Value); Changed; end;
end;

procedure TUniCardTemplate.SetWordWrap(const Value: Boolean);
begin
  if FWordWrap <> Value then begin FWordWrap := Value; Changed; end;
end;

procedure TUniCardTemplate.SetTitleField(const Value: string);
begin
  if FTitleField <> Value then begin FTitleField := Value; Changed; end;
end;

procedure TUniCardTemplate.SetTextField(const Value: string);
begin
  if FTextField <> Value then begin FTextField := Value; Changed; end;
end;

procedure TUniCardTemplate.SetDetailField(const Value: string);
begin
  if FDetailField <> Value then begin FDetailField := Value; Changed; end;
end;

procedure TUniCardTemplate.SetIconField(const Value: string);
begin
  if FIconField <> Value then begin FIconField := Value; Changed; end;
end;

procedure TUniCardTemplate.SetStatusField(const Value: string);
begin
  if FStatusField <> Value then begin FStatusField := Value; Changed; end;
end;

class function TUniCardHit.None: TUniCardHit;
begin
  Result.Kind := uchNone;
  Result.ItemIndex := -1;
  Result.ActionIndex := -1;
  Result.TextPart := utpNone;
end;

end.
