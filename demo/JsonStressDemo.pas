unit JsonStressDemo;

interface

uses
  System.SysUtils, System.Classes, System.Actions, System.Diagnostics,
  System.UITypes,
  FMX.Types, FMX.Controls, FMX.Controls.Presentation, FMX.Forms,
  FMX.StdCtrls, FMX.Edit, FMX.ListBox, FMX.Layouts, FMX.Objects, FMX.Memo,
  FMX.ActnList,
  UniList.Control, UniList.Json.Adapter,
  Demo.Json.StressGenerator;

type
  TJsonStressForm = class(TForm)
    BackgroundRect: TRectangle;
    RootLayout: TLayout;
    SettingsPanel: TRectangle;
    TitleLabel: TLabel;
    RowCountLabel: TLabel;
    RowCountCombo: TComboBox;
    ColumnCountLabel: TLabel;
    ColumnCountCombo: TComboBox;
    NestedObjectsCheck: TCheckBox;
    UnicodeCheck: TCheckBox;
    RandomNullsCheck: TCheckBox;
    DifferentFieldsCheck: TCheckBox;
    LargeTextCheck: TCheckBox;
    BooleanFieldsCheck: TCheckBox;
    FloatFieldsCheck: TCheckBox;
    DateTimeFieldsCheck: TCheckBox;
    GuidFieldsCheck: TCheckBox;
    NestedArraysCheck: TCheckBox;
    GenerateButton: TButton;
    LoadButton: TButton;
    GenerateLoadButton: TButton;
    ReloadButton: TButton;
    ReloadTenButton: TButton;
    ClearButton: TButton;
    SmallButton: TButton;
    MediumButton: TButton;
    LargeButton: TButton;
    VeryLargeButton: TButton;
    ListModeButton: TButton;
    CardsModeButton: TButton;
    AutoFitButton: TButton;
    SearchEdit: TEdit;
    SearchButton: TButton;
    ClearSearchButton: TButton;
    CopyStatsButton: TButton;
    CloseButton: TButton;
    MemoryNoteLabel: TLabel;
    BodyLayout: TLayout;
    StressListView: TUniListView;
    SidePanel: TRectangle;
    StatisticsLabel: TLabel;
    StatisticsMemo: TMemo;
    LogLabel: TLabel;
    LogMemo: TMemo;
    StressActions: TActionList;
    actGenerateJson: TAction;
    actLoadJson: TAction;
    actGenerateAndLoad: TAction;
    actReloadJson: TAction;
    actReloadTenTimes: TAction;
    actClear: TAction;
    actRunPresetSmall: TAction;
    actRunPresetMedium: TAction;
    actRunPresetLarge: TAction;
    actRunPresetVeryLarge: TAction;
    actToggleListMode: TAction;
    actToggleCardsMode: TAction;
    actAutoBestFit: TAction;
    actApplySearch: TAction;
    actClearSearch: TAction;
    actCopyStatistics: TAction;
    actClose: TAction;
    JsonDataAdapter: TUniJsonDataAdapter;
    procedure FormCreate(Sender: TObject);
    procedure actGenerateJsonExecute(Sender: TObject);
    procedure actLoadJsonExecute(Sender: TObject);
    procedure actGenerateAndLoadExecute(Sender: TObject);
    procedure actReloadJsonExecute(Sender: TObject);
    procedure actReloadTenTimesExecute(Sender: TObject);
    procedure actClearExecute(Sender: TObject);
    procedure actRunPresetSmallExecute(Sender: TObject);
    procedure actRunPresetMediumExecute(Sender: TObject);
    procedure actRunPresetLargeExecute(Sender: TObject);
    procedure actRunPresetVeryLargeExecute(Sender: TObject);
    procedure actToggleListModeExecute(Sender: TObject);
    procedure actToggleCardsModeExecute(Sender: TObject);
    procedure actAutoBestFitExecute(Sender: TObject);
    procedure actApplySearchExecute(Sender: TObject);
    procedure actClearSearchExecute(Sender: TObject);
    procedure actCopyStatisticsExecute(Sender: TObject);
    procedure actCloseExecute(Sender: TObject);
  private
    FBusy: Boolean;
    FGenerationMilliseconds: Int64;
    FJsonBytes: Int64;
    FJsonText: string;
    FLoadMilliseconds: Int64;
    FReloadCount: Integer;
    FRequestedColumns: Integer;
    FRequestedRows: Integer;
    FTotalMilliseconds: Int64;
    procedure AddLog(const AText: string);
    function BuildOptions: TJsonStressOptions;
    procedure ClearCurrentTest;
    procedure GenerateJson;
    procedure LoadJson(const AIsReload: Boolean);
    function ParsePositiveCombo(const ACombo: TComboBox;
      const AName: string; const AMaximum: Integer): Integer;
    procedure RunGuarded(const AOperation: string; const AProc: TProc);
    procedure RunPreset(const ARowIndex, AColumnIndex: Integer);
    procedure SetBusy(const Value: Boolean);
    procedure SetRunActionsEnabled(const Value: Boolean);
    procedure UpdateStatistics;
  end;

implementation

uses
  System.Math, System.Rtti,
  FMX.Dialogs, FMX.Platform,
  UniList.Columns;

{$R *.fmx}

const
  CMaximumRows = 100000;
  CMaximumColumns = 200;
  CReloadIterationCount = 10;
  CMaximumLogLines = 500;
  CBytesPerKilobyte = 1024;
  CBytesPerMegabyte = CBytesPerKilobyte * CBytesPerKilobyte;

function FormatCount(const AValue: Int64): string;
begin
  Result := FormatFloat('#,##0', AValue);
end;

function FormatDuration(const AMilliseconds: Int64): string;
begin
  if AMilliseconds >= 1000 then
    Result := Format('%d ms (%.2f s)',
      [AMilliseconds, AMilliseconds / 1000])
  else
    Result := Format('%d ms', [AMilliseconds]);
end;

function FormatBytes(const ABytes: Int64): string;
begin
  if ABytes >= CBytesPerMegabyte then
    Result := Format('%.2f MB', [ABytes / CBytesPerMegabyte])
  else if ABytes >= CBytesPerKilobyte then
    Result := Format('%.2f KB', [ABytes / CBytesPerKilobyte])
  else
    Result := Format('%d bytes', [ABytes]);
end;

procedure TJsonStressForm.FormCreate(Sender: TObject);
begin
  StressListView.Columns.Clear;
  StressListView.Actions.Clear;
  FJsonText := '';
  FReloadCount := 0;
  UpdateStatistics;
end;

function TJsonStressForm.ParsePositiveCombo(const ACombo: TComboBox;
  const AName: string; const AMaximum: Integer): Integer;
var
  ValueText: string;
begin
  if ACombo.Selected = nil then
    raise EArgumentException.CreateFmt('%s is not selected.', [AName]);
  ValueText := StringReplace(ACombo.Selected.Text, ' ', '',
    [rfReplaceAll]);
  if not TryStrToInt(ValueText, Result) or (Result <= 0) or
     (Result > AMaximum) then
    raise EArgumentException.CreateFmt(
      '%s must be between 1 and %s.', [AName, FormatCount(AMaximum)]);
end;

function TJsonStressForm.BuildOptions: TJsonStressOptions;
begin
  Result := Default(TJsonStressOptions);
  Result.RowCount := ParsePositiveCombo(RowCountCombo, 'Row count',
    CMaximumRows);
  Result.ColumnCount := ParsePositiveCombo(ColumnCountCombo, 'Column count',
    CMaximumColumns);
  Result.IncludeNestedObjects := NestedObjectsCheck.IsChecked;
  Result.IncludeUnicode := UnicodeCheck.IsChecked;
  Result.IncludeRandomNulls := RandomNullsCheck.IsChecked;
  Result.IncludeDifferentFieldSets := DifferentFieldsCheck.IsChecked;
  Result.IncludeLargeText := LargeTextCheck.IsChecked;
  Result.IncludeBooleanFields := BooleanFieldsCheck.IsChecked;
  Result.IncludeFloatingPointFields := FloatFieldsCheck.IsChecked;
  Result.IncludeDateTimeStrings := DateTimeFieldsCheck.IsChecked;
  Result.IncludeGuidStrings := GuidFieldsCheck.IsChecked;
  Result.IncludeNestedArrays := NestedArraysCheck.IsChecked;
end;

procedure TJsonStressForm.SetRunActionsEnabled(const Value: Boolean);
begin
  actGenerateJson.Enabled := Value;
  actLoadJson.Enabled := Value;
  actGenerateAndLoad.Enabled := Value;
  actReloadJson.Enabled := Value;
  actReloadTenTimes.Enabled := Value;
  actClear.Enabled := Value;
  actRunPresetSmall.Enabled := Value;
  actRunPresetMedium.Enabled := Value;
  actRunPresetLarge.Enabled := Value;
  actRunPresetVeryLarge.Enabled := Value;
end;

procedure TJsonStressForm.SetBusy(const Value: Boolean);
begin
  FBusy := Value;
  SetRunActionsEnabled(not Value);
  if Value then
    Cursor := crHourGlass
  else
    Cursor := crDefault;
end;

procedure TJsonStressForm.RunGuarded(const AOperation: string;
  const AProc: TProc);
begin
  if FBusy then
    Exit;
  SetBusy(True);
  try
    try
      AProc();
    except
      on E: Exception do
      begin
        AddLog(Format('%s failed: %s: %s',
          [AOperation, E.ClassName, E.Message]));
        ShowMessage(E.Message);
      end;
    end;
  finally
    SetBusy(False);
  end;
end;

procedure TJsonStressForm.AddLog(const AText: string);
begin
  LogMemo.Lines.Add(Format('[%s] %s',
    [FormatDateTime('hh:nn:ss', Now), AText]));
  while LogMemo.Lines.Count > CMaximumLogLines do
    LogMemo.Lines.Delete(0);
  LogMemo.GoToTextEnd;
end;

procedure TJsonStressForm.GenerateJson;
var
  Options: TJsonStressOptions;
  Stopwatch: TStopwatch;
begin
  Options := BuildOptions;
  Stopwatch := TStopwatch.StartNew;
  FJsonText := TJsonStressGenerator.Generate(Options);
  Stopwatch.Stop;

  FRequestedRows := Options.RowCount;
  FRequestedColumns := Options.ColumnCount;
  FGenerationMilliseconds := Stopwatch.ElapsedMilliseconds;
  FJsonBytes := TEncoding.UTF8.GetByteCount(FJsonText);
  FLoadMilliseconds := 0;
  FTotalMilliseconds := FGenerationMilliseconds;
  FReloadCount := 0;
  UpdateStatistics;
  AddLog(Format('Generated %s rows, %s columns, %s, %s',
    [FormatCount(FRequestedRows), FormatCount(FRequestedColumns),
     FormatBytes(FJsonBytes), FormatDuration(FGenerationMilliseconds)]));
end;

procedure TJsonStressForm.LoadJson(const AIsReload: Boolean);
var
  Stopwatch: TStopwatch;
begin
  if FJsonText = '' then
    raise EInvalidOperation.Create(
      'Generate JSON before loading or reloading it.');

  Stopwatch := TStopwatch.StartNew;
  JsonDataAdapter.LoadFromString(FJsonText);
  Stopwatch.Stop;
  FLoadMilliseconds := Stopwatch.ElapsedMilliseconds;
  FTotalMilliseconds := FGenerationMilliseconds + FLoadMilliseconds;
  if AIsReload then
    Inc(FReloadCount);
  UpdateStatistics;
  AddLog(Format('Loaded %s rows, %s columns, %s',
    [FormatCount(StressListView.Items.Count),
     FormatCount(StressListView.Columns.Count),
     FormatDuration(FLoadMilliseconds)]));
end;

procedure TJsonStressForm.ClearCurrentTest;
begin
  JsonDataAdapter.Clear;
  FJsonText := '';
  FJsonBytes := 0;
  FGenerationMilliseconds := 0;
  FLoadMilliseconds := 0;
  FTotalMilliseconds := 0;
  FReloadCount := 0;
  FRequestedRows := 0;
  FRequestedColumns := 0;
  SearchEdit.Text := '';
  StressListView.ClearSearch;
  UpdateStatistics;
  AddLog('Current test cleared');
end;

procedure TJsonStressForm.UpdateStatistics;
var
  Lines: TStringList;
  ViewModeText: string;
begin
  if StressListView.ViewMode = uvmList then
    ViewModeText := 'List'
  else
    ViewModeText := 'Cards';

  Lines := TStringList.Create;
  try
    Lines.Add('Rows requested: ' + FormatCount(FRequestedRows));
    Lines.Add('Rows loaded: ' + FormatCount(StressListView.Items.Count));
    Lines.Add('Columns requested: ' + FormatCount(FRequestedColumns));
    Lines.Add('Columns created: ' + FormatCount(StressListView.Columns.Count));
    Lines.Add('JSON chars: ' + FormatCount(Length(FJsonText)));
    Lines.Add('JSON UTF-8 bytes: ' + FormatBytes(FJsonBytes));
    Lines.Add('Generation: ' + FormatDuration(FGenerationMilliseconds));
    Lines.Add('Load: ' + FormatDuration(FLoadMilliseconds));
    Lines.Add('Total: ' + FormatDuration(FTotalMilliseconds));
    Lines.Add('Reload count: ' + FormatCount(FReloadCount));
    Lines.Add('View mode: ' + ViewModeText);
    Lines.Add('Search: ' + StressListView.SearchText);
    Lines.Add('Visible/filtered: ' +
      FormatCount(StressListView.NavigationItemCount));
    { The RTL has no portable process-memory counter for this demo. }
    Lines.Add('Process memory: N/A');
    StatisticsMemo.Lines.Assign(Lines);
  finally
    Lines.Free;
  end;
end;

procedure TJsonStressForm.RunPreset(const ARowIndex,
  AColumnIndex: Integer);
begin
  RowCountCombo.ItemIndex := ARowIndex;
  ColumnCountCombo.ItemIndex := AColumnIndex;
  LargeTextCheck.IsChecked := False;
  GenerateJson;
  LoadJson(False);
end;

procedure TJsonStressForm.actGenerateJsonExecute(Sender: TObject);
begin
  RunGuarded('Generate JSON',
    procedure
    begin
      GenerateJson;
    end);
end;

procedure TJsonStressForm.actLoadJsonExecute(Sender: TObject);
begin
  RunGuarded('Load JSON',
    procedure
    begin
      LoadJson(False);
    end);
end;

procedure TJsonStressForm.actGenerateAndLoadExecute(Sender: TObject);
begin
  RunGuarded('Generate and load',
    procedure
    begin
      GenerateJson;
      LoadJson(False);
    end);
end;

procedure TJsonStressForm.actReloadJsonExecute(Sender: TObject);
begin
  RunGuarded('Reload JSON',
    procedure
    begin
      LoadJson(True);
    end);
end;

procedure TJsonStressForm.actReloadTenTimesExecute(Sender: TObject);
begin
  RunGuarded('Reload x10',
    procedure
    var
      ColumnCount: Integer;
      Iteration: Integer;
      Stopwatch: TStopwatch;
      TotalMilliseconds: Int64;
    begin
      if FJsonText = '' then
        raise EInvalidOperation.Create(
          'Generate JSON before running Reload x10.');
      if StressListView.Items.Count = 0 then
        raise EInvalidOperation.Create(
          'Load JSON before running Reload x10.');
      ColumnCount := StressListView.Columns.Count;
      TotalMilliseconds := 0;
      for Iteration := 1 to CReloadIterationCount do
      begin
        try
          Stopwatch := TStopwatch.StartNew;
          JsonDataAdapter.LoadFromString(FJsonText);
          Stopwatch.Stop;
        except
          on E: Exception do
            raise EInvalidOperation.CreateFmt(
              'Reload iteration %d failed: %s', [Iteration, E.Message]);
        end;
        Inc(TotalMilliseconds, Stopwatch.ElapsedMilliseconds);
        Inc(FReloadCount);
        if StressListView.Columns.Count <> ColumnCount then
          raise EInvalidOperation.CreateFmt(
            'Column count changed on reload iteration %d.', [Iteration]);
      end;
      FLoadMilliseconds := TotalMilliseconds div CReloadIterationCount;
      FTotalMilliseconds := TotalMilliseconds;
      UpdateStatistics;
      AddLog(Format('Reload x10 completed, total %s, average %s',
        [FormatDuration(TotalMilliseconds),
         FormatDuration(FLoadMilliseconds)]));
    end);
end;

procedure TJsonStressForm.actClearExecute(Sender: TObject);
begin
  RunGuarded('Clear',
    procedure
    begin
      ClearCurrentTest;
    end);
end;

procedure TJsonStressForm.actRunPresetSmallExecute(Sender: TObject);
begin
  RunGuarded('Small preset',
    procedure
    begin
      RunPreset(1, 0);
    end);
end;

procedure TJsonStressForm.actRunPresetMediumExecute(Sender: TObject);
begin
  RunGuarded('Medium preset',
    procedure
    begin
      RunPreset(2, 1);
    end);
end;

procedure TJsonStressForm.actRunPresetLargeExecute(Sender: TObject);
begin
  RunGuarded('Large preset',
    procedure
    begin
      RunPreset(3, 2);
    end);
end;

procedure TJsonStressForm.actRunPresetVeryLargeExecute(Sender: TObject);
begin
  RunGuarded('Very Large preset',
    procedure
    begin
      RunPreset(4, 3);
    end);
end;

procedure TJsonStressForm.actToggleListModeExecute(Sender: TObject);
begin
  StressListView.ViewMode := uvmList;
  UpdateStatistics;
end;

procedure TJsonStressForm.actToggleCardsModeExecute(Sender: TObject);
begin
  StressListView.ViewMode := uvmCards;
  UpdateStatistics;
end;

procedure TJsonStressForm.actAutoBestFitExecute(Sender: TObject);
begin
  StressListView.AutoFitAllColumns;
  AddLog('AutoBestFit applied');
end;

procedure TJsonStressForm.actApplySearchExecute(Sender: TObject);
begin
  StressListView.SearchText := SearchEdit.Text;
  UpdateStatistics;
  AddLog('Search applied: ' + SearchEdit.Text);
end;

procedure TJsonStressForm.actClearSearchExecute(Sender: TObject);
begin
  SearchEdit.Text := '';
  StressListView.ClearSearch;
  UpdateStatistics;
end;

procedure TJsonStressForm.actCopyStatisticsExecute(Sender: TObject);
var
  Clipboard: IFMXClipboardService;
begin
  if TPlatformServices.Current.SupportsPlatformService(
    IFMXClipboardService, Clipboard) then
  begin
    Clipboard.SetClipboard(StatisticsMemo.Text);
    AddLog('Statistics copied to clipboard');
  end
  else
    AddLog('Clipboard service is unavailable');
end;

procedure TJsonStressForm.actCloseExecute(Sender: TObject);
begin
  Close;
end;

end.
