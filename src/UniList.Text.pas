unit UniList.Text;

interface

uses
  System.SysUtils, System.Math, System.Generics.Collections, UniList.Performance;

type
  TUniMeasureTextEvent = function(const AText: string): Single of object;

  TUniTextLayout = record
    Lines: TArray<string>;
    Width: Single;
    Height: Single;
    LineHeight: Single;
    Truncated: Boolean;
  end;

function BuildTextLayout(const AText: string; const AMaxWidth, AFontSize: Single;
  const AWordWrap, AEllipsis: Boolean; const AMaxLines: Integer): TUniTextLayout;
function BuildMeasuredTextLayout(const AText: string;
  const AMaxWidth, AFontSize: Single; const AWordWrap,
  AEllipsis: Boolean; const AMaxLines: Integer;
  const AMeasureText: TUniMeasureTextEvent): TUniTextLayout;
function EstimateTextWidth(const AText: string; const AFontSize: Single): Single;

implementation

function EstimateTextWidth(const AText: string; const AFontSize: Single): Single;
begin
  Result := Length(AText) * AFontSize * 0.56;
end;

function FitWithEllipsis(const S: string; const MaxChars: Integer): string;
begin
  if MaxChars <= 0 then
    Exit('');
  if Length(S) <= MaxChars then
    Exit(S);
  if MaxChars = 1 then
    Exit('…');
  Result := Copy(S, 1, MaxChars - 1) + '…';
end;

function ProfileMeasureText(const AMeasureText: TUniMeasureTextEvent;
  const AText: string): Single;
var
  PerfTimer: TUniPerfScope;
begin
  UniPerfInc(upcMeasureText);
  PerfTimer := TUniPerfScope.Start(upcMeasureText);
  try
    Result := AMeasureText(AText);
  finally
    PerfTimer.Stop;
  end;
end;

function FitMeasuredWithEllipsis(const AText: string;
  const AMaxWidth: Single;
  const AMeasureText: TUniMeasureTextEvent): string;
const
  ELLIPSIS = '…';
var
  HighValue, LowValue, MiddleValue: Integer;
begin
  if ProfileMeasureText(AMeasureText, AText) <= AMaxWidth then
    Exit(AText);
  if ProfileMeasureText(AMeasureText, ELLIPSIS) > AMaxWidth then
    Exit('');
  LowValue := 0;
  HighValue := Length(AText);
  while LowValue < HighValue do
  begin
    MiddleValue := (LowValue + HighValue + 1) div 2;
    if ProfileMeasureText(AMeasureText, Copy(AText, 1, MiddleValue) +
       ELLIPSIS) <= AMaxWidth then
      LowValue := MiddleValue
    else
      HighValue := MiddleValue - 1;
  end;
  Result := Copy(AText, 1, LowValue) + ELLIPSIS;
end;

function FittingPrefixLength(const AText: string; const AMaxWidth: Single;
  const AMeasureText: TUniMeasureTextEvent): Integer;
var
  HighValue, LowValue, MiddleValue: Integer;
begin
  LowValue := 0;
  HighValue := Length(AText);
  while LowValue < HighValue do
  begin
    MiddleValue := (LowValue + HighValue + 1) div 2;
    if ProfileMeasureText(AMeasureText, Copy(AText, 1, MiddleValue)) <=
       AMaxWidth then
      LowValue := MiddleValue
    else
      HighValue := MiddleValue - 1;
  end;
  Result := Max(1, LowValue);
end;

function HyphenBreakLength(const AText: string;
  const AFittingLength: Integer): Integer;
var
  I: Integer;
begin
  Result := AFittingLength;
  for I := Min(AFittingLength, Length(AText) - 1) downto 2 do
    if AText[I] = '-' then
      Exit(I);
end;

function BuildMeasuredTextLayout(const AText: string;
  const AMaxWidth, AFontSize: Single; const AWordWrap,
  AEllipsis: Boolean; const AMaxLines: Integer;
  const AMeasureText: TUniMeasureTextEvent): TUniTextLayout;
var
  Current, NormalizedText, Part, WordValue: string;
  I, PrefixLength: Integer;
  Lines: TList<string>;
  WasTruncated: Boolean;
  Words: TArray<string>;
  PerfTimer: TUniPerfScope;
begin
  UniPerfInc(upcCreateTextLayout);
  PerfTimer := TUniPerfScope.Start(upcCreateTextLayout);
  try
    Result.Lines := nil;
    Result.Width := 0;
    Result.LineHeight := Max(1, AFontSize * 1.28);
    Result.Height := 0;
    Result.Truncated := False;
    if (AText = '') or not Assigned(AMeasureText) then
      Exit;

    NormalizedText := AText.Replace(#13, ' ').Replace(#10, ' ')
      .Replace(#9, ' ');
    Lines := TList<string>.Create;
    try
      WasTruncated := False;
      if not AWordWrap then
      begin
        Part := NormalizedText;
        if AEllipsis then
          Part := FitMeasuredWithEllipsis(Part, AMaxWidth, AMeasureText);
        Lines.Add(Part);
        WasTruncated := Part <> NormalizedText;
      end
      else
      begin
        Words := NormalizedText.Split([' '],
          TStringSplitOptions.ExcludeEmpty);
        Current := '';
        for WordValue in Words do
        begin
          if Current = '' then
            Part := WordValue
          else
            Part := Current + ' ' + WordValue;
          if ProfileMeasureText(AMeasureText, Part) <= AMaxWidth then
          begin
            Current := Part;
            Continue;
          end;
          if Current <> '' then
          begin
            Lines.Add(Current);
            Current := '';
          end;
          Part := WordValue;
          while ProfileMeasureText(AMeasureText, Part) > AMaxWidth do
          begin
            PrefixLength := FittingPrefixLength(Part, AMaxWidth,
              AMeasureText);
            PrefixLength := HyphenBreakLength(Part, PrefixLength);
            Lines.Add(Copy(Part, 1, PrefixLength));
            Delete(Part, 1, PrefixLength);
          end;
          Current := Part;
        end;
        if Current <> '' then
          Lines.Add(Current);
      end;

      if (AMaxLines > 0) and (Lines.Count > AMaxLines) then
      begin
        WasTruncated := True;
        while Lines.Count > AMaxLines do
          Lines.Delete(Lines.Count - 1);
        if AEllipsis and (Lines.Count > 0) then
        begin
          I := Lines.Count - 1;
          Lines[I] := FitMeasuredWithEllipsis(Lines[I] + '…',
            AMaxWidth, AMeasureText);
        end;
      end;

      Result.Lines := Lines.ToArray;
      for I := 0 to High(Result.Lines) do
        Result.Width := Max(Result.Width,
          Min(AMaxWidth, ProfileMeasureText(AMeasureText, Result.Lines[I])));
      Result.Height := Length(Result.Lines) * Result.LineHeight;
      Result.Truncated := WasTruncated;
    finally
      Lines.Free;
    end;
  finally
    PerfTimer.Stop;
  end;
end;

function BuildTextLayout(const AText: string; const AMaxWidth, AFontSize: Single;
  const AWordWrap, AEllipsis: Boolean; const AMaxLines: Integer): TUniTextLayout;
var
  Lines: TList<string>;
  Words: TArray<string>;
  WordValue, Current, Part: string;
  MaxChars, I, TakeCount: Integer;
  EffectiveMaxLines: Integer;
  WasTruncated: Boolean;
begin
  Result.Lines := nil;
  Result.Width := 0;
  Result.LineHeight := Max(1, AFontSize * 1.28);
  Result.Height := 0;
  Result.Truncated := False;

  if AText = '' then
    Exit;

  MaxChars := Max(1, Floor(AMaxWidth / Max(1, AFontSize * 0.56)));
  EffectiveMaxLines := AMaxLines;
  Lines := TList<string>.Create;
  try
    WasTruncated := False;

    if not AWordWrap then
    begin
      Part := AText.Replace(#13, ' ').Replace(#10, ' ');
      if AEllipsis then
        Part := FitWithEllipsis(Part, MaxChars);
      Lines.Add(Part);
      WasTruncated := Length(Part) < Length(AText);
    end
    else
    begin
      Words := AText.Replace(#13, ' ').Replace(#10, ' ').Split([' '],
        TStringSplitOptions.ExcludeEmpty);
      Current := '';
      for WordValue in Words do
      begin
        if Length(WordValue) > MaxChars then
        begin
          if Current <> '' then
          begin
            Lines.Add(Current);
            Current := '';
          end;
          Part := WordValue;
          while Length(Part) > MaxChars do
          begin
            TakeCount := HyphenBreakLength(Part, MaxChars);
            Lines.Add(Copy(Part, 1, TakeCount));
            Delete(Part, 1, TakeCount);
          end;
          Current := Part;
        end
        else if Current = '' then
          Current := WordValue
        else if Length(Current) + 1 + Length(WordValue) <= MaxChars then
          Current := Current + ' ' + WordValue
        else
        begin
          Lines.Add(Current);
          Current := WordValue;
        end;
      end;
      if Current <> '' then
        Lines.Add(Current);
    end;

    if (EffectiveMaxLines > 0) and (Lines.Count > EffectiveMaxLines) then
    begin
      WasTruncated := True;
      while Lines.Count > EffectiveMaxLines do
        Lines.Delete(Lines.Count - 1);
      if AEllipsis and (Lines.Count > 0) then
      begin
        I := Lines.Count - 1;
        TakeCount := Max(1, MaxChars - 1);
        Lines[I] := Copy(Lines[I], 1, TakeCount) + '…';
      end;
    end;

    Result.Lines := Lines.ToArray;
    for I := 0 to High(Result.Lines) do
      Result.Width := Max(Result.Width,
        Min(AMaxWidth, EstimateTextWidth(Result.Lines[I], AFontSize)));
    Result.Height := Length(Result.Lines) * Result.LineHeight;
    Result.Truncated := WasTruncated;
  finally
    Lines.Free;
  end;
end;

end.