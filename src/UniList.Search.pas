unit UniList.Search;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  System.Diagnostics, System.Rtti, System.TypInfo,
  FMX.Types,
  UniList.Items, UniList.Performance;

type
  TUniSearchOption = (soIgnoreCase, soVisibleColumnsOnly, soWrapAround,
    soRespectFilters);
  TUniSearchOptions = set of TUniSearchOption;

  TUniSearchChangedEvent = procedure(Sender: TObject) of object;
  TUniSearchCurrentChangedEvent = procedure(Sender: TObject;
    const AItemIndex: Integer) of object;

  TUniSearchEngine = class
  private const
    SEARCH_TIMER_INTERVAL_MS = 1;
    SEARCH_SLICE_BUDGET_MS = 6;
    SEARCH_MAX_ITEMS_PER_SLICE = 2048;
    FIELD_SEPARATOR = #0;
  private
    FItems: TUniListItems;
    FVisibleFields: TArray<string>;
    FFilteredIndices: TArray<Integer>;
    FOptions: TUniSearchOptions;
    FSearchText: string;
    FPreparedSearchText: string;
    FCachedText: TArray<string>;
    FCacheValid: TArray<Boolean>;
    FCandidates: TArray<Integer>;
    FMatches: TList<Integer>;
    FMatchLookup: TDictionary<Integer, Integer>;
    FCurrentMatch: Integer;
    FScanPosition: Integer;
    FRunning: Boolean;
    FTimer: TTimer;
    FOnChanged: TUniSearchChangedEvent;
    FOnCurrentChanged: TUniSearchCurrentChangedEvent;
    procedure SetSearchText(const Value: string);
    procedure SetOptions(const Value: TUniSearchOptions);
    procedure TimerTick(Sender: TObject);
    procedure PrepareCandidates;
    procedure RestartSearch;
    procedure FinishSearch;
    procedure NotifyChanged;
    procedure NotifyCurrentChanged;
    procedure SetCurrentMatch(const Value: Integer);
    procedure InvalidateAllCache;
    function BuildItemText(const AItemIndex: Integer): string;
    function ScalarValueToText(const AValue: TValue): string;
    function PreparedText(const Value: string): string;
    function CandidateMatches(const AItemIndex: Integer): Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Configure(AItems: TUniListItems;
      const AVisibleFields: TArray<string>;
      const AFilteredIndices: TArray<Integer>);
    procedure InvalidateItem(const AItemIndex: Integer);
    procedure InvalidateAll;
    procedure Clear;
    procedure FindNext;
    procedure FindPrevious;
    function IsMatch(const AItemIndex: Integer): Boolean;
    function CurrentItemIndex: Integer;
    function MatchItemIndex(const AMatchIndex: Integer): Integer;
    function MatchIndexOf(const AItemIndex: Integer): Integer;
    function MatchCount: Integer;
    property Running: Boolean read FRunning;
    property SearchText: string read FSearchText write SetSearchText;
    property Options: TUniSearchOptions read FOptions write SetOptions;
    property OnChanged: TUniSearchChangedEvent read FOnChanged write FOnChanged;
    property OnCurrentChanged: TUniSearchCurrentChangedEvent
      read FOnCurrentChanged write FOnCurrentChanged;
  end;

implementation

constructor TUniSearchEngine.Create;
begin
  inherited Create;
  FOptions := [soIgnoreCase, soVisibleColumnsOnly, soWrapAround,
    soRespectFilters];
  FMatches := TList<Integer>.Create;
  FMatchLookup := TDictionary<Integer, Integer>.Create;
  FCurrentMatch := -1;
  FTimer := TTimer.Create(nil);
  FTimer.Enabled := False;
  FTimer.Interval := SEARCH_TIMER_INTERVAL_MS;
  FTimer.OnTimer := TimerTick;
end;

destructor TUniSearchEngine.Destroy;
begin
  FTimer.Free;
  FMatchLookup.Free;
  FMatches.Free;
  inherited;
end;

procedure TUniSearchEngine.Configure(AItems: TUniListItems;
  const AVisibleFields: TArray<string>;
  const AFilteredIndices: TArray<Integer>);
begin
  FItems := AItems;
  FVisibleFields := Copy(AVisibleFields, 0, Length(AVisibleFields));
  FFilteredIndices := Copy(AFilteredIndices, 0, Length(AFilteredIndices));
  InvalidateAllCache;
  RestartSearch;
end;

procedure TUniSearchEngine.InvalidateAllCache;
begin
  if FItems = nil then
  begin
    SetLength(FCachedText, 0);
    SetLength(FCacheValid, 0);
    Exit;
  end;
  SetLength(FCachedText, FItems.Count);
  SetLength(FCacheValid, FItems.Count);
  if Length(FCacheValid) > 0 then
    FillChar(FCacheValid[0], Length(FCacheValid) * SizeOf(Boolean), 0);
end;

procedure TUniSearchEngine.InvalidateItem(const AItemIndex: Integer);
begin
  if (AItemIndex >= 0) and (AItemIndex < Length(FCacheValid)) then
    FCacheValid[AItemIndex] := False;
  if FSearchText <> '' then
    RestartSearch;
end;

procedure TUniSearchEngine.InvalidateAll;
begin
  InvalidateAllCache;
  RestartSearch;
end;

procedure TUniSearchEngine.SetSearchText(const Value: string);
begin
  if FSearchText = Value then
    Exit;
  FSearchText := Value;
  RestartSearch;
end;

procedure TUniSearchEngine.SetOptions(const Value: TUniSearchOptions);
begin
  if FOptions = Value then
    Exit;
  FOptions := Value;
  InvalidateAllCache;
  RestartSearch;
end;

function TUniSearchEngine.PreparedText(const Value: string): string;
begin
  if soIgnoreCase in FOptions then
    Result := LowerCase(Value)
  else
    Result := Value;
end;

function TUniSearchEngine.ScalarValueToText(const AValue: TValue): string;
begin
  Result := '';
  if AValue.IsEmpty then
    Exit;
  case AValue.Kind of
    tkInteger, tkInt64, tkFloat, tkEnumeration, tkChar, tkWChar,
    tkString, tkLString, tkWString, tkUString, tkVariant:
      Result := AValue.ToString;
  end;
end;

function TUniSearchEngine.BuildItemText(const AItemIndex: Integer): string;
var
  Builder: TStringBuilder;
  FieldName: string;
  Pair: TPair<string, TValue>;
  ValueText: string;
begin
  Result := '';
  if (FItems = nil) or (AItemIndex < 0) or
     (AItemIndex >= FItems.Count) then
    Exit;

  Builder := TStringBuilder.Create;
  try
    if soVisibleColumnsOnly in FOptions then
    begin
      for FieldName in FVisibleFields do
      begin
        ValueText := ScalarValueToText(FItems[AItemIndex].Fields[FieldName]);
        if ValueText = '' then
          Continue;
        if Builder.Length > 0 then
          Builder.Append(FIELD_SEPARATOR);
        Builder.Append(ValueText);
      end;
    end
    else
      for Pair in FItems[AItemIndex].Data do
      begin
        ValueText := ScalarValueToText(Pair.Value);
        if ValueText = '' then
          Continue;
        if Builder.Length > 0 then
          Builder.Append(FIELD_SEPARATOR);
        Builder.Append(ValueText);
      end;
    Result := PreparedText(Builder.ToString);
  finally
    Builder.Free;
  end;
end;

procedure TUniSearchEngine.PrepareCandidates;
var
  CandidateIndex: Integer;
begin
  if FItems = nil then
  begin
    SetLength(FCandidates, 0);
    Exit;
  end;
  if soRespectFilters in FOptions then
  begin
    FCandidates := Copy(FFilteredIndices, 0, Length(FFilteredIndices));
    Exit;
  end;
  SetLength(FCandidates, FItems.Count);
  for CandidateIndex := 0 to FItems.Count - 1 do
    FCandidates[CandidateIndex] := CandidateIndex;
end;

procedure TUniSearchEngine.RestartSearch;
begin
  UniPerfInc(upcSearchRebuild);
  FTimer.Enabled := False;
  FRunning := False;
  FMatches.Clear;
  FMatchLookup.Clear;
  FCurrentMatch := -1;
  FScanPosition := 0;
  FPreparedSearchText := PreparedText(FSearchText);
  UniPerfSetSearchResultCount(0);
  PrepareCandidates;
  NotifyChanged;
  NotifyCurrentChanged;
  if (FPreparedSearchText = '') or (Length(FCandidates) = 0) then
    Exit;
  FRunning := True;
  TimerTick(Self);
  if FRunning then
    FTimer.Enabled := True;
end;

function TUniSearchEngine.CandidateMatches(
  const AItemIndex: Integer): Boolean;
begin
  if (AItemIndex < 0) or (AItemIndex >= Length(FCacheValid)) then
    Exit(False);
  if not FCacheValid[AItemIndex] then
  begin
    FCachedText[AItemIndex] := BuildItemText(AItemIndex);
    FCacheValid[AItemIndex] := True;
  end;
  Result := Pos(FPreparedSearchText, FCachedText[AItemIndex]) > 0;
end;

procedure TUniSearchEngine.TimerTick(Sender: TObject);
var
  Stopwatch: TStopwatch;
  ProcessedCount: Integer;
  ItemIndex: Integer;
  PerfTimer: TUniPerfScope;
begin
  PerfTimer := TUniPerfScope.Start(upcSearchRebuild);
  try
  if not FRunning then
  begin
    FTimer.Enabled := False;
    Exit;
  end;

  Stopwatch := TStopwatch.StartNew;
  ProcessedCount := 0;
  while (FScanPosition < Length(FCandidates)) and
        (ProcessedCount < SEARCH_MAX_ITEMS_PER_SLICE) and
        ((ProcessedCount = 0) or
         (Stopwatch.ElapsedMilliseconds < SEARCH_SLICE_BUDGET_MS)) do
  begin
    ItemIndex := FCandidates[FScanPosition];
    Inc(FScanPosition);
    Inc(ProcessedCount);
    if not CandidateMatches(ItemIndex) then
      Continue;
    FMatchLookup.AddOrSetValue(ItemIndex, FMatches.Count);
    FMatches.Add(ItemIndex);
    if FCurrentMatch < 0 then
    begin
      FCurrentMatch := 0;
      NotifyCurrentChanged;
    end;
  end;
  if ProcessedCount > 0 then
  begin
    UniPerfAddItemsScanned(ProcessedCount);
    UniPerfSetSearchResultCount(FMatches.Count);
    NotifyChanged;
  end;
  if FScanPosition >= Length(FCandidates) then
    FinishSearch;
  finally
    PerfTimer.Stop;
  end;
end;

procedure TUniSearchEngine.FinishSearch;
begin
  FRunning := False;
  FTimer.Enabled := False;
  UniPerfSetSearchResultCount(FMatches.Count);
  NotifyChanged;
end;

procedure TUniSearchEngine.SetCurrentMatch(const Value: Integer);
begin
  if FCurrentMatch = Value then
    Exit;
  FCurrentMatch := Value;
  NotifyCurrentChanged;
  NotifyChanged;
end;

procedure TUniSearchEngine.FindNext;
var
  NewMatch: Integer;
begin
  if FMatches.Count = 0 then
    Exit;
  NewMatch := FCurrentMatch + 1;
  if NewMatch >= FMatches.Count then
  begin
    if not (soWrapAround in FOptions) then
      Exit;
    NewMatch := 0;
  end;
  SetCurrentMatch(NewMatch);
end;

procedure TUniSearchEngine.FindPrevious;
var
  NewMatch: Integer;
begin
  if FMatches.Count = 0 then
    Exit;
  NewMatch := FCurrentMatch - 1;
  if NewMatch < 0 then
  begin
    if not (soWrapAround in FOptions) then
      Exit;
    NewMatch := FMatches.Count - 1;
  end;
  SetCurrentMatch(NewMatch);
end;

procedure TUniSearchEngine.Clear;
begin
  SearchText := '';
end;

function TUniSearchEngine.IsMatch(const AItemIndex: Integer): Boolean;
begin
  Result := FMatchLookup.ContainsKey(AItemIndex);
end;

function TUniSearchEngine.CurrentItemIndex: Integer;
begin
  if (FCurrentMatch < 0) or (FCurrentMatch >= FMatches.Count) then
    Exit(-1);
  Result := FMatches[FCurrentMatch];
end;

function TUniSearchEngine.MatchItemIndex(const AMatchIndex: Integer): Integer;
begin
  if (AMatchIndex < 0) or (AMatchIndex >= FMatches.Count) then
    Exit(-1);
  Result := FMatches[AMatchIndex];
end;

function TUniSearchEngine.MatchIndexOf(const AItemIndex: Integer): Integer;
begin
  if not FMatchLookup.TryGetValue(AItemIndex, Result) then
    Result := -1;
end;

function TUniSearchEngine.MatchCount: Integer;
begin
  Result := FMatches.Count;
end;

procedure TUniSearchEngine.NotifyChanged;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure TUniSearchEngine.NotifyCurrentChanged;
begin
  if Assigned(FOnCurrentChanged) then
    FOnCurrentChanged(Self, CurrentItemIndex);
end;

end.

