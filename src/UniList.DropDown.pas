unit UniList.DropDown;

interface

uses
  System.Classes,
  System.Types,
  System.UITypes,
  System.SysUtils,
  FMX.Types,
  FMX.Controls,
  FMX.Graphics,
  UniList.Popup,
  UniList.Diagnostics;

type
  TUniDropDownOpeningEvent = procedure(Sender: TObject;
    var AAllow: Boolean) of object;

  TUniDropDownHitPart = (
    uddhpNone,
    uddhpField,
    uddhpButton
  );

  TUniDropDown = class(TControl)
  private
    FPopupHost: TUniPopupHost;
    FPopupContent: TControl;
    FText: string;
    FPromptText: string;
    FOpenOnFieldClick: Boolean;
    FIsDropDownOpen: Boolean;
    FOpening: Boolean;
    FDestroying: Boolean;
    FHoverPart: TUniDropDownHitPart;
    FPressedPart: TUniDropDownHitPart;
    FThemeName: string;
    FBackgroundColor: TAlphaColor;
    FBorderColor: TAlphaColor;
    FHoverBackgroundColor: TAlphaColor;
    FPressedBackgroundColor: TAlphaColor;
    FFocusBorderColor: TAlphaColor;
    FTextColor: TAlphaColor;
    FPromptColor: TAlphaColor;
    FChevronColor: TAlphaColor;
    FDisabledTextColor: TAlphaColor;
    FDisabledBackgroundColor: TAlphaColor;
    FOnOpening: TUniDropDownOpeningEvent;
    FOnOpened: TNotifyEvent;
    FOnClosed: TUniPopupClosedEvent;
    procedure SetText(const Value: string);
    procedure SetPromptText(const Value: string);
    procedure SetThemeName(const Value: string);
    function GetDropDownPlacement: TUniPopupPlacement;
    procedure SetDropDownPlacement(const Value: TUniPopupPlacement);
    function GetDropDownWidthMode: TUniPopupWidthMode;
    procedure SetDropDownWidthMode(const Value: TUniPopupWidthMode);
    function GetDropDownWidth: Single;
    procedure SetDropDownWidth(const Value: Single);
    function GetDropDownMaxHeight: Single;
    procedure SetDropDownMaxHeight(const Value: Single);
    function GetResizable: Boolean;
    procedure SetResizable(const Value: Boolean);
    function GetMinPopupWidth: Single;
    procedure SetMinPopupWidth(const Value: Single);
    function GetMinPopupHeight: Single;
    procedure SetMinPopupHeight(const Value: Single);
    function GetMaxPopupWidth: Single;
    procedure SetMaxPopupWidth(const Value: Single);
    function GetMaxPopupHeight: Single;
    procedure SetMaxPopupHeight(const Value: Single);
    function GetRememberUserSize: Boolean;
    procedure SetRememberUserSize(const Value: Boolean);
    function GetCloseOnEscape: Boolean;
    procedure SetCloseOnEscape(const Value: Boolean);
    function GetCloseOnOutsideClick: Boolean;
    procedure SetCloseOnOutsideClick(const Value: Boolean);
    procedure PopupShown(Sender: TObject);
    procedure PopupClosed(Sender: TObject;
      const AReason: TUniPopupCloseReason);
    procedure ApplyTheme;
    function ButtonRect: TRectF;
    function HitPart(const X, Y: Single): TUniDropDownHitPart;
    function FitTextToWidth(const AText: string;
      const AMaxWidth: Single): string;
    function PopupContentContainsDropDown(
      const AContent: TControl): Boolean;
  protected
    procedure SetPopupContent(const Value: TControl); virtual;
    procedure DoDropDownOpening(var AAllow: Boolean); virtual;
    procedure DoDropDownOpened; virtual;
    procedure DoDropDownClosed(
      const AReason: TUniPopupCloseReason); virtual;
    procedure DoThemeChanged; virtual;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
    procedure Paint; override;
    procedure DoMouseEnter; override;
    procedure DoMouseLeave; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Single); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Single); override;
    procedure MouseClick(Button: TMouseButton; Shift: TShiftState;
      X, Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Single); override;
    procedure KeyDown(var Key: Word; var KeyChar: WideChar;
      Shift: TShiftState); override;
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure EnabledChanged; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure OpenDropDown;
    procedure CloseDropDown;
    procedure ToggleDropDown;
    property IsDropDownOpen: Boolean read FIsDropDownOpen;
    property PopupHost: TUniPopupHost read FPopupHost;
  published
    property Align;
    property Anchors;
    property Enabled;
    property Height;
    property HitTest;
    property Margins;
    property Opacity;
    property Padding;
    property Position;
    property Size;
    property TabOrder;
    property TabStop;
    property Visible;
    property Width;
    property Text: string read FText write SetText;
    property PromptText: string read FPromptText write SetPromptText;
    property PopupContent: TControl read FPopupContent write SetPopupContent;
    property OpenOnFieldClick: Boolean read FOpenOnFieldClick
      write FOpenOnFieldClick default True;
    property ThemeName: string read FThemeName write SetThemeName;
    property DropDownPlacement: TUniPopupPlacement
      read GetDropDownPlacement write SetDropDownPlacement
      default uppAuto;
    property DropDownWidthMode: TUniPopupWidthMode
      read GetDropDownWidthMode write SetDropDownWidthMode
      default upwAnchor;
    property DropDownWidth: Single read GetDropDownWidth
      write SetDropDownWidth;
    property DropDownMaxHeight: Single read GetDropDownMaxHeight
      write SetDropDownMaxHeight;
    property Resizable: Boolean read GetResizable write SetResizable
      default False;
    property MinPopupWidth: Single read GetMinPopupWidth
      write SetMinPopupWidth;
    property MinPopupHeight: Single read GetMinPopupHeight
      write SetMinPopupHeight;
    property MaxPopupWidth: Single read GetMaxPopupWidth
      write SetMaxPopupWidth;
    property MaxPopupHeight: Single read GetMaxPopupHeight
      write SetMaxPopupHeight;
    property RememberUserSize: Boolean read GetRememberUserSize
      write SetRememberUserSize default True;
    property CloseOnEscape: Boolean read GetCloseOnEscape
      write SetCloseOnEscape default True;
    property CloseOnOutsideClick: Boolean read GetCloseOnOutsideClick
      write SetCloseOnOutsideClick default True;
    property OnOpening: TUniDropDownOpeningEvent read FOnOpening
      write FOnOpening;
    property OnOpened: TNotifyEvent read FOnOpened write FOnOpened;
    property OnClosed: TUniPopupClosedEvent read FOnClosed write FOnClosed;
    property OnClick;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

procedure Register;

implementation

uses
  System.Math,
  UniList.Theme;

const
  CDropDownDefaultWidth = 220.0;
  CDropDownDefaultHeight = 36.0;
  CDropDownHorizontalPadding = 10.0;
  CDropDownButtonWidth = 34.0;
  CDropDownCornerRadius = 6.0;
  CDropDownBorderThickness = 1.0;
  CDropDownChevronSize = 12.0;
  CDropDownChevronThickness = 1.7;
  CDropDownTextSize = 14.0;
  CDropDownTextButtonGap = 4.0;
  CDropDownDefaultPopupWidth = 240.0;
  CDropDownDefaultPopupMaxHeight = 320.0;
  CDropDownDefaultThemeName = 'Termius Light';
  CBackgroundBlend = 0.06;
  CBorderBlend = 0.24;
  CHoverBlend = 0.12;
  CPressedBlend = 0.20;
  CPromptBlend = 0.58;
  CDisabledTextBlend = 0.36;
  CDisabledBackgroundBlend = 0.03;

constructor TUniDropDown.Create(AOwner: TComponent);
begin
  inherited;
  FDestroying := False;
  FOpenOnFieldClick := True;
  FIsDropDownOpen := False;
  FOpening := False;
  FHoverPart := uddhpNone;
  FPressedPart := uddhpNone;
  FThemeName := CDropDownDefaultThemeName;
  FPopupHost := TUniPopupHost.Create(Self);
  FPopupHost.Placement := uppAuto;
  FPopupHost.WidthMode := upwAnchor;
  FPopupHost.PopupWidth := CDropDownDefaultPopupWidth;
  FPopupHost.MaxPopupHeight := CDropDownDefaultPopupMaxHeight;
  FPopupHost.CloseOnEscape := True;
  FPopupHost.CloseOnOutsideClick := True;
  FPopupHost.ThemeName := FThemeName;
  FPopupHost.OnPopupShown := PopupShown;
  FPopupHost.OnPopupClosed := PopupClosed;
  CanFocus := True;
  TabStop := True;
  AutoCapture := True;
  HitTest := True;
  SetBounds(Position.X, Position.Y, CDropDownDefaultWidth,
    CDropDownDefaultHeight);
  ApplyTheme;
end;

destructor TUniDropDown.Destroy;
begin
  FDestroying := True;
  if FPopupContent <> nil then
    FPopupContent.RemoveFreeNotification(Self);
  FPopupContent := nil;
  if FPopupHost <> nil then
  begin
    FPopupHost.OnPopupShown := nil;
    FPopupHost.OnPopupClosed := nil;
    FPopupHost.ClosePopup;
  end;
  inherited;
end;

procedure TUniDropDown.SetText(const Value: string);
begin
  if FText = Value then
    Exit;
  FText := Value;
  Repaint;
end;

procedure TUniDropDown.SetPromptText(const Value: string);
begin
  if FPromptText = Value then
    Exit;
  FPromptText := Value;
  Repaint;
end;

function TUniDropDown.PopupContentContainsDropDown(
  const AContent: TControl): Boolean;
var
  ParentObject: TFmxObject;
begin
  Result := False;
  if AContent = nil then
    Exit;
  ParentObject := Parent;
  while ParentObject <> nil do
  begin
    if ParentObject = AContent then
      Exit(True);
    ParentObject := ParentObject.Parent;
  end;
end;

procedure TUniDropDown.SetPopupContent(const Value: TControl);
begin
  if FPopupContent = Value then
    Exit;
  if Value = Self then
    raise EArgumentException.Create(
      'PopupContent cannot reference the dropdown itself');
  if PopupContentContainsDropDown(Value) then
    raise EArgumentException.Create(
      'PopupContent cannot contain its dropdown anchor');

  CloseDropDown;
  if FPopupContent <> nil then
    FPopupContent.RemoveFreeNotification(Self);
  FPopupContent := Value;
  if FPopupContent <> nil then
    FPopupContent.FreeNotification(Self);
end;

procedure TUniDropDown.SetThemeName(const Value: string);
begin
  if SameText(FThemeName, Value) then
    Exit;
  FThemeName := Value;
  FPopupHost.ThemeName := Value;
  ApplyTheme;
  DoThemeChanged;
  Repaint;
end;

procedure TUniDropDown.DoDropDownOpening(var AAllow: Boolean);
begin
end;

procedure TUniDropDown.DoDropDownOpened;
begin
  if UniPopupDiagnosticsEnabled then
    UniTraceDoDropDownOpenedEntered;
end;

procedure TUniDropDown.DoDropDownClosed(
  const AReason: TUniPopupCloseReason);
begin
end;

procedure TUniDropDown.DoThemeChanged;
begin
end;

procedure TUniDropDown.ApplyTheme;
var
  Theme: TUniThemeDefinition;
begin
  Theme := TUniThemeManager.Find(FThemeName);
  if (Theme = nil) and (TUniThemeManager.Count > 0) then
    Theme := TUniThemeManager.ThemeAt(0);
  if Theme = nil then
    Exit;

  FBackgroundColor := UniBlendColor(Theme.Background, Theme.Foreground,
    CBackgroundBlend);
  FBorderColor := UniBlendColor(Theme.Background, Theme.Foreground,
    CBorderBlend);
  FHoverBackgroundColor := UniBlendColor(FBackgroundColor, Theme.Cursor,
    CHoverBlend);
  FPressedBackgroundColor := UniBlendColor(FBackgroundColor, Theme.Cursor,
    CPressedBlend);
  FFocusBorderColor := Theme.Cursor;
  FTextColor := Theme.Foreground;
  FPromptColor := UniBlendColor(FBackgroundColor, Theme.Foreground,
    CPromptBlend);
  FChevronColor := Theme.Foreground;
  FDisabledTextColor := UniBlendColor(FBackgroundColor, Theme.Foreground,
    CDisabledTextBlend);
  FDisabledBackgroundColor := UniBlendColor(Theme.Background,
    Theme.Foreground, CDisabledBackgroundBlend);
end;

function TUniDropDown.ButtonRect: TRectF;
begin
  Result := LocalRect;
  Result.Left := Max(Result.Left, Result.Right - CDropDownButtonWidth);
end;

function TUniDropDown.HitPart(const X, Y: Single): TUniDropDownHitPart;
begin
  Result := uddhpNone;
  if not LocalRect.Contains(PointF(X, Y)) then
    Exit;
  if ButtonRect.Contains(PointF(X, Y)) then
    Exit(uddhpButton);
  Result := uddhpField;
end;

function TUniDropDown.FitTextToWidth(const AText: string;
  const AMaxWidth: Single): string;
const
  CEllipsis = '…';
var
  HighValue, LowValue, MiddleValue: Integer;
begin
  Result := '';
  if (AText = '') or (AMaxWidth <= 0) then
    Exit;
  if Canvas.TextWidth(AText) <= AMaxWidth then
    Exit(AText);
  if Canvas.TextWidth(CEllipsis) > AMaxWidth then
    Exit;

  LowValue := 0;
  HighValue := Length(AText);
  while LowValue < HighValue do
  begin
    MiddleValue := (LowValue + HighValue + 1) div 2;
    if Canvas.TextWidth(Copy(AText, 1, MiddleValue) + CEllipsis) <=
       AMaxWidth then
      LowValue := MiddleValue
    else
      HighValue := MiddleValue - 1;
  end;
  Result := Copy(AText, 1, LowValue) + CEllipsis;
end;

procedure TUniDropDown.Paint;
var
  BorderColor, ChevronColor, DisplayText: TAlphaColor;
  ButtonArea, ChevronRect, FieldRect, TextRect: TRectF;
  CenterX, CenterY, ChevronHalf: Single;
  FillColor: TAlphaColor;
  IsPrompt: Boolean;
  VisibleText: string;
begin
  inherited;
  FieldRect := LocalRect;
  FieldRect.Inflate(-CDropDownBorderThickness * 0.5,
    -CDropDownBorderThickness * 0.5);
  ButtonArea := ButtonRect;

  if not AbsoluteEnabled then
  begin
    FillColor := FDisabledBackgroundColor;
    BorderColor := FBorderColor;
    DisplayText := FDisabledTextColor;
    ChevronColor := FDisabledTextColor;
  end
  else
  begin
    FillColor := FBackgroundColor;
    if FHoverPart <> uddhpNone then
      FillColor := FHoverBackgroundColor;
    if FPressedPart <> uddhpNone then
      FillColor := FPressedBackgroundColor;
    if FIsDropDownOpen or IsFocused then
      BorderColor := FFocusBorderColor
    else
      BorderColor := FBorderColor;
    DisplayText := FTextColor;
    ChevronColor := FChevronColor;
  end;

  Canvas.Fill.Kind := TBrushKind.Solid;
  Canvas.Fill.Color := FillColor;
  Canvas.FillRect(FieldRect, CDropDownCornerRadius, CDropDownCornerRadius,
    AllCorners, AbsoluteOpacity);

  if AbsoluteEnabled and (FHoverPart = uddhpButton) then
  begin
    Canvas.Fill.Color := IfThen(FPressedPart = uddhpButton,
      FPressedBackgroundColor, FHoverBackgroundColor);
    Canvas.FillRect(ButtonArea, 0, 0, [], AbsoluteOpacity);
  end;

  Canvas.Stroke.Kind := TBrushKind.Solid;
  Canvas.Stroke.Color := BorderColor;
  Canvas.Stroke.Thickness := CDropDownBorderThickness;
  Canvas.DrawRect(FieldRect, CDropDownCornerRadius, CDropDownCornerRadius,
    AllCorners, AbsoluteOpacity);

  IsPrompt := FText = '';
  if IsPrompt then
  begin
    VisibleText := FPromptText;
    DisplayText := IfThen(AbsoluteEnabled, FPromptColor,
      FDisabledTextColor);
  end
  else
    VisibleText := FText;

  TextRect := LocalRect;
  TextRect.Left := TextRect.Left + CDropDownHorizontalPadding;
  TextRect.Right := ButtonArea.Left - CDropDownTextButtonGap;
  Canvas.Font.Size := CDropDownTextSize;
  Canvas.Fill.Color := DisplayText;
  VisibleText := FitTextToWidth(VisibleText, Max(0, TextRect.Width));
  Canvas.FillText(TextRect, VisibleText, False, AbsoluteOpacity,
    FillTextFlags, TTextAlign.Leading, TTextAlign.Center);

  ChevronRect := ButtonArea;
  ChevronRect.Inflate(
    -(ButtonArea.Width - CDropDownChevronSize) * 0.5,
    -(ButtonArea.Height - CDropDownChevronSize) * 0.5);
  CenterX := ChevronRect.CenterPoint.X;
  CenterY := ChevronRect.CenterPoint.Y;
  ChevronHalf := CDropDownChevronSize * 0.32;
  Canvas.Stroke.Color := ChevronColor;
  Canvas.Stroke.Thickness := CDropDownChevronThickness;
  if FIsDropDownOpen then
  begin
    Canvas.DrawLine(PointF(CenterX - ChevronHalf,
      CenterY + ChevronHalf * 0.5), PointF(CenterX,
      CenterY - ChevronHalf * 0.5), AbsoluteOpacity);
    Canvas.DrawLine(PointF(CenterX,
      CenterY - ChevronHalf * 0.5), PointF(CenterX + ChevronHalf,
      CenterY + ChevronHalf * 0.5), AbsoluteOpacity);
  end
  else
  begin
    Canvas.DrawLine(PointF(CenterX - ChevronHalf,
      CenterY - ChevronHalf * 0.5), PointF(CenterX,
      CenterY + ChevronHalf * 0.5), AbsoluteOpacity);
    Canvas.DrawLine(PointF(CenterX,
      CenterY + ChevronHalf * 0.5), PointF(CenterX + ChevronHalf,
      CenterY - ChevronHalf * 0.5), AbsoluteOpacity);
  end;
end;

procedure TUniDropDown.DoMouseEnter;
begin
  inherited;
  if AbsoluteEnabled then
    FHoverPart := uddhpField;
  Repaint;
end;

procedure TUniDropDown.DoMouseLeave;
begin
  inherited;
  FHoverPart := uddhpNone;
  if not Pressed then
    FPressedPart := uddhpNone;
  Repaint;
end;

procedure TUniDropDown.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  inherited;
  if not AbsoluteEnabled or (Button <> TMouseButton.mbLeft) then
    Exit;
  FPressedPart := HitPart(X, Y);
  Repaint;
end;

procedure TUniDropDown.MouseMove(Shift: TShiftState; X, Y: Single);
var
  NewHoverPart: TUniDropDownHitPart;
begin
  inherited;
  if not AbsoluteEnabled then
    Exit;
  NewHoverPart := HitPart(X, Y);
  if FHoverPart = NewHoverPart then
    Exit;
  FHoverPart := NewHoverPart;
  Repaint;
end;

procedure TUniDropDown.MouseClick(Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
var
  ClickPart: TUniDropDownHitPart;
begin
  if UniPopupDiagnosticsEnabled then
    UniTraceMouseClickEntered;
  if AbsoluteEnabled and (Button = TMouseButton.mbLeft) and
     not (csDesigning in ComponentState) then
  begin
    ClickPart := HitPart(X, Y);
    if (ClickPart = uddhpButton) or
       ((ClickPart = uddhpField) and FOpenOnFieldClick) then
      ToggleDropDown;
  end;
  inherited;
end;

procedure TUniDropDown.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  inherited;
  FPressedPart := uddhpNone;
  Repaint;
end;

procedure TUniDropDown.KeyDown(var Key: Word; var KeyChar: WideChar;
  Shift: TShiftState);
var
  Handled: Boolean;
begin
  Handled := False;
  if AbsoluteEnabled and IsFocused then
  begin
    if ((Key = vkDown) and (ssAlt in Shift)) or
       (Key = vkSpace) or (Key = vkReturn) then
    begin
      OpenDropDown;
      Handled := True;
    end
    else if (Key = vkEscape) or
            ((Key = vkUp) and (ssAlt in Shift)) then
    begin
      CloseDropDown;
      Handled := True;
    end
    else if Key = vkF4 then
    begin
      ToggleDropDown;
      Handled := True;
    end;
  end;

  if Handled then
  begin
    Key := 0;
    KeyChar := #0;
    Exit;
  end;
  inherited;
end;

procedure TUniDropDown.DoEnter;
begin
  inherited;
  Repaint;
end;

procedure TUniDropDown.DoExit;
begin
  inherited;
  Repaint;
end;

procedure TUniDropDown.EnabledChanged;
begin
  inherited;
  if not Enabled then
    CloseDropDown;
  Repaint;
end;

procedure TUniDropDown.OpenDropDown;
var
  AllowOpen: Boolean;
begin
  if UniPopupDiagnosticsEnabled then
  begin
    UniTraceOpenDropDownEntered;
    UniTraceDestroying(FDestroying);
    if not FDestroying then
      UniTraceAbsoluteEnabled(AbsoluteEnabled);
  end;
  if FDestroying or not AbsoluteEnabled then
    Exit;
  if UniPopupDiagnosticsEnabled then
    UniTracePopupContentAssigned(FPopupContent <> nil);
  if FPopupContent = nil then
    Exit;
  if UniPopupDiagnosticsEnabled then
    UniTracePopupAlreadyOpeningOrOpen(
      FOpening or FIsDropDownOpen or FPopupHost.IsOpen);
  if FOpening or FIsDropDownOpen or FPopupHost.IsOpen then
    Exit;
  if UniPopupDiagnosticsEnabled then
    UniTraceDesignMode(csDesigning in ComponentState);
  if csDesigning in ComponentState then
    Exit;

  FOpening := True;
  try
    AllowOpen := True;
    if Assigned(FOnOpening) then
      FOnOpening(Self, AllowOpen);
    if UniPopupDiagnosticsEnabled then
      UniTraceOnOpeningResult(AllowOpen);
    if AllowOpen then
    begin
      DoDropDownOpening(AllowOpen);
      if UniPopupDiagnosticsEnabled then
        UniTraceDoDropDownOpeningResult(AllowOpen);
    end;
    if not AllowOpen or FDestroying or not AbsoluteEnabled or
       (FPopupContent = nil) or FPopupHost.IsOpen then
      Exit;
    FPopupHost.ShowPopup(Self, FPopupContent);
  finally
    FOpening := False;
  end;
end;
procedure TUniDropDown.CloseDropDown;
begin
  if FPopupHost.IsOpen then
  begin
    FPopupHost.ClosePopup;
    Exit;
  end;
  if not FIsDropDownOpen then
    Exit;
  FIsDropDownOpen := False;
  Repaint;
end;

procedure TUniDropDown.ToggleDropDown;
begin
  if UniPopupDiagnosticsEnabled then
    UniTraceToggleDropDownEntered;
  if FIsDropDownOpen or FPopupHost.IsOpen then
    CloseDropDown
  else
    OpenDropDown;
end;

procedure TUniDropDown.PopupShown(Sender: TObject);
begin
  if UniPopupDiagnosticsEnabled then
    UniTracePopupShownCallback;
  if FDestroying then
    Exit;
  FIsDropDownOpen := True;
  Repaint;
  DoDropDownOpened;
  if Assigned(FOnOpened) then
    FOnOpened(Self);
end;

procedure TUniDropDown.PopupClosed(Sender: TObject;
  const AReason: TUniPopupCloseReason);
var
  WasOpen: Boolean;
begin
  WasOpen := FIsDropDownOpen;
  FIsDropDownOpen := False;
  FPressedPart := uddhpNone;
  Repaint;
  if FDestroying or not WasOpen then
    Exit;
  DoDropDownClosed(AReason);
  if Assigned(FOnClosed) then
    FOnClosed(Self, AReason);
end;

procedure TUniDropDown.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (Operation <> opRemove) or (AComponent <> FPopupContent) then
    Exit;
  FPopupContent := nil;
  if FPopupHost.IsOpen then
    FPopupHost.ClosePopup;
end;

function TUniDropDown.GetDropDownPlacement: TUniPopupPlacement;
begin
  Result := FPopupHost.Placement;
end;

procedure TUniDropDown.SetDropDownPlacement(
  const Value: TUniPopupPlacement);
begin
  FPopupHost.Placement := Value;
end;

function TUniDropDown.GetDropDownWidthMode: TUniPopupWidthMode;
begin
  Result := FPopupHost.WidthMode;
end;

procedure TUniDropDown.SetDropDownWidthMode(
  const Value: TUniPopupWidthMode);
begin
  FPopupHost.WidthMode := Value;
end;

function TUniDropDown.GetDropDownWidth: Single;
begin
  Result := FPopupHost.PopupWidth;
end;

procedure TUniDropDown.SetDropDownWidth(const Value: Single);
begin
  FPopupHost.PopupWidth := Max(0, Value);
end;

function TUniDropDown.GetDropDownMaxHeight: Single;
begin
  Result := FPopupHost.MaxPopupHeight;
end;

procedure TUniDropDown.SetDropDownMaxHeight(const Value: Single);
begin
  FPopupHost.MaxPopupHeight := Max(0, Value);
end;

function TUniDropDown.GetResizable: Boolean;
begin
  Result := FPopupHost.Resizable;
end;

procedure TUniDropDown.SetResizable(const Value: Boolean);
begin
  FPopupHost.Resizable := Value;
end;

function TUniDropDown.GetMinPopupWidth: Single;
begin
  Result := FPopupHost.MinPopupWidth;
end;

procedure TUniDropDown.SetMinPopupWidth(const Value: Single);
begin
  FPopupHost.MinPopupWidth := Value;
end;

function TUniDropDown.GetMinPopupHeight: Single;
begin
  Result := FPopupHost.MinPopupHeight;
end;

procedure TUniDropDown.SetMinPopupHeight(const Value: Single);
begin
  FPopupHost.MinPopupHeight := Value;
end;

function TUniDropDown.GetMaxPopupWidth: Single;
begin
  Result := FPopupHost.MaxPopupWidth;
end;

procedure TUniDropDown.SetMaxPopupWidth(const Value: Single);
begin
  FPopupHost.MaxPopupWidth := Value;
end;

function TUniDropDown.GetMaxPopupHeight: Single;
begin
  Result := FPopupHost.MaxPopupHeight;
end;

procedure TUniDropDown.SetMaxPopupHeight(const Value: Single);
begin
  FPopupHost.MaxPopupHeight := Value;
end;

function TUniDropDown.GetRememberUserSize: Boolean;
begin
  Result := FPopupHost.RememberUserSize;
end;

procedure TUniDropDown.SetRememberUserSize(const Value: Boolean);
begin
  FPopupHost.RememberUserSize := Value;
end;

function TUniDropDown.GetCloseOnEscape: Boolean;
begin
  Result := FPopupHost.CloseOnEscape;
end;

procedure TUniDropDown.SetCloseOnEscape(const Value: Boolean);
begin
  FPopupHost.CloseOnEscape := Value;
end;

function TUniDropDown.GetCloseOnOutsideClick: Boolean;
begin
  Result := FPopupHost.CloseOnOutsideClick;
end;

procedure TUniDropDown.SetCloseOnOutsideClick(const Value: Boolean);
begin
  FPopupHost.CloseOnOutsideClick := Value;
end;

procedure Register;
begin
  RegisterComponents('UniListView', [TUniDropDown]);
end;

end.
