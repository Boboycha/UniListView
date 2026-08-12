unit UniList.Rules;

interface

uses
  System.SysUtils, System.Classes, System.UITypes, System.Math, System.StrUtils,
  UniList.Items;

type
  TUniColorRuleOperator = (
    ucroEqual,
    ucroNotEqual,
    ucroContains,
    ucroNotContains,
    ucroStartsWith,
    ucroEndsWith,
    ucroGreater,
    ucroGreaterOrEqual,
    ucroLess,
    ucroLessOrEqual,
    ucroIsEmpty,
    ucroIsNotEmpty
  );

  TUniColorRuleScope = (
    ucrsRow,
    ucrsCell
  );

  TUniColorRuleThemeTone = (
    ucrttAccent,
    ucrttSuccess,
    ucrttWarning,
    ucrttDanger,
    ucrttInfo
  );

  TUniColorRule = class(TCollectionItem)
  private
    FEnabled: Boolean;
    FFieldName: string;
    FOperator: TUniColorRuleOperator;
    FValue: string;
    FScope: TUniColorRuleScope;
    FTargetColumn: string;
    FUseBackgroundColor: Boolean;
    FBackgroundColor: TAlphaColor;
    FUseTextColor: Boolean;
    FTextColor: TAlphaColor;
    FUseThemeColors: Boolean;
    FThemeTone: TUniColorRuleThemeTone;
    procedure Changed;
    procedure SetEnabled(const Value: Boolean);
    procedure SetFieldName(const Value: string);
    procedure SetOperator(const Value: TUniColorRuleOperator);
    procedure SetValue(const Value: string);
    procedure SetScope(const Value: TUniColorRuleScope);
    procedure SetTargetColumn(const Value: string);
    procedure SetUseBackgroundColor(const Value: Boolean);
    procedure SetBackgroundColor(const Value: TAlphaColor);
    procedure SetUseTextColor(const Value: Boolean);
    procedure SetTextColor(const Value: TAlphaColor);
    procedure SetUseThemeColors(const Value: Boolean);
    procedure SetThemeTone(const Value: TUniColorRuleThemeTone);
  public
    constructor Create(Collection: TCollection); override;
    function Matches(const AItem: TUniListItem): Boolean;
  published
    property Enabled: Boolean read FEnabled write SetEnabled default True;
    property FieldName: string read FFieldName write SetFieldName;
    property Operator: TUniColorRuleOperator read FOperator write SetOperator
      default ucroEqual;
    property Value: string read FValue write SetValue;
    property Scope: TUniColorRuleScope read FScope write SetScope default ucrsRow;
    property TargetColumn: string read FTargetColumn write SetTargetColumn;
    property UseBackgroundColor: Boolean read FUseBackgroundColor
      write SetUseBackgroundColor default False;
    property BackgroundColor: TAlphaColor read FBackgroundColor
      write SetBackgroundColor default $FFFFE8E8;
    property UseTextColor: Boolean read FUseTextColor write SetUseTextColor
      default False;
    property TextColor: TAlphaColor read FTextColor write SetTextColor
      default $FFB91C1C;
    property UseThemeColors: Boolean read FUseThemeColors
      write SetUseThemeColors default False;
    property ThemeTone: TUniColorRuleThemeTone read FThemeTone
      write SetThemeTone default ucrttAccent;
  end;

  TUniColorRules = class(TOwnedCollection)
  private
    FOnChanged: TNotifyEvent;
    function GetItem(const Index: Integer): TUniColorRule;
    procedure SetItem(const Index: Integer; const Value: TUniColorRule);
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TUniColorRule;
    property Items[const Index: Integer]: TUniColorRule read GetItem
      write SetItem; default;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  end;

implementation

constructor TUniColorRule.Create(Collection: TCollection);
begin
  inherited;
  FEnabled := True;
  FOperator := ucroEqual;
  FScope := ucrsRow;
  FUseBackgroundColor := False;
  FBackgroundColor := $FFFFE8E8;
  FUseTextColor := False;
  FTextColor := $FFB91C1C;
  FUseThemeColors := False;
  FThemeTone := ucrttAccent;
end;

procedure TUniColorRule.Changed;
begin
  if Collection <> nil then
    inherited Changed(False);
end;

procedure TUniColorRule.SetEnabled(const Value: Boolean);
begin
  if FEnabled = Value then Exit;
  FEnabled := Value;
  Changed;
end;

procedure TUniColorRule.SetFieldName(const Value: string);
begin
  if FFieldName = Value then Exit;
  FFieldName := Value;
  Changed;
end;

procedure TUniColorRule.SetOperator(const Value: TUniColorRuleOperator);
begin
  if FOperator = Value then Exit;
  FOperator := Value;
  Changed;
end;

procedure TUniColorRule.SetValue(const Value: string);
begin
  if FValue = Value then Exit;
  FValue := Value;
  Changed;
end;

procedure TUniColorRule.SetScope(const Value: TUniColorRuleScope);
begin
  if FScope = Value then Exit;
  FScope := Value;
  Changed;
end;

procedure TUniColorRule.SetTargetColumn(const Value: string);
begin
  if FTargetColumn = Value then Exit;
  FTargetColumn := Value;
  Changed;
end;

procedure TUniColorRule.SetUseBackgroundColor(const Value: Boolean);
begin
  if FUseBackgroundColor = Value then Exit;
  FUseBackgroundColor := Value;
  Changed;
end;

procedure TUniColorRule.SetBackgroundColor(const Value: TAlphaColor);
begin
  if FBackgroundColor = Value then Exit;
  FBackgroundColor := Value;
  Changed;
end;

procedure TUniColorRule.SetUseTextColor(const Value: Boolean);
begin
  if FUseTextColor = Value then Exit;
  FUseTextColor := Value;
  Changed;
end;

procedure TUniColorRule.SetTextColor(const Value: TAlphaColor);
begin
  if FTextColor = Value then Exit;
  FTextColor := Value;
  Changed;
end;

procedure TUniColorRule.SetUseThemeColors(const Value: Boolean);
begin
  if FUseThemeColors = Value then Exit;
  FUseThemeColors := Value;
  Changed;
end;

procedure TUniColorRule.SetThemeTone(const Value: TUniColorRuleThemeTone);
begin
  if FThemeTone = Value then Exit;
  FThemeTone := Value;
  Changed;
end;

function TUniColorRule.Matches(const AItem: TUniListItem): Boolean;
var
  ActualText, ExpectedText: string;
  ActualNumber, ExpectedNumber: Double;
  ActualIsNumber, ExpectedIsNumber: Boolean;
begin
  Result := False;
  if not FEnabled or (AItem = nil) or (Trim(FFieldName) = '') then
    Exit;

  ActualText := AItem.FieldAsString(FFieldName, '');
  ExpectedText := FValue;
  ActualIsNumber := TryStrToFloat(ActualText, ActualNumber);
  ExpectedIsNumber := TryStrToFloat(ExpectedText, ExpectedNumber);

  case FOperator of
    ucroEqual:
      if ActualIsNumber and ExpectedIsNumber then
        Result := SameValue(ActualNumber, ExpectedNumber)
      else
        Result := SameText(ActualText, ExpectedText);
    ucroNotEqual:
      if ActualIsNumber and ExpectedIsNumber then
        Result := not SameValue(ActualNumber, ExpectedNumber)
      else
        Result := not SameText(ActualText, ExpectedText);
    ucroContains:
      Result := ContainsText(ActualText, ExpectedText);
    ucroNotContains:
      Result := not ContainsText(ActualText, ExpectedText);
    ucroStartsWith:
      Result := StartsText(ExpectedText, ActualText);
    ucroEndsWith:
      Result := EndsText(ExpectedText, ActualText);
    ucroGreater:
      Result := ActualIsNumber and ExpectedIsNumber and
        (ActualNumber > ExpectedNumber);
    ucroGreaterOrEqual:
      Result := ActualIsNumber and ExpectedIsNumber and
        (ActualNumber >= ExpectedNumber);
    ucroLess:
      Result := ActualIsNumber and ExpectedIsNumber and
        (ActualNumber < ExpectedNumber);
    ucroLessOrEqual:
      Result := ActualIsNumber and ExpectedIsNumber and
        (ActualNumber <= ExpectedNumber);
    ucroIsEmpty:
      Result := Trim(ActualText) = '';
    ucroIsNotEmpty:
      Result := Trim(ActualText) <> '';
  end;
end;

constructor TUniColorRules.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TUniColorRule);
end;

function TUniColorRules.Add: TUniColorRule;
begin
  Result := TUniColorRule(inherited Add);
end;

function TUniColorRules.GetItem(const Index: Integer): TUniColorRule;
begin
  Result := TUniColorRule(inherited GetItem(Index));
end;

procedure TUniColorRules.SetItem(const Index: Integer;
  const Value: TUniColorRule);
begin
  inherited SetItem(Index, Value);
end;

procedure TUniColorRules.Update(Item: TCollectionItem);
begin
  inherited;
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

end.
