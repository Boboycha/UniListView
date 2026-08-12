unit UniList.Vector;

interface

uses
  System.Types, System.UITypes, System.Math,
  Skia,
  UniList.Types;

procedure DrawVectorIcon(const ACanvas: ISkCanvas; const AIcon: TUniVectorIcon;
  const R: TRectF; const AColor: TAlphaColor; const AStrokeWidth: Single = 1.7);

implementation

procedure DrawVectorIcon(const ACanvas: ISkCanvas; const AIcon: TUniVectorIcon;
  const R: TRectF; const AColor: TAlphaColor; const AStrokeWidth: Single);
var
  P: ISkPaint;
  C: TPointF;
  S, L, T, B, M: Single;
  I: Integer;
begin
  if AIcon = uviNone then
    Exit;

  P := TSkPaint.Create;
  P.AntiAlias := True;
  P.Color := AColor;
  P.Style := TSkPaintStyle.Stroke;
  P.StrokeWidth := AStrokeWidth;
  P.StrokeCap := TSkStrokeCap.Round;
  P.StrokeJoin := TSkStrokeJoin.Round;

  C := R.CenterPoint;
  S := Min(R.Width, R.Height);
  L := C.X - S * 0.34;
  T := C.Y - S * 0.34;
  B := C.Y + S * 0.34;
  M := C.X + S * 0.34;

  case AIcon of
    uviEdit:
      begin
        (* Тонкие штрихи на 16-18px не читались как карандаш - переходим
           на заливку: сплошной скруглённый корпус + треугольный носик,
           весь рисунок повёрнут на -45° вокруг центра, чтобы получить
           карандаш, направленный в верхне-правый угол. *)
        ACanvas.Save;
        try
          ACanvas.Rotate(-45, C.X, C.Y);
          P.Style := TSkPaintStyle.Fill;
          ACanvas.DrawRoundRect(RectF(C.X - S * 0.32, C.Y - S * 0.08,
            C.X + S * 0.14, C.Y + S * 0.08), S * 0.03, S * 0.03, P);
          P.Style := TSkPaintStyle.Stroke;
          ACanvas.DrawLine(PointF(C.X + S * 0.14, C.Y - S * 0.08),
            PointF(C.X + S * 0.28, C.Y), P);
          ACanvas.DrawLine(PointF(C.X + S * 0.14, C.Y + S * 0.08),
            PointF(C.X + S * 0.28, C.Y), P);
          ACanvas.DrawLine(PointF(C.X + S * 0.14, C.Y - S * 0.08),
            PointF(C.X + S * 0.14, C.Y + S * 0.08), P);
        finally
          ACanvas.Restore;
        end;
      end;
    uviDelete:
      begin
        (* Ручка - капсула, крышка - линия, корпус - скруглённый
           прямоугольник; тот же язык, что uviServer/uviOpen. Прежний
           вариант из 7 отдельных штрихов (стенки+рёбра) сливался в
           нечитаемое пятно на маленьком размере. *)
        ACanvas.DrawRoundRect(RectF(C.X - S * 0.12, T + S * 0.02,
          C.X + S * 0.12, T + S * 0.14), S * 0.05, S * 0.05, P);
        ACanvas.DrawLine(PointF(L + S * 0.06, T + S * 0.18),
          PointF(M - S * 0.06, T + S * 0.18), P);
        ACanvas.DrawRoundRect(RectF(L + S * 0.12, T + S * 0.18,
          M - S * 0.12, B - S * 0.04), S * 0.07, S * 0.07, P);
      end;
    uviOpen:
      begin
        ACanvas.DrawRoundRect(RectF(L + S * 0.04, T + S * 0.20,
          M - S * 0.15, B - S * 0.04), S * 0.08, S * 0.08, P);
        ACanvas.DrawLine(PointF(C.X, T + S * 0.06),
          PointF(M - S * 0.04, T + S * 0.06), P);
        ACanvas.DrawLine(PointF(M - S * 0.04, T + S * 0.06),
          PointF(M - S * 0.04, C.Y), P);
        ACanvas.DrawLine(PointF(M - S * 0.04, T + S * 0.06),
          PointF(C.X - S * 0.02, C.Y + S * 0.02), P);
      end;
    uviMore:
      begin
        P.Style := TSkPaintStyle.Fill;
        for I := -1 to 1 do
          ACanvas.DrawCircle(C.X + I * S * 0.23, C.Y, S * 0.055, P);
      end;
    uviServer:
      begin
        ACanvas.DrawRoundRect(RectF(L + S * 0.08, T + S * 0.12,
          M - S * 0.08, B - S * 0.08), S * 0.08, S * 0.08, P);
        ACanvas.DrawLine(PointF(C.X, B - S * 0.08),
          PointF(C.X, B + S * 0.05), P);
        ACanvas.DrawLine(PointF(C.X - S * 0.18, B + S * 0.05),
          PointF(C.X + S * 0.18, B + S * 0.05), P);
      end;
    uviCheck:
      begin
        ACanvas.DrawLine(PointF(L + S * 0.08, C.Y),
          PointF(C.X - S * 0.06, B - S * 0.10), P);
        ACanvas.DrawLine(PointF(C.X - S * 0.06, B - S * 0.10),
          PointF(M - S * 0.03, T + S * 0.10), P);
      end;
    uviDatabase:
      begin
        ACanvas.DrawOval(RectF(L + S * 0.08, T + S * 0.10,
          M - S * 0.08, T + S * 0.32), P);
        ACanvas.DrawLine(PointF(L + S * 0.08, T + S * 0.21),
          PointF(L + S * 0.08, B - S * 0.16), P);
        ACanvas.DrawLine(PointF(M - S * 0.08, T + S * 0.21),
          PointF(M - S * 0.08, B - S * 0.16), P);
        ACanvas.DrawArc(RectF(L + S * 0.08, C.Y - S * 0.10,
          M - S * 0.08, C.Y + S * 0.12), 0, 180, False, P);
        ACanvas.DrawArc(RectF(L + S * 0.08, B - S * 0.28,
          M - S * 0.08, B - S * 0.06), 0, 180, False, P);
      end;
    uviChevronRight:
      begin
        ACanvas.DrawLine(PointF(C.X - S * 0.12, T + S * 0.10),
          PointF(C.X + S * 0.12, C.Y), P);
        ACanvas.DrawLine(PointF(C.X + S * 0.12, C.Y),
          PointF(C.X - S * 0.12, B - S * 0.10), P);
      end;
    uviChevronLeft:
      begin
        ACanvas.DrawLine(PointF(C.X + S * 0.12, T + S * 0.10),
          PointF(C.X - S * 0.12, C.Y), P);
        ACanvas.DrawLine(PointF(C.X - S * 0.12, C.Y),
          PointF(C.X + S * 0.12, B - S * 0.10), P);
      end;
    uviChevronDown:
      begin
        ACanvas.DrawLine(PointF(L + S * 0.10, C.Y - S * 0.10),
          PointF(C.X, C.Y + S * 0.12), P);
        ACanvas.DrawLine(PointF(C.X, C.Y + S * 0.12),
          PointF(M - S * 0.10, C.Y - S * 0.10), P);
      end;
    uviChevronUp:
      begin
        ACanvas.DrawLine(PointF(L + S * 0.10, C.Y + S * 0.10),
          PointF(C.X, C.Y - S * 0.12), P);
        ACanvas.DrawLine(PointF(C.X, C.Y - S * 0.12),
          PointF(M - S * 0.10, C.Y + S * 0.10), P);
      end;
  end;
end;

end.
