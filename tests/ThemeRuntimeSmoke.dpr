program ThemeRuntimeSmoke;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.UITypes,
  FMX.Forms,
  UniList.Control,
  UniList.Columns,
  UniList.Items,
  UniList.Theme;

procedure FillFlat(AList: TUniListView);
var
  Item: TUniListItem;
begin
  AList.BeginUpdate;
  try
    AList.Clear;
    Item := AList.AddItem('Alpha', 'primary', 'ready');
    Item.ID := '1';
    Item.SetField('checked', True);
    Item := AList.AddItem('Beta', 'secondary', 'idle');
    Item.ID := '2';
    Item.SetField('checked', False);
  finally
    AList.EndUpdate;
  end;
end;

procedure FillTree(AList: TUniListView);
var
  Item: TUniListItem;
begin
  AList.TreeMode := True;
  AList.TreeKeyField := 'id';
  AList.TreeParentField := 'parentid';
  AList.BeginUpdate;
  try
    AList.Clear;
    Item := AList.AddItem('Root', 'group', '');
    Item.ID := 'root';
    Item.SetField('checked', True);
    Item := AList.AddItem('Child', 'node', '');
    Item.ID := 'child';
    Item.ParentID := 'root';
    Item.SetField('checked', False);
  finally
    AList.EndUpdate;
  end;
end;

procedure Require(const ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

var
  ListView: TUniListView;
  CardsView: TUniListView;
  TreeView: TUniListView;
  ListPtr: Pointer;
  CardsPtr: Pointer;
  TreePtr: Pointer;
  LightBackground: TAlphaColor;
  DarkBackground: TAlphaColor;
begin
  Application.Initialize;

  ListView := TUniListView.Create(nil);
  CardsView := TUniListView.Create(nil);
  TreeView := TUniListView.Create(nil);
  try
    ListView.ViewMode := uvmList;
    CardsView.ViewMode := uvmCards;
    TreeView.ViewMode := uvmList;
    FillFlat(ListView);
    FillFlat(CardsView);
    FillTree(TreeView);

    ListPtr := Pointer(ListView);
    CardsPtr := Pointer(CardsView);
    TreePtr := Pointer(TreeView);

    ListView.ThemeName := 'Termius Light';
    CardsView.ThemeName := 'Termius Light';
    TreeView.ThemeName := 'Termius Light';
    LightBackground := ListView.BackgroundColor;

    ListView.SelectedIndex := 0;
    CardsView.SelectedIndex := 1;
    TreeView.SelectedIndex := 0;

    ListView.ThemeName := 'Termius Dark';
    CardsView.ThemeName := 'Termius Dark';
    TreeView.ThemeName := 'Termius Dark';
    DarkBackground := ListView.BackgroundColor;

    Require(Pointer(ListView) = ListPtr, 'ListView was recreated');
    Require(Pointer(CardsView) = CardsPtr, 'CardsView was recreated');
    Require(Pointer(TreeView) = TreePtr, 'TreeView was recreated');
    Require(ListView.ThemeVariant = utvDark, 'List theme variant was not updated');
    Require(CardsView.ThemeVariant = utvDark, 'Cards theme variant was not updated');
    Require(TreeView.ThemeVariant = utvDark, 'Tree theme variant was not updated');
    Require(LightBackground <> DarkBackground, 'Theme colors did not change');
    Require(ListView.Items.Count = 2, 'List data was lost');
    Require(CardsView.Items.Count = 2, 'Cards data was lost');
    Require(TreeView.Items.Count = 2, 'Tree data was lost');
    Require(ListView.SelectedIndex = 0, 'List selection was lost');
    Require(CardsView.SelectedIndex = 1, 'Cards selection was lost');
    Require(TreeView.SelectedIndex = 0, 'Tree selection was lost');

    Writeln('ThemeRuntimeSmoke OK');
    Writeln('Themes: ', TUniThemeManager.Count);
    Writeln('Light background: $', IntToHex(LightBackground, 8));
    Writeln('Dark background: $', IntToHex(DarkBackground, 8));
  finally
    TreeView.Free;
    CardsView.Free;
    ListView.Free;
  end;
end.

