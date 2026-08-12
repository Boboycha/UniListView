program ActionVisibilitySmoke;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  UniList.Types in '..\src\UniList.Types.pas',
  UniList.Items in '..\src\UniList.Items.pas',
  UniList.Vector in '..\src\UniList.Vector.pas',
  UniList.Text in '..\src\UniList.Text.pas',
  UniList.Columns in '..\src\UniList.Columns.pas',
  UniList.Theme in '..\src\UniList.Theme.pas',
  UniList.Rules in '..\src\UniList.Rules.pas',
  UniList.Search in '..\src\UniList.Search.pas',
  UniList.Control in '..\src\UniList.Control.pas';

var
  LayoutJSON: string;
  ListView: TUniListView;

begin
  ListView := TUniListView.Create(nil);
  try
    if ListView.ActionVisibility <> uavAlways then
      raise Exception.Create('Default ActionVisibility must be uavAlways');
    ListView.ActionVisibility := uavOnHover;
    LayoutJSON := ListView.SaveLayoutToJSON;
    if Pos('"actionVisibility": "onHover"', LayoutJSON) = 0 then
      raise Exception.Create('ActionVisibility was not saved');
    ListView.ActionVisibility := uavAlways;
    ListView.LoadLayoutFromJSON(LayoutJSON);
    if ListView.ActionVisibility <> uavOnHover then
      raise Exception.Create('ActionVisibility was not restored');
  finally
    ListView.Free;
  end;
end.
