program UniListDemo;

uses
  System.StartUpCopy,
  FMX.Forms,
  FMX.Skia,
  MainUnit in 'MainUnit.pas' {MainForm},
  DesignPreviewDemo in 'DesignPreviewDemo.pas' {DesignPreviewForm},
  JsonStressDemo in 'JsonStressDemo.pas' {JsonStressForm},
  Demo.Json.StressGenerator in 'Demo.Json.StressGenerator.pas',
  UniList.Types in '..\src\UniList.Types.pas',
  UniList.Items in '..\src\UniList.Items.pas',
  UniList.Columns in '..\src\UniList.Columns.pas',
  UniList.Canvas in '..\src\UniList.Canvas.pas',
  UniList.Vector in '..\src\UniList.Vector.pas',
  UniList.Text in '..\src\UniList.Text.pas',
  UniList.Theme in '..\src\UniList.Theme.pas',
  UniList.Rules in '..\src\UniList.Rules.pas',
  UniList.Search in '..\src\UniList.Search.pas',
  UniList.Control in '..\src\UniList.Control.pas',
  UniList.Popup in '..\src\UniList.Popup.pas',
  UniList.DropDown in '..\src\UniList.DropDown.pas',
  UniList.Lookup in '..\src\UniList.Lookup.pas',
  UniList.Json.Adapter in '..\src\UniList.Json.Adapter.pas',
  UniList.Performance in '..\src\UniList.Performance.pas',
  UniList.Diagnostics in '..\src\UniList.Diagnostics.pas';

{$R *.res}

begin
  Randomize;
  GlobalUseSkia := True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
