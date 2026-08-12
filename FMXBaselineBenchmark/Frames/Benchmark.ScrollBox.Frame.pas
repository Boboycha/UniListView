unit Benchmark.ScrollBox.Frame;

interface

uses
  System.Classes, System.Types, System.UITypes, FMX.Types, FMX.Controls,
  FMX.Layouts, FMX.StdCtrls, FMX.Objects, Benchmark.Base.Frame;

type
  TBenchmarkScrollBoxFrame = class(TBenchmarkBaseFrame)
  private
    FCardCount: Integer;
    FScrollBox: TVertScrollBox;
  protected
    procedure BuildContent; override;
    function WorkloadText: string; override;
    function VisibleWorkloadText: string; override;
  public
    procedure Configure(const ACardCount: Integer);
  end;

implementation

{$R *.fmx}

uses
  System.SysUtils, Benchmark.Profiler;

procedure TBenchmarkScrollBoxFrame.Configure(const ACardCount: Integer);
begin
  FCardCount := ACardCount;
end;

procedure TBenchmarkScrollBoxFrame.BuildContent;
var
  Index: Integer;
  CardRect, ImageRect: TRectangle;
  LabelControl: TLabel;
  StartTicks: Int64;
begin
  inherited;
  if FScrollBox <> nil then
    FreeAndNil(FScrollBox);
  StartTicks := BenchmarkNowTicks;
  FScrollBox := TVertScrollBox.Create(Self);
  FScrollBox.Parent := Self;
  FScrollBox.Align := TAlignLayout.Client;
  for Index := 0 to FCardCount - 1 do
  begin
    CardRect := TRectangle.Create(Self);
    CardRect.Parent := FScrollBox;
    CardRect.Position.X := 12;
    CardRect.Position.Y := 12 + Index * 86;
    CardRect.Width := 520;
    CardRect.Height := 74;
    CardRect.Fill.Color := TAlphaColors.White;
    CardRect.Stroke.Color := TAlphaColors.Gray;
    ImageRect := TRectangle.Create(Self);
    ImageRect.Parent := CardRect;
    ImageRect.Position.X := 8;
    ImageRect.Position.Y := 8;
    ImageRect.Width := 28;
    ImageRect.Height := 28;
    ImageRect.Fill.Color := TAlphaColors.Dodgerblue;
    LabelControl := TLabel.Create(Self);
    LabelControl.Parent := CardRect;
    LabelControl.Position.X := 44;
    LabelControl.Position.Y := 6;
    LabelControl.Width := 440;
    LabelControl.Height := 18;
    LabelControl.Text := 'Scroll card ' + IntToStr(Index + 1);
    LabelControl := TLabel.Create(Self);
    LabelControl.Parent := CardRect;
    LabelControl.Position.X := 44;
    LabelControl.Position.Y := 28;
    LabelControl.Width := 440;
    LabelControl.Height := 18;
    LabelControl.Text := 'Subtitle';
    LabelControl := TLabel.Create(Self);
    LabelControl.Parent := CardRect;
    LabelControl.Position.X := 8;
    LabelControl.Position.Y := 52;
    LabelControl.Width := 480;
    LabelControl.Height := 18;
    LabelControl.Text := 'Detail line';
  end;
  if TagObject is TBenchmarkProfiler then
    TBenchmarkProfiler(TagObject).AddLoadMs(
      BenchmarkTicksToMs(BenchmarkNowTicks - StartTicks));
end;

function TBenchmarkScrollBoxFrame.WorkloadText: string;
begin
  Result := Format('TVertScrollBox with %d control cards', [FCardCount]);
end;

function TBenchmarkScrollBoxFrame.VisibleWorkloadText: string;
begin
  Result := 'visible cards depend on window height';
end;

end.
