unit ThemeUiDesignTest.MainForm;

interface

uses
  System.SysUtils, System.Classes, System.UITypes, System.Math,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Layouts, FMX.Objects, FMX.StdCtrls, FMX.ListBox, FMX.Edit,
  FMX.Controls.Presentation,
  UniList.Control, UniList.Columns, UniList.Items, UniList.Theme, UniList.Types;

type
  TThemeUiDesignTestForm = class(TForm)
    RootLayout: TLayout;
    TopBar: TRectangle;
    TitleLabel: TLabel;
    ThemeCombo: TComboBox;
    SampleButton: TButton;
    SampleEdit: TEdit;
    InfoLabel: TLabel;
    BodyLayout: TLayout;
    ListPanel: TLayout;
    ListTitleLabel: TLabel;
    ListView: TUniListView;
    CardsPanel: TLayout;
    CardsTitleLabel: TLabel;
    CardsView: TUniListView;
    TreePanel: TLayout;
    TreeTitleLabel: TLabel;
    TreeView: TUniListView;
    procedure FormCreate(Sender: TObject);
    procedure ThemeComboChange(Sender: TObject);
  private
    procedure FillThemes;
    procedure FillList(const AList: TUniListView; const ATree: Boolean = False);
    procedure ApplyTheme(const AThemeName: string);
    procedure ApplyStandardPalette(const ATheme: TUniThemeDefinition);
    procedure ApplyLabelColor(const ALabel: TLabel; const AColor: TAlphaColor);  end;

var
  ThemeUiDesignTestForm: TThemeUiDesignTestForm;

implementation

{$R *.fmx}

procedure TThemeUiDesignTestForm.FormCreate(Sender: TObject);
begin
  FillThemes;
  FillList(ListView);
  FillList(CardsView);
  FillList(TreeView, True);
  ApplyTheme('Termius Light');
end;

procedure TThemeUiDesignTestForm.FillThemes;
var
  ThemeName: string;
begin
  ThemeCombo.Items.BeginUpdate;
  try
    ThemeCombo.Items.Clear;
    for ThemeName in TUniThemeManager.ThemeNames do
      ThemeCombo.Items.Add(ThemeName);
  finally
    ThemeCombo.Items.EndUpdate;
  end;
end;

procedure TThemeUiDesignTestForm.FillList(const AList: TUniListView;
  const ATree: Boolean);
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

procedure TThemeUiDesignTestForm.ThemeComboChange(Sender: TObject);
begin
  if ThemeCombo.ItemIndex >= 0 then
    ApplyTheme(ThemeCombo.Items[ThemeCombo.ItemIndex]);
end;

procedure TThemeUiDesignTestForm.ApplyTheme(const AThemeName: string);
var
  I: Integer;
  Theme: TUniThemeDefinition;
begin
  Theme := TUniThemeManager.Find(AThemeName);
  if Theme = nil then
    Exit;

  for I := 0 to ThemeCombo.Items.Count - 1 do
    if SameText(ThemeCombo.Items[I], AThemeName) then
    begin
      ThemeCombo.ItemIndex := I;
      Break;
    end;

  ListView.ThemeName := AThemeName;
  CardsView.ThemeName := AThemeName;
  TreeView.ThemeName := AThemeName;
  ApplyStandardPalette(Theme);
end;

procedure TThemeUiDesignTestForm.ApplyStandardPalette(
  const ATheme: TUniThemeDefinition);
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
  TopBar.Fill.Color := Surface;
  TopBar.Stroke.Kind := TBrushKind.Solid;
  TopBar.Stroke.Color := Border;

  ApplyLabelColor(TitleLabel, ATheme.Foreground);
  ApplyLabelColor(InfoLabel, Muted);
  ApplyLabelColor(ListTitleLabel, ATheme.Foreground);
  ApplyLabelColor(CardsTitleLabel, ATheme.Foreground);
  ApplyLabelColor(TreeTitleLabel, ATheme.Foreground);

  SampleButton.StyledSettings := SampleButton.StyledSettings - [TStyledSetting.FontColor];
  SampleButton.TextSettings.FontColor := ATheme.Foreground;
  SampleEdit.StyledSettings := SampleEdit.StyledSettings - [TStyledSetting.FontColor];
  SampleEdit.TextSettings.FontColor := ATheme.Foreground;

  if ATheme.Variant = utvDark then
    InfoLabel.Text := ATheme.Name + ' / dark - FMX styled backgrounds are NOT themed'
  else
    InfoLabel.Text := ATheme.Name + ' / light - FMX styled backgrounds are NOT themed';
end;

procedure TThemeUiDesignTestForm.ApplyLabelColor(const ALabel: TLabel;
  const AColor: TAlphaColor);
begin
  ALabel.StyledSettings := ALabel.StyledSettings - [TStyledSetting.FontColor];
  ALabel.TextSettings.FontColor := AColor;
end;


end.




