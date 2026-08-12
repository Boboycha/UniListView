unit Benchmark.PaintBox.Frame;

interface

uses
  System.Classes, FMX.Graphics, System.Types,
  Benchmark.Base.Frame;

type
  TBenchmarkPaintBoxFrame = class(TBenchmarkBaseFrame)
  protected
    function WorkloadText: string; override;
  end;

implementation

{$R *.fmx}

function TBenchmarkPaintBoxFrame.WorkloadText: string;
begin
  Result := 'One TPaintBox Align=Client, OnPaint does no drawing';
end;

end.
