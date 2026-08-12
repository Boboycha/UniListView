program DesignPreviewSmoke;

uses
  System.SysUtils,
  FMX.Forms,
  FMX.Skia,
  Data.DB,
  UniList.Types in '..\src\UniList.Types.pas',
  UniList.Items in '..\src\UniList.Items.pas',
  UniList.Columns in '..\src\UniList.Columns.pas',
  UniList.Vector in '..\src\UniList.Vector.pas',
  UniList.Text in '..\src\UniList.Text.pas',
  UniList.Theme in '..\src\UniList.Theme.pas',
  UniList.Rules in '..\src\UniList.Rules.pas',
  UniList.Search in '..\src\UniList.Search.pas',
  UniList.Control in '..\src\UniList.Control.pas';

var
  ListView: TUniListView;
  Source: TDataSource;

begin
  GlobalUseSkia := True;
  ListView := TUniListView.Create(nil);
  Source := TDataSource.Create(nil);
  try
    if ListView.DesignPreviewMode <> dpmSampleData then
      raise Exception.Create('Invalid DesignPreviewMode default');
    if ListView.DesignPreviewRows <> 8 then
      raise Exception.Create('Invalid DesignPreviewRows default');
    if ListView.Items.Count <> 0 then
      raise Exception.Create('Design preview leaked into runtime');
    ListView.FontFamily := 'Segoe UI';
    ListView.CardSizingMode := ucsmAutoByTitle;
    ListView.FontSize := 13;
    ListView.TitleFontSize := 17;
    ListView.DetailFontSize := 11;
    ListView.DataSource := Source;
    ListView.DesignPreviewMode := dpmConnectedData;
    if ListView.Items.Count <> 0 then
      raise Exception.Create('Connected preview leaked into runtime');
  finally
    ListView.Free;
    Source.Free;
  end;
end.
