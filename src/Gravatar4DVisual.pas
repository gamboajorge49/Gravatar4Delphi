unit Gravatar4DVisual;

interface

uses
  System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.ExtCtrls,
  Gravatar4D;

type
  { TGravatarImage
    Visual component that displays a Gravatar avatar based on the published
    Gravatar properties (Email, Size, Rating and Default image). It relies on
    the existing TGravatar4D engine to build the URL and download the image. }
  TGravatarImage = class(TImage)
  private
    FEngine: TGravatar4D;
    FEmail: string;
    FGravatarSize: Smallint;
    FRating: TGravatarRating;
    FDefaultImage: TGravatarDeafult;
    FDefaultImageUrl: string;
    FAutoLoad: Boolean;
    procedure SetEmail(const Value: string);
    procedure SetGravatarSize(const Value: Smallint);
    procedure SetRating(const Value: TGravatarRating);
    procedure SetDefaultImage(const Value: TGravatarDeafult);
    procedure SetDefaultImageUrl(const Value: string);
    procedure ReloadIfAutoLoad;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    { Builds the Gravatar URL for the current properties. }
    function GravatarUrl: string;

    { Downloads the Gravatar image and assigns it to the Picture. }
    procedure LoadGravatar;
  published
    property Email: string read FEmail write SetEmail;
    property GravatarSize: Smallint read FGravatarSize write SetGravatarSize default 80;
    property Rating: TGravatarRating read FRating write SetRating default grG;
    property DefaultImage: TGravatarDeafult read FDefaultImage write SetDefaultImage default gdNone;
    property DefaultImageUrl: string read FDefaultImageUrl write SetDefaultImageUrl;
    { When True the avatar is (re)loaded automatically whenever a Gravatar
      property changes at run time. }
    property AutoLoad: Boolean read FAutoLoad write FAutoLoad default False;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Gravatar4D', [TGravatarImage]);
end;

{ TGravatarImage }

constructor TGravatarImage.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FEngine := TGravatar4D.Create;
  FGravatarSize := 80;
  FRating := grG;
  FDefaultImage := gdNone;
  FAutoLoad := False;
  Proportional := True;
  Center := True;
end;

destructor TGravatarImage.Destroy;
begin
  FreeAndNil(FEngine);
  inherited Destroy;
end;

function TGravatarImage.GravatarUrl: string;
begin
  Result := FEngine.GenerateUrl(FEmail, FGravatarSize, FRating, FDefaultImage, FDefaultImageUrl);
end;

procedure TGravatarImage.LoadGravatar;
var
  DownloadedPicture: TPicture;
begin
  if Trim(FEmail) = '' then
    Exit;

  DownloadedPicture := FEngine.GravatarImage(FEmail, FGravatarSize, FRating, FDefaultImage, FDefaultImageUrl);
  try
    Picture.Assign(DownloadedPicture);
  finally
    FreeAndNil(DownloadedPicture);
  end;
end;

procedure TGravatarImage.ReloadIfAutoLoad;
begin
  if FAutoLoad and not (csDesigning in ComponentState) and not (csLoading in ComponentState) then
    LoadGravatar;
end;

procedure TGravatarImage.SetEmail(const Value: string);
begin
  if FEmail <> Value then
  begin
    FEmail := Value;
    ReloadIfAutoLoad;
  end;
end;

procedure TGravatarImage.SetGravatarSize(const Value: Smallint);
begin
  if FGravatarSize <> Value then
  begin
    FGravatarSize := Value;
    ReloadIfAutoLoad;
  end;
end;

procedure TGravatarImage.SetRating(const Value: TGravatarRating);
begin
  if FRating <> Value then
  begin
    FRating := Value;
    ReloadIfAutoLoad;
  end;
end;

procedure TGravatarImage.SetDefaultImage(const Value: TGravatarDeafult);
begin
  if FDefaultImage <> Value then
  begin
    FDefaultImage := Value;
    ReloadIfAutoLoad;
  end;
end;

procedure TGravatarImage.SetDefaultImageUrl(const Value: string);
begin
  if FDefaultImageUrl <> Value then
  begin
    FDefaultImageUrl := Value;
    ReloadIfAutoLoad;
  end;
end;

end.
