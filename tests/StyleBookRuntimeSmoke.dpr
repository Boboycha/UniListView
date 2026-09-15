program StyleBookRuntimeSmoke;

{$APPTYPE CONSOLE}

uses
  System.SysUtils, System.Classes, System.UITypes, System.Messaging,
  FMX.Forms, FMX.Types, FMX.Controls, FMX.Graphics, FMX.Objects,
  UniList.Control, UniList.Theme;

procedure Require(const Condition: Boolean; const MessageText: string);
begin
  if not Condition then raise Exception.Create(MessageText);
end;

procedure Run;
var
  Form, OtherForm: TForm;
  List: TUniListView;
  DarkBook, BitmapBook: TStyleBook;
  OwnBackground, OwnCard, StyledBackground: TAlphaColor;
  Resource: TFmxObject;
  Bitmap: TBitmap;
  Layout: string;
  Stream: TMemoryStream;
  RestoredList: TUniListView;
begin
  Form := TForm.CreateNew(nil);
  OtherForm := TForm.CreateNew(nil);
  try
    Form.SetBounds(100, 100, 900, 600);
    DarkBook := TStyleBook.Create(Form);
    DarkBook.LoadFromFile(ParamStr(1) + '\Dark.style');
    BitmapBook := TStyleBook.Create(Form);
    BitmapBook.LoadFromFile(ParamStr(1) + '\Win10ModernSlateGray.style');
    List := TUniListView.Create(Form);
    List.Parent := Form;
    List.Align := TAlignLayout.Client;
    List.AddItem('Alpha', 'StyleBook palette', 'Ready');
    List.AddItem('Beta', 'Own themes remain available', 'Idle');
    List.SelectedIndex := 0;
    List.ThemeName := 'Nord Light';
    List.CardColor := $FF123456;
    OwnBackground := List.BackgroundColor;
    OwnCard := List.CardColor;
    Form.StyleBook := DarkBook;
    Require(List.BackgroundColor = OwnBackground, 'Default mode followed StyleBook');
    List.UseStyleBook := True;
    Require(List.ThemeName = 'Nord Light', 'StyleBook replaced own theme name');
    Require(List.ThemeVariant = utvDark, 'Dark style was not detected');
    Require(List.BackgroundColor <> OwnBackground, 'Style colors were not applied');
    StyledBackground := List.BackgroundColor;
    Form.StyleBook := BitmapBook;
    Require(List.BackgroundColor <> StyledBackground, 'Bitmap style replacement was not applied');
    Writeln('Bitmap style background: ', IntToHex(List.BackgroundColor, 8));
    Form.StyleBook := DarkBook;
    Require(List.BackgroundColor = StyledBackground, 'Dark style did not return');
    List.UseStyleBook := False;
    Require(List.BackgroundColor = OwnBackground, 'Own background was not restored');
    Require(List.CardColor = OwnCard, 'Own color override was not restored');
    List.UseStyleBook := True;
    List.ThemeName := List.ThemeName;
    Require(not List.UseStyleBook, 'Same theme name did not select own theme');
    Require(List.CardColor = OwnCard, 'Same theme name lost own overrides');
    List.UseStyleBook := True;
    Form.StyleBook := nil;
    Require(List.BackgroundColor = OwnBackground, 'Missing StyleBook did not use own theme');
    Form.StyleBook := DarkBook;
    List.Parent := OtherForm;
    Require(List.BackgroundColor = OwnBackground, 'Reparenting did not refresh palette');
    List.Parent := Form;
    Require(List.BackgroundColor = StyledBackground, 'Reparenting back did not refresh palette');
    Resource := TBrushObject.Create(nil);
    Resource.StyleName := 'unilistbackground';
    TBrushObject(Resource).Brush.Color := $FF203040;
    Resource.Parent := DarkBook.Style;
    List.RefreshStyleBook;
    Require(List.BackgroundColor = $FF203040, 'Semantic palette resource was ignored');
    Layout := List.SaveLayoutToJSON;
    List.UseStyleBook := False;
    List.LoadLayoutFromJSON(Layout);
    Require(List.UseStyleBook, 'Layout lost StyleBook mode');
    Stream := TMemoryStream.Create;
    RestoredList := TUniListView.Create(nil);
    try
      Stream.WriteComponent(List);
      Stream.Position := 0;
      RestoredList.Parent := Form;
      Stream.ReadComponent(RestoredList);
      Require(RestoredList.UseStyleBook, 'Component streaming lost StyleBook mode');
      Require(RestoredList.BackgroundColor = $FF203040, 'Loaded component missed form palette');
    finally
      RestoredList.Free;
      Stream.Free;
    end;
    Require(List.Items.Count = 2, 'Theme switching changed data');
    Require(List.SelectedIndex = 0, 'Theme switching changed selection');
    Form.Show;
    Application.ProcessMessages;
    Bitmap := List.MakeScreenshot;
    try Bitmap.SaveToFile('StyleBookRuntimeSmoke-wide.png'); finally Bitmap.Free; end;
    Form.Width := 420;
    Application.ProcessMessages;
    Bitmap := List.MakeScreenshot;
    try Bitmap.SaveToFile('StyleBookRuntimeSmoke-narrow.png'); finally Bitmap.Free; end;
    Form.Hide;
    DarkBook.Free;
    Require(List.BackgroundColor = OwnBackground, 'StyleBook destruction did not restore own theme');
  finally
    OtherForm.Free;
    Form.Free;
  end;
end;

begin
  try
    Application.Initialize;
    Run;
    Writeln('StyleBookRuntimeSmoke OK');
  except
    on E: Exception do
    begin
      Writeln(E.ClassName, ': ', E.Message);
      ExitCode := 1;
    end;
  end;
end.
