unit Benchmark.ListView.Frame;

interface

uses
  System.Classes, FMX.Types, FMX.Controls, FMX.ListView, FMX.ListView.Types,
  FMX.ListView.Appearances,
  Benchmark.Base.Frame;

type
  TBenchmarkListViewFrame = class(TBenchmarkBaseFrame)
  private
    FItemCount: Integer;
    FListView: TListView;
  protected
    procedure BuildContent; override;
    function WorkloadText: string; override;
    function VisibleWorkloadText: string; override;
  public
    procedure Configure(const AItemCount: Integer);
  end;

implementation

{$R *.fmx}

uses
  System.SysUtils, Benchmark.Profiler;

procedure TBenchmarkListViewFrame.Configure(const AItemCount: Integer);
begin
  FItemCount := AItemCount;
end;

procedure TBenchmarkListViewFrame.BuildContent;
var
  Index: Integer;
  Item: TListViewItem;
  StartTicks: Int64;
begin
  inherited;
  if FListView <> nil then
    FreeAndNil(FListView);
  StartTicks := BenchmarkNowTicks;
  FListView := TListView.Create(Self);
  FListView.Parent := Self;
  FListView.Align := TAlignLayout.Client;
  FListView.ItemAppearance.ItemAppearance := 'ImageListItemBottomDetail';
  FListView.BeginUpdate;
  try
    for Index := 0 to FItemCount - 1 do
    begin
      Item := FListView.Items.Add;
      Item.Text := 'Standard item ' + IntToStr(Index + 1);
      Item.Detail := 'Detail ' + IntToStr(Index mod 100);
    end;
  finally
    FListView.EndUpdate;
  end;
  if TagObject is TBenchmarkProfiler then
    TBenchmarkProfiler(TagObject).AddLoadMs(
      BenchmarkTicksToMs(BenchmarkNowTicks - StartTicks));
end;

function TBenchmarkListViewFrame.WorkloadText: string;
begin
  Result := Format('FMX TListView with %d items', [FItemCount]);
end;

function TBenchmarkListViewFrame.VisibleWorkloadText: string;
begin
  Result := 'visible item count depends on FMX TListView virtualization and viewport';
end;

end.
