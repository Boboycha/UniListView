unit DesignPreviewDemo;

interface

uses
  System.Classes,
  FMX.Forms,
  UniList.Control;

type
  TDesignPreviewForm = class(TForm)
    ListPreview: TUniListView;
    CardsPreview: TUniListView;
    FullWidthPreview: TUniListView;
    TreePreview: TUniListView;
  end;

implementation

{$R *.fmx}

end.
