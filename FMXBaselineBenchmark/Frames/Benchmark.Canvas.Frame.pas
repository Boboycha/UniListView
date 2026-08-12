unit Benchmark.Canvas.Frame;

interface

uses
  System.Classes, System.Types, System.UITypes,
  FMX.Types, FMX.Graphics, Benchmark.Base.Frame, Benchmark.Profiler;

type
  TBenchmarkCanvasMode = (bcmFillRect, bcmText, bcmBitmap, bcmCombined);

  TBenchmarkCanvasFrame = class(TBenchmarkBaseFrame)
  private
    FMode: TBenchmarkCanvasMode;
    FOperationCount: Integer;
    FBitmap: TBitmap;
  protected
    procedure PaintWorkload(Canvas: TCanvas; const ARect: TRectF); override;
    function WorkloadText: string; override;
  public
    constructor CreateBenchmark(AOwner: TComponent;
      const AProfiler: TBenchmarkProfiler); override;
    destructor Destroy; override;
    procedure Configure(const AMode: TBenchmarkCanvasMode;
      const AOperationCount: Integer);
  end;

implementation

{$R *.fmx}

uses
  System.SysUtils;

constructor TBenchmarkCanvasFrame.CreateBenchmark(AOwner: TComponent;
  const AProfiler: TBenchmarkProfiler);
begin
  inherited;
  FMode := bcmFillRect;
  FOperationCount := 100;
  FBitmap := TBitmap.Create(32, 32);
  FBitmap.Canvas.BeginScene;
  try
    FBitmap.Canvas.Clear(TAlphaColors.Cornflowerblue);
    FBitmap.Canvas.Fill.Color := TAlphaColors.Orange;
    FBitmap.Canvas.FillRect(RectF(6, 6, 26, 26), 4, 4, [], 1);
  finally
    FBitmap.Canvas.EndScene;
  end;
end;

destructor TBenchmarkCanvasFrame.Destroy;
begin
  FBitmap.Free;
  inherited;
end;

procedure TBenchmarkCanvasFrame.Configure(const AMode: TBenchmarkCanvasMode;
  const AOperationCount: Integer);
begin
  FMode := AMode;
  FOperationCount := AOperationCount;
end;

function TBenchmarkCanvasFrame.WorkloadText: string;
begin
  case FMode of
    bcmFillRect: Result := Format('%d Canvas FillRect', [FOperationCount]);
    bcmText: Result := Format('%d Canvas FillText', [FOperationCount]);
    bcmBitmap: Result := Format('%d Canvas DrawBitmap', [FOperationCount]);
    bcmCombined: Result := 'Combined PaintBox: card-like rectangles, icons, text and separators';
  else
    Result := 'Canvas workload';
  end;
end;

procedure TBenchmarkCanvasFrame.PaintWorkload(Canvas: TCanvas;
  const ARect: TRectF);
var
  Index, XIndex, YIndex: Integer;
  R: TRectF;
  TextValue: string;
begin
  case FMode of
    bcmFillRect:
      begin
        Canvas.Fill.Color := TAlphaColors.Steelblue;
        for Index := 0 to FOperationCount - 1 do
        begin
          XIndex := Index mod 40;
          YIndex := Index div 40;
          R := RectF(8 + XIndex * 24, 8 + YIndex * 18,
            28 + XIndex * 24, 22 + YIndex * 18);
          Canvas.FillRect(R, 2, 2, [], 1);
        end;
      end;
    bcmText:
      begin
        Canvas.Fill.Color := TAlphaColors.Black;
        Canvas.Font.Size := 12;
        TextValue := 'FMX baseline text sample';
        for Index := 0 to FOperationCount - 1 do
        begin
          XIndex := Index mod 30;
          YIndex := Index div 30;
          R := RectF(8 + XIndex * 120, 8 + YIndex * 22,
            124 + XIndex * 120, 28 + YIndex * 22);
          Canvas.FillText(R, TextValue, False, 1, [], TTextAlign.Leading,
            TTextAlign.Center);
        end;
      end;
    bcmBitmap:
      for Index := 0 to FOperationCount - 1 do
      begin
        XIndex := Index mod 30;
        YIndex := Index div 30;
        R := RectF(8 + XIndex * 38, 8 + YIndex * 38,
          40 + XIndex * 38, 40 + YIndex * 38);
        Canvas.DrawBitmap(FBitmap, RectF(0, 0, FBitmap.Width, FBitmap.Height),
          R, 1);
      end;
    bcmCombined:
      begin
        Canvas.Font.Size := 12;
        for Index := 0 to 99 do
        begin
          XIndex := Index mod 5;
          YIndex := Index div 5;
          R := RectF(12 + XIndex * 210, 12 + YIndex * 92,
            202 + XIndex * 210, 88 + YIndex * 92);
          Canvas.Fill.Color := TAlphaColors.White;
          Canvas.FillRect(R, 4, 4, [], 1);
          Canvas.Stroke.Color := TAlphaColors.Gray;
          Canvas.DrawRect(R, 4, 4, [], 1);
          Canvas.Fill.Color := TAlphaColors.Dodgerblue;
          Canvas.FillRect(RectF(R.Left + 8, R.Top + 8, R.Left + 30,
            R.Top + 30), 3, 3, [], 1);
          Canvas.Fill.Color := TAlphaColors.Black;
          Canvas.FillText(RectF(R.Left + 40, R.Top + 8, R.Right - 8,
            R.Top + 25), 'Card title', False, 1, [], TTextAlign.Leading,
            TTextAlign.Center);
          Canvas.Fill.Color := TAlphaColors.Dimgray;
          Canvas.FillText(RectF(R.Left + 40, R.Top + 30, R.Right - 8,
            R.Top + 47), 'Subtitle text', False, 1, [], TTextAlign.Leading,
            TTextAlign.Center);
          Canvas.FillText(RectF(R.Left + 8, R.Top + 54, R.Right - 8,
            R.Top + 72), 'Detail line', False, 1, [], TTextAlign.Leading,
            TTextAlign.Center);
        end;
      end;
  end;
end;

end.
