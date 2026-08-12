unit Demo.Json.StressGenerator;

interface

type
  TJsonStressOptions = record
    RowCount: Integer;
    ColumnCount: Integer;
    IncludeNestedObjects: Boolean;
    IncludeUnicode: Boolean;
    IncludeRandomNulls: Boolean;
    IncludeDifferentFieldSets: Boolean;
    IncludeLargeText: Boolean;
    IncludeBooleanFields: Boolean;
    IncludeFloatingPointFields: Boolean;
    IncludeDateTimeStrings: Boolean;
    IncludeGuidStrings: Boolean;
    IncludeNestedArrays: Boolean;
  end;

  TJsonStressGenerator = class
  public
    class function Generate(const AOptions: TJsonStressOptions): string;
      static;
  end;

implementation

uses
  System.SysUtils, System.Classes, System.JSON, System.Math;

const
  CBaseFieldCount = 8;
  CNestedFieldCount = 5;
  CLargeTextFieldCount = 1;
  CLargeTextTargetBytes = 12 * 1024;
  CNullPercent = 10;
  CPercentBase = 100;
  CDifferentFieldModulo = 13;
  CUnicodeValueCount = 7;
  CLargeTextPart =
    'UniListView JSON stress payload: reactive rendering, search, cards, ' +
    'tree and virtualized scrolling. ';

function UnicodeValue(const AIndex: Integer): string;
begin
  case AIndex mod CUnicodeValueCount of
    0: Result := 'Русский текст';
    1: Result := 'O‘zbekcha matn';
    2: Result := 'Ўзбекча матн';
    3: Result := 'العربية';
    4: Result := '日本語';
    5: Result := '中文';
  else
    Result := 'Emoji 😊 🚀 ✅';
  end;
end;

function ShouldUseNull(const ARowIndex, AFieldIndex: Integer;
  const AOptions: TJsonStressOptions): Boolean;
begin
  Result := AOptions.IncludeRandomNulls and
    (((ARowIndex * 31) + (AFieldIndex * 17)) mod CPercentBase <
      CNullPercent);
end;

function ShouldSkipField(const ARowIndex, AFieldIndex: Integer;
  const AOptions: TJsonStressOptions): Boolean;
begin
  Result := AOptions.IncludeDifferentFieldSets and (ARowIndex > 0) and
    (((ARowIndex + AFieldIndex) mod CDifferentFieldModulo) = 0);
end;

procedure AddOptionalValue(const AObject: TJSONObject;
  const AName: string; const ARowIndex, AFieldIndex: Integer;
  const AOptions: TJsonStressOptions);
var
  ValueKind: Integer;
begin
  if ShouldSkipField(ARowIndex, AFieldIndex, AOptions) then
    Exit;
  if ShouldUseNull(ARowIndex, AFieldIndex, AOptions) then
  begin
    AObject.AddPair(AName, TJSONNull.Create);
    Exit;
  end;

  ValueKind := AFieldIndex mod 5;
  if (ValueKind = 0) and AOptions.IncludeBooleanFields then
    AObject.AddPair(AName, TJSONBool.Create(
      ((ARowIndex + AFieldIndex) mod 2) = 0))
  else if (ValueKind = 1) and AOptions.IncludeFloatingPointFields then
    AObject.AddPair(AName, TJSONNumber.Create(
      (ARowIndex * 0.125) + AFieldIndex))
  else if (ValueKind = 2) and AOptions.IncludeDateTimeStrings then
    AObject.AddPair(AName, Format('2026-01-%2.2dT12:%2.2d:00Z',
      [(ARowIndex mod 28) + 1, AFieldIndex mod 60]))
  else if (ValueKind = 3) and AOptions.IncludeGuidStrings then
    AObject.AddPair(AName,
      Format('{00000000-0000-0000-0000-%.12d}',
        [Int64(ARowIndex) * 1000 + AFieldIndex]))
  else if AOptions.IncludeUnicode then
    AObject.AddPair(AName, UnicodeValue(ARowIndex + AFieldIndex))
  else
    AObject.AddPair(AName, Format('value_%d_%d',
      [ARowIndex + 1, AFieldIndex + 1]));
end;

function BuildLargeText: string;
var
  Builder: TStringBuilder;
begin
  Builder := TStringBuilder.Create(CLargeTextTargetBytes);
  try
    while Builder.Length < CLargeTextTargetBytes do
      Builder.Append(CLargeTextPart);
    Result := Builder.ToString(0, CLargeTextTargetBytes);
  finally
    Builder.Free;
  end;
end;

procedure AddBaseFields(const AObject: TJSONObject;
  const ARowIndex: Integer; const AOptions: TJsonStressOptions);
var
  DisplayName: string;
begin
  if AOptions.IncludeUnicode then
    DisplayName := UnicodeValue(ARowIndex)
  else
    DisplayName := Format('Service %d', [ARowIndex + 1]);

  AObject.AddPair('id', TJSONNumber.Create(ARowIndex + 1));
  AObject.AddPair('code', Format('SRV-%.8d', [ARowIndex + 1]));
  AObject.AddPair('name', DisplayName);
  if ShouldUseNull(ARowIndex, 3, AOptions) then
    AObject.AddPair('description', TJSONNull.Create)
  else
    AObject.AddPair('description',
      Format('Generated stress row %d', [ARowIndex + 1]));

  if AOptions.IncludeBooleanFields then
    AObject.AddPair('active', TJSONBool.Create((ARowIndex mod 3) <> 0))
  else
    AObject.AddPair('active', BoolToStr((ARowIndex mod 3) <> 0, True));
  if AOptions.IncludeFloatingPointFields then
    AObject.AddPair('amount', TJSONNumber.Create(ARowIndex * 1.25))
  else
    AObject.AddPair('amount', FormatFloat('0.00', ARowIndex * 1.25));
  if AOptions.IncludeDateTimeStrings then
    AObject.AddPair('created_at', Format('2026-01-%2.2dT12:00:00Z',
      [(ARowIndex mod 28) + 1]))
  else
    AObject.AddPair('created_at', '');
  if AOptions.IncludeGuidStrings then
    AObject.AddPair('guid',
      Format('{00000000-0000-0000-0000-%.12d}', [ARowIndex + 1]))
  else
    AObject.AddPair('guid', '');
end;

procedure AddNestedFields(const AObject: TJSONObject);
var
  Address: TJSONObject;
  Profile: TJSONObject;
begin
  Address := TJSONObject.Create;
  Address.AddPair('country', 'Uzbekistan');
  Address.AddPair('city', 'Tashkent');
  Address.AddPair('district', 'Yunusabad');
  AObject.AddPair('address', Address);

  Profile := TJSONObject.Create;
  Profile.AddPair('department', 'DevOps');
  Profile.AddPair('role', 'Administrator');
  AObject.AddPair('profile', Profile);
end;

procedure AddNestedArray(const AObject: TJSONObject;
  const ARowIndex: Integer);
var
  Phones: TJSONArray;
begin
  Phones := TJSONArray.Create;
  Phones.Add(Format('+99890%.7d', [ARowIndex mod 10000000]));
  Phones.Add(Format('+99891%.7d', [ARowIndex mod 10000000]));
  AObject.AddPair('phones', Phones);
end;

class function TJsonStressGenerator.Generate(
  const AOptions: TJsonStressOptions): string;
var
  AdditionalFieldCount: Integer;
  Builder: TStringBuilder;
  FieldIndex: Integer;
  FixedFieldCount: Integer;
  LargeText: string;
  Meta: TJSONObject;
  Row: TJSONObject;
  RowIndex: Integer;
begin
  FixedFieldCount := CBaseFieldCount;
  if AOptions.IncludeNestedObjects then
    Inc(FixedFieldCount, CNestedFieldCount);
  if AOptions.IncludeLargeText then
    Inc(FixedFieldCount, CLargeTextFieldCount);
  AdditionalFieldCount := Max(0, AOptions.ColumnCount - FixedFieldCount);

  if AOptions.IncludeLargeText then
    LargeText := BuildLargeText
  else
    LargeText := '';

  Builder := TStringBuilder.Create;
  try
    Meta := TJSONObject.Create;
    try
      Meta.AddPair('generatedAt', '2026-01-01T12:00:00Z');
      Meta.AddPair('rowCount', TJSONNumber.Create(AOptions.RowCount));
      Meta.AddPair('columnCount', TJSONNumber.Create(AOptions.ColumnCount));
      Builder.Append('{"meta":');
      Builder.Append(Meta.ToJSON);
      Builder.Append(',"data":{"items":[');
    finally
      Meta.Free;
    end;

    for RowIndex := 0 to AOptions.RowCount - 1 do
    begin
      if RowIndex > 0 then
        Builder.Append(',');
      Row := TJSONObject.Create;
      try
        AddBaseFields(Row, RowIndex, AOptions);
        if AOptions.IncludeNestedObjects then
          AddNestedFields(Row);
        if AOptions.IncludeLargeText then
          Row.AddPair('large_text', LargeText);
        for FieldIndex := 0 to AdditionalFieldCount - 1 do
          AddOptionalValue(Row, Format('field_%.3d', [FieldIndex + 1]),
            RowIndex, FieldIndex, AOptions);
        if AOptions.IncludeNestedArrays then
          AddNestedArray(Row, RowIndex);
        Builder.Append(Row.ToJSON);
      finally
        Row.Free;
      end;
    end;

    Builder.Append(']}}');
    Result := Builder.ToString;
  finally
    Builder.Free;
  end;
end;

end.
