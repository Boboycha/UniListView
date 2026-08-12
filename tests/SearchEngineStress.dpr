program SearchEngineStress;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.Diagnostics,
  System.StartUpCopy,
  FMX.Forms,
  UniList.Items in '..\src\UniList.Items.pas',
  UniList.Search in '..\src\UniList.Search.pas';

const
  ITEM_COUNT = 30000;

procedure WaitForSearch(const AEngine: TUniSearchEngine);
begin
  while AEngine.Running do
    Application.ProcessMessages;
end;

procedure RunSearch(const AEngine: TUniSearchEngine; const AQuery: string;
  const AExpectedCount: Integer);
var
  Stopwatch: TStopwatch;
begin
  Stopwatch := TStopwatch.StartNew;
  AEngine.SearchText := AQuery;
  WaitForSearch(AEngine);
  Stopwatch.Stop;
  if AEngine.MatchCount <> AExpectedCount then
    raise Exception.CreateFmt('%s: expected %d matches, got %d',
      [AQuery, AExpectedCount, AEngine.MatchCount]);
  Writeln(Format('%-12s %6d matches  %6d ms',
    [AQuery, AEngine.MatchCount, Stopwatch.ElapsedMilliseconds]));
end;

var
  Engine: TUniSearchEngine;
  FilteredIndices: TArray<Integer>;
  ItemIndex: Integer;
  Items: TUniListItems;
  PopulateStopwatch: TStopwatch;
  VisibleFields: TArray<string>;
begin
  Application.Initialize;
  Items := TUniListItems.Create;
  Engine := TUniSearchEngine.Create;
  try
    PopulateStopwatch := TStopwatch.StartNew;
    Items.BeginUpdate;
    try
      for ItemIndex := 0 to ITEM_COUNT - 1 do
      begin
        Items.Add.SetField('name', Format('Service %.5d', [ItemIndex]));
        Items[ItemIndex].SetField('description',
          Format('Stress record %.5d for UniListView', [ItemIndex]));
      end;
      Items[ITEM_COUNT - 1].SetField('name', 'Needle Service 29999');
    finally
      Items.EndUpdate;
    end;
    PopulateStopwatch.Stop;

    SetLength(FilteredIndices, ITEM_COUNT);
    for ItemIndex := 0 to ITEM_COUNT - 1 do
      FilteredIndices[ItemIndex] := ItemIndex;
    VisibleFields := TArray<string>.Create('name', 'description');
    Engine.Configure(Items, VisibleFields, FilteredIndices);

    Writeln(Format('Populate      %6d items    %6d ms',
      [ITEM_COUNT, PopulateStopwatch.ElapsedMilliseconds]));
    RunSearch(Engine, 'needle', 1);
    RunSearch(Engine, 'service', ITEM_COUNT);
    RunSearch(Engine, 'not-found-value', 0);
    Writeln('SearchEngineStress: PASS');
  finally
    Engine.Free;
    Items.Free;
  end;
end.
