program JsonAdapterCoreSmoke;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.Classes,
  System.Math,
  System.StartUpCopy,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  UniList.Types in '..\src\UniList.Types.pas',
  UniList.Items in '..\src\UniList.Items.pas',
  UniList.Vector in '..\src\UniList.Vector.pas',
  UniList.Text in '..\src\UniList.Text.pas',
  UniList.Columns in '..\src\UniList.Columns.pas',
  UniList.Theme in '..\src\UniList.Theme.pas',
  UniList.Rules in '..\src\UniList.Rules.pas',
  UniList.Search in '..\src\UniList.Search.pas',
  UniList.Control in '..\src\UniList.Control.pas',
  UniList.Json.Adapter in '..\src\UniList.Json.Adapter.pas';

procedure Require(const ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

procedure RequireAdapterError(const AAdapter: TUniJsonDataAdapter;
  const AJson: string; const AMessage: string);
begin
  try
    AAdapter.LoadFromString(AJson);
  except
    on EUniJsonAdapter do
      Exit;
  end;
  raise Exception.Create(AMessage);
end;

function HasColumn(const AListView: TUniListView;
  const AFieldName: string): Boolean;
var
  Index: Integer;
begin
  for Index := 0 to AListView.Columns.Count - 1 do
    if SameText(AListView.Columns[Index].FieldName, AFieldName) then
      Exit(True);
  Result := False;
end;

var
  Adapter: TUniJsonDataAdapter;
  Bytes: TBytes;
  Column: TUniListColumn;
  ColumnCountBeforeReload: Integer;
  ItemCountBeforeError: Integer;
  ListView: TUniListView;
  Stream: TBytesStream;

begin
  try
    Adapter := nil;
    ListView := nil;
    try
      Adapter := TUniJsonDataAdapter.Create(nil);
      ListView := TUniListView.Create(nil);
      Adapter.ListView := ListView;
      Require(Adapter.AutoCreateColumns, 'AutoCreateColumns default is invalid');
      Require(Adapter.ClearBeforeLoad, 'ClearBeforeLoad default is invalid');
      Require(not Adapter.AutoBestFit, 'AutoBestFit default is invalid');

    Adapter.LoadFromString(
      '[{"id":1,"name":"John","active":true,"score":1.5,' +
      '"empty":null,"address":{"city":"London"},' +
      '"phones":["100","200"]}]');
    Require(ListView.Items.Count = 1, 'Root array was not loaded');
    Require(ListView.Items[0].FieldAsInt64('id') = 1,
      'Integer value was not retained');
    Require(ListView.Items[0].FieldAsBoolean('active'),
      'Boolean value was not retained');
    Require(SameValue(ListView.Items[0].FieldAsFloat('score'), 1.5),
      'Floating-point value was not retained');
    Require(ListView.Items[0].FieldAsString('address.city') = 'London',
      'Nested object was not flattened');
    Require(not ListView.Items[0].ContainsField('phones'),
      'Nested array field must be skipped');
    Require(HasColumn(ListView, 'address.city'),
      'Flattened column was not created');

    ColumnCountBeforeReload := ListView.Columns.Count;
    Adapter.LoadFromString('[{"id":2,"name":"Jane"}]');
    Require(ListView.Items.Count = 1, 'ClearBeforeLoad was ignored');
    Require(ListView.Columns.Count = ColumnCountBeforeReload,
      'Repeated load created duplicate columns');

    Adapter.RootPath := 'payload.response';
    Adapter.ArrayPath := 'records';
    Adapter.LoadFromString(
      '{"payload":{"response":{"records":[{"id":3,"name":"RootPath"}]}}}');
    Require(ListView.Items[0].FieldAsString('name') = 'RootPath',
      'RootPath and ArrayPath did not work together');

    Adapter.RootPath := '';
    Adapter.ArrayPath := 'result.items';
    Adapter.LoadFromString(
      '{"result":{"items":[{"id":4,"name":"ArrayPath"}]}}');
    Require(ListView.Items[0].FieldAsString('name') = 'ArrayPath',
      'Nested ArrayPath was not resolved');

    Adapter.ClearBeforeLoad := False;
    Adapter.LoadFromString('{"result":{"items":[{"id":5}]}}');
    Require(ListView.Items.Count = 2, 'Append mode cleared existing rows');
    Adapter.ClearBeforeLoad := True;

    ItemCountBeforeError := ListView.Items.Count;
    RequireAdapterError(Adapter, '{"result":', 'Invalid JSON was accepted');
    Require(ListView.Items.Count = ItemCountBeforeError,
      'Invalid JSON changed existing rows');
    Adapter.ArrayPath := 'missing.items';
    RequireAdapterError(Adapter, '{"result":{}}',
      'Invalid path was accepted');
    Require(ListView.Items.Count = ItemCountBeforeError,
      'Invalid path changed existing rows');

    Adapter.ArrayPath := '';
    Adapter.LoadFromString('[]');
    Require(ListView.Items.Count = 0, 'Empty array was not accepted');

    ListView.Columns.Clear;
    Column := ListView.Columns.Add;
    Column.FieldName := 'name';
    Column.Caption := 'Name';
    Adapter.AutoCreateColumns := False;
    Adapter.LoadFromString('[{"name":"Kept","extra":"Ignored"}]');
    Require(ListView.Columns.Count = 1,
      'AutoCreateColumns=False changed columns');
    Require(ListView.Items[0].ContainsField('name') and
      not ListView.Items[0].ContainsField('extra'),
      'AutoCreateColumns=False retained an unknown field');

    Adapter.AutoCreateColumns := True;
    Bytes := TEncoding.UTF8.GetBytes('[{"name":"Ташкент"}]');
    Adapter.LoadFromBytes(Bytes);
    Require(ListView.Items[0].FieldAsString('name') = 'Ташкент',
      'UTF-8 bytes were decoded incorrectly');

    Stream := TBytesStream.Create(
      TEncoding.UTF8.GetBytes('[{"name":"Stream"}]'));
    try
      Adapter.LoadFromStream(Stream);
      Require(Stream.Position = Stream.Size,
        'LoadFromStream did not consume the input stream');
      Require(ListView.Items[0].FieldAsString('name') = 'Stream',
        'Stream JSON was not loaded');
    finally
      Stream.Free;
    end;

    Adapter.Clear;
    Require((ListView.Items.Count = 0) and (ListView.Columns.Count > 0),
      'Clear removed columns or retained rows');

    ListView.Free;
    ListView := nil;
    Require(Adapter.ListView = nil,
      'FreeNotification did not clear ListView');

      Writeln('JsonAdapterCoreSmoke: PASS');
    finally
      ListView.Free;
      Adapter.Free;
    end;
  except
    on E: Exception do
    begin
      Writeln(E.ClassName + ': ' + E.Message);
      ExitCode := 1;
    end;
  end;
end.
