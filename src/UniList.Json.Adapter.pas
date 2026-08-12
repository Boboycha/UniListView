unit UniList.Json.Adapter;

interface

uses
  System.SysUtils, System.Classes,
  UniList.Control;

type
  EUniJsonAdapter = class(Exception);

  TUniJsonDataAdapter = class(TComponent)
  private
    FListView: TUniListView;
    FRootPath: string;
    FArrayPath: string;
    FAutoCreateColumns: Boolean;
    FClearBeforeLoad: Boolean;
    FAutoBestFit: Boolean;
    procedure SetListView(const Value: TUniListView);
  protected
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure LoadFromString(const AJson: string);
    procedure LoadFromStream(const AStream: TStream);
    procedure LoadFromBytes(const ABytes: TBytes);
    procedure Clear;
  published
    property ListView: TUniListView read FListView write SetListView;
    property RootPath: string read FRootPath write FRootPath;
    property ArrayPath: string read FArrayPath write FArrayPath;
    property AutoCreateColumns: Boolean read FAutoCreateColumns
      write FAutoCreateColumns default True;
    property ClearBeforeLoad: Boolean read FClearBeforeLoad
      write FClearBeforeLoad default True;
    property AutoBestFit: Boolean read FAutoBestFit write FAutoBestFit
      default False;
  end;

procedure Register;

implementation

uses
  System.JSON, System.Generics.Collections, System.Generics.Defaults,
  UniList.Items, UniList.Columns;

const
  CStreamBufferSize = 8192;
  CUtf8BomSize = 3;
  CUtf8BomByte0 = $EF;
  CUtf8BomByte1 = $BB;
  CUtf8BomByte2 = $BF;

type
  TUniJsonScalarKind = (ujskString, ujskInteger, ujskFloat, ujskBoolean,
    ujskNull);

  TUniJsonPreparedField = record
    Name: string;
    Kind: TUniJsonScalarKind;
    StringValue: string;
    IntegerValue: Int64;
    FloatValue: Double;
    BooleanValue: Boolean;
  end;

  TUniJsonPreparedRow = class
  private
    FFields: TList<TUniJsonPreparedField>;
    FFieldNames: TDictionary<string, Byte>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddField(const AField: TUniJsonPreparedField);
    property Fields: TList<TUniJsonPreparedField> read FFields;
  end;

  TUniJsonPreparedData = class
  private
    FRows: TObjectList<TUniJsonPreparedRow>;
    FFieldNames: TList<string>;
    FKnownFieldNames: TDictionary<string, Byte>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddFieldName(const AName: string);
    property Rows: TObjectList<TUniJsonPreparedRow> read FRows;
    property FieldNames: TList<string> read FFieldNames;
  end;

constructor TUniJsonPreparedRow.Create;
begin
  inherited;
  FFields := TList<TUniJsonPreparedField>.Create;
  FFieldNames := TDictionary<string, Byte>.Create(
    TIStringComparer.Ordinal);
end;

destructor TUniJsonPreparedRow.Destroy;
begin
  FFieldNames.Free;
  FFields.Free;
  inherited;
end;

procedure TUniJsonPreparedRow.AddField(
  const AField: TUniJsonPreparedField);
begin
  if FFieldNames.ContainsKey(AField.Name) then
    raise EUniJsonAdapter.CreateFmt(
      'JSON record contains duplicate flattened field "%s".',
      [AField.Name]);
  FFieldNames.Add(AField.Name, 0);
  FFields.Add(AField);
end;

constructor TUniJsonPreparedData.Create;
begin
  inherited;
  FRows := TObjectList<TUniJsonPreparedRow>.Create(True);
  FFieldNames := TList<string>.Create;
  FKnownFieldNames := TDictionary<string, Byte>.Create(
    TIStringComparer.Ordinal);
end;

destructor TUniJsonPreparedData.Destroy;
begin
  FKnownFieldNames.Free;
  FFieldNames.Free;
  FRows.Free;
  inherited;
end;

procedure TUniJsonPreparedData.AddFieldName(const AName: string);
begin
  if FKnownFieldNames.ContainsKey(AName) then
    Exit;
  FKnownFieldNames.Add(AName, 0);
  FFieldNames.Add(AName);
end;

function CombinedPath(const ABasePath, ARelativePath: string): string;
begin
  if ABasePath = '' then
    Exit(ARelativePath);
  if ARelativePath = '' then
    Exit(ABasePath);
  Result := ABasePath + '.' + ARelativePath;
end;

function ResolvePath(const AStart: TJSONValue; const APath,
  AFullPath: string): TJSONValue;
var
  Current: TJSONValue;
  Segment: string;
  Segments: TArray<string>;
begin
  if APath = '' then
    Exit(AStart);

  Current := AStart;
  Segments := APath.Split(['.']);
  for Segment in Segments do
  begin
    if Segment = '' then
      raise EUniJsonAdapter.CreateFmt('Invalid JSON path "%s".',
        [AFullPath]);
    if not (Current is TJSONObject) then
      raise EUniJsonAdapter.CreateFmt(
        'JSON path "%s" cannot be resolved through a non-object node.',
        [AFullPath]);
    Current := TJSONObject(Current).GetValue(Segment);
    if Current = nil then
      raise EUniJsonAdapter.CreateFmt('JSON path "%s" was not found.',
        [AFullPath]);
  end;
  Result := Current;
end;

procedure AddScalarField(const AName: string; const AValue: TJSONValue;
  const ARow: TUniJsonPreparedRow;
  const AData: TUniJsonPreparedData);
var
  Field: TUniJsonPreparedField;
  NumberText: string;
begin
  Field := Default(TUniJsonPreparedField);
  Field.Name := AName;

  if AValue is TJSONNumber then
  begin
    NumberText := TJSONNumber(AValue).Value;
    if TryStrToInt64(NumberText, Field.IntegerValue) then
      Field.Kind := ujskInteger
    else
    begin
      Field.Kind := ujskFloat;
      Field.FloatValue := TJSONNumber(AValue).AsDouble;
    end;
  end
  else if AValue is TJSONString then
  begin
    Field.Kind := ujskString;
    Field.StringValue := TJSONString(AValue).Value;
  end
  else if AValue is TJSONBool then
  begin
    Field.Kind := ujskBoolean;
    Field.BooleanValue := TJSONBool(AValue).AsBoolean;
  end
  else if AValue is TJSONNull then
    Field.Kind := ujskNull
  else
    raise EUniJsonAdapter.CreateFmt(
      'JSON field "%s" has an unsupported scalar value.', [AName]);

  ARow.AddField(Field);
  AData.AddFieldName(AName);
end;

procedure FlattenObject(const AObject: TJSONObject; const APrefix: string;
  const ARow: TUniJsonPreparedRow;
  const AData: TUniJsonPreparedData);
var
  FieldName: string;
  Pair: TJSONPair;
begin
  for Pair in AObject do
  begin
    if Pair.JsonString.Value = '' then
      raise EUniJsonAdapter.Create(
        'JSON record contains an empty field name.');
    FieldName := Pair.JsonString.Value;
    if APrefix <> '' then
      FieldName := APrefix + '.' + FieldName;

    if Pair.JsonValue is TJSONObject then
      FlattenObject(TJSONObject(Pair.JsonValue), FieldName, ARow, AData)
    else if Pair.JsonValue is TJSONArray then
      { Core Patch deliberately skips nested array fields. }
      Continue
    else
      AddScalarField(FieldName, Pair.JsonValue, ARow, AData);
  end;
end;

function PrepareData(const ARoot: TJSONValue; const ARootPath,
  AArrayPath: string): TUniJsonPreparedData;
var
  ArrayNode: TJSONValue;
  FullArrayPath: string;
  Index: Integer;
  RootNode: TJSONValue;
  Row: TUniJsonPreparedRow;
begin
  RootNode := ResolvePath(ARoot, ARootPath, ARootPath);
  FullArrayPath := CombinedPath(ARootPath, AArrayPath);
  ArrayNode := ResolvePath(RootNode, AArrayPath, FullArrayPath);
  if not (ArrayNode is TJSONArray) then
  begin
    if FullArrayPath = '' then
      FullArrayPath := '<root>';
    raise EUniJsonAdapter.CreateFmt(
      'JSON node at "%s" is not an array of records.', [FullArrayPath]);
  end;

  Result := TUniJsonPreparedData.Create;
  try
    for Index := 0 to TJSONArray(ArrayNode).Count - 1 do
    begin
      if not (TJSONArray(ArrayNode).Items[Index] is TJSONObject) then
        raise EUniJsonAdapter.CreateFmt(
          'JSON record at index %d is not an object.', [Index]);
      Row := TUniJsonPreparedRow.Create;
      Result.Rows.Add(Row);
      FlattenObject(TJSONObject(TJSONArray(ArrayNode).Items[Index]), '',
        Row, Result);
    end;
  except
    Result.Free;
    raise;
  end;
end;

constructor TUniJsonDataAdapter.Create(AOwner: TComponent);
begin
  inherited;
  FAutoCreateColumns := True;
  FClearBeforeLoad := True;
  FAutoBestFit := False;
end;

procedure TUniJsonDataAdapter.SetListView(const Value: TUniListView);
begin
  if FListView = Value then
    Exit;
  if FListView <> nil then
    FListView.RemoveFreeNotification(Self);
  FListView := Value;
  if FListView <> nil then
    FListView.FreeNotification(Self);
end;

procedure TUniJsonDataAdapter.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FListView) then
    FListView := nil;
end;

function ColumnExists(const AColumns: TUniListColumns;
  const AFieldName: string): Boolean;
var
  Index: Integer;
begin
  for Index := 0 to AColumns.Count - 1 do
    if SameText(AColumns[Index].FieldName, AFieldName) then
      Exit(True);
  Result := False;
end;

procedure SetItemField(const AItem: TUniListItem;
  const AField: TUniJsonPreparedField);
begin
  if SameText(AField.Name, 'checked') and
     (AField.Kind = ujskBoolean) then
  begin
    AItem.Checked := AField.BooleanValue;
    Exit;
  end;
  case AField.Kind of
    ujskString:
      AItem.SetField(AField.Name, AField.StringValue);
    ujskInteger:
      AItem.SetField(AField.Name, AField.IntegerValue);
    ujskFloat:
      AItem.SetField(AField.Name, AField.FloatValue);
    ujskBoolean:
      AItem.SetField(AField.Name, AField.BooleanValue);
    ujskNull:
      AItem.SetField(AField.Name, '');
  end;
end;

procedure TUniJsonDataAdapter.LoadFromString(const AJson: string);
var
  Column: TUniListColumn;
  AllowedFieldNames: TDictionary<string, Byte>;
  ColumnIndex: Integer;
  Field: TUniJsonPreparedField;
  FieldName: string;
  Item: TUniListItem;
  JsonText: string;
  Prepared: TUniJsonPreparedData;
  Root: TJSONValue;
  Row: TUniJsonPreparedRow;
begin
  if FListView = nil then
    raise EUniJsonAdapter.Create('ListView is not assigned.');

  JsonText := AJson;
  if (JsonText <> '') and (JsonText[1] = #$FEFF) then
    Delete(JsonText, 1, 1);
  if Trim(JsonText) = '' then
    raise EUniJsonAdapter.Create('JSON input is empty.');

  try
    Root := TJSONValue.ParseJSONValue(JsonText, True, True);
  except
    on E: Exception do
      raise EUniJsonAdapter.CreateFmt('Invalid JSON: %s', [E.Message]);
  end;
  if Root = nil then
    raise EUniJsonAdapter.Create('Invalid JSON.');

  try
    Prepared := PrepareData(Root, FRootPath, FArrayPath);
    try
      AllowedFieldNames := TDictionary<string, Byte>.Create(
        TIStringComparer.Ordinal);
      try
        if not FAutoCreateColumns then
          for ColumnIndex := 0 to FListView.Columns.Count - 1 do
            AllowedFieldNames.AddOrSetValue(
              FListView.Columns[ColumnIndex].FieldName, 0);

        FListView.BeginUpdate;
        try
          FListView.Columns.BeginUpdate;
          try
            if FAutoCreateColumns then
              for FieldName in Prepared.FieldNames do
                if not ColumnExists(FListView.Columns, FieldName) then
                begin
                  Column := FListView.Columns.Add;
                  Column.FieldName := FieldName;
                  Column.Caption := FieldName;
                end;
          finally
            FListView.Columns.EndUpdate;
          end;

          if FClearBeforeLoad then
            FListView.Clear;
          for Row in Prepared.Rows do
          begin
            Item := FListView.Items.Add;
            for Field in Row.Fields do
              if FAutoCreateColumns or
                 AllowedFieldNames.ContainsKey(Field.Name) then
                SetItemField(Item, Field);
          end;
        finally
          FListView.EndUpdate;
        end;
      finally
        AllowedFieldNames.Free;
      end;
      if FAutoBestFit then
        FListView.AutoFitAllColumns;
    finally
      Prepared.Free;
    end;
  finally
    Root.Free;
  end;
end;

procedure TUniJsonDataAdapter.LoadFromStream(const AStream: TStream);
var
  Buffer: array[0..CStreamBufferSize - 1] of Byte;
  Bytes: TBytes;
  Memory: TMemoryStream;
  ReadCount: Integer;
begin
  if AStream = nil then
    raise EUniJsonAdapter.Create('Stream is not assigned.');

  Memory := TMemoryStream.Create;
  try
    repeat
      ReadCount := AStream.Read(Buffer, SizeOf(Buffer));
      if ReadCount > 0 then
        Memory.WriteBuffer(Buffer, ReadCount);
    until ReadCount = 0;
    SetLength(Bytes, Memory.Size);
    if Length(Bytes) > 0 then
    begin
      Memory.Position := 0;
      Memory.ReadBuffer(Bytes[0], Length(Bytes));
    end;
  finally
    Memory.Free;
  end;
  LoadFromBytes(Bytes);
end;

procedure TUniJsonDataAdapter.LoadFromBytes(const ABytes: TBytes);
var
  ByteCount: Integer;
  ByteOffset: Integer;
  Encoding: TUTF8Encoding;
  Json: string;
begin
  ByteOffset := 0;
  if (Length(ABytes) >= CUtf8BomSize) and
     (ABytes[0] = CUtf8BomByte0) and
     (ABytes[1] = CUtf8BomByte1) and
     (ABytes[2] = CUtf8BomByte2) then
    ByteOffset := CUtf8BomSize;
  ByteCount := Length(ABytes) - ByteOffset;

  Encoding := TUTF8Encoding.Create(False);
  try
    if (ByteCount > 0) and
       not Encoding.IsBufferValid(@ABytes[ByteOffset], ByteCount) then
      raise EUniJsonAdapter.Create('Invalid UTF-8 JSON.');
    Json := Encoding.GetString(ABytes, ByteOffset, ByteCount);
  finally
    Encoding.Free;
  end;
  LoadFromString(Json);
end;

procedure TUniJsonDataAdapter.Clear;
begin
  if FListView = nil then
    raise EUniJsonAdapter.Create('ListView is not assigned.');
  FListView.Clear;
end;

procedure Register;
begin
  RegisterComponents('UniListView', [TUniJsonDataAdapter]);
end;

end.
