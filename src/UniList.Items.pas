unit UniList.Items;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.Variants,
  System.Rtti, System.UITypes, System.TypInfo, System.Generics.Defaults;

type
  TUniCheckState = (ucsUnchecked, ucsChecked, ucsIndeterminate);

  TUniListItem = class;
  TUniListItems = class;

  TUniCheckedItemEnumerator = record
  private
    FItems: TUniListItems;
    FIndex: Integer;
    function GetCurrent: TUniListItem;
  public
    constructor Create(const AItems: TUniListItems);
    function MoveNext: Boolean;
    property Current: TUniListItem read GetCurrent;
  end;

  TUniCheckedItems = record
  private
    FItems: TUniListItems;
  public
    constructor Create(const AItems: TUniListItems);
    function GetEnumerator: TUniCheckedItemEnumerator;
  end;

  TUniListItemChangedEvent = procedure(Sender: TObject; AItem: TUniListItem;
    const AFieldName: string) of object;
  TUniListItemsItemChangedEvent = procedure(Sender: TObject;
    const AItemIndex: Integer; const AFieldName: string) of object;

  TUniListItem = class(TPersistent)
  private
    FData: TDictionary<string, TValue>;
    FOnChanged: TUniListItemChangedEvent;
    FCheckState: TUniCheckState;
    function NormalizeName(const AName: string): string;
    function GetFieldValue(const AName: string): TValue;
    procedure SetFieldValue(const AName: string; const AValue: TValue);
    function GetStringField(const AName: string): string;
    procedure SetStringField(const AName, AValue: string);
    function GetBooleanField(const AName: string; const ADefault: Boolean): Boolean;
    procedure SetBooleanField(const AName: string; const AValue: Boolean);
    function GetID: string;
    procedure SetID(const Value: string);
    function GetParentID: string;
    procedure SetParentID(const Value: string);
    function GetTitle: string;
    procedure SetTitle(const Value: string);
    function GetText: string;
    procedure SetText(const Value: string);
    function GetDetail: string;
    procedure SetDetail(const Value: string);
    function GetIconText: string;
    procedure SetIconText(const Value: string);
    function GetEnabled: Boolean;
    procedure SetEnabled(const Value: Boolean);
    function GetChecked: Boolean;
    procedure SetChecked(const Value: Boolean);
    procedure SetCheckState(const Value: TUniCheckState);
    procedure Changed(const AFieldName: string);
  public
    constructor Create;
    destructor Destroy; override;
    procedure ClearField(const AName: string);
    function ContainsField(const AName: string): Boolean;
    procedure SetField(const AName: string; const AValue: TValue); overload;
    procedure SetField(const AName: string; const AValue: string); overload;
    procedure SetField(const AName: string; const AValue: Integer); overload;
    procedure SetField(const AName: string; const AValue: Int64); overload;
    procedure SetField(const AName: string; const AValue: Double); overload;
    procedure SetField(const AName: string; const AValue: Boolean); overload;
    procedure SetFieldDateTime(const AName: string; const AValue: TDateTime);
    procedure SetFieldColor(const AName: string; const AValue: TAlphaColor);
    procedure SetFieldObject(const AName: string; const AValue: TObject);
    function FieldAsString(const AName: string;
      const ADefault: string = ''): string;
    function FieldAsInteger(const AName: string;
      const ADefault: Integer = 0): Integer;
    function FieldAsInt64(const AName: string;
      const ADefault: Int64 = 0): Int64;
    function FieldAsFloat(const AName: string;
      const ADefault: Double = 0): Double;
    function FieldAsBoolean(const AName: string;
      const ADefault: Boolean = False): Boolean;
    function FieldAsDateTime(const AName: string;
      const ADefault: TDateTime = 0): TDateTime;
    function FieldAsColor(const AName: string;
      const ADefault: TAlphaColor = 0): TAlphaColor;
    function FieldAsObject(const AName: string): TObject;
    { Compatibility API from v0.3.x. }
    procedure SetValue(const AName: string; const AValue: Variant);
    function GetValue(const AName: string; const ADefault: Variant): Variant;
    property Fields[const AName: string]: TValue read GetFieldValue
      write SetFieldValue; default;
    property Data: TDictionary<string, TValue> read FData;
    property OnChanged: TUniListItemChangedEvent read FOnChanged write FOnChanged;
  published
    property ID: string read GetID write SetID;
    property ParentID: string read GetParentID write SetParentID;
    property Title: string read GetTitle write SetTitle;
    property Text: string read GetText write SetText;
    property Detail: string read GetDetail write SetDetail;
    property IconText: string read GetIconText write SetIconText;
    property Enabled: Boolean read GetEnabled write SetEnabled default True;
    property Checked: Boolean read GetChecked write SetChecked default False;
    property CheckState: TUniCheckState read FCheckState write SetCheckState
      default ucsUnchecked;
  end;

  TUniListItems = class
  private
    FItems: TObjectList<TUniListItem>;
    FOnChanged: TNotifyEvent;
    FOnItemChanged: TUniListItemsItemChangedEvent;
    FUpdateCount: Integer;
    FChangedPending: Boolean;
    function GetCount: Integer;
    function GetItem(Index: Integer): TUniListItem;
    procedure Changed;
    procedure ItemChanged(Sender: TObject; AItem: TUniListItem;
      const AFieldName: string);
  public
    constructor Create;
    destructor Destroy; override;
    function Add: TUniListItem;
    function GetEnumerator: TEnumerator<TUniListItem>;
    procedure Clear;
    procedure Delete(Index: Integer);
    procedure BeginUpdate;
    procedure EndUpdate;
    function IndexOf(AItem: TUniListItem): Integer;
    procedure SortByField(const AFieldName: string; const AAscending: Boolean);
    procedure SortByFields(const AFieldNames: TArray<string>;
      const AAscending: TArray<Boolean>);
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TUniListItem read GetItem; default;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
    property OnItemChanged: TUniListItemsItemChangedEvent read FOnItemChanged
      write FOnItemChanged;
  end;

implementation

constructor TUniCheckedItemEnumerator.Create(const AItems: TUniListItems);
begin
  FItems := AItems;
  FIndex := -1;
end;

function TUniCheckedItemEnumerator.GetCurrent: TUniListItem;
begin
  Result := FItems[FIndex];
end;

function TUniCheckedItemEnumerator.MoveNext: Boolean;
begin
  repeat
    Inc(FIndex);
  until (FIndex >= FItems.Count) or FItems[FIndex].Checked;
  Result := FIndex < FItems.Count;
end;

constructor TUniCheckedItems.Create(const AItems: TUniListItems);
begin
  FItems := AItems;
end;

function TUniCheckedItems.GetEnumerator: TUniCheckedItemEnumerator;
begin
  Result := TUniCheckedItemEnumerator.Create(FItems);
end;

constructor TUniListItem.Create;
begin
  inherited;
  FData := TDictionary<string, TValue>.Create;
  SetBooleanField('enabled', True);
end;

destructor TUniListItem.Destroy;
begin
  FData.Free;
  inherited;
end;

function TUniListItem.NormalizeName(const AName: string): string;
begin
  Result := LowerCase(Trim(AName));
end;

procedure TUniListItem.Changed(const AFieldName: string);
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self, Self, NormalizeName(AFieldName));
end;

procedure TUniListItem.SetChecked(const Value: Boolean);
begin
  if Value then
    SetCheckState(ucsChecked)
  else
    SetCheckState(ucsUnchecked);
end;

function TUniListItem.GetChecked: Boolean;
begin
  Result := FCheckState = ucsChecked;
end;

procedure TUniListItem.SetCheckState(const Value: TUniCheckState);
begin
  if FCheckState = Value then
    Exit;
  FCheckState := Value;
  Changed('checked');
end;

function TUniListItem.GetFieldValue(const AName: string): TValue;
begin
  if not FData.TryGetValue(NormalizeName(AName), Result) then
    Result := TValue.Empty;
end;

procedure TUniListItem.SetFieldValue(const AName: string; const AValue: TValue);
var
  Key: string;
begin
  Key := NormalizeName(AName);
  if Key = '' then
    Exit;
  FData.AddOrSetValue(Key, AValue);
  Changed(Key);
end;

procedure TUniListItem.SetField(const AName: string; const AValue: TValue);
begin
  SetFieldValue(AName, AValue);
end;

procedure TUniListItem.SetField(const AName, AValue: string);
begin
  SetFieldValue(AName, TValue.From<string>(AValue));
end;

procedure TUniListItem.SetField(const AName: string; const AValue: Integer);
begin
  SetFieldValue(AName, TValue.From<Integer>(AValue));
end;

procedure TUniListItem.SetField(const AName: string; const AValue: Int64);
begin
  SetFieldValue(AName, TValue.From<Int64>(AValue));
end;

procedure TUniListItem.SetField(const AName: string; const AValue: Double);
begin
  SetFieldValue(AName, TValue.From<Double>(AValue));
end;

procedure TUniListItem.SetField(const AName: string; const AValue: Boolean);
begin
  SetFieldValue(AName, TValue.From<Boolean>(AValue));
end;

procedure TUniListItem.SetFieldDateTime(const AName: string; const AValue: TDateTime);
begin
  SetFieldValue(AName, TValue.From<TDateTime>(AValue));
end;

procedure TUniListItem.SetFieldColor(const AName: string; const AValue: TAlphaColor);
begin
  SetFieldValue(AName, TValue.From<TAlphaColor>(AValue));
end;

procedure TUniListItem.SetFieldObject(const AName: string; const AValue: TObject);
begin
  SetFieldValue(AName, TValue.From<TObject>(AValue));
end;

procedure TUniListItem.ClearField(const AName: string);
var
  Key: string;
begin
  Key := NormalizeName(AName);
  if FData.ContainsKey(Key) then
  begin
    FData.Remove(Key);
    Changed(Key);
  end;
end;

function TUniListItem.ContainsField(const AName: string): Boolean;
begin
  Result := FData.ContainsKey(NormalizeName(AName));
end;

function TUniListItem.FieldAsString(const AName, ADefault: string): string;
var
  Value: TValue;
begin
  Value := GetFieldValue(AName);
  if Value.IsEmpty then
    Exit(ADefault);
  try
    Result := Value.ToString;
  except
    Result := ADefault;
  end;
end;

function TUniListItem.FieldAsInteger(const AName: string;
  const ADefault: Integer): Integer;
var
  Value: TValue;
begin
  Value := GetFieldValue(AName);
  try
    if Value.IsType<Integer> then Exit(Value.AsInteger);
    Result := StrToIntDef(Value.ToString, ADefault);
  except Result := ADefault; end;
end;

function TUniListItem.FieldAsInt64(const AName: string;
  const ADefault: Int64): Int64;
var
  Value: TValue;
begin
  Value := GetFieldValue(AName);
  try
    if Value.IsType<Int64> then Exit(Value.AsInt64);
    Result := StrToInt64Def(Value.ToString, ADefault);
  except Result := ADefault; end;
end;

function TUniListItem.FieldAsFloat(const AName: string;
  const ADefault: Double): Double;
var
  Value: TValue;
begin
  Value := GetFieldValue(AName);
  try
    if Value.IsType<Double> then Exit(Value.AsType<Double>);
    Result := StrToFloatDef(Value.ToString, ADefault);
  except Result := ADefault; end;
end;

function TUniListItem.FieldAsBoolean(const AName: string;
  const ADefault: Boolean): Boolean;
var
  Value: TValue;
  S: string;
begin
  Value := GetFieldValue(AName);
  if Value.IsEmpty then Exit(ADefault);
  try
    if Value.IsType<Boolean> then Exit(Value.AsBoolean);
    S := LowerCase(Value.ToString);
    if (S = 'true') or (S = '1') or (S = 'yes') then Exit(True);
    if (S = 'false') or (S = '0') or (S = 'no') then Exit(False);
    Result := ADefault;
  except Result := ADefault; end;
end;

function TUniListItem.FieldAsDateTime(const AName: string;
  const ADefault: TDateTime): TDateTime;
var
  Value: TValue;
begin
  Value := GetFieldValue(AName);
  try
    if Value.IsType<TDateTime> then Exit(Value.AsType<TDateTime>);
    if not TryStrToDateTime(Value.ToString, Result) then Result := ADefault;
  except Result := ADefault; end;
end;

function TUniListItem.FieldAsColor(const AName: string;
  const ADefault: TAlphaColor): TAlphaColor;
var
  Value: TValue;
begin
  Value := GetFieldValue(AName);
  try
    if Value.IsType<TAlphaColor> then Exit(Value.AsType<TAlphaColor>);
    Result := TAlphaColor(StrToIntDef(Value.ToString, Integer(ADefault)));
  except Result := ADefault; end;
end;

function TUniListItem.FieldAsObject(const AName: string): TObject;
var
  Value: TValue;
begin
  Result := nil;
  Value := GetFieldValue(AName);
  if Value.Kind = tkClass then
    Result := Value.AsObject;
end;

function TUniListItem.GetStringField(const AName: string): string;
begin
  Result := FieldAsString(AName, '');
end;

procedure TUniListItem.SetStringField(const AName, AValue: string);
begin
  SetField(AName, AValue);
end;

function TUniListItem.GetBooleanField(const AName: string;
  const ADefault: Boolean): Boolean;
begin
  Result := FieldAsBoolean(AName, ADefault);
end;

procedure TUniListItem.SetBooleanField(const AName: string;
  const AValue: Boolean);
begin
  SetField(AName, AValue);
end;

function TUniListItem.GetID: string; begin Result := GetStringField('id'); end;
procedure TUniListItem.SetID(const Value: string); begin SetStringField('id', Value); end;
function TUniListItem.GetParentID: string; begin Result := GetStringField('parentid'); end;
procedure TUniListItem.SetParentID(const Value: string); begin SetStringField('parentid', Value); end;
function TUniListItem.GetTitle: string; begin Result := GetStringField('title'); end;
procedure TUniListItem.SetTitle(const Value: string); begin SetStringField('title', Value); end;
function TUniListItem.GetText: string; begin Result := GetStringField('text'); end;
procedure TUniListItem.SetText(const Value: string); begin SetStringField('text', Value); end;
function TUniListItem.GetDetail: string; begin Result := GetStringField('detail'); end;
procedure TUniListItem.SetDetail(const Value: string); begin SetStringField('detail', Value); end;
function TUniListItem.GetIconText: string; begin Result := GetStringField('icontext'); end;
procedure TUniListItem.SetIconText(const Value: string); begin SetStringField('icontext', Value); end;
function TUniListItem.GetEnabled: Boolean; begin Result := GetBooleanField('enabled', True); end;
procedure TUniListItem.SetEnabled(const Value: Boolean); begin SetBooleanField('enabled', Value); end;

procedure TUniListItem.SetValue(const AName: string; const AValue: Variant);
begin
  case VarType(AValue) of
    varBoolean: SetField(AName, Boolean(AValue));
    varByte, varSmallint, varInteger, varShortInt, varWord:
      SetField(AName, Integer(AValue));
    varLongWord, varInt64: SetField(AName, Int64(AValue));
    varSingle, varDouble, varCurrency: SetField(AName, Double(AValue));
  else
    SetField(AName, VarToStr(AValue));
  end;
end;

function TUniListItem.GetValue(const AName: string;
  const ADefault: Variant): Variant;
var
  Value: TValue;
begin
  Value := GetFieldValue(AName);
  if Value.IsEmpty then Exit(ADefault);
  try
    if Value.IsType<Boolean> then Exit(Value.AsBoolean);
    if Value.IsType<Integer> then Exit(Value.AsInteger);
    if Value.IsType<Int64> then Exit(Value.AsInt64);
    if Value.IsType<Double> then Exit(Value.AsType<Double>);
    Result := Value.ToString;
  except
    Result := ADefault;
  end;
end;

constructor TUniListItems.Create;
begin
  inherited;
  FItems := TObjectList<TUniListItem>.Create(True);
end;

destructor TUniListItems.Destroy;
begin
  FItems.Free;
  inherited;
end;

function TUniListItems.Add: TUniListItem;
begin
  Result := TUniListItem.Create;
  Result.OnChanged := ItemChanged;
  FItems.Add(Result);
  Changed;
end;

function TUniListItems.GetEnumerator: TEnumerator<TUniListItem>;
begin
  Result := FItems.GetEnumerator;
end;

function TUniListItems.IndexOf(AItem: TUniListItem): Integer;
begin
  Result := FItems.IndexOf(AItem);
end;

procedure TUniListItems.ItemChanged(Sender: TObject; AItem: TUniListItem;
  const AFieldName: string);
var
  ItemIndex: Integer;
begin
  if FUpdateCount > 0 then
  begin
    FChangedPending := True;
    Exit;
  end;

  ItemIndex := IndexOf(AItem);
  if Assigned(FOnItemChanged) and (ItemIndex >= 0) then
    FOnItemChanged(Self, ItemIndex, AFieldName);
end;

procedure TUniListItems.BeginUpdate;
begin Inc(FUpdateCount); end;

procedure TUniListItems.Changed;
begin
  if FUpdateCount > 0 then FChangedPending := True
  else if Assigned(FOnChanged) then FOnChanged(Self);
end;

procedure TUniListItems.Clear;
begin FItems.Clear; Changed; end;
procedure TUniListItems.Delete(Index: Integer);
begin FItems.Delete(Index); Changed; end;

procedure TUniListItems.EndUpdate;
begin
  if FUpdateCount = 0 then
    Exit;

  Dec(FUpdateCount);
  if FUpdateCount <> 0 then
    Exit;

  if FChangedPending then
  begin
    FChangedPending := False;
    Changed;
  end;
end;

function TUniListItems.GetCount: Integer;
begin Result := FItems.Count; end;
function TUniListItems.GetItem(Index: Integer): TUniListItem;
begin Result := FItems[Index]; end;

procedure TUniListItems.SortByField(const AFieldName: string;
  const AAscending: Boolean);
var
  FieldNames: TArray<string>;
  Ascending: TArray<Boolean>;
begin
  SetLength(FieldNames, 1);
  SetLength(Ascending, 1);
  FieldNames[0] := AFieldName;
  Ascending[0] := AAscending;
  SortByFields(FieldNames, Ascending);
end;

procedure TUniListItems.SortByFields(const AFieldNames: TArray<string>;
  const AAscending: TArray<Boolean>);
begin
  if (Length(AFieldNames) = 0) or
     (Length(AFieldNames) <> Length(AAscending)) then
    Exit;

  FItems.Sort(TComparer<TUniListItem>.Construct(
    function(const Left, Right: TUniListItem): Integer
    var
      FieldIndex: Integer;
      Direction: Integer;
      LeftText, RightText: string;
      LeftNumber, RightNumber: Double;
    begin
      Result := 0;
      for FieldIndex := 0 to High(AFieldNames) do
      begin
        LeftText := Left.FieldAsString(AFieldNames[FieldIndex], '');
        RightText := Right.FieldAsString(AFieldNames[FieldIndex], '');
        if TryStrToFloat(LeftText, LeftNumber) and
           TryStrToFloat(RightText, RightNumber) then
        begin
          if LeftNumber < RightNumber then
            Result := -1
          else if LeftNumber > RightNumber then
            Result := 1
          else
            Result := 0;
        end
        else
          Result := CompareText(LeftText, RightText);

        if Result <> 0 then
        begin
          Direction := 1;
          if not AAscending[FieldIndex] then
            Direction := -1;
          Result := Result * Direction;
          Exit;
        end;
      end;
    end));
  Changed;
end;

end.
