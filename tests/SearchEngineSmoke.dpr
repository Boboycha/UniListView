program SearchEngineSmoke;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.StartUpCopy,
  FMX.Forms,
  UniList.Items in '..\src\UniList.Items.pas',
  UniList.Search in '..\src\UniList.Search.pas';

procedure Require(const ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

var
  Items: TUniListItems;
  Engine: TUniSearchEngine;
  VisibleFields: TArray<string>;
  FilteredIndices: TArray<Integer>;
begin
  Application.Initialize;
  Items := TUniListItems.Create;
  Engine := TUniSearchEngine.Create;
  try
    Items.Add.SetField('name', 'First item');
    Items[0].SetField('secret', 'alpha-hidden');
    Items.Add.SetField('name', 'PostgreSQL Production');
    Items[1].SetField('secret', 'beta-hidden');

    VisibleFields := TArray<string>.Create('name');
    FilteredIndices := TArray<Integer>.Create(1);
    Engine.Configure(Items, VisibleFields, FilteredIndices);

    Engine.SearchText := 'postgresql';
    Require(Engine.MatchCount = 1,
      'Visible-field search did not find PostgreSQL');
    Require(Engine.CurrentItemIndex = 1,
      'Visible-field search selected the wrong item');

    Engine.Options := Engine.Options - [soVisibleColumnsOnly];
    Engine.SearchText := 'beta-hidden';
    Require(Engine.MatchCount = 1,
      'Hidden scalar-field search did not find beta-hidden');

    Engine.SearchText := 'first item';
    Require(Engine.MatchCount = 0,
      'Filtered search included an item outside the filter');

    Engine.Options := Engine.Options - [soRespectFilters];
    Require(Engine.MatchCount = 1,
      'Unfiltered search did not include the first item');

    Writeln('SearchEngineSmoke: PASS');
  finally
    Engine.Free;
    Items.Free;
  end;
end.
