unit UniList.Theme;

interface

uses
  System.SysUtils, System.Classes, System.UITypes, System.Math, System.StrUtils,
  System.Generics.Collections;

type
  TUniThemeVariant = (utvLight, utvDark);

  TUniThemeDefinition = class
  private
    FName: string;
    FAuthor: string;
    FVariant: TUniThemeVariant;
    FBackground: TAlphaColor;
    FForeground: TAlphaColor;
    FCursor: TAlphaColor;
    FSelection: TAlphaColor;
    FTerminalUI: TAlphaColor;
  public
    property Name: string read FName;
    property Author: string read FAuthor;
    property Variant: TUniThemeVariant read FVariant;
    property Background: TAlphaColor read FBackground;
    property Foreground: TAlphaColor read FForeground;
    property Cursor: TAlphaColor read FCursor;
    property Selection: TAlphaColor read FSelection;
    property TerminalUI: TAlphaColor read FTerminalUI;
  end;

  TUniThemeManager = class
  strict private
    class var FThemes: TObjectList<TUniThemeDefinition>;
    class procedure AddBuiltIn(const AName, AAuthor, AVariant: string;
      const ABackground, AForeground, ACursor, ASelection, ATerminalUI: TAlphaColor); static;
    class function ReadYAMLValue(const ALines: TStrings; const AKey: string): string; static;
  public
    class constructor Create;
    class destructor Destroy;
    class function Count: Integer; static;
    class function ThemeAt(const AIndex: Integer): TUniThemeDefinition; static;
    class function Find(const AName: string): TUniThemeDefinition; static;
    class function ThemeNames: TArray<string>; static;
    class function LoadFromYAMLFile(const AFileName: string): TUniThemeDefinition; static;
  end;

function UniBlendColor(const ABase, AOverlay: TAlphaColor; const AAmount: Single): TAlphaColor;

implementation

function UniBlendColor(const ABase, AOverlay: TAlphaColor; const AAmount: Single): TAlphaColor;
var
  T: Single;
  BA, BR, BG, BB, OA, ORed, OG, OB: Byte;
begin
  T := EnsureRange(AAmount, 0, 1);
  BA := (ABase shr 24) and $FF; BR := (ABase shr 16) and $FF;
  BG := (ABase shr 8) and $FF; BB := ABase and $FF;
  OA := (AOverlay shr 24) and $FF; ORed := (AOverlay shr 16) and $FF;
  OG := (AOverlay shr 8) and $FF; OB := AOverlay and $FF;
  Result := (Round(BA + (OA - BA) * T) shl 24) or
    (Round(BR + (ORed - BR) * T) shl 16) or
    (Round(BG + (OG - BG) * T) shl 8) or
    Round(BB + (OB - BB) * T);
end;

class procedure TUniThemeManager.AddBuiltIn(const AName, AAuthor, AVariant: string;
  const ABackground, AForeground, ACursor, ASelection, ATerminalUI: TAlphaColor);
var T: TUniThemeDefinition;
begin
  T := TUniThemeDefinition.Create;
  T.FName := AName; T.FAuthor := AAuthor;
  if SameText(AVariant, 'light') then T.FVariant := utvLight else T.FVariant := utvDark;
  T.FBackground := ABackground; T.FForeground := AForeground; T.FCursor := ACursor;
  T.FSelection := ASelection; T.FTerminalUI := ATerminalUI;
  FThemes.Add(T);
end;

class constructor TUniThemeManager.Create;
begin
  FThemes := TObjectList<TUniThemeDefinition>.Create(True);
  AddBuiltIn('1984 Dark', 'Termius', 'dark', $FF0D1030, $FFDEDEE1, $FFDEDEE1, $80DEDEE1, $FF767698);
  AddBuiltIn('1984 Light', 'Termius', 'light', $FFE4ECF4, $FF353247, $FF353247, $80353247, $FF798DA1);
  AddBuiltIn('Atom One Dark', 'Termius', 'dark', $FF1E2127, $FFABB2BF, $FF5C6370, $80ABB2BF, $FF70798D);
  AddBuiltIn('Atom One Light', 'Termius', 'light', $FFF9F9F9, $FF383A42, $FF383A42, $80383A42, $FF9395A3);
  AddBuiltIn('Aubergine', 'Termius', 'dark', $FF2C001E, $FFEEEEEC, $FFBBBBBB, $80EEEEEC, $FFB385A5);
  AddBuiltIn('Aura', 'Termius', 'dark', $FF21202E, $FFEDECEE, $FFEDECEE, $80EDECEE, $FFA6A2D7);
  AddBuiltIn('Ayu Dark', 'Termius', 'dark', $FF0F1419, $FFE6E1CF, $FFF29718, $80E6E1CF, $FF716F67);
  AddBuiltIn('Ayu Light', 'Termius', 'light', $FFFAFAFA, $FF5C6773, $FFFF6A00, $805C6773, $FFA1A1A1);
  AddBuiltIn('Basic', 'Termius', 'light', $FFFFFFFF, $FF000000, $FF7F7F7F, $80000000, $FF808080);
  AddBuiltIn('Catppuccin Latte', 'Termius', 'light', $FFEFF1F5, $FF4C4F69, $FFDC8A78, $80DC8A78, $FF858A9C);
  AddBuiltIn('Catppuccin Mocha', 'Termius', 'dark', $FF1E1E2E, $FFCDD6F4, $FFF5E0DC, $80F5E0DC, $FF777790);
  AddBuiltIn('Cobalt2', 'Termius', 'dark', $FF132738, $FFFFFFFF, $FFF0CC09, $80FFFFFF, $FF8B9CAB);
  AddBuiltIn('Cyberpunk Scarlet', 'Termius', 'dark', $FF101116, $FFFF0055, $FF00FFC8, $80FF0055, $FF933F5B);
  AddBuiltIn('Cyberpunk', 'Termius', 'dark', $FF332A57, $FFE5E5E5, $FF21F6BC, $80E5E5E5, $FF8174B8);
  AddBuiltIn('Dia De Muertos', 'Termius', 'light', $FFFFFDF5, $FF281F63, $FFB33A00, $80E67601, $FF8B8982);
  AddBuiltIn('Diwali', 'Termius', 'dark', $FF311652, $FFFDF6F6, $FFFFA900, $80FFA900, $FF856EA2);
  AddBuiltIn('Dracula', 'Termius', 'dark', $FF282A36, $FFF8F8F2, $FFBBBBBB, $80F8F8F2, $FF7D8197);
  AddBuiltIn('Everforest Dark', 'Termius', 'dark', $FF282E32, $FFD3C6AA, $FFD3C6AA, $80D3C6AA, $FF88928A);
  AddBuiltIn('Everforest Light', 'Termius', 'light', $FFFEFBF1, $FF5C6A72, $FF5C6A72, $805C6A72, $FF959F92);
  AddBuiltIn('Flexoki Dark', 'Termius', 'dark', $FF100F0F, $FFCECDC3, $FFCECDC3, $80CECDC3, $FF888781);
  AddBuiltIn('Flexoki Light', 'Termius', 'light', $FFFFFCF0, $FF100F0F, $FF100F0F, $80100F0F, $FF878580);
  AddBuiltIn('Grass', 'Termius', 'dark', $FF13773D, $FFFFF0A5, $FF8C2800, $80FFF0A5, $FF8ED4AC);
  AddBuiltIn('Gruvbox Dark', 'Termius', 'dark', $FF282828, $FFEBDBB2, $FFEBDBB2, $80EBDBB2, $FF908477);
  AddBuiltIn('Gruvbox Light', 'Termius', 'light', $FFFBF1C7, $FF282828, $FF282828, $80282828, $FF857D5F);
  AddBuiltIn('Hacker Blue', 'Termius', 'dark', $FF010515, $FF11B7FF, $FF10B6FF, $80C1E4FF, $FF2C71A4);
  AddBuiltIn('Hacker Green', 'Termius', 'dark', $FF020F01, $FF16B10E, $FF15D00D, $80D4FFC1, $FF2CA43F);
  AddBuiltIn('Hacker Red', 'Termius', 'dark', $FF200000, $FFB10E0E, $FFB00D0D, $80EBC1FF, $FFA42C2C);
  AddBuiltIn('Halloween', 'Termius', 'dark', $FF22012B, $FFE5E5E5, $FFFFA900, $80FFA900, $FF9F84A7);
  AddBuiltIn('Homebrew', 'Termius', 'dark', $FF000000, $FF00FF00, $FF23FF18, $8000FF00, $FF9D9D9D);
  AddBuiltIn('Kanagawa Dragon', 'Termius', 'dark', $FF181616, $FFC5C9C5, $FFC8C093, $80C9C580, $FF88928A);
  AddBuiltIn('Kanagawa Lotus', 'Termius', 'light', $FFF2ECBC, $FF545464, $FF43436C, $80546480, $FF88928A);
  AddBuiltIn('Kanagawa Wave', 'Termius', 'dark', $FF1F1F28, $FFDCD7BA, $FFC8C093, $80D7BA80, $FF88928A);
  AddBuiltIn('Light Owl', 'Termius', 'light', $FFFBFBFB, $FF403F53, $FF90A7B2, $80403F53, $FF8898A4);
  AddBuiltIn('Man Page', 'Termius', 'light', $FFFEF49C, $FF000000, $FF7F7F7F, $80000000, $FF848057);
  AddBuiltIn('Manhattan', 'Termius', 'dark', $FF0A0A0A, $FFB8B9B4, $FFDFE0DB, $80B8B9B4, $FF7B7B7B);
  AddBuiltIn('Material Dark', 'Termius', 'dark', $FF232322, $FFE5E5E5, $FF16AFCA, $80E5E5E5, $FF75756E);
  AddBuiltIn('Material Light', 'Termius', 'light', $FFEAEAEA, $FF2F2F2F, $FF16AFCA, $80232322, $FF747474);
  AddBuiltIn('Monokai', 'Termius', 'dark', $FF0C0C0C, $FFD9D9D9, $FFFC971F, $80D9D9D9, $FF86899A);
  AddBuiltIn('Movember', 'Termius', 'dark', $FF1F0900, $FFFFE7C3, $FFE6C03C, $803B2626, $FF8C6D5E);
  AddBuiltIn('Night Owl', 'Termius', 'dark', $FF011627, $FFD6DEEB, $FF80A4C2, $80D6DEEB, $FF6D90AD);
  AddBuiltIn('Nord Dark', 'Termius', 'dark', $FF2E3440, $FFD8DEE9, $FFECEFF4, $80ECEFF4, $FF808A9E);
  AddBuiltIn('Nord Light', 'Termius', 'light', $FFE5E9F0, $FF414858, $FF88C0D0, $80414858, $FF6F7683);
  AddBuiltIn('Novel', 'Termius', 'light', $FFDFDBC3, $FF3B2322, $FF73635A, $803B2322, $FF6F6C5A);
  AddBuiltIn('Ocean', 'Termius', 'dark', $FF224FBC, $FFFFFFFF, $FF7F7F7F, $80FFFFFF, $FF9BB4EE);
  AddBuiltIn('Octocat Dark', 'Termius', 'dark', $FF101216, $FF8B949E, $FFC9D1D9, $808B949E, $FF626873);
  AddBuiltIn('Octocat Light', 'Termius', 'light', $FFF4F4F4, $FF3E3E3E, $FF3F3F3F, $803E3E3E, $FFA1A1A1);
  AddBuiltIn('Peach Fresh', 'Termius', 'light', $FFF5C19E, $FF520701, $FFB33A00, $80E67601, $FF8A6851);
  AddBuiltIn('Plastic World', 'Termius', 'dark', $FFEA56C1, $FFFFE9DA, $FFBAFC8B, $80FFE9DA, $FFFFD9F2);
  AddBuiltIn('Pro', 'Termius', 'dark', $FF000000, $FFF2F2F2, $FF4D4D4D, $80F2F2F2, $FF9D9D9D);
  AddBuiltIn('Red Sands', 'Termius', 'dark', $FF7A251E, $FFD7C9A7, $FFFFFFFF, $80D7C9A7, $FFCC8984);
  AddBuiltIn('Romania Day', 'Termius', 'light', $FFF5E8E7, $FF632228, $FFD7B25E, $80632228, $FFB29A98);
  AddBuiltIn('Romania Night', 'Termius', 'dark', $FF0B141F, $FFF5F5EA, $FFF7D382, $80F5F5EA, $FF8092A7);
  AddBuiltIn('Rosé Pine Dawn', 'Termius', 'light', $FFFAF4ED, $FF575279, $FF575279, $80575279, $FF7D776F);
  AddBuiltIn('Rosé Pine Moon', 'Termius', 'dark', $FF232136, $FFE0DEF4, $FFE0DEF4, $80E0DEF4, $FF858297);
  AddBuiltIn('Rosé Pine', 'Termius', 'dark', $FF191724, $FFE0DEF4, $FFE0DEF4, $80E0DEF4, $FF858297);
  AddBuiltIn('Silver Aerogel', 'Termius', 'light', $FF919191, $FF000000, $FFD9D9D9, $80000000, $FF4D4D4D);
  AddBuiltIn('Solarized Dark', 'Termius', 'dark', $FF002B36, $FF839496, $FF657779, $80657779, $FF5D838D);
  AddBuiltIn('Solarized Light', 'Termius', 'light', $FFFDF6E3, $FF657B83, $FF657B83, $80657B83, $FF9C9686);
  AddBuiltIn('Termius Dark', 'Termius', 'dark', $FF141729, $FF21B568, $FF21B568, $8021B568, $FF8D91A5);
  AddBuiltIn('Termius Light', 'Termius', 'light', $FFD5DDE0, $FF32364A, $FF32364A, $8032364A, $FF6C797E);
  AddBuiltIn('Tokyo Day', 'Termius', 'light', $FFE1E2E7, $FF2F54A8, $FF3760BF, $803760BF, $FF757885);
  AddBuiltIn('Tokyo Night', 'Termius', 'dark', $FF1A1B26, $FFCDD6FF, $FFC0CAF5, $80C0CAF5, $FF6E769A);
  AddBuiltIn('Winter Day', 'Termius', 'light', $FFECE3D1, $FF1A2720, $FF5C6370, $80ABB2BF, $FF887F6A);
  AddBuiltIn('Winter Night', 'Termius', 'dark', $FF00192C, $FFE4D5CC, $FFF8CFA6, $80E4D5CC, $FF869CB2);
end;

class destructor TUniThemeManager.Destroy;
begin
  FThemes.Free;
end;

class function TUniThemeManager.Count: Integer;
begin Result := FThemes.Count; end;

class function TUniThemeManager.ThemeAt(const AIndex: Integer): TUniThemeDefinition;
begin
  if (AIndex < 0) or (AIndex >= FThemes.Count) then Exit(nil);
  Result := FThemes[AIndex];
end;

class function TUniThemeManager.Find(const AName: string): TUniThemeDefinition;
var T: TUniThemeDefinition;
begin
  Result := nil;
  for T in FThemes do if SameText(T.Name, AName) then Exit(T);
end;

class function TUniThemeManager.ThemeNames: TArray<string>;
var I: Integer;
begin
  SetLength(Result, FThemes.Count);
  for I := 0 to FThemes.Count - 1 do Result[I] := FThemes[I].Name;
end;

class function TUniThemeManager.ReadYAMLValue(const ALines: TStrings; const AKey: string): string;
var Line, Prefix: string; I: Integer;
begin
  Result := ''; Prefix := AKey + ':';
  for I := 0 to ALines.Count - 1 do
  begin
    Line := Trim(ALines[I]);
    if StartsText(Prefix, Line) then
    begin
      Result := Trim(Copy(Line, Length(Prefix) + 1, MaxInt));
      Result := Result.Trim(['"', #39]);
      Exit;
    end;
  end;
end;

function ParseThemeColor(const S: string): TAlphaColor;
var V: string; N: UInt64;
begin
  V := S.Trim.Trim(['"', #39]);
  if V.StartsWith('#') then Delete(V, 1, 1);
  if Length(V) = 6 then V := 'FF' + V
  else if Length(V) = 8 then V := Copy(V, 7, 2) + Copy(V, 1, 6);
  if not TryStrToUInt64('$' + V, N) then N := 0;
  Result := TAlphaColor(N);
end;

class function TUniThemeManager.LoadFromYAMLFile(const AFileName: string): TUniThemeDefinition;
var L: TStringList; V: string;
begin
  Result := nil;
  if not FileExists(AFileName) then Exit;
  L := TStringList.Create;
  try
    L.LoadFromFile(AFileName, TEncoding.UTF8);
    Result := TUniThemeDefinition.Create;
    Result.FName := ReadYAMLValue(L, 'name');
    Result.FAuthor := ReadYAMLValue(L, 'author');
    V := ReadYAMLValue(L, 'variant');
    if SameText(V, 'light') then Result.FVariant := utvLight else Result.FVariant := utvDark;
    Result.FBackground := ParseThemeColor(ReadYAMLValue(L, 'background'));
    Result.FForeground := ParseThemeColor(ReadYAMLValue(L, 'foreground'));
    Result.FCursor := ParseThemeColor(ReadYAMLValue(L, 'cursor'));
    Result.FSelection := ParseThemeColor(ReadYAMLValue(L, 'selection'));
    Result.FTerminalUI := ParseThemeColor(ReadYAMLValue(L, 'terminal_ui'));
  finally
    L.Free;
  end;
end;

end.
