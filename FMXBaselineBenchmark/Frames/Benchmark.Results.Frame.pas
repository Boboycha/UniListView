unit Benchmark.Results.Frame;

interface

uses
  System.Classes, FMX.Controls, FMX.Forms, FMX.Memo;

type
  TBenchmarkResultsFrame = class(TFrame)
  private
    FMemo: TMemo;
  public
    constructor Create(AOwner: TComponent); override;
    procedure SetText(const AText: string);
  end;

implementation

{$R *.fmx}

uses
  FMX.Types;

constructor TBenchmarkResultsFrame.Create(AOwner: TComponent);
begin
  inherited;
  Align := TAlignLayout.Client;
  FMemo := TMemo.Create(Self);
  FMemo.Parent := Self;
  FMemo.Align := TAlignLayout.Client;
  FMemo.ReadOnly := True;
end;

procedure TBenchmarkResultsFrame.SetText(const AText: string);
begin
  FMemo.Text := AText;
end;

end.
