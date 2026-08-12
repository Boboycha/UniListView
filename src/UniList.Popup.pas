unit UniList.Popup;

interface

uses
  System.Classes,
  System.Types,
  System.UITypes,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Objects,
  FMX.Layouts,
  FMX.Effects,
  UniList.Diagnostics;

type
  TUniPopupPlacement = (
    uppAuto,
    uppBelow,
    uppAbove
  );

  TUniPopupWidthMode = (
    upwAnchor,
    upwContent,
    upwFixed
  );

  TUniPopupCloseReason = (
    upcrProgrammatic,
    upcrEscape,
    upcrOutsideClick,
    upcrOwnerHidden,
    upcrOwnerDestroyed
  );

  TUniPopupClosedEvent = procedure(Sender: TObject;
    const AReason: TUniPopupCloseReason) of object;
  TUniPopupHost = class(TComponent)
  private
    FPlacement: TUniPopupPlacement;
    FWidthMode: TUniPopupWidthMode;
    FPopupWidth: Single;
    FMinPopupWidth: Single;
    FMinPopupHeight: Single;
    FMaxPopupWidth: Single;
    FMaxPopupHeight: Single;
    FResizable: Boolean;
    FRememberUserSize: Boolean;
    FIsResizing: Boolean;
    FResizeHovered: Boolean;
    FResizeStartPoint: TPointF;
    FResizeStartSize: TSizeF;
    FResizeStartPosition: TPointF;
    FResizeFixedBottom: Single;
    FUserSize: TSizeF;
    FHasRememberedUserSize: Boolean;
    FHasSessionUserSize: Boolean;
    FHasSessionResizeOrigin: Boolean;
    FResolvedOpenAbove: Boolean;
    FCloseOnEscape: Boolean;
    FCloseOnOutsideClick: Boolean;
    FThemeName: string;
    FIsOpen: Boolean;
    FClosing: Boolean;
    FAnchor: TControl;
    FContent: TControl;
    FForm: TCommonCustomForm;
    FOverlay: TLayout;
    FContainer: TRectangle;
    FContentHost: TLayout;
    FResizeHandle: TPaintBox;
    FShadow: TShadowEffect;
    FMonitorTimer: TTimer;
    FOriginalParent: TFmxObject;
    FOriginalAlign: TAlignLayout;
    FOriginalPosition: TPointF;
    FOriginalSize: TSizeF;
    FOriginalVisible: Boolean;
    FPreviousFocused: TControl;
    FPreviousFormKeyDown: TKeyEvent;
    FOnPopupShown: TNotifyEvent;
    FOnPopupClosed: TUniPopupClosedEvent;
    FSurfaceColor: TAlphaColor;
    FBorderColor: TAlphaColor;
    FShadowColor: TAlphaColor;
    FTextContrastColor: TAlphaColor;
    procedure SetThemeName(const Value: string);
    procedure SetResizable(const Value: Boolean);
    procedure SetMinPopupWidth(const Value: Single);
    procedure SetMinPopupHeight(const Value: Single);
    procedure SetMaxPopupWidth(const Value: Single);
    procedure SetMaxPopupHeight(const Value: Single);
    procedure SetRememberUserSize(const Value: Boolean);
    procedure OverlayMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure ResizeHandlePaint(Sender: TObject; Canvas: TCanvas);
    procedure ResizeHandleMouseEnter(Sender: TObject);
    procedure ResizeHandleMouseLeave(Sender: TObject);
    procedure ResizeHandleMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure ResizeHandleMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Single);
    procedure ResizeHandleMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: WideChar; Shift: TShiftState);
    procedure MonitorTimer(Sender: TObject);
    procedure InternalClose(const AReason: TUniPopupCloseReason);
    procedure CreatePopupControls;
    procedure DestroyPopupControls;
    procedure PositionPopup;
    procedure ApplyTheme;
    procedure ApplyThemeToContent(const AControl: TControl);
    procedure FocusPopupContent;
    function FindFocusableControl(const AControl: TControl): TControl;
    function AnchorForm(const AAnchor: TControl): TCommonCustomForm;
    function CurrentAnchorRect: TRectF;
    function GetPopupBounds: TRectF;
    function DesiredPopupSize: TSizeF;
    function ConstrainPopupSize(const ASize: TSizeF;
      const AAvailableWidth, AAvailableHeight: Single): TSizeF;
    procedure ResetResizeState;
    procedure UpdateResizeHandle;
    function FormKeyHandlerIsInstalled: Boolean;
    procedure AddPopupFreeNotifications;
    procedure RemovePopupFreeNotifications;
  protected
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ShowPopup(const AAnchor: TControl;
      const AContent: TControl);
    procedure ClosePopup;
    property IsOpen: Boolean read FIsOpen;
    property PopupBounds: TRectF read GetPopupBounds;
    property SurfaceColor: TAlphaColor read FSurfaceColor;
    property BorderColor: TAlphaColor read FBorderColor;
    property ShadowColor: TAlphaColor read FShadowColor;
    property TextContrastColor: TAlphaColor read FTextContrastColor;
  published
    property Placement: TUniPopupPlacement read FPlacement write FPlacement
      default uppAuto;
    property WidthMode: TUniPopupWidthMode read FWidthMode write FWidthMode
      default upwAnchor;
    property PopupWidth: Single read FPopupWidth write FPopupWidth;
    property Resizable: Boolean read FResizable write SetResizable
      default False;
    property MinPopupWidth: Single read FMinPopupWidth
      write SetMinPopupWidth;
    property MinPopupHeight: Single read FMinPopupHeight
      write SetMinPopupHeight;
    property MaxPopupWidth: Single read FMaxPopupWidth
      write SetMaxPopupWidth;
    property MaxPopupHeight: Single read FMaxPopupHeight
      write SetMaxPopupHeight;
    property RememberUserSize: Boolean read FRememberUserSize
      write SetRememberUserSize default True;
    property CloseOnEscape: Boolean read FCloseOnEscape
      write FCloseOnEscape default True;
    property CloseOnOutsideClick: Boolean read FCloseOnOutsideClick
      write FCloseOnOutsideClick default True;
    property ThemeName: string read FThemeName write SetThemeName;
    property OnPopupShown: TNotifyEvent read FOnPopupShown
      write FOnPopupShown;
    property OnPopupClosed: TUniPopupClosedEvent read FOnPopupClosed
      write FOnPopupClosed;
  end;

procedure Register;

implementation

uses
  System.Math,
  System.Math.Vectors,
  System.SysUtils,
  UniList.Theme,
  UniList.Control;


const
  CPopupDefaultGap = 4.0;
  CPopupDefaultMaxHeight = 320.0;
  CPopupDefaultWidth = 240.0;
  CPopupDefaultMinWidth = 96.0;
  CPopupDefaultMinHeight = 64.0;
  CPopupDefaultMaxWidth = 0.0;
  CPopupScreenMargin = 8.0;
  CPopupCornerRadius = 6.0;
  CPopupBorderWidth = 1.0;
  CPopupContentInset = 1.0;
  CPopupResizeHandleSize = 18.0;
  CPopupResizeLineInset = 4.0;
  CPopupResizeLineSpacing = 4.0;
  CPopupResizeLineThickness = 1.4;
  CPopupShadowDistance = 3.0;
  CPopupShadowDirection = 90.0;
  CPopupShadowSoftness = 0.35;
  CPopupShadowOpacity = 0.45;
  CPopupMonitorInterval = 32;
  CPopupSurfaceBlend = 0.08;
  CPopupBorderBlend = 0.24;
  CPopupShadowBlend = 0.12;
  CPopupResizeNormalOpacity = 0.55;
  CPopupResizeHoverOpacity = 0.82;
  CPopupResizePressedOpacity = 1.0;
  CPopupDefaultThemeName = 'Termius Light';
  CPopupDefaultSurfaceColor = $FFF7F8FA;
  CPopupDefaultBorderColor = $FFBCC2CC;
  CPopupDefaultShadowColor = $66000000;
  CPopupDefaultTextColor = $FF20242C;

function SamePopupPosition(const ALeft, ATop, BLeft, BTop: Single): Boolean;
begin
  Result := SameValue(ALeft, BLeft, TEpsilon.Position) and
    SameValue(ATop, BTop, TEpsilon.Position);
end;

function SamePopupSize(const AWidth, AHeight, BWidth,
  BHeight: Single): Boolean;
begin
  Result := SameValue(AWidth, BWidth, TEpsilon.Position) and
    SameValue(AHeight, BHeight, TEpsilon.Position);
end;

function IsFrontmostChild(const AParent, AChild: TFmxObject): Boolean;
begin
  Result := (AParent <> nil) and (AChild <> nil) and
    (AParent.ChildrenCount > 0) and
    (AParent.Children[AParent.ChildrenCount - 1] = AChild);
end;

constructor TUniPopupHost.Create(AOwner: TComponent);
begin
  inherited;
  FPlacement := uppAuto;
  FWidthMode := upwAnchor;
  FPopupWidth := CPopupDefaultWidth;
  FMinPopupWidth := CPopupDefaultMinWidth;
  FMinPopupHeight := CPopupDefaultMinHeight;
  FMaxPopupWidth := CPopupDefaultMaxWidth;
  FMaxPopupHeight := CPopupDefaultMaxHeight;
  FResizable := False;
  FRememberUserSize := True;
  FCloseOnEscape := True;
  FCloseOnOutsideClick := True;
  FThemeName := CPopupDefaultThemeName;
  FSurfaceColor := CPopupDefaultSurfaceColor;
  FBorderColor := CPopupDefaultBorderColor;
  FShadowColor := CPopupDefaultShadowColor;
  FTextContrastColor := CPopupDefaultTextColor;
  FMonitorTimer := TTimer.Create(Self);
  FMonitorTimer.Enabled := False;
  FMonitorTimer.Interval := CPopupMonitorInterval;
  FMonitorTimer.OnTimer := MonitorTimer;
  ApplyTheme;
end;

destructor TUniPopupHost.Destroy;
begin
  if FIsOpen then
    InternalClose(upcrOwnerDestroyed);
  FMonitorTimer.Enabled := False;
  inherited;
end;

procedure TUniPopupHost.SetThemeName(const Value: string);
begin
  if SameText(FThemeName, Value) then
    Exit;
  FThemeName := Value;
  ApplyTheme;
  if FContent <> nil then
    ApplyThemeToContent(FContent);
end;

procedure TUniPopupHost.SetResizable(const Value: Boolean);
begin
  if FResizable = Value then
    Exit;
  FResizable := Value;
  if not FResizable then
    ResetResizeState;
  UpdateResizeHandle;
end;

procedure TUniPopupHost.SetMinPopupWidth(const Value: Single);
begin
  FMinPopupWidth := Max(0, Value);
  if (FMaxPopupWidth > 0) and (FMinPopupWidth > FMaxPopupWidth) then
    FMaxPopupWidth := FMinPopupWidth;
  if FIsOpen then
    PositionPopup;
end;

procedure TUniPopupHost.SetMinPopupHeight(const Value: Single);
begin
  FMinPopupHeight := Max(0, Value);
  if (FMaxPopupHeight > 0) and (FMinPopupHeight > FMaxPopupHeight) then
    FMaxPopupHeight := FMinPopupHeight;
  if FIsOpen then
    PositionPopup;
end;

procedure TUniPopupHost.SetMaxPopupWidth(const Value: Single);
begin
  FMaxPopupWidth := Max(0, Value);
  if (FMaxPopupWidth > 0) and (FMinPopupWidth > FMaxPopupWidth) then
    FMinPopupWidth := FMaxPopupWidth;
  if FIsOpen then
    PositionPopup;
end;

procedure TUniPopupHost.SetMaxPopupHeight(const Value: Single);
begin
  FMaxPopupHeight := Max(0, Value);
  if (FMaxPopupHeight > 0) and (FMinPopupHeight > FMaxPopupHeight) then
    FMinPopupHeight := FMaxPopupHeight;
  if FIsOpen then
    PositionPopup;
end;

procedure TUniPopupHost.SetRememberUserSize(const Value: Boolean);
begin
  if FRememberUserSize = Value then
    Exit;
  FRememberUserSize := Value;
  if not FRememberUserSize then
    FHasRememberedUserSize := False;
end;

procedure TUniPopupHost.ApplyTheme;
var
  Theme: TUniThemeDefinition;
begin
  Theme := TUniThemeManager.Find(FThemeName);
  if Theme = nil then
  begin
    FSurfaceColor := CPopupDefaultSurfaceColor;
    FBorderColor := CPopupDefaultBorderColor;
    FShadowColor := CPopupDefaultShadowColor;
    FTextContrastColor := CPopupDefaultTextColor;
  end
  else
  begin
    FSurfaceColor := UniBlendColor(Theme.Background, Theme.Foreground,
      CPopupSurfaceBlend);
    FBorderColor := UniBlendColor(Theme.Background, Theme.Foreground,
      CPopupBorderBlend);
    FShadowColor := UniBlendColor(CPopupDefaultShadowColor,
      Theme.Background, CPopupShadowBlend);
    FTextContrastColor := Theme.Foreground;
  end;

  if FContainer <> nil then
  begin
    FContainer.Fill.Color := FSurfaceColor;
    FContainer.Stroke.Color := FBorderColor;
  end;
  if FShadow <> nil then
    FShadow.ShadowColor := FShadowColor;
  if FResizeHandle <> nil then
      FResizeHandle.Repaint;
end;

procedure TUniPopupHost.ApplyThemeToContent(const AControl: TControl);
var
  ChildIndex: Integer;
begin
  if AControl = nil then
    Exit;
  if AControl is TUniListView then
    TUniListView(AControl).ThemeName := FThemeName;
  for ChildIndex := 0 to AControl.ChildrenCount - 1 do
    if AControl.Children[ChildIndex] is TControl then
      ApplyThemeToContent(TControl(AControl.Children[ChildIndex]));
end;

function TUniPopupHost.AnchorForm(
  const AAnchor: TControl): TCommonCustomForm;
begin
  Result := nil;
  if (AAnchor = nil) or (AAnchor.Root = nil) then
    Exit;
  if AAnchor.Root.GetObject is TCommonCustomForm then
    Result := TCommonCustomForm(AAnchor.Root.GetObject);
end;

procedure TUniPopupHost.ShowPopup(const AAnchor, AContent: TControl);
var
  PopupForm: TCommonCustomForm;
begin
  if UniPopupDiagnosticsEnabled then
  begin
    UniTraceShowPopupEntered;
    UniTraceAnchorAssigned(AAnchor <> nil);
  end;
  if AAnchor = nil then
    Exit;
  if UniPopupDiagnosticsEnabled then
    UniTraceContentAssigned(AContent <> nil);
  if AContent = nil then
    Exit;
  if AAnchor = AContent then
    Exit;

  PopupForm := AnchorForm(AAnchor);
  if UniPopupDiagnosticsEnabled then
    UniTraceAnchorFormAssigned(PopupForm <> nil);
  if PopupForm = nil then
    Exit;
  if UniPopupDiagnosticsEnabled then
    UniTraceFormActive(PopupForm.Active);
  if not PopupForm.Active then
    Exit;
  if UniPopupDiagnosticsEnabled then
    UniTraceAnchorParentedVisible(AAnchor.ParentedVisible);
  if not AAnchor.ParentedVisible then
    Exit;

  if FIsOpen then
    InternalClose(upcrProgrammatic);

  FAnchor := AAnchor;
  FContent := AContent;
  FForm := PopupForm;
  FOriginalParent := AContent.Parent;
  FOriginalAlign := AContent.Align;
  FOriginalPosition := AContent.Position.Point;
  FOriginalSize := AContent.Size.Size;
  FOriginalVisible := AContent.Visible;
  FHasSessionUserSize :=
    FRememberUserSize and FHasRememberedUserSize;
  FHasSessionResizeOrigin := False;
  if (FForm.Focused <> nil) and
     (FForm.Focused.GetObject is TControl) then
    FPreviousFocused := TControl(FForm.Focused.GetObject)
  else
    FPreviousFocused := nil;

  AddPopupFreeNotifications;
  try
    CreatePopupControls;
    ApplyTheme;
    ApplyThemeToContent(FContent);
    if FContent.Parent <> FContentHost then
      FContent.Parent := FContentHost;
    if FContent.Align <> TAlignLayout.Client then
      FContent.Align := TAlignLayout.Client;
    if not SamePopupPosition(FContent.Position.X, FContent.Position.Y, 0, 0) then
      FContent.Position.Point := TPointF.Zero;
    if not FContent.Visible then
      FContent.Visible := True;
    PositionPopup;
    if not IsFrontmostChild(FForm, FOverlay) then
      FOverlay.BringToFront;
    if not FOverlay.Visible then
      FOverlay.Visible := True;
    FPreviousFormKeyDown := FForm.OnKeyDown;
    FForm.OnKeyDown := FormKeyDown;
    FIsOpen := True;
    FMonitorTimer.Enabled := True;
    FocusPopupContent;
    if Assigned(FOnPopupShown) then
      FOnPopupShown(Self);
  except
    InternalClose(upcrProgrammatic);
    raise;
  end;
end;
procedure TUniPopupHost.ClosePopup;
begin
  InternalClose(upcrProgrammatic);
end;

procedure TUniPopupHost.InternalClose(
  const AReason: TUniPopupCloseReason);
var
  AnchorToFocus: TControl;
  ContentToRestore: TControl;
  OriginalParent: TFmxObject;
  OriginalAlign: TAlignLayout;
  OriginalPosition: TPointF;
  OriginalSize: TSizeF;
  OriginalVisible: Boolean;
begin
  if FClosing then
    Exit;
  if not FIsOpen and (FOverlay = nil) then
    Exit;

  FClosing := True;
  try
    FMonitorTimer.Enabled := False;
    ResetResizeState;
    FHasSessionUserSize := False;
    FHasSessionResizeOrigin := False;
    AnchorToFocus := FAnchor;
    ContentToRestore := FContent;
    OriginalParent := FOriginalParent;
    OriginalAlign := FOriginalAlign;
    OriginalPosition := FOriginalPosition;
    OriginalSize := FOriginalSize;
    OriginalVisible := FOriginalVisible;

    if FormKeyHandlerIsInstalled then
      FForm.OnKeyDown := FPreviousFormKeyDown;
    FPreviousFormKeyDown := nil;
    FIsOpen := False;

    if (ContentToRestore <> nil) and
       not (csDestroying in ContentToRestore.ComponentState) then
    begin
      if ContentToRestore.Parent <> OriginalParent then
        ContentToRestore.Parent := OriginalParent;
      if ContentToRestore.Align <> OriginalAlign then
        ContentToRestore.Align := OriginalAlign;
      if not SamePopupPosition(ContentToRestore.Position.X,
        ContentToRestore.Position.Y, OriginalPosition.X,
        OriginalPosition.Y) then
        ContentToRestore.Position.Point := OriginalPosition;
      if not SamePopupSize(ContentToRestore.Width, ContentToRestore.Height,
        OriginalSize.Width, OriginalSize.Height) then
        ContentToRestore.Size.Size := OriginalSize;
      if ContentToRestore.Visible <> OriginalVisible then
        ContentToRestore.Visible := OriginalVisible;
    end;

    RemovePopupFreeNotifications;
    FAnchor := nil;
    FContent := nil;
    FForm := nil;
    FOriginalParent := nil;
    FPreviousFocused := nil;
    DestroyPopupControls;

    if (AnchorToFocus <> nil) and
       not (csDestroying in AnchorToFocus.ComponentState) and
       AnchorToFocus.ParentedVisible and AnchorToFocus.Enabled and
       AnchorToFocus.CanFocus then
      AnchorToFocus.SetFocus;

    if Assigned(FOnPopupClosed) then
      FOnPopupClosed(Self, AReason);
  finally
    FClosing := False;
  end;
end;

procedure TUniPopupHost.CreatePopupControls;
begin
  if FForm = nil then
    Exit;

  FOverlay := TLayout.Create(Self);
  FOverlay.Parent := FForm;
  FOverlay.Align := TAlignLayout.Client;
  FOverlay.HitTest := FCloseOnOutsideClick;
  FOverlay.Visible := False;
  FOverlay.OnMouseDown := OverlayMouseDown;

  FContainer := TRectangle.Create(Self);
  FContainer.Parent := FOverlay;
  FContainer.HitTest := True;
  FContainer.ClipChildren := True;
  FContainer.XRadius := CPopupCornerRadius;
  FContainer.YRadius := CPopupCornerRadius;
  FContainer.Fill.Kind := TBrushKind.Solid;
  FContainer.Stroke.Kind := TBrushKind.Solid;
  FContainer.Stroke.Thickness := CPopupBorderWidth;
  FContainer.Padding.Rect := RectF(CPopupContentInset,
    CPopupContentInset, CPopupContentInset, CPopupContentInset);

  FShadow := TShadowEffect.Create(Self);
  FShadow.Parent := FContainer;
  FShadow.Distance := CPopupShadowDistance;
  FShadow.Direction := CPopupShadowDirection;
  FShadow.Softness := CPopupShadowSoftness;
  FShadow.Opacity := CPopupShadowOpacity;
  FShadow.Enabled := True;

  FContentHost := TLayout.Create(Self);
  FContentHost.Parent := FContainer;
  FContentHost.Align := TAlignLayout.Client;
  FContentHost.HitTest := True;

  FResizeHandle := TPaintBox.Create(Self);
  FResizeHandle.Parent := FContainer;
  FResizeHandle.Align := TAlignLayout.None;
  FResizeHandle.SetBounds(0, 0, CPopupResizeHandleSize,
    CPopupResizeHandleSize);
  FResizeHandle.AutoCapture := True;
  FResizeHandle.HitTest := True;
  FResizeHandle.Cursor := crSizeNWSE;
  FResizeHandle.OnPaint := ResizeHandlePaint;
  FResizeHandle.OnMouseEnter := ResizeHandleMouseEnter;
  FResizeHandle.OnMouseLeave := ResizeHandleMouseLeave;
  FResizeHandle.OnMouseDown := ResizeHandleMouseDown;
  FResizeHandle.OnMouseMove := ResizeHandleMouseMove;
  FResizeHandle.OnMouseUp := ResizeHandleMouseUp;
  UpdateResizeHandle;
end;

procedure TUniPopupHost.DestroyPopupControls;
var
  OverlayToFree: TLayout;
begin
  OverlayToFree := FOverlay;
  FOverlay := nil;
  FContainer := nil;
  FContentHost := nil;
  FResizeHandle := nil;
  FShadow := nil;
  if OverlayToFree = nil then
    Exit;
  OverlayToFree.Parent := nil;
  OverlayToFree.Free;
end;

function TUniPopupHost.DesiredPopupSize: TSizeF;
var
  AvailableHeight: Single;
  AvailableWidth: Single;
  AnchorRect: TRectF;
begin
  Result := TSizeF.Create(CPopupDefaultWidth, CPopupDefaultMaxHeight);
  if (FContent = nil) or (FOverlay = nil) then
    Exit;

  AnchorRect := CurrentAnchorRect;
  AvailableWidth := Max(0, FOverlay.Width - CPopupScreenMargin * 2);
  AvailableHeight := Max(0, FOverlay.Height - CPopupScreenMargin * 2);
  if FHasSessionUserSize then
  begin
    Result := FUserSize;
    Result := ConstrainPopupSize(Result, AvailableWidth, AvailableHeight);
  end
  else
  begin
    case FWidthMode of
      upwAnchor:
        Result.Width := AnchorRect.Width;
      upwContent:
        begin
          Result.Width := Max(AnchorRect.Width, FOriginalSize.Width);
          if FMaxPopupWidth > 0 then
            Result.Width := Min(Result.Width, FMaxPopupWidth);
          Result.Width := EnsureRange(Result.Width,
            Min(FMinPopupWidth, AvailableWidth), AvailableWidth);
        end;
      upwFixed:
        Result.Width := FPopupWidth;
    end;
    if FWidthMode <> upwContent then
      Result.Width := EnsureRange(Result.Width, 0, AvailableWidth);
    Result.Height := FOriginalSize.Height;
    if FResizable then
      Result.Height := Result.Height + CPopupResizeHandleSize;
    if FMaxPopupHeight > 0 then
      Result.Height := Min(Result.Height, FMaxPopupHeight);
    Result.Height := EnsureRange(Result.Height, 0, AvailableHeight);
  end;
end;

function TUniPopupHost.ConstrainPopupSize(const ASize: TSizeF;
  const AAvailableWidth, AAvailableHeight: Single): TSizeF;
var
  MaximumHeight: Single;
  MaximumWidth: Single;
  MinimumHeight: Single;
  MinimumWidth: Single;
begin
  MaximumWidth := Max(0, AAvailableWidth);
  if FMaxPopupWidth > 0 then
    MaximumWidth := Min(MaximumWidth, FMaxPopupWidth);
  MinimumWidth := Min(MaximumWidth, Max(0, FMinPopupWidth));

  MaximumHeight := Max(0, AAvailableHeight);
  if FMaxPopupHeight > 0 then
    MaximumHeight := Min(MaximumHeight, FMaxPopupHeight);
  MinimumHeight := Min(MaximumHeight, Max(0, FMinPopupHeight));

  Result.Width := EnsureRange(ASize.Width, MinimumWidth, MaximumWidth);
  Result.Height := EnsureRange(ASize.Height, MinimumHeight, MaximumHeight);
end;

function TUniPopupHost.CurrentAnchorRect: TRectF;
begin
  Result := TRectF.Empty;
  if (FAnchor = nil) or (FOverlay = nil) then
    Exit;
  Result := FOverlay.AbsoluteToLocal(FAnchor.AbsoluteRect);
end;

function TUniPopupHost.GetPopupBounds: TRectF;
begin
  if FContainer = nil then
    Exit(TRectF.Empty);
  Result := FContainer.BoundsRect;
end;

procedure TUniPopupHost.PositionPopup;
var
  AnchorRect: TRectF;
  PopupSize: TSizeF;
  ClientLeft, ClientTop, ClientRight, ClientBottom: Single;
  AvailableAbove, AvailableBelow, PopupHeight, PopupX, PopupY: Single;
  OpenAbove: Boolean;
begin
  if (FOverlay = nil) or (FContainer = nil) or (FAnchor = nil) then
    Exit;

  AnchorRect := CurrentAnchorRect;
  PopupSize := DesiredPopupSize;
  ClientLeft := CPopupScreenMargin;
  ClientTop := CPopupScreenMargin;
  ClientRight := Max(ClientLeft, FOverlay.Width - CPopupScreenMargin);
  ClientBottom := Max(ClientTop, FOverlay.Height - CPopupScreenMargin);
  AvailableBelow := Max(0, ClientBottom - AnchorRect.Bottom -
    CPopupDefaultGap);
  AvailableAbove := Max(0, AnchorRect.Top - CPopupDefaultGap -
    ClientTop);

  if FHasSessionResizeOrigin then
    OpenAbove := FResolvedOpenAbove
  else
  begin
    case FPlacement of
      uppAbove:
        OpenAbove := True;
      uppBelow:
        OpenAbove := False;
    else
      OpenAbove := (PopupSize.Height > AvailableBelow) and
        (AvailableAbove > AvailableBelow);
    end;
    FResolvedOpenAbove := OpenAbove;
  end;

  if FHasSessionResizeOrigin then
  begin
    PopupSize.Width := Min(PopupSize.Width,
      Max(0, ClientRight - FResizeStartPosition.X));
    if OpenAbove then
      PopupHeight := Min(PopupSize.Height,
        Max(0, FResizeFixedBottom - ClientTop))
    else
      PopupHeight := Min(PopupSize.Height,
        Max(0, ClientBottom - FResizeStartPosition.Y));
  end
  else if OpenAbove then
    PopupHeight := Min(PopupSize.Height, AvailableAbove)
  else
    PopupHeight := Min(PopupSize.Height, AvailableBelow);
  PopupHeight := Max(0, PopupHeight);

  if FHasSessionResizeOrigin then
    PopupX := FResizeStartPosition.X
  else
    PopupX := EnsureRange(AnchorRect.Left, ClientLeft,
      Max(ClientLeft, ClientRight - PopupSize.Width));
  if FHasSessionResizeOrigin then
  begin
    if OpenAbove then
      PopupY := FResizeFixedBottom - PopupHeight
    else
      PopupY := FResizeStartPosition.Y;
  end
  else
  begin
    if OpenAbove then
      PopupY := AnchorRect.Top - CPopupDefaultGap - PopupHeight
    else
      PopupY := AnchorRect.Bottom + CPopupDefaultGap;
    PopupY := EnsureRange(PopupY, ClientTop,
      Max(ClientTop, ClientBottom - PopupHeight));
  end;

  if not SamePopupPosition(FContainer.Position.X, FContainer.Position.Y,
       PopupX, PopupY) or
     not SamePopupSize(FContainer.Width, FContainer.Height,
       PopupSize.Width, PopupHeight) then
  begin
    FContainer.SetBounds(PopupX, PopupY, PopupSize.Width, PopupHeight);
    UpdateResizeHandle;
  end;
end;

procedure TUniPopupHost.UpdateResizeHandle;
var
  HandleChanged: Boolean;
  HandleVisible: Boolean;
  NewMarginBottom: Single;
  NewPosition: TPointF;
begin
  HandleChanged := False;
  if FContentHost <> nil then
  begin
    if FResizable then
      NewMarginBottom := CPopupResizeHandleSize
    else
      NewMarginBottom := 0;
    if not SameValue(FContentHost.Margins.Bottom, NewMarginBottom,
      TEpsilon.Position) then
      FContentHost.Margins.Bottom := NewMarginBottom;
  end;
  if FResizeHandle = nil then
    Exit;
  HandleVisible := FResizable and (FContainer <> nil);
  if FResizeHandle.Visible <> HandleVisible then
  begin
    FResizeHandle.Visible := HandleVisible;
    HandleChanged := True;
  end;
  if FResizeHandle.HitTest <> HandleVisible then
  begin
    FResizeHandle.HitTest := HandleVisible;
    HandleChanged := True;
  end;
  if not HandleVisible then
  begin
    if HandleChanged then
      FResizeHandle.Repaint;
    Exit;
  end;
  NewPosition := PointF(
    Max(0, FContainer.Width - CPopupResizeHandleSize),
    Max(0, FContainer.Height - CPopupResizeHandleSize));
  if not SamePopupPosition(FResizeHandle.Position.X,
    FResizeHandle.Position.Y, NewPosition.X, NewPosition.Y) then
  begin
    FResizeHandle.Position.Point := NewPosition;
    HandleChanged := True;
  end;
  if not IsFrontmostChild(FContainer, FResizeHandle) then
  begin
    FResizeHandle.BringToFront;
    HandleChanged := True;
  end;
  if HandleChanged then
    FResizeHandle.Repaint;
end;

procedure TUniPopupHost.ResetResizeState;
var
  StateChanged: Boolean;
begin
  StateChanged := FIsResizing or FResizeHovered;
  FIsResizing := False;
  FResizeHovered := False;
  if StateChanged and (FResizeHandle <> nil) then
    FResizeHandle.Repaint;
end;

procedure TUniPopupHost.ResizeHandlePaint(Sender: TObject;
  Canvas: TCanvas);
var
  HandleControl: TPaintBox;
  LineIndex: Integer;
  LineOffset: Single;
  LineOpacity: Single;
begin
  if not FResizable or (FResizeHandle = nil) then
    Exit;
  HandleControl := FResizeHandle;
  if FIsResizing then
    LineOpacity := CPopupResizePressedOpacity
  else if FResizeHovered then
    LineOpacity := CPopupResizeHoverOpacity
  else
    LineOpacity := CPopupResizeNormalOpacity;
  if (FAnchor = nil) or not FAnchor.AbsoluteEnabled then
    LineOpacity := LineOpacity * CPopupResizeNormalOpacity;

  Canvas.Stroke.Kind := TBrushKind.Solid;
  Canvas.Stroke.Color := FTextContrastColor;
  Canvas.Stroke.Thickness := CPopupResizeLineThickness;
  for LineIndex := 1 to 3 do
  begin
    LineOffset := CPopupResizeLineInset +
      LineIndex * CPopupResizeLineSpacing;
    Canvas.DrawLine(
      PointF(HandleControl.Width - LineOffset,
        HandleControl.Height - CPopupResizeLineInset),
      PointF(HandleControl.Width - CPopupResizeLineInset,
        HandleControl.Height - LineOffset),
      LineOpacity);
  end;
end;

procedure TUniPopupHost.ResizeHandleMouseEnter(Sender: TObject);
begin
  if not FResizable then
    Exit;
  FResizeHovered := True;
  if FResizeHandle <> nil then
      FResizeHandle.Repaint;
end;

procedure TUniPopupHost.ResizeHandleMouseLeave(Sender: TObject);
begin
  FResizeHovered := False;
  if (FResizeHandle <> nil) and not FIsResizing then
      FResizeHandle.Repaint;
end;

procedure TUniPopupHost.ResizeHandleMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if not FResizable or not FIsOpen then
    Exit;
  if Button <> TMouseButton.mbLeft then
    Exit;
  if (FResizeHandle = nil) or (FContainer = nil) then
    Exit;

  FIsResizing := True;
  FResizeStartPoint :=
    FResizeHandle.LocalToAbsolute(PointF(X, Y));
  FResizeStartSize := FContainer.Size.Size;
  FResizeStartPosition := FContainer.Position.Point;
  FResizeFixedBottom := FContainer.BoundsRect.Bottom;
  FUserSize := FResizeStartSize;
  FHasSessionUserSize := True;
  FHasSessionResizeOrigin := True;
  FResizeHandle.Repaint;
end;

procedure TUniPopupHost.ResizeHandleMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Single);
var
  AvailableHeight: Single;
  AvailableWidth: Single;
  CurrentPoint: TPointF;
  NewPosition: TPointF;
  NewSize: TSizeF;
begin
  if not FIsResizing then
    Exit;
  if (FResizeHandle = nil) or (FContainer = nil) or
     (FOverlay = nil) then
  begin
    ResetResizeState;
    Exit;
  end;

  CurrentPoint := FResizeHandle.LocalToAbsolute(PointF(X, Y));
  NewSize.Width := FResizeStartSize.Width +
    CurrentPoint.X - FResizeStartPoint.X;
  NewSize.Height := FResizeStartSize.Height +
    CurrentPoint.Y - FResizeStartPoint.Y;
  AvailableWidth := Max(0, FOverlay.Width - CPopupScreenMargin -
    FResizeStartPosition.X);
  if FResolvedOpenAbove then
    AvailableHeight := Max(0, FResizeFixedBottom - CPopupScreenMargin)
  else
    AvailableHeight := Max(0, FOverlay.Height - CPopupScreenMargin -
      FResizeStartPosition.Y);
  NewSize := ConstrainPopupSize(NewSize, AvailableWidth, AvailableHeight);

  NewPosition := FResizeStartPosition;
  if FResolvedOpenAbove then
    NewPosition.Y := FResizeFixedBottom - NewSize.Height;
  if not SamePopupPosition(FContainer.Position.X, FContainer.Position.Y,
       NewPosition.X, NewPosition.Y) or
     not SamePopupSize(FContainer.Width, FContainer.Height,
       NewSize.Width, NewSize.Height) then
    FContainer.SetBounds(NewPosition.X, NewPosition.Y,
      NewSize.Width, NewSize.Height);
  FUserSize := NewSize;
  if FRememberUserSize then
    FHasRememberedUserSize := True;
  UpdateResizeHandle;
end;

procedure TUniPopupHost.ResizeHandleMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if Button <> TMouseButton.mbLeft then
    Exit;
  if not FIsResizing then
    Exit;
  FIsResizing := False;
  if FRememberUserSize then
    FHasRememberedUserSize := True;
  if FResizeHandle <> nil then
      FResizeHandle.Repaint;
end;

procedure TUniPopupHost.OverlayMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if not FIsOpen then
    Exit;
  if FIsResizing then
    Exit;
  if not FCloseOnOutsideClick then
    Exit;
  if (FContainer <> nil) and
     FContainer.BoundsRect.Contains(PointF(X, Y)) then
    Exit;
  InternalClose(upcrOutsideClick);
end;

procedure TUniPopupHost.FormKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
var
  PreviousHandler: TKeyEvent;
begin
  if FIsOpen and FCloseOnEscape and (Key = vkEscape) then
  begin
    InternalClose(upcrEscape);
    Key := 0;
    KeyChar := #0;
    Exit;
  end;
  PreviousHandler := FPreviousFormKeyDown;
  if Assigned(PreviousHandler) then
    PreviousHandler(Sender, Key, KeyChar, Shift);
end;

procedure TUniPopupHost.MonitorTimer(Sender: TObject);
begin
  if not FIsOpen then
    Exit;
  if (FForm = nil) or not FForm.Visible then
  begin
    InternalClose(upcrOwnerHidden);
    Exit;
  end;
  if (FAnchor = nil) or not FAnchor.ParentedVisible then
  begin
    InternalClose(upcrOwnerHidden);
    Exit;
  end;
  PositionPopup;
end;

function TUniPopupHost.FindFocusableControl(
  const AControl: TControl): TControl;
var
  ChildIndex: Integer;
begin
  Result := nil;
  if AControl = nil then
    Exit;
  if AControl.CanFocus and AControl.Enabled and AControl.ParentedVisible then
    Exit(AControl);
  for ChildIndex := 0 to AControl.ChildrenCount - 1 do
    if AControl.Children[ChildIndex] is TControl then
    begin
      Result := FindFocusableControl(TControl(AControl.Children[ChildIndex]));
      if Result <> nil then
        Exit;
    end;
end;

procedure TUniPopupHost.FocusPopupContent;
var
  FocusControl: TControl;
begin
  FocusControl := FindFocusableControl(FContent);
  if FocusControl = nil then
    Exit;
  try
    FocusControl.SetFocus;
  except
    { Some styled controls cannot accept focus until their presentation
      has been created. A popup must still remain usable in that case. }
  end;
end;

function TUniPopupHost.FormKeyHandlerIsInstalled: Boolean;
var
  CurrentMethod, HostMethod: TMethod;
  HostHandler: TKeyEvent;
begin
  Result := False;
  if FForm = nil then
    Exit;
  CurrentMethod := TMethod(FForm.OnKeyDown);
  HostHandler := FormKeyDown;
  HostMethod := TMethod(HostHandler);
  Result := (CurrentMethod.Code = HostMethod.Code) and
    (CurrentMethod.Data = HostMethod.Data);
end;

procedure TUniPopupHost.AddPopupFreeNotifications;
begin
  if FAnchor <> nil then
    FAnchor.FreeNotification(Self);
  if FContent <> nil then
    FContent.FreeNotification(Self);
  if FForm <> nil then
    FForm.FreeNotification(Self);
  if FOriginalParent is TComponent then
    TComponent(FOriginalParent).FreeNotification(Self);
  if FPreviousFocused <> nil then
    FPreviousFocused.FreeNotification(Self);
end;

procedure TUniPopupHost.RemovePopupFreeNotifications;
begin
  if FAnchor <> nil then
    FAnchor.RemoveFreeNotification(Self);
  if FContent <> nil then
    FContent.RemoveFreeNotification(Self);
  if FForm <> nil then
    FForm.RemoveFreeNotification(Self);
  if FOriginalParent is TComponent then
    TComponent(FOriginalParent).RemoveFreeNotification(Self);
  if FPreviousFocused <> nil then
    FPreviousFocused.RemoveFreeNotification(Self);
end;

procedure TUniPopupHost.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if Operation <> opRemove then
    Exit;
  if FClosing then
    Exit;

  if AComponent = FAnchor then
  begin
    FAnchor := nil;
    InternalClose(upcrOwnerDestroyed);
    Exit;
  end;
  if AComponent = FContent then
  begin
    FContent := nil;
    InternalClose(upcrOwnerDestroyed);
    Exit;
  end;
  if AComponent = FForm then
  begin
    FForm := nil;
    FOriginalParent := nil;
    InternalClose(upcrOwnerDestroyed);
    Exit;
  end;
  if AComponent = FOriginalParent then
  begin
    FOriginalParent := nil;
    InternalClose(upcrOwnerDestroyed);
    Exit;
  end;
  if AComponent = FPreviousFocused then
    FPreviousFocused := nil;
end;

procedure Register;
begin
  RegisterComponents('UniListView', [TUniPopupHost]);
end;

end.
