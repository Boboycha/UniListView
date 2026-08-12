program ThemeUiTest;

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Math,
  FMX.Forms,
  FMX.Types,
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  FMX.Layouts,
  FMX.Objects,
  FMX.Graphics,
  FMX.Edit,
  FMX.ListBox,
  UniList.Control,
  UniList.Types,
  UniList.Columns,
  UniList.Items,
  UniList.Theme;

type
  TThemeUiTestForm = class(TForm)
  private
    FRoot: TLayout;
    FTopBar: TRectangle;
    FTitle: TLabel;
    FThemeCombo: TComboBox;
    FSampleButton: TButton;
    FSampleEdit: TEdit;
    FInfoLabel: TLabel;
    FBody: TLayout;
    FListView: TUniListView;
    FCardsView: TUniListView;
    FTreeView: TUniListView;
    procedure BuildUi;
    procedure FillList(const AList: TUniListView; const ATree: Boolean = False);
    procedure ThemeComboChange(Sender: TObject);
    procedure ApplyTheme(const AThemeName: string);
    procedure ApplyStandardPalette(const ATheme: TUniThemeDefinition);
    procedure StyleButton(const AButton: TButton; const ATheme: TUniThemeDefinition);
    procedure StyleEdit(const AEdit: TEdit; const ATheme: TUniThemeDefinition);
  public
    constructor Create(AOwner: TComponent); override;
  end;

constructor TThemeUiTestForm.Create(AOwner: TComponent);
begin
  inherited;
  Caption := 'UniListView Theme UI Test';
  Width := 1180;
  Height := 760;
  BuildUi;
  ApplyTheme('Termius Light');
end;

procedure TThemeUiTestForm.BuildUi;
var
  ThemeName: string;
begin
  FRoot := TLayout.Create(Self);
  FRoot.Parent := Self;
  FRoot.Align := TAlignLayout.Client;

  FTopBar := TRectangle.Create(Self);
  FTopBar.Parent := FRoot;
  FTopBar.Align := TAlignLayout.Top;
  FTopBar.Height := 92;
  FTopBar.Stroke.Kind := TBrushKind.None;

  FTitle := TLabel.Create(Self);
  FTitle.Parent := FTopBar;
  FTitle.Position.X := 16;
  FTitle.Position.Y := 12;
  FTitle.Width := 360;
  FTitle.Height := 28;
  FTitle.Text := 'UniListView Theme UI Test';
  FTitle.StyledSettings := [];
  FTitle.TextSettings.Font.Size := 20;

  FThemeCombo := TComboBox.Create(Self);
  FThemeCombo.Parent := FTopBar;
  FThemeCombo.Position.X := 16;
  FThemeCombo.Position.Y := 48;
  FThemeCombo.Width := 260;
  FThemeCombo.Height := 32;
  for ThemeName in TUniThemeManager.ThemeNames do
    FThemeCombo.Items.Add(ThemeName);
  FThemeCombo.OnChange := ThemeComboChange;

  FSampleButton := TButton.Create(Self);
  FSampleButton.Parent := FTopBar;
  FSampleButton.Position.X := 292;
  FSampleButton.Position.Y := 48;
  FSampleButton.Width := 130;
  FSampleButton.Height := 32;
  FSampleButton.Text := 'FMX Button';

  FSampleEdit := TEdit.Create(Self);
  FSampleEdit.Parent := FTopBar;
  FSampleEdit.Position.X := 438;
  FSampleEdit.Position.Y := 48;
  FSampleEdit.Width := 220;
  FSampleEdit.Height := 32;
  FSampleEdit.Text := 'FMX Edit';

  FInfoLabel := TLabel.Create(Self);
  FInfoLabel.Parent := FTopBar;
  FInfoLabel.Position.X := 680;
  FInfoLabel.Position.Y := 48;
  FInfoLabel.Width := 450;
  FInfoLabel.Height := 32;
  FInfoLabel.StyledSettings := [];

  FBody := TLayout.Create(Self);
  FBody.Parent := FRoot;
  FBody.Align := TAlignLayout.Client;
  FBody.Padding.Rect := RectF(12, 12, 12, 12);

  FListView := TUniListView.Create(Self);
  FListView.Parent := FBody;
  FListView.Align := TAlignLayout.Left;
  FListView.Width := 360;
  FListView.Margins.Right := 12;
  FListView.ViewMode := uvmList;
  FListView.TreeMode := False;
  FillList(FListView);

  FCardsView := TUniListView.Create(Self);
  FCardsView.Parent := FBody;
  FCardsView.Align := TAlignLayout.Client;
  FCardsView.Margins.Right := 12;
  FCardsView.ViewMode := uvmCards;
  FCardsView.CardLayout := uclGrid;
  FillList(FCardsView);

  FTreeView := TUniListView.Create(Self);
  FTreeView.Parent := FBody;
  FTreeView.Align := TAlignLayout.Right;
  FTreeView.Width := 360;
  FTreeView.ViewMode := uvmList;
  FTreeView.TreeMode := True;
  FTreeView.TreeKeyField := 'id';
  FTreeView.TreeParentField := 'parentid';
  FTreeView.TreeColumn := 'name';
  FillList(FTreeView, True);
end;

procedure TThemeUiTestForm.FillList(const AList: TUniListView; const ATree: Boolean);
var
  Item: TUniListItem;
begin
  AList.BeginUpdate;
  try
    AList.Clear;
    if ATree then
    begin
      Item := AList.AddItem('Production', 'group', '3 nodes');
      Item.ID := 'prod';
      Item.IconText := 'P';
      Item.SetField('checked', True);

      Item := AList.AddItem('API Server', '172.16.24.237', 'online');
      Item.ID := 'api';
      Item.ParentID := 'prod';
      Item.IconText := 'A';
      Item.SetField('checked', True);

      Item := AList.AddItem('Proxy Server', '172.16.24.238', 'idle');
      Item.ID := 'proxy';
      Item.ParentID := 'prod';
      Item.IconText := 'X';
      Item.SetField('checked', False);

      Item := AList.AddItem('Local Lab', 'group', '2 nodes');
      Item.ID := 'lab';
      Item.IconText := 'L';
      Item.SetField('checked', False);
    end
    else
    begin
      Item := AList.AddItem('API Server', '172.16.24.237', 'nbhas@172.16.24.237:22');
      Item.IconText := 'API';
      Item.SetField('checked', True);

      Item := AList.AddItem('Proxy Server', '172.16.24.238', 'proxy@172.16.24.238:5433');
      Item.IconText := 'PX';
      Item.SetField('checked', False);

      Item := AList.AddItem('Build Agent', '192.168.10.44', 'builder@192.168.10.44');
      Item.IconText := 'CI';
      Item.SetField('checked', True);
    end;
  finally
    AList.EndUpdate;
  end;
  AList.SelectedIndex := 0;
end;

procedure TThemeUiTestForm.ThemeComboChange(Sender: TObject);
begin
  if FThemeCombo.ItemIndex >= 0 then
    ApplyTheme(FThemeCombo.Items[FThemeCombo.ItemIndex]);
end;

procedure TThemeUiTestForm.ApplyTheme(const AThemeName: string);
var
  I: Integer;
  Theme: TUniThemeDefinition;
begin
  Theme := TUniThemeManager.Find(AThemeName);
  if Theme = nil then
    Exit;

  for I := 0 to FThemeCombo.Items.Count - 1 do
    if SameText(FThemeCombo.Items[I], AThemeName) then
    begin
      FThemeCombo.ItemIndex := I;
      Break;
    end;

  FListView.ThemeName := AThemeName;
  FCardsView.ThemeName := AThemeName;
  FTreeView.ThemeName := AThemeName;
  ApplyStandardPalette(Theme);
end;

procedure TThemeUiTestForm.ApplyStandardPalette(const ATheme: TUniThemeDefinition);
var
  Surface: TAlphaColor;
  Border: TAlphaColor;
  Muted: TAlphaColor;
begin
  Surface := UniBlendColor(ATheme.Background, ATheme.Foreground,
    IfThen(ATheme.Variant = utvDark, 0.075, 0.035));
  Border := UniBlendColor(ATheme.Background, ATheme.TerminalUI, 0.48);
  Muted := UniBlendColor(ATheme.Foreground, ATheme.Background, 0.38);

  Fill.Color := ATheme.Background;
  FTopBar.Fill.Color := Surface;
  FTopBar.Stroke.Kind := TBrushKind.Solid;
  FTopBar.Stroke.Color := Border;
  FTitle.TextSettings.FontColor := ATheme.Foreground;
  FInfoLabel.TextSettings.FontColor := Muted;
  if ATheme.Variant = utvDark then
    FInfoLabel.Text := ATheme.Name + ' / dark'
  else
    FInfoLabel.Text := ATheme.Name + ' / light';

  StyleButton(FSampleButton, ATheme);
  StyleEdit(FSampleEdit, ATheme);
end;

procedure TThemeUiTestForm.StyleButton(const AButton: TButton; const ATheme: TUniThemeDefinition);
begin
  AButton.TextSettings.FontColor := ATheme.Foreground;
  AButton.StyledSettings := AButton.StyledSettings - [TStyledSetting.FontColor];
end;

procedure TThemeUiTestForm.StyleEdit(const AEdit: TEdit; const ATheme: TUniThemeDefinition);
begin
  AEdit.TextSettings.FontColor := ATheme.Foreground;
  AEdit.StyledSettings := AEdit.StyledSettings - [TStyledSetting.FontColor];
end;

var
  Form: TThemeUiTestForm;

begin
  Application.Initialize;
  Application.CreateForm(TThemeUiTestForm, Form);
  Application.Run;
end.

