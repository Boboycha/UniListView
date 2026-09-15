program DemoStyleStartupSmoke;

{$APPTYPE CONSOLE}

uses
  System.SysUtils, System.Classes, System.UITypes, FMX.Forms, FMX.Skia, FMX.Graphics, UniList.Items,
  MainUnit in '..\demo\MainUnit.pas',
  JsonStressDemo in '..\demo\JsonStressDemo.pas',
  Demo.Json.StressGenerator in '..\demo\Demo.Json.StressGenerator.pas';

procedure Require(const Condition: Boolean; const MessageText: string);
begin
  if not Condition then raise Exception.Create(MessageText);
end;

var
  EmbeddedColor, LoadedColor: TAlphaColor;
  ItemCount, Selected: Integer;
  Rejected: Boolean;
  Bitmap: TBitmap;
begin
  try
    GlobalUseSkia := True;
    Application.Initialize;
    MainForm := TMainForm.Create(Application);
    Writeln('Created');
    MainForm.Show;
    Application.ProcessMessages;
    Writeln('Shown');
    Require(MainForm.UniListView1.UseStyleBook, 'Startup disabled StyleBook');
    if ParamCount > 0 then
    begin
      EmbeddedColor := MainForm.UniListView1.BackgroundColor;
      ItemCount := MainForm.UniListView1.Items.Count;
      MainForm.UniListView1.SelectedIndex := 2;
      Selected := MainForm.UniListView1.SelectedIndex;
      MainForm.LoadStyleFile(ParamStr(1) + '\Dark.style');
      Require(MainForm.StyleBook = MainForm.StyleBook1, 'Form lost its assigned StyleBook');
      Require(MainForm.UniListView1.UseStyleBook, 'File loading disabled StyleBook');
      LoadedColor := MainForm.UniListView1.BackgroundColor;
      MainForm.LoadStyleFile(ParamStr(1) + '\Win10ModernSlateGray.style');
      MainForm.LoadStyleFile(ParamStr(1) + '\Win10ModernPurple.style');
      Require(MainForm.UniListView1.BackgroundColor <> LoadedColor, 'Style did not change palette');
      LoadedColor := MainForm.UniListView1.BackgroundColor;
      Rejected := False;
      try
        MainForm.LoadStyleFile(ParamStr(1) + '\missing-style.style');
      except
        on E: Exception do Rejected := True;
      end;
      Require(Rejected, 'Missing style was accepted');
      Require(MainForm.UniListView1.BackgroundColor = LoadedColor, 'Rejected file changed palette');
      Require(MainForm.UniListView1.Items.Count = ItemCount, 'Style loading changed data');
      Require(MainForm.UniListView1.SelectedIndex = Selected, 'Style loading changed selection');
      MainForm.HoverActionsCheckBox.IsChecked := False;
      MainForm.UniListView1.Items[0].CheckState := ucsIndeterminate;
      MainForm.UniListView1.Items[1].CheckState := ucsUnchecked;
      MainForm.UniListView1.Items[2].CheckState := ucsChecked;
      MainForm.UniListView1.Repaint;
      Application.ProcessMessages;
      Bitmap := MainForm.Background.MakeScreenshot;
      try Bitmap.SaveToFile('DemoStyle-wide.png'); finally Bitmap.Free; end;
      MainForm.Width := 980;
      MainForm.HoverActionsCheckBox.IsChecked := False;
      MainForm.UniListView1.Items[0].CheckState := ucsIndeterminate;
      MainForm.UniListView1.Items[1].CheckState := ucsUnchecked;
      MainForm.UniListView1.Items[2].CheckState := ucsChecked;
      MainForm.UniListView1.Repaint;
      Application.ProcessMessages;
      Bitmap := MainForm.Background.MakeScreenshot;
      try Bitmap.SaveToFile('DemoStyle-narrow.png'); finally Bitmap.Free; end;
      MainForm.ThemeComboBox.ItemIndex := 0;
      Require(MainForm.UniListView1.BackgroundColor = EmbeddedColor, 'Embedded style was not restored');
      MainForm.ThemeComboBox.ItemIndex := 1;
      Require(MainForm.UniListView1.BackgroundColor <> EmbeddedColor, 'ComboBox did not reload file');
    end;
    MainForm.Free;
    Writeln('DemoStyleStartupSmoke OK');
  except
    on E: Exception do
    begin
      Writeln(E.ClassName, ': ', E.Message, ' at ', IntToHex(NativeUInt(ExceptAddr), 8));
      ExitCode := 1;
    end;
  end;
end.
