program FieldEditingSmoke;

{$APPTYPE CONSOLE}

uses
  System.SysUtils, System.Types, System.UITypes, System.Rtti,
  Winapi.Windows, Winapi.Messages, FMX.Platform.Win,
  FMX.Edit, FMX.Graphics, FMX.Filter.Effects,
  System.Classes,
  System.Math,
  System.StartUpCopy,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  UniList.Types in '..\src\UniList.Types.pas',
  UniList.Canvas in '..\src\UniList.Canvas.pas',
  UniList.Performance in '..\src\UniList.Performance.pas',
  UniList.Items in '..\src\UniList.Items.pas',
  UniList.Vector in '..\src\UniList.Vector.pas',
  UniList.Text in '..\src\UniList.Text.pas',
  UniList.Columns in '..\src\UniList.Columns.pas',
  UniList.Theme in '..\src\UniList.Theme.pas',
  UniList.Rules in '..\src\UniList.Rules.pas',
  UniList.Search in '..\src\UniList.Search.pas',
  UniList.Control in '..\src\UniList.Control.pas';

procedure Require(const OK: Boolean; const Msg: string);
begin
  if not OK then raise Exception.Create(Msg);
end;

type
  TTestForm = class(TForm)
    procedure SendKey(const AKey: Word; const Shift: TShiftState = []);
  end;
  TTestList = class(TUniListView)
    procedure ClickPoint(const P: TPointF; const DoubleClick: Boolean = False);
  end;
  TChecks = class
    List: TUniListView;
    Mode, Changes: Integer;
    procedure Validate(Sender: TObject; Item: TUniListItem; const Field: string;
      var Value: TValue; var Error: string);
    procedure Edited(Sender: TObject; Item: TUniListItem; const Field: string;
      const OldValue, NewValue: TValue);
  end;

procedure TTestForm.SendKey(const AKey: Word; const Shift: TShiftState);
var K: Word; Ch: WideChar;
begin
  K := AKey; Ch := #0; KeyDown(K, Ch, Shift);
end;

procedure TTestList.ClickPoint(const P: TPointF; const DoubleClick: Boolean);
begin
  MouseDown(TMouseButton.mbLeft, [], P.X, P.Y);
  MouseUp(TMouseButton.mbLeft, [], P.X, P.Y);
  if DoubleClick then
  begin
    MouseDown(TMouseButton.mbLeft, [ssDouble], P.X, P.Y);
    MouseUp(TMouseButton.mbLeft, [], P.X, P.Y);
  end;
end;

procedure TChecks.Validate(Sender: TObject; Item: TUniListItem; const Field: string;
  var Value: TValue; var Error: string);
begin
  case Mode of
    1: Error := 'Rejected';
    2: Value := TValue.From<string>('Validated');
    3: List.Clear;
    4: List.Columns.Clear;
  end;
end;

procedure TChecks.Edited(Sender: TObject; Item: TUniListItem; const Field: string;
  const OldValue, NewValue: TValue);
begin
  Inc(Changes);
end;

var
  Form: TTestForm;
  L: TTestList;
  C: TUniListColumn;
  Item, Other: TUniListItem;
  EditPoint: TPointF;
  Style: TStyleBook;
  Checks: TChecks;
  B: TBitmap;
  Editor: TEdit;
  I: Integer;
  Key: Word;
  Ch: WideChar;

procedure Start(const Field: string);
begin
  Require(L.BeginFieldEdit(0, Field), 'Begin edit: ' + Field);
  Application.ProcessMessages;
  Require(L.Editing, 'Editor stays active: ' + Field);
end;

procedure NativeClick(const P: TPointF; const DoubleClick: Boolean = False);
var
  H: HWND;
  PointParam: LPARAM;
  ClientPoint: TPointF;
begin
  H := WindowHandleToPlatform(Form.Handle).Wnd;
  ClientPoint := L.LocalToAbsolute(P) * Form.Handle.Scale;
  PointParam := MakeLParam(Round(ClientPoint.X), Round(ClientPoint.Y));
  SendMessage(H, WM_MOUSEMOVE, 0, PointParam);
  SendMessage(H, WM_LBUTTONDOWN, MK_LBUTTON, PointParam);
  SendMessage(H, WM_LBUTTONUP, 0, PointParam);
  if DoubleClick then
  begin
    SendMessage(H, WM_LBUTTONDBLCLK, MK_LBUTTON, PointParam);
    SendMessage(H, WM_LBUTTONUP, 0, PointParam);
  end;
  Application.ProcessMessages;
end;

procedure CheckActiveField(const Field: string);
begin
  Start(Field);
  EditPoint := PointF(Editor.Position.X + 10, Editor.Position.Y + 3);
  L.CancelEdit;
  L.SelectedIndex := -1;
  NativeClick(EditPoint);
  Require((L.ActiveFieldName = Field) and (L.SelectedIndex = 0), 'Active field: ' + Field);
  SendMessage(WindowHandleToPlatform(Form.Handle).Wnd, WM_KEYDOWN, vkF2, 0);
  Application.ProcessMessages;
  Require(L.Editing and (L.EditText = Item.FieldAsString(Field)), 'Native F2: ' + Field);
  L.CancelEdit;
  NativeClick(EditPoint, True);
  Require(L.Editing and Editor.IsFocused, 'Native double click focus: ' + Field);
  Require(L.EditText = Item.FieldAsString(Field), 'Native double click field: ' + Field);
  L.CancelEdit;
end;

procedure SaveShot(const Name: string);
begin
  B := L.MakeScreenshot;
  try B.SaveToFile(ExtractFilePath(ParamStr(0)) + Name + '.png'); finally B.Free; end;
end;

begin
  try
    Application.Initialize;
    Form := TTestForm.CreateNew(nil);
    Checks := TChecks.Create;
    try
      Form.SetBounds(80, 80, 820, 480);
      L := TTestList.Create(Form);
      L.Parent := Form;
      L.Align := TAlignLayout.Client;
      Checks.List := L;
      L.OnValidateEdit := Checks.Validate;
      L.OnFieldEdited := Checks.Edited;
      L.ViewMode := uvmList;
      L.Columns.Clear;
      L.Actions.Clear;
      for I := 0 to 4 do
      begin
        C := L.Columns.Add;
        C.FieldName := 'f' + I.ToString;
        C.Caption := C.FieldName;
        C.Width := 140;
        C.DataType := TUniColumnDataType(I);
      end;
      Item := L.Items.Add;
      Item.SetField('f0', 'Alpha');
      Item.SetField('f1', Int64(12));
      Item.SetField('f2', 1.5);
      Item.SetField('f3', EncodeDate(2026, 10, 13));
      Item.SetField('f4', True);
      Form.Show;
      Application.ProcessMessages;
      Require(not L.BeginEdit(0, 0), 'Editing must be opt-in');
      L.Editable := True;
      L.Columns[0].ReadOnly := True;
      Require(not L.BeginEdit(0, 0), 'ReadOnly');
      L.Columns[0].ReadOnly := False;
      Start('f0');
      SaveShot('editing-list');
      L.EditText := 'Привет, Oʻzbekiston';
      Require(L.CommitEdit, 'Unicode commit');
      Require(Item.FieldAsString('f0') = 'Привет, Oʻzbekiston', 'Unicode stored');
      Start('f1');
      L.EditText := 'oops';
      Require(not L.CommitEdit and L.Editing and (L.EditError <> ''), 'Invalid integer');
      Require(Item.FieldAsInt64('f1') = 12, 'Invalid integer unchanged');
      L.EditText := '42';
      Require(L.CommitEdit and (Item.FieldAsInt64('f1') = 42), 'Integer commit');
      Start('f2'); L.EditText := FloatToStr(2.75);
      Require(L.CommitEdit and (Abs(Item.FieldAsFloat('f2') - 2.75) < 0.001), 'Float');
      Start('f3');
      Require(L.CommitEdit and (Item.FieldAsDateTime('f3') = EncodeDate(2026,10,13)), 'Date roundtrip');
      Start('f4'); L.EditText := 'False';
      Require(L.CommitEdit and not Item.FieldAsBoolean('f4'), 'Boolean');
      Start('f0'); L.EditText := 'Rejected'; Checks.Mode := 1;
      Require(not L.CommitEdit and (L.EditError = 'Rejected'), 'Custom validation');
      Checks.Mode := 2;
      Require(L.CommitEdit and (Item.FieldAsString('f0') = 'Validated'), 'Validation transform');
      Checks.Mode := 0;
      Start('f0'); L.EditText := 'Cancel';
      Editor := nil;
      for I := 0 to L.ChildrenCount - 1 do
        if L.Children[I] is TEdit then Editor := TEdit(L.Children[I]);
      Require(Editor <> nil, 'Native editor');
      Key := vkEscape; Ch := #0;
      Editor.OnKeyDown(Editor, Key, Ch, []);
      Require(not L.Editing and (Item.FieldAsString('f0') = 'Validated'), 'Escape');
      Start('f0');
      L.EditText := 'Tab saved';
      Form.SendKey(vkTab);
      Require(L.Editing and (L.EditText = '42'), 'Form Tab advances');
      Form.SendKey(vkTab, [ssShift]);
      Require(L.Editing and (L.EditText = 'Tab saved'), 'Form Shift Tab returns');
      EditPoint := PointF(Editor.Position.X + 10, Editor.Position.Y + 10);
      Form.SendKey(vkEscape);
      L.ClickPoint(EditPoint, True);
      Require(L.Editing, 'Double click list');
      L.CancelEdit;
      L.SetFocus;
      Form.SendKey(vkF2);
      Require(L.Editing, 'Form F2');
      L.CancelEdit;
      CheckActiveField('f1');
      L.Columns[1].ReadOnly := True;
      NativeClick(EditPoint);
      Form.SendKey(vkF2);
      Require(not L.Editing, 'F2 must not fall back from read-only active field');
      L.Columns[1].ReadOnly := False;
      Other := L.Items.Add;
      Other.SetField('f0', 'B');
      L.ClickPoint(PointF(30, 10)); // Enable sorting by first column.
      Require(L.BeginFieldEdit(L.Items.IndexOf(Item), 'f0'), 'Sort start');
      L.EditText := 'A';
      Require(L.BeginFieldEdit(L.Items.IndexOf(Other), 'f0'), 'Switch after reorder');
      Require(L.EditText = 'B', 'Editor follows target identity after sort');
      L.CancelEdit;
      Require(L.Items[0] = Item, 'Source item reordered');
      Require(L.BeginFieldEdit(0, 'f0'), 'External mutation start');
      L.Items.Add.SetField('f0', 'Third');
      Require(not L.Editing, 'External collection mutation cancels');
      L.Items.Delete(L.Items.IndexOf(Other));
      L.Items.Delete(1);
      L.CardTemplate.TitleField := 'f0';
      L.CardTemplate.TextField := 'f1';
      L.CardTemplate.DetailField := 'f2';
      L.CardHeight := 160;
      L.MultiCheck := True;
      L.ShowCheckBoxes := True;
      L.ViewMode := uvmCards;
      Application.ProcessMessages;
      Start('f0'); SaveShot('editing-cards'); L.EditText := 'Card title';
      Key := vkReturn; Editor.OnKeyDown(Editor, Key, Ch, []);
      Require(not L.Editing and (Item.FieldAsString('f0') = 'Card title'), 'Card Enter');
      Start('f1'); L.EditText := '77';
      Require(L.CommitEdit and (Item.FieldAsInt64('f1') = 77), 'Card typed subtitle');
      Start('f2'); L.CancelEdit;
      Item.SetField('f1', '');
      Start('f1'); L.EditText := '88';
      Form.SendKey(vkReturn);
      Require(Item.FieldAsInt64('f1') = 88, 'Empty card field');
      Start('f0');
      EditPoint := PointF(Editor.Position.X + 10, Editor.Position.Y + 10);
      L.CancelEdit; L.ClickPoint(EditPoint, True);
      Require(L.Editing, 'Double click card'); L.CancelEdit;
      L.CardTemplate.SelectableText := True;
      CheckActiveField('f1');
      CheckActiveField('f2');
      L.CardLayout := uclFullWidth;
      L.Columns[0].CardRole := ucrTitle;
      L.Columns[1].CardRole := ucrSubtitle;
      L.Columns[2].CardRole := ucrDetail;
      L.Columns[4].CardRole := ucrTrailing;
      Application.ProcessMessages;
      Start('f4'); SaveShot('editing-fullwidth'); L.EditText := 'True';
      Require(L.CommitEdit and Item.FieldAsBoolean('f4'), 'Trailing boolean');
      CheckActiveField('f4');
      if ParamCount > 0 then
      begin
        Style := TStyleBook.Create(Form);
        Style.LoadFromFile(ParamStr(1));
        Form.StyleBook := Style;
        L.UseStyleBook := True;
        Application.ProcessMessages;
        Start('f0'); SaveShot('editing-stylebook'); L.CancelEdit;
        CheckActiveField('f1');
      end;
      Start('f0'); Checks.Mode := 4;
      Require(not L.CommitEdit and not L.Editing, 'Columns cleared during validation');
      Checks.Mode := 0;
      Start('f0'); L.CancelEdit;
      Start('f0'); Checks.Mode := 3;
      Require(not L.CommitEdit and not L.Editing and (L.Items.Count = 0), 'Items cleared during validation');
      Require(Checks.Changes >= 9, 'Changed events');
      Writeln('FieldEditingSmoke: PASS');
    finally
      Form.Free;
      Checks.Free;
    end;
  except
    on E: Exception do
    begin
      Writeln(E.ClassName + ': ' + E.Message);
      Halt(1);
    end;
  end;
end.
