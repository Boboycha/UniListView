program UniListPlayground;

uses
  System.StartUpCopy,
  FMX.Forms,
  MainUnit in 'MainUnit.pas' {MainForm},
  UniList.Control in '..\src\UniList.Control.pas',
  UniList.Types in '..\src\UniList.Types.pas',
  UniList.Items in '..\src\UniList.Items.pas',
  UniList.Columns in '..\src\UniList.Columns.pas',
  UniList.Vector in '..\src\UniList.Vector.pas',
  UniList.Text in '..\src\UniList.Text.pas',
  UniList.Theme in '..\src\UniList.Theme.pas',
  UniList.Rules in '..\src\UniList.Rules.pas',
  UniList.Search in '..\src\UniList.Search.pas',
  UniList.Performance in '..\src\UniList.Performance.pas';

{$R *.res}

begin
  Randomize;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
