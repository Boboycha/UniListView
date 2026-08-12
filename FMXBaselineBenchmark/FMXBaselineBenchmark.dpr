program FMXBaselineBenchmark;

uses
  System.StartUpCopy,
  System.SysUtils, System.IOUtils,
  FMX.Forms,
  Benchmark.Types in 'Benchmark.Types.pas',
  Benchmark.Profiler in 'Benchmark.Profiler.pas',
  Benchmark.Base.Frame in 'Frames\Benchmark.Base.Frame.pas',
  Benchmark.Empty.Frame in 'Frames\Benchmark.Empty.Frame.pas',
  Benchmark.PaintBox.Frame in 'Frames\Benchmark.PaintBox.Frame.pas',
  Benchmark.Canvas.Frame in 'Frames\Benchmark.Canvas.Frame.pas',
  Benchmark.Controls.Frame in 'Frames\Benchmark.Controls.Frame.pas',
  Benchmark.ScrollBox.Frame in 'Frames\Benchmark.ScrollBox.Frame.pas',
  Benchmark.ListView.Frame in 'Frames\Benchmark.ListView.Frame.pas',
  Benchmark.UniListView.Frame in 'Frames\Benchmark.UniListView.Frame.pas',
  Benchmark.Results.Frame in 'Frames\Benchmark.Results.Frame.pas',
  Benchmark.MainForm in 'Benchmark.MainForm.pas';

{$R *.res}

begin
  Application.Initialize;
  try
    Application.CreateForm(TBenchmarkMainForm, BenchmarkMainForm);
    Application.Run;
  except
    on E: Exception do
    begin
      TFile.WriteAllText(ChangeFileExt(ParamStr(0), '.startup-error.txt'),
        E.ClassName + ': ' + E.Message, TEncoding.UTF8);
      raise;
    end;
  end;
end.
