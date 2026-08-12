unit Benchmark.Empty.Frame;

interface

uses
  System.Classes, Benchmark.Base.Frame;

type
  TBenchmarkEmptyFrame = class(TBenchmarkBaseFrame)
  protected
    function WorkloadText: string; override;
  end;

implementation

{$R *.fmx}

function TBenchmarkEmptyFrame.WorkloadText: string;
begin
  Result := 'TForm + TLayout + lightweight sampler only';
end;

end.
