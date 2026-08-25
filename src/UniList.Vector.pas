unit UniList.Vector;

interface

uses
  System.Types, System.UITypes, System.Math, System.Math.Vectors,
  UniList.Canvas,
  UniList.Types;

procedure DrawVectorIcon(const ACanvas: IUniCanvas; const AIcon: TUniVectorIcon;
  const R: TRectF; const AColor: TAlphaColor; const AStrokeWidth: Single = 1.7);

implementation

procedure DrawVectorIcon(const ACanvas: IUniCanvas; const AIcon: TUniVectorIcon;
  const R: TRectF; const AColor: TAlphaColor; const AStrokeWidth: Single);
var
  P: IUniPaint;
  C: TPointF;
  S, L, T, B, M, A, OuterRadius, InnerRadius: Single;
  I: Integer;
  StarPoints: TPolygon;
begin
  if AIcon = uviNone then
    Exit;

  P := TUniPaintFactory.Create;
  P.AntiAlias := True;
  P.Color := AColor;
  P.Style := TUniPaintStyle.Stroke;
  P.StrokeWidth := AStrokeWidth;
  P.StrokeCap := TUniStrokeCap.Round;
  P.StrokeJoin := TUniStrokeJoin.Round;

  C := R.CenterPoint;
  S := Min(R.Width, R.Height);
  L := C.X - S * 0.34;
  T := C.Y - S * 0.34;
  B := C.Y + S * 0.34;
  M := C.X + S * 0.34;

  case AIcon of
    uviEdit:
      begin
        (* Match the outline pencil used by nbFmxDocking header actions. *)
        P.StrokeWidth := Max(1, AStrokeWidth * 0.72);
        SetLength(StarPoints, 5);
        StarPoints[0] := PointF(C.X - S * 0.3125, C.Y + S * 0.3125);
        StarPoints[1] := PointF(C.X - S * 0.1375, C.Y + S * 0.2792);
        StarPoints[2] := PointF(C.X + S * 0.2917, C.Y - S * 0.1500);
        StarPoints[3] := PointF(C.X + S * 0.1500, C.Y - S * 0.2917);
        StarPoints[4] := PointF(C.X - S * 0.2792, C.Y + S * 0.1375);
        ACanvas.DrawPolygon(StarPoints, P);
        ACanvas.DrawLine(
          PointF(C.X + S * 0.1125, C.Y - S * 0.2542),
          PointF(C.X + S * 0.2542, C.Y - S * 0.1125), P);
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
        P.Style := TUniPaintStyle.Fill;
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
    uviStar, uviStarFilled:
      begin
        SetLength(StarPoints, 10);
        OuterRadius := S * 0.34;
        InnerRadius := OuterRadius * 0.45;
        for I := 0 to High(StarPoints) do
        begin
          A := -Pi * 0.5 + I * Pi / 5;
          if Odd(I) then
            StarPoints[I] := PointF(C.X + Cos(A) * InnerRadius,
              C.Y + Sin(A) * InnerRadius)
          else
            StarPoints[I] := PointF(C.X + Cos(A) * OuterRadius,
              C.Y + Sin(A) * OuterRadius);
        end;
        if AIcon = uviStarFilled then
          P.Style := TUniPaintStyle.Fill;
        ACanvas.DrawPolygon(StarPoints, P);
      end;    uviDatabase:
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
