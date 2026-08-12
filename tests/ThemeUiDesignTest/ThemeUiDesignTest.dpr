program ThemeUiDesignTest;

uses
  System.StartUpCopy,
  FMX.Forms,
  ThemeUiDesignTest.MainForm in 'ThemeUiDesignTest.MainForm.pas' {ThemeUiDesignTestForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TThemeUiDesignTestForm, ThemeUiDesignTestForm);
  Application.Run;
end.
