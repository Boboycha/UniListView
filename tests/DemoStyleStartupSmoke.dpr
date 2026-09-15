program DemoStyleStartupSmoke;

{$APPTYPE CONSOLE}

uses
  System.SysUtils, System.Classes, FMX.Forms, FMX.Skia,
  MainUnit in '..\demo\MainUnit.pas',
  JsonStressDemo in '..\demo\JsonStressDemo.pas',
  Demo.Json.StressGenerator in '..\demo\Demo.Json.StressGenerator.pas';

begin
  try
    GlobalUseSkia := True;
    Application.Initialize;
    MainForm := TMainForm.Create(Application);
    Writeln('Created');
    MainForm.Show;
    Application.ProcessMessages;
    Writeln('Shown');
    MainForm.Free;
    Writeln('DemoStyleStartupSmoke OK');
  except
    on E: Exception do
    begin
      Writeln(E.ClassName, ': ', E.Message, ' at ', IntToHex(NativeUInt(ExceptAddr), 8));
      ExitCode := 1;
    end;
  end;
end.
