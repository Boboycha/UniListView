unit UniList.Columns;

interface

uses
  System.Classes, System.SysUtils, System.UITypes, FMX.Types;

type
  TUniViewMode = (uvmCards, uvmList);
  TUniColumnWidthMode = (ucwmFixed, ucwmAuto, ucwmFill);
  TUniColumnDataType = (ucdtText, ucdtInteger, ucdtFloat, ucdtDateTime,
    ucdtBoolean);
  TUniFooterAggregate = (ufaNone, ufaCount, ufaSum, ufaMin, ufaMax, ufaAverage,
    ufaCustomText);
  TUniFilterOperator = (ufoContains, ufoEquals, ufoStartsWith, ufoNotEqual,
    ufoGreater, ufoGreaterOrEqual, ufoLess, ufoLessOrEqual);
  TUniCardRole = (ucrAuto, ucrTitle, ucrSubtitle, ucrDetail, ucrTrailing,
    ucrHidden);

  TUniListColumn = class(TCollectionItem)
  private
    FLayoutID: string;
    FFieldName: string;
    FCaption: string;
    FWidth: Single;
    FMinWidth: Single;
    FMaxWidth: Single;
    FWidthMode: TUniColumnWidthMode;
    FDataType: TUniColumnDataType;
    FAlignment: TTextAlign;
    FVisible: Boolean;
    FVisibleInCards: Boolean;
    FCardRole: TUniCardRole;
    FSortable: Boolean;
    FFrozen: Boolean;
    FFormat: string;
    FFooterAggregate: TUniFooterAggregate;
    FFooterText: string;
    FFooterFormat: string;
    FFilterOperator: TUniFilterOperator;
    FFilterValue: string;
    FWrapText: Boolean;
    FMaxLines: Integer;
    procedure SetLayoutID(const Value: string);
    procedure SetFieldName(const Value: string);
    procedure SetCaption(const Value: string);
    procedure SetWidth(const Value: Single);
    procedure SetMinWidth(const Value: Single);
    procedure SetMaxWidth(const Value: Single);
    procedure SetWidthMode(const Value: TUniColumnWidthMode);
    procedure SetDataType(const Value: TUniColumnDataType);
    procedure SetAlignment(const Value: TTextAlign);
    procedure SetVisible(const Value: Boolean);
    procedure SetVisibleInCards(const Value: Boolean);
    procedure SetCardRole(const Value: TUniCardRole);
    procedure SetSortable(const Value: Boolean);
    procedure SetFrozen(const Value: Boolean);
    procedure SetFormat(const Value: string);
    procedure SetFooterAggregate(const Value: TUniFooterAggregate);
    procedure SetFooterText(const Value: string);
    procedure SetFooterFormat(const Value: string);
    procedure SetFilterOperator(const Value: TUniFilterOperator);
    procedure SetFilterValue(const Value: string);
    procedure SetWrapText(const Value: Boolean);
    procedure SetMaxLines(const Value: Integer);
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property LayoutID: string read FLayoutID write SetLayoutID;
    property FieldName: string read FFieldName write SetFieldName;
    property Caption: string read FCaption write SetCaption;
    property Width: Single read FWidth write SetWidth;
    property MinWidth: Single read FMinWidth write SetMinWidth;
    property MaxWidth: Single read FMaxWidth write SetMaxWidth;
    property WidthMode: TUniColumnWidthMode read FWidthMode write SetWidthMode
      default ucwmFixed;
    property DataType: TUniColumnDataType read FDataType write SetDataType
      default ucdtText;
    property Alignment: TTextAlign read FAlignment write SetAlignment
      default TTextAlign.Leading;
    property Visible: Boolean read FVisible write SetVisible default True;
    property VisibleInCards: Boolean read FVisibleInCards
      write SetVisibleInCards default True;
    property CardRole: TUniCardRole read FCardRole write SetCardRole
      default ucrAuto;
    property Sortable: Boolean read FSortable write SetSortable default True;
    property Frozen: Boolean read FFrozen write SetFrozen default False;
    property Format: string read FFormat write SetFormat;
    property FooterAggregate: TUniFooterAggregate read FFooterAggregate
      write SetFooterAggregate default ufaNone;
    property FooterText: string read FFooterText write SetFooterText;
    property FooterFormat: string read FFooterFormat write SetFooterFormat;
    property FilterOperator: TUniFilterOperator read FFilterOperator
      write SetFilterOperator default ufoContains;
    property FilterValue: string read FFilterValue write SetFilterValue;
    property WrapText: Boolean read FWrapText write SetWrapText default False;
    property MaxLines: Integer read FMaxLines write SetMaxLines default 0;
  end;

  TUniListColumns = class(TOwnedCollection)
  private
    FOnChanged: TNotifyEvent;
    function GetItem(Index: Integer): TUniListColumn;
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TUniListColumn;
    property Items[Index: Integer]: TUniListColumn read GetItem; default;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  end;

implementation

constructor TUniListColumn.Create(Collection: TCollection);
begin
  inherited;
  FLayoutID := TGUID.NewGuid.ToString;
  FWidth := 140;
  FMinWidth := 60;
  FMaxWidth := 600;
  FWidthMode := ucwmFixed;
  FDataType := ucdtText;
  FAlignment := TTextAlign.Leading;
  FVisible := True;
  FVisibleInCards := True;
  FCardRole := ucrAuto;
  FSortable := True;
  FFrozen := False;
  FFooterAggregate := ufaNone;
  FFilterOperator := ufoContains;
  FWrapText := False;
  FMaxLines := 0;
end;

procedure TUniListColumn.SetLayoutID(const Value: string);
begin
  if FLayoutID = Value then
    Exit;
  FLayoutID := Value;
  Changed(False);
end;

procedure TUniListColumn.SetFieldName(const Value: string);
begin
  if FFieldName = Value then
    Exit;
  FFieldName := Value;
  Changed(False);
end;

procedure TUniListColumn.SetCaption(const Value: string);
begin
  if FCaption = Value then
    Exit;
  FCaption := Value;
  Changed(False);
end;

procedure TUniListColumn.SetWidth(const Value: Single);
begin
  if FWidth = Value then
    Exit;
  FWidth := Value;
  Changed(False);
end;

procedure TUniListColumn.SetMinWidth(const Value: Single);
begin
  if FMinWidth = Value then
    Exit;
  FMinWidth := Value;
  Changed(False);
end;

procedure TUniListColumn.SetMaxWidth(const Value: Single);
begin
  if FMaxWidth = Value then
    Exit;
  FMaxWidth := Value;
  Changed(False);
end;

procedure TUniListColumn.SetWidthMode(const Value: TUniColumnWidthMode);
begin
  if FWidthMode = Value then
    Exit;
  FWidthMode := Value;
  Changed(False);
end;

procedure TUniListColumn.SetDataType(const Value: TUniColumnDataType);
begin
  if FDataType = Value then
    Exit;
  FDataType := Value;
  Changed(False);
end;

procedure TUniListColumn.SetAlignment(const Value: TTextAlign);
begin
  if FAlignment = Value then
    Exit;
  FAlignment := Value;
  Changed(False);
end;

procedure TUniListColumn.SetVisible(const Value: Boolean);
begin
  if FVisible = Value then
    Exit;
  FVisible := Value;
  Changed(False);
end;

procedure TUniListColumn.SetVisibleInCards(const Value: Boolean);
begin
  if FVisibleInCards = Value then
    Exit;
  FVisibleInCards := Value;
  Changed(False);
end;

procedure TUniListColumn.SetCardRole(const Value: TUniCardRole);
begin
  if FCardRole = Value then
    Exit;
  FCardRole := Value;
  Changed(False);
end;

procedure TUniListColumn.SetSortable(const Value: Boolean);
begin
  if FSortable = Value then
    Exit;
  FSortable := Value;
  Changed(False);
end;

procedure TUniListColumn.SetFrozen(const Value: Boolean);
begin
  if FFrozen = Value then
    Exit;
  FFrozen := Value;
  Changed(False);
end;

procedure TUniListColumn.SetFormat(const Value: string);
begin
  if FFormat = Value then
    Exit;
  FFormat := Value;
  Changed(False);
end;

procedure TUniListColumn.SetFooterAggregate(
  const Value: TUniFooterAggregate);
begin
  if FFooterAggregate = Value then
    Exit;
  FFooterAggregate := Value;
  Changed(False);
end;

procedure TUniListColumn.SetFooterText(const Value: string);
begin
  if FFooterText = Value then
    Exit;
  FFooterText := Value;
  Changed(False);
end;

procedure TUniListColumn.SetFooterFormat(const Value: string);
begin
  if FFooterFormat = Value then
    Exit;
  FFooterFormat := Value;
  Changed(False);
end;


procedure TUniListColumn.SetFilterOperator(const Value: TUniFilterOperator);
begin
  if FFilterOperator = Value then
    Exit;
  FFilterOperator := Value;
  Changed(False);
end;

procedure TUniListColumn.SetFilterValue(const Value: string);
begin
  if FFilterValue = Value then
    Exit;
  FFilterValue := Value;
  Changed(False);
end;

procedure TUniListColumn.SetWrapText(const Value: Boolean);
begin
  if FWrapText = Value then
    Exit;
  FWrapText := Value;
  Changed(False);
end;

procedure TUniListColumn.SetMaxLines(const Value: Integer);
begin
  if FMaxLines = Value then
    Exit;
  if Value < 0 then
    FMaxLines := 0
  else
    FMaxLines := Value;
  Changed(False);
end;

procedure TUniListColumn.Assign(Source: TPersistent);
begin
  if Source is TUniListColumn then
  begin
    FLayoutID := TUniListColumn(Source).LayoutID;
    FFieldName := TUniListColumn(Source).FieldName;
    FCaption := TUniListColumn(Source).Caption;
    FWidth := TUniListColumn(Source).Width;
    FMinWidth := TUniListColumn(Source).MinWidth;
    FMaxWidth := TUniListColumn(Source).MaxWidth;
    FWidthMode := TUniListColumn(Source).WidthMode;
    FDataType := TUniListColumn(Source).DataType;
    FAlignment := TUniListColumn(Source).Alignment;
    FVisible := TUniListColumn(Source).Visible;
    FVisibleInCards := TUniListColumn(Source).VisibleInCards;
    FCardRole := TUniListColumn(Source).CardRole;
    FSortable := TUniListColumn(Source).Sortable;
    FFrozen := TUniListColumn(Source).Frozen;
    FFormat := TUniListColumn(Source).Format;
    FFooterAggregate := TUniListColumn(Source).FooterAggregate;
    FFooterText := TUniListColumn(Source).FooterText;
    FFooterFormat := TUniListColumn(Source).FooterFormat;
    FFilterOperator := TUniListColumn(Source).FilterOperator;
    FFilterValue := TUniListColumn(Source).FilterValue;
    FWrapText := TUniListColumn(Source).WrapText;
    FMaxLines := TUniListColumn(Source).MaxLines;
    Changed(False);
  end
  else
    inherited;
end;

constructor TUniListColumns.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TUniListColumn);
end;

function TUniListColumns.Add: TUniListColumn;
begin
  Result := inherited Add as TUniListColumn;
end;

function TUniListColumns.GetItem(Index: Integer): TUniListColumn;
begin
  Result := inherited GetItem(Index) as TUniListColumn;
end;

procedure TUniListColumns.Update(Item: TCollectionItem);
begin
  inherited;
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

end.
