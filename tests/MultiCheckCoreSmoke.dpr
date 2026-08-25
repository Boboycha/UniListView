program MultiCheckCoreSmoke;

{$APPTYPE CONSOLE}

uses
  System.Classes,
  System.SysUtils,
  System.StartUpCopy,
  FMX.Forms,
  UniList.Types in '..\src\UniList.Types.pas',
  UniList.Items in '..\src\UniList.Items.pas',
  UniList.Canvas in '..\src\UniList.Canvas.pas',
  UniList.Vector in '..\src\UniList.Vector.pas',
  UniList.Performance in '..\src\UniList.Performance.pas',
  UniList.Diagnostics in '..\src\UniList.Diagnostics.pas',
  UniList.Text in '..\src\UniList.Text.pas',
  UniList.Columns in '..\src\UniList.Columns.pas',
  UniList.Theme in '..\src\UniList.Theme.pas',
  UniList.Rules in '..\src\UniList.Rules.pas',
  UniList.Search in '..\src\UniList.Search.pas',
  UniList.Control in '..\src\UniList.Control.pas';

procedure Require(const ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

procedure CheckStreamedCollections;
var
  Source: TUniListView;
  Stream: TMemoryStream;
  Target: TUniListView;
begin
  Source := TUniListView.Create(nil);
  Target := TUniListView.Create(nil);
  Stream := TMemoryStream.Create;
  try
    Source.Columns.Clear;
    with Source.Columns.Add do
    begin
      FieldName := 'name';
      Caption := 'Name';
      WidthMode := ucwmFill;
    end;
    Source.Actions.Clear;
    with Source.Actions.Add do
      Name := 'edit';

    Require(Target.Columns.Count = 3,
      'The constructor defaults needed by the streaming test are missing');
    Require(Target.Actions.Count = 2,
      'The constructor actions needed by the streaming test are missing');

    Stream.WriteComponent(Source);
    Stream.Position := 0;
    Stream.ReadComponent(Target);

    Require(Target.Columns.Count = 1,
      'Streamed columns were appended to constructor defaults');
    Require(Target.Actions.Count = 1,
      'Streamed actions were appended to constructor defaults');
    Require(Target.Columns[0].FieldName = 'name',
      'The streamed column was not restored');
  finally
    Stream.Free;
    Target.Free;
    Source.Free;
  end;
end;

procedure Run;
var
  CheckedItem: TUniListItem;
  CheckedItemsCount: Integer;
  Item: TUniListItem;
  ItemIndex: Integer;
  ListView: TUniListView;
begin
  Application.Initialize;
  CheckStreamedCollections;
  ListView := TUniListView.Create(nil);
  try
    ListView.MultiCheck := True;
    ListView.BeginUpdate;
    try
      for ItemIndex := 1 to 10 do
      begin
        Item := ListView.AddItem(Format('Service %d', [ItemIndex]), '', '');
        Item.ID := IntToStr(ItemIndex);
        Item.SetField('name', Item.Title);
      end;
    finally
      ListView.EndUpdate;
    end;

    ListView.CheckAll(ucsVisibleItems);
    Require(ListView.CheckedCount = 10,
      'Check visible without a filter did not check every item');

    ListView.UncheckAll;
    Require(ListView.CheckedCount = 0,
      'Uncheck all did not clear every item');

    ListView.SearchText := 'Service 1';
    Require(ListView.SearchMatchCount = 2,
      'Search did not produce the expected visible result');
    ListView.CheckAll(ucsVisibleItems);
    Require(ListView.CheckedCount = 2,
      'Check visible did not use the search result');
    ListView.UncheckAll(ucsVisibleItems);
    Require(ListView.CheckedCount = 0,
      'Uncheck visible did not use the search result');
    ListView.InvertChecks(ucsVisibleItems);
    Require(ListView.CheckedCount = 2,
      'Invert visible did not use the search result');

    CheckedItemsCount := 0;
    for CheckedItem in ListView.CheckedItems do
      Inc(CheckedItemsCount);
    Require(CheckedItemsCount = 2,
      'CheckedItems returned an invalid count');

    ListView.ClearSearch;
    ListView.UncheckAll;
    Require(ListView.CheckedCount = 0,
      'Uncheck all after search did not clear hidden items');

    Writeln('MultiCheckCoreSmoke: PASS');
  finally
    ListView.Free;
  end;
end;

begin
  try
    Run;
  except
    on Error: Exception do
    begin
      Writeln(Error.ClassName + ': ' + Error.Message);
      Halt(1);
    end;
  end;
end.
