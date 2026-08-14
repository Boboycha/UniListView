unit UniList.Canvas;

{$SCOPEDENUMS ON}

interface

uses
  System.Classes, System.Types, System.UITypes, System.Math,
  System.Math.Vectors, System.Generics.Collections,
  FMX.Types, FMX.Graphics, FMX.TextLayout;

type
  TUniPaintStyle = (Fill, Stroke);
  TUniStrokeCap = (Butt, Round, Square);
  TUniStrokeJoin = (Miter, Round, Bevel);

  TUniFontStyle = record
  public
    class function Normal: TUniFontStyle; static;
  end;

  IUniTypeface = interface
    ['{22E79515-24F8-4233-9861-15B092132BAF}']
    function GetFamily: string;
    property Family: string read GetFamily;
  end;

  IUniFont = interface
    ['{7E32B581-9A7D-4428-8957-FBFD943676B6}']
    function GetFamily: string;
    function GetSize: Single;
    function MeasureText(const AText: string): Single;
    property Family: string read GetFamily;
    property Size: Single read GetSize;
  end;

  IUniPaint = interface
    ['{1DBED2C2-2E0C-44C1-A474-DC97D03FCFC9}']
    function GetAntiAlias: Boolean;
    function GetColor: TAlphaColor;
    function GetStyle: TUniPaintStyle;
    function GetStrokeWidth: Single;
    function GetStrokeCap: TUniStrokeCap;
    function GetStrokeJoin: TUniStrokeJoin;
    procedure SetAntiAlias(const AValue: Boolean);
    procedure SetColor(const AValue: TAlphaColor);
    procedure SetStyle(const AValue: TUniPaintStyle);
    procedure SetStrokeWidth(const AValue: Single);
    procedure SetStrokeCap(const AValue: TUniStrokeCap);
    procedure SetStrokeJoin(const AValue: TUniStrokeJoin);
    property AntiAlias: Boolean read GetAntiAlias write SetAntiAlias;
    property Color: TAlphaColor read GetColor write SetColor;
    property Style: TUniPaintStyle read GetStyle write SetStyle;
    property StrokeWidth: Single read GetStrokeWidth write SetStrokeWidth;
    property StrokeCap: TUniStrokeCap read GetStrokeCap write SetStrokeCap;
    property StrokeJoin: TUniStrokeJoin read GetStrokeJoin write SetStrokeJoin;
  end;

  IUniCanvas = interface
    ['{0FD50FC8-C8A9-470F-B7D4-37DA6AB15FAE}']
    procedure Save;
    procedure Restore;
    procedure ClipRect(const ARect: TRectF);
    procedure Rotate(const ADegrees, AX, AY: Single);
    procedure DrawRect(const ARect: TRectF; const APaint: IUniPaint);
    procedure DrawRoundRect(const ARect: TRectF; const AXRadius,
      AYRadius: Single; const APaint: IUniPaint);
    procedure DrawLine(const AP1, AP2: TPointF; const APaint: IUniPaint); overload;
    procedure DrawLine(const AX1, AY1, AX2, AY2: Single;
      const APaint: IUniPaint); overload;
    procedure DrawCircle(const AX, AY, ARadius: Single; const APaint: IUniPaint);
    procedure DrawOval(const ARect: TRectF; const APaint: IUniPaint);
    procedure DrawArc(const ARect: TRectF; const AStartAngle, ASweepAngle: Single;
      const AUseCenter: Boolean; const APaint: IUniPaint);
    procedure DrawSimpleText(const AText: string; const AX, ABaseline: Single;
      const AFont: IUniFont; const APaint: IUniPaint);
  end;

  TUniTypefaceFactory = class
  public
    class function MakeFromName(const AFamily: string;
      const AStyle: TUniFontStyle): IUniTypeface; static;
    class function MakeDefault: IUniTypeface; static;
  end;

  TUniFontFactory = class
  public
    class function Create(const ATypeface: IUniTypeface;
      const ASize: Single): IUniFont; reintroduce; static;
  end;

  TUniPaintFactory = class
  public
    class function Create: IUniPaint; reintroduce; static;
  end;

function WrapCanvas(const ACanvas: TCanvas; const AScaleX,
  AScaleY: Single): IUniCanvas;

implementation

type
  TTypeface = class(TInterfacedObject, IUniTypeface)
  private
    FFamily: string;
    function GetFamily: string;
  public
    constructor Create(const AFamily: string);
  end;

  TFont = class(TInterfacedObject, IUniFont)
  private
    FFamily: string;
    FSize: Single;
    function GetFamily: string;
    function GetSize: Single;
  public
    constructor Create(const ATypeface: IUniTypeface; const ASize: Single);
    function MeasureText(const AText: string): Single;
  end;

  TPaint = class(TInterfacedObject, IUniPaint)
  private
    FAntiAlias: Boolean;
    FColor: TAlphaColor;
    FStyle: TUniPaintStyle;
    FStrokeWidth: Single;
    FStrokeCap: TUniStrokeCap;
    FStrokeJoin: TUniStrokeJoin;
    function GetAntiAlias: Boolean;
    function GetColor: TAlphaColor;
    function GetStyle: TUniPaintStyle;
    function GetStrokeWidth: Single;
    function GetStrokeCap: TUniStrokeCap;
    function GetStrokeJoin: TUniStrokeJoin;
    procedure SetAntiAlias(const AValue: Boolean);
    procedure SetColor(const AValue: TAlphaColor);
    procedure SetStyle(const AValue: TUniPaintStyle);
    procedure SetStrokeWidth(const AValue: Single);
    procedure SetStrokeCap(const AValue: TUniStrokeCap);
    procedure SetStrokeJoin(const AValue: TUniStrokeJoin);
  end;

  TCanvasAdapter = class(TInterfacedObject, IUniCanvas)
  private
    FCanvas: TCanvas;
    FScaleX: Single;
    FScaleY: Single;
    FStates: TStack<TCanvasSaveState>;
    procedure ApplyPaint(const APaint: IUniPaint);
  public
    constructor Create(const ACanvas: TCanvas; const AScaleX,
      AScaleY: Single);
    destructor Destroy; override;
    procedure Save;
    procedure Restore;
    procedure ClipRect(const ARect: TRectF);
    procedure Rotate(const ADegrees, AX, AY: Single);
    procedure DrawRect(const ARect: TRectF; const APaint: IUniPaint);
    procedure DrawRoundRect(const ARect: TRectF; const AXRadius,
      AYRadius: Single; const APaint: IUniPaint);
    procedure DrawLine(const AP1, AP2: TPointF; const APaint: IUniPaint); overload;
    procedure DrawLine(const AX1, AY1, AX2, AY2: Single;
      const APaint: IUniPaint); overload;
    procedure DrawCircle(const AX, AY, ARadius: Single; const APaint: IUniPaint);
    procedure DrawOval(const ARect: TRectF; const APaint: IUniPaint);
    procedure DrawArc(const ARect: TRectF; const AStartAngle, ASweepAngle: Single;
      const AUseCenter: Boolean; const APaint: IUniPaint);
    procedure DrawSimpleText(const AText: string; const AX, ABaseline: Single;
      const AFont: IUniFont; const APaint: IUniPaint);
  end;

class function TUniFontStyle.Normal: TUniFontStyle;
begin
  Result := Default(TUniFontStyle);
end;

constructor TTypeface.Create(const AFamily: string);
begin
  inherited Create;
  FFamily := AFamily;
end;

function TTypeface.GetFamily: string;
begin
  Result := FFamily;
end;

constructor TFont.Create(const ATypeface: IUniTypeface; const ASize: Single);
begin
  inherited Create;
  if ATypeface <> nil then
    FFamily := ATypeface.Family;
  FSize := ASize;
end;

function TFont.GetFamily: string;
begin
  Result := FFamily;
end;

function TFont.GetSize: Single;
begin
  Result := FSize;
end;

function TFont.MeasureText(const AText: string): Single;
var
  Layout: TTextLayout;
begin
  Layout := TTextLayoutManager.DefaultTextLayout.Create;
  try
    Layout.BeginUpdate;
    try
      Layout.Font.Family := FFamily;
      Layout.Font.Size := FSize;
      Layout.MaxSize := PointF(100000, 100000);
      Layout.WordWrap := False;
      Layout.Text := AText;
    finally
      Layout.EndUpdate;
    end;
    Result := Layout.TextWidth;
  finally
    Layout.Free;
  end;
end;

function TPaint.GetAntiAlias: Boolean; begin Result := FAntiAlias; end;
function TPaint.GetColor: TAlphaColor; begin Result := FColor; end;
function TPaint.GetStyle: TUniPaintStyle; begin Result := FStyle; end;
function TPaint.GetStrokeWidth: Single; begin Result := FStrokeWidth; end;
function TPaint.GetStrokeCap: TUniStrokeCap; begin Result := FStrokeCap; end;
function TPaint.GetStrokeJoin: TUniStrokeJoin; begin Result := FStrokeJoin; end;
procedure TPaint.SetAntiAlias(const AValue: Boolean); begin FAntiAlias := AValue; end;
procedure TPaint.SetColor(const AValue: TAlphaColor); begin FColor := AValue; end;
procedure TPaint.SetStyle(const AValue: TUniPaintStyle); begin FStyle := AValue; end;
procedure TPaint.SetStrokeWidth(const AValue: Single); begin FStrokeWidth := AValue; end;
procedure TPaint.SetStrokeCap(const AValue: TUniStrokeCap); begin FStrokeCap := AValue; end;
procedure TPaint.SetStrokeJoin(const AValue: TUniStrokeJoin); begin FStrokeJoin := AValue; end;

constructor TCanvasAdapter.Create(const ACanvas: TCanvas; const AScaleX,
  AScaleY: Single);
begin
  inherited Create;
  FCanvas := ACanvas;
  FScaleX := Max(0.001, AScaleX);
  FScaleY := Max(0.001, AScaleY);
  FStates := TStack<TCanvasSaveState>.Create;
end;

destructor TCanvasAdapter.Destroy;
begin
  while FStates.Count > 0 do
    FCanvas.RestoreState(FStates.Pop);
  FStates.Free;
  inherited;
end;

procedure TCanvasAdapter.ApplyPaint(const APaint: IUniPaint);
begin
  FCanvas.Fill.Kind := TBrushKind.Solid;
  FCanvas.Fill.Color := APaint.Color;
  FCanvas.Stroke.Kind := TBrushKind.Solid;
  FCanvas.Stroke.Color := APaint.Color;
  FCanvas.Stroke.Thickness := Max(0.1, APaint.StrokeWidth);
end;

procedure TCanvasAdapter.Save;
begin
  FStates.Push(FCanvas.SaveState);
end;

procedure TCanvasAdapter.Restore;
begin
  if FStates.Count > 0 then
    FCanvas.RestoreState(FStates.Pop);
end;

procedure TCanvasAdapter.ClipRect(const ARect: TRectF);
begin
  FCanvas.IntersectClipRect(ARect);
end;

procedure TCanvasAdapter.Rotate(const ADegrees, AX, AY: Single);
var
  M1, M2: TMatrix;
begin
  M1 := TMatrix.CreateTranslation(-AX, -AY);
  M2 := TMatrix.CreateTranslation(AX, AY);
  FCanvas.MultiplyMatrix(M1 * (TMatrix.CreateRotation(DegToRad(ADegrees)) * M2));
end;

procedure TCanvasAdapter.DrawRect(const ARect: TRectF; const APaint: IUniPaint);
begin
  ApplyPaint(APaint);
  if APaint.Style = TUniPaintStyle.Fill then
    FCanvas.FillRect(ARect, 1)
  else
    FCanvas.DrawRect(ARect, 1);
end;

procedure TCanvasAdapter.DrawRoundRect(const ARect: TRectF;
  const AXRadius, AYRadius: Single; const APaint: IUniPaint);
begin
  ApplyPaint(APaint);
  if APaint.Style = TUniPaintStyle.Fill then
    FCanvas.FillRect(ARect, AXRadius, AYRadius, AllCorners, 1)
  else
    FCanvas.DrawRect(ARect, AXRadius, AYRadius, AllCorners, 1);
end;

procedure TCanvasAdapter.DrawLine(const AP1, AP2: TPointF;
  const APaint: IUniPaint);
begin
  ApplyPaint(APaint);
  FCanvas.DrawLine(AP1, AP2, 1);
end;

procedure TCanvasAdapter.DrawLine(const AX1, AY1, AX2, AY2: Single;
  const APaint: IUniPaint);
begin
  DrawLine(PointF(AX1, AY1), PointF(AX2, AY2), APaint);
end;

procedure TCanvasAdapter.DrawCircle(const AX, AY, ARadius: Single;
  const APaint: IUniPaint);
begin
  DrawOval(RectF(AX - ARadius, AY - ARadius, AX + ARadius, AY + ARadius), APaint);
end;

procedure TCanvasAdapter.DrawOval(const ARect: TRectF; const APaint: IUniPaint);
begin
  ApplyPaint(APaint);
  if APaint.Style = TUniPaintStyle.Fill then
    FCanvas.FillEllipse(ARect, 1)
  else
    FCanvas.DrawEllipse(ARect, 1);
end;

procedure TCanvasAdapter.DrawArc(const ARect: TRectF; const AStartAngle,
  ASweepAngle: Single; const AUseCenter: Boolean; const APaint: IUniPaint);
begin
  ApplyPaint(APaint);
  FCanvas.DrawArc(ARect.CenterPoint,
    PointF(ARect.Width * 0.5, ARect.Height * 0.5), AStartAngle, ASweepAngle, 1);
end;

procedure TCanvasAdapter.DrawSimpleText(const AText: string; const AX,
  ABaseline: Single; const AFont: IUniFont; const APaint: IUniPaint);
var
  DrawX, DrawBaseline, DrawSize: Single;
begin
  ApplyPaint(APaint);
  DrawX := Round(AX * FScaleX) / FScaleX;
  DrawBaseline := Round(ABaseline * FScaleY) / FScaleY;
  DrawSize := Max(1, Round(AFont.Size * FScaleY)) / FScaleY;
  FCanvas.Font.Family := AFont.Family;
  FCanvas.Font.Size := DrawSize;
  FCanvas.FillText(RectF(DrawX, DrawBaseline - DrawSize, DrawX + 100000,
    DrawBaseline + DrawSize), AText, False, 1, [], TTextAlign.Leading,
    TTextAlign.Leading);
end;

class function TUniTypefaceFactory.MakeFromName(const AFamily: string;
  const AStyle: TUniFontStyle): IUniTypeface;
begin
  Result := TTypeface.Create(AFamily);
end;

class function TUniTypefaceFactory.MakeDefault: IUniTypeface;
begin
  Result := TTypeface.Create('');
end;

class function TUniFontFactory.Create(const ATypeface: IUniTypeface;
  const ASize: Single): IUniFont;
begin
  Result := TFont.Create(ATypeface, ASize);
end;

class function TUniPaintFactory.Create: IUniPaint;
begin
  Result := TPaint.Create;
  Result.AntiAlias := True;
  Result.Color := TAlphaColors.Black;
  Result.Style := TUniPaintStyle.Fill;
  Result.StrokeWidth := 1;
end;

function WrapCanvas(const ACanvas: TCanvas; const AScaleX,
  AScaleY: Single): IUniCanvas;
begin
  Result := TCanvasAdapter.Create(ACanvas, AScaleX, AScaleY);
end;

end.
