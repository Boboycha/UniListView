program UniPopupPerformanceLab;

uses
  System.StartUpCopy,
  FMX.Forms,
  PopupPerf.Metrics in 'PopupPerf.Metrics.pas',
  PopupPerf.Diagnostics in 'PopupPerf.Diagnostics.pas',
  UniList.Diagnostics in '..\src\UniList.Diagnostics.pas',
  PopupPerf.AutomaticRunner in 'PopupPerf.AutomaticRunner.pas',
  PopupPerf.TestContent in 'PopupPerf.TestContent.pas',
  PopupPerf.MainForm in 'PopupPerf.MainForm.pas' {PopupPerfMainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TPopupPerfMainForm, PopupPerfMainForm);
  Application.Run;
end.