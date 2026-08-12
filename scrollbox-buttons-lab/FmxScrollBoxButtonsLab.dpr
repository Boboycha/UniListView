program FmxScrollBoxButtonsLab;

uses
  System.StartUpCopy,
  FMX.Forms,
  FMX.Skia,
  MainFormUnit in 'MainFormUnit.pas' {MainForm};

{$R *.res}

begin
  GlobalUseSkia := True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
