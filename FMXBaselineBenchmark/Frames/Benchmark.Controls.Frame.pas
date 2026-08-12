unit Benchmark.Controls.Frame;

interface

uses
  System.Classes, System.Diagnostics, System.Types, System.UITypes,
  FMX.Types, FMX.Controls, FMX.Layouts, FMX.StdCtrls, FMX.Objects,
  Benchmark.Base.Frame, Benchmark.Profiler;

type
  TBenchmarkControlsMode = (bcmLabels, bcmRectangles, bcmCards);

  TBenchmarkControlsFrame = class(TBenchmarkBaseFrame)
  private
    FMode: TBenchmarkControlsMode;
    FControlCount: Integer;
  protected
    procedure BuildContent; override;
    function WorkloadText: string; override;
    function VisibleWorkloadText: string; override;
  public
    procedure Configure(const AMode: TBenchmarkControlsMode;
      const AControlCount: Integer);
  end;

implementation

{$R *.fmx}

uses
  System.SysUtils;

procedure TBenchmarkControlsFrame.Configure(const AMode: TBenchmarkControlsMode;
  const AControlCount: Integer);
begin
  FMode := AMode;
  FControlCount := AControlCount;
end;

procedure TBenchmarkControlsFrame.BuildContent;
var
  Index, XIndex, YIndex: Integer;
  LabelControl: TLabel;
  RectControl, CardRect: TRectangle;
  ImageRect: TRectangle;
  StartTicks: Int64;
begin
  inherited;
  while ChildrenCount > 1 do
    Children[ChildrenCount - 1].Free;
  StartTicks := BenchmarkNowTicks;
  case FMode of
    bcmLabels:
      for Index := 0 to FControlCount - 1 do
      begin
        XIndex := Index mod 20;
        YIndex := Index div 20;
        LabelControl := TLabel.Create(Self);
        LabelControl.Parent := Self;
        LabelControl.Position.X := 8 + XIndex * 92;
        LabelControl.Position.Y := 8 + YIndex * 24;
        LabelControl.Width := 88;
        LabelControl.Height := 20;
        LabelControl.Text := 'Label ' + IntToStr(Index + 1);
      end;
    bcmRectangles:
      for Index := 0 to FControlCount - 1 do
      begin
        XIndex := Index mod 30;
        YIndex := Index div 30;
        RectControl := TRectangle.Create(Self);
        RectControl.Parent := Self;
        RectControl.Position.X := 8 + XIndex * 36;
        RectControl.Position.Y := 8 + YIndex * 26;
        RectControl.Width := 30;
        RectControl.Height := 20;
        RectControl.Fill.Color := TAlphaColors.Steelblue;
      end;
    bcmCards:
      for Index := 0 to FControlCount - 1 do
      begin
        XIndex := Index mod 5;
        YIndex := Index div 5;
        CardRect := TRectangle.Create(Self);
        CardRect.Parent := Self;
        CardRect.Position.X := 10 + XIndex * 210;
        CardRect.Position.Y := 10 + YIndex * 94;
        CardRect.Width := 190;
        CardRect.Height := 76;
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
        LabelControl.Width := 130;
        LabelControl.Height := 18;
        LabelControl.Text := 'Card title';
        LabelControl := TLabel.Create(Self);
        LabelControl.Parent := CardRect;
        LabelControl.Position.X := 44;
        LabelControl.Position.Y := 28;
        LabelControl.Width := 130;
        LabelControl.Height := 18;
        LabelControl.Text := 'Subtitle';
        LabelControl := TLabel.Create(Self);
        LabelControl.Parent := CardRect;
        LabelControl.Position.X := 8;
        LabelControl.Position.Y := 52;
        LabelControl.Width := 166;
        LabelControl.Height := 18;
        LabelControl.Text := 'Detail line';
      end;
  end;
  if Assigned(Owner) and (Owner is TComponent) then
    ;
  if TagObject is TBenchmarkProfiler then
    TBenchmarkProfiler(TagObject).AddLoadMs(
      BenchmarkTicksToMs(BenchmarkNowTicks - StartTicks));
end;

function TBenchmarkControlsFrame.WorkloadText: string;
begin
  case FMode of
    bcmLabels: Result := Format('%d TLabel controls', [FControlCount]);
    bcmRectangles: Result := Format('%d TRectangle controls', [FControlCount]);
    bcmCards: Result := Format('%d mixed cards: TRectangle + image rectangle + 3 labels', [FControlCount]);
  else
    Result := 'Standard controls';
  end;
end;

function TBenchmarkControlsFrame.VisibleWorkloadText: string;
begin
  Result := WorkloadText;
end;

end.
