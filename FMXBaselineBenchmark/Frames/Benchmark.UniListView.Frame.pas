unit Benchmark.UniListView.Frame;

interface

uses
  System.Classes, FMX.Types, FMX.Controls,
  Benchmark.Types, Benchmark.Base.Frame,
  UniList.Control;

type
  TBenchmarkUniListViewFrame = class(TBenchmarkBaseFrame)
  private
    FItemCount: Integer;
    FMode: TBenchmarkTestId;
    FListView: TUniListView;
    procedure ListMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure ListClick(Sender: TObject);
    procedure ListMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; var Handled: Boolean);
  protected
    procedure BuildContent; override;
    procedure Resize; override;
    procedure ApplyScale; override;
    function WorkloadText: string; override;
    function VisibleWorkloadText: string; override;
  public
    procedure Configure(const AMode: TBenchmarkTestId; const AItemCount: Integer);
    procedure Start(const AScenario: TBenchmarkScenario;
      const AMode: TBenchmarkSamplingMode); override;
    procedure Stop; override;
  end;

implementation

{$R *.fmx}

uses
  System.SysUtils, Benchmark.Profiler,
  UniList.Types, UniList.Items, UniList.Columns, UniList.Performance;

procedure TBenchmarkUniListViewFrame.Configure(const AMode: TBenchmarkTestId;
  const AItemCount: Integer);
begin
  FMode := AMode;
  FItemCount := AItemCount;
end;

procedure TBenchmarkUniListViewFrame.BuildContent;
var
  Index: Integer;
  Item: TUniListItem;
  StartTicks: Int64;
begin
  inherited;
  FreeAndNil(FListView);
  StartTicks := BenchmarkNowTicks;
  FListView := TUniListView.Create(Self);
  FListView.Parent := Self;
  FListView.Align := TAlignLayout.Client;
  FListView.ListAutoRowHeight := False;
  FListView.ListRowHeight := 34;
  FListView.Columns.Add.FieldName := 'name';
  FListView.Columns.Add.FieldName := 'group';
  FListView.Columns.Add.FieldName := 'status';
  FListView.BeginUpdate;
  try
    for Index := 0 to FItemCount - 1 do
    begin
      Item := FListView.AddItem('Benchmark item ' + IntToStr(Index + 1),
        'Group ' + IntToStr(Index mod 100),
        'Status ' + IntToStr(Index mod 7));
      Item.ID := IntToStr(Index + 1);
      if Index >= 10 then
        Item.ParentID := IntToStr((Index div 10));
      Item.SetField('id', Item.ID);
      Item.SetField('parentid', Item.ParentID);
      Item.SetField('name', Item.Title);
      Item.SetField('group', 'Group ' + IntToStr(Index mod 100));
      Item.SetField('status', 'Status ' + IntToStr(Index mod 7));
    end;
  finally
    FListView.EndUpdate;
  end;
  case FMode of
    btiUniCards:
      begin
        FListView.TreeMode := False;
        FListView.ViewMode := uvmCards;
      end;
    btiUniTree:
      begin
        FListView.ViewMode := uvmList;
        FListView.TreeKeyField := 'id';
        FListView.TreeParentField := 'parentid';
        FListView.TreeColumn := 'name';
        FListView.TreeMode := True;
        FListView.ExpandToLevel(2);
      end;
  else
    FListView.TreeMode := False;
    FListView.ViewMode := uvmList;
  end;
  FListView.OnMouseMove := ListMouseMove;
  FListView.OnClick := ListClick;
  FListView.OnMouseWheel := ListMouseWheel;
  FListView.ResetPerformanceCounters;
  if Profiler <> nil then
    Profiler.AddLoadMs(BenchmarkTicksToMs(BenchmarkNowTicks - StartTicks));
end;

procedure TBenchmarkUniListViewFrame.ApplyScale;
begin
  inherited;
  if FListView <> nil then
  begin
    FListView.Scale.X := BenchmarkScale;
    FListView.Scale.Y := BenchmarkScale;
  end;
end;

procedure TBenchmarkUniListViewFrame.ListMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Single);
begin
  MarkBenchmarkInput;
  RequestBenchmarkFrame;
end;

procedure TBenchmarkUniListViewFrame.ListClick(Sender: TObject);
begin
  MarkBenchmarkInput;
  RequestBenchmarkFrame;
end;

procedure TBenchmarkUniListViewFrame.ListMouseWheel(Sender: TObject;
  Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
begin
  MarkBenchmarkInput;
  RequestBenchmarkFrame;
end;

procedure TBenchmarkUniListViewFrame.Resize;
begin
  inherited;
  MarkBenchmarkInput;
  RequestBenchmarkFrame;
end;

procedure TBenchmarkUniListViewFrame.Start(const AScenario: TBenchmarkScenario;
  const AMode: TBenchmarkSamplingMode);
begin
  FListView.ResetPerformanceCounters;
  inherited;
end;

procedure TBenchmarkUniListViewFrame.Stop;
var
  Snapshot: TUniPerformanceSnapshot;
  PaintMetric: TUniPerfMetricSnapshot;
begin
  inherited;
  Snapshot := FListView.GetPerformanceSnapshot;
  PaintMetric := Snapshot.MetricSnapshots[upcPaint];
  if Profiler <> nil then
    Profiler.ReplacePaintMetric(PaintMetric.Calls, PaintMetric.LastMilliseconds,
      PaintMetric.TotalMilliseconds, PaintMetric.MaxMilliseconds);
end;

function TBenchmarkUniListViewFrame.WorkloadText: string;
begin
  Result := Format('%s with %d items', [BenchmarkTestName(FMode), FItemCount]);
end;

function TBenchmarkUniListViewFrame.VisibleWorkloadText: string;
var
  Snapshot: TUniPerformanceSnapshot;
begin
  if FListView = nil then
    Exit('0');
  Snapshot := FListView.GetPerformanceSnapshot;
  Result := IntToStr(Snapshot.VisibleItems) + ' visible items';
end;

end.