unit Gravatar4D;

interface

uses
  System.SysUtils, System.Classes, System.TypInfo, System.RegularExpressions,
  System.Hash, System.JSON, System.Contnrs, Vcl.Graphics, Vcl.Dialogs, Vcl.Imaging.pngimage, Vcl.Imaging.jpeg,
  IdUri, IdHashMessageDigest, REST.Types, REST.Client, Data.Bind.Components,
  Data.Bind.ObjectScope;

type
  TGravatarRating = (grG, grPG, grR, grX);

  TGravatarDeafult = (gdNone, gdUrlImage, gd404, gdmp, gdidenticon, gdmonsterid, gdwavatar, gdretro, gdrobohash, gdblank);

  EGravatar4dException = class(Exception)
  private
    FEmail: string;
  public
    property Email: string read FEmail;
    constructor Create(const Msg: string; const AEmail: string);
  end;

  TGravatarVerifiedAccount = class
  public
    ServiceType: string;
    ServiceLabel: string;
    ServiceIcon: string;
    Url: string;
    IsHidden: Boolean;
  end;

  TGravatarSectionVisibility = class
  public
    HiddenContactInfo: Boolean;
    HiddenFeeds: Boolean;
    HiddenLinks: Boolean;
    HiddenInterests: Boolean;
    HiddenWallet: Boolean;
    HiddenPhotos: Boolean;
    HiddenVerifiedAccounts: Boolean;
  end;

  TGravatarProfile = class
  public
    Hash: string;
    DisplayName: string;
    ProfileUrl: string;
    AvatarUrl: string;
    AvatarAltText: string;
    Location: string;
    Description: string;
    JobTitle: string;
    Company: string;
    Pronunciation: string;
    Pronouns: string;
    HideDefaultHeaderImage: Boolean;
    BackgroundColor: string;
    SectionVisibility: TGravatarSectionVisibility;
    VerifiedAccounts: TObjectList;
    constructor Create;
    destructor Destroy; override;
  end;

  TGravatar4D = class(TComponent)
  private
    FGravatarRating: TGravatarRating;
    function DownloadImage(const Url: string): TPicture;
    function EmailIsValid(const AEmail: string): Boolean;
  public
    constructor Create; reintroduce;

    function EmailToMD5(const Value: string): string;

    function GenerateUrl(const Email: string; const Size: Smallint = 0; const GravatarRating: TGravatarRating = grG; const GravatarDeafult: TGravatarDeafult = gdNone; const URLDefaultImage: string = ''): string;

    function GravatarImage(const Email: string): TPicture; overload;

    function GravatarImage(const Email: string; const Size: Smallint): TPicture; overload;

    function GravatarImage(const Email: string; const Size: Smallint; const GravatarRating: TGravatarRating = grG; const GravatarDeafult: TGravatarDeafult = gdNone; const URLDefaultImage: string = ''): TPicture; overload;
  end;

  TGravatar4DV3 = class(TComponent)
  private
    function DownloadImage(const Url: string): TPicture;
    function DownloadImageByRequest(const BaseUrl: string; const Resource: string): TPicture;
    function EmailIsValid(const AEmail: string): Boolean;
    function BuildProfileResourceByIdentifier(const Identifier: string): string;
    function BuildQrCodeResource(const Sha256Hash: string; const Size: Smallint; const Version: Smallint; const IconType: string): string;
    function ExecuteJsonGet(const BaseUrl: string; const Resource: string; const ApiKey: string): string;
  public
    constructor Create; reintroduce;

    function EmailToSHA256(const Value: string): string;
    function GenerateAvatarUrl(const Email: string): string;

    function GetAvatarImageByEmail(const Email: string): TPicture;
    function GetAvatarImageByHash(const Sha256Hash: string): TPicture;

    function GetProfileJsonByEmail(const Email: string; const ApiKey: string = ''): string;
    function GetProfileJsonByIdentifier(const Identifier: string; const ApiKey: string = ''): string;
    function GetProfileByEmail(const Email: string; const ApiKey: string = ''): TGravatarProfile;
    function GetProfileByIdentifier(const Identifier: string; const ApiKey: string = ''): TGravatarProfile;
    function ParseProfileJson(const Json: string): TGravatarProfile;

    function GetQrCodeImageByEmail(const Email: string; const Size: Smallint = 0; const Version: Smallint = 0; const IconType: string = ''): TPicture;
    function GetQrCodeImageByHash(const Sha256Hash: string; const Size: Smallint = 0; const Version: Smallint = 0; const IconType: string = ''): TPicture;
  end;

procedure Register;

const
  URL_BASE: string = 'https://www.gravatar.com/avatar/';
  URL_BASE_V3_AVATAR: string = 'https://0.gravatar.com/avatar/';
  URL_API_V3_BASE: string = 'https://api.gravatar.com';
  URL_API_V3_PATH: string = 'v3';

implementation

procedure Register;
begin
  RegisterComponents('Gravatar4D', [TGravatar4D, TGravatar4DV3]);
end;

{ TGravatarProfile }

constructor TGravatarProfile.Create;
begin
  inherited Create;
  SectionVisibility:= TGravatarSectionVisibility.Create;
  VerifiedAccounts:= TObjectList.Create(True);
end;

destructor TGravatarProfile.Destroy;
begin
  FreeAndNil(SectionVisibility);
  FreeAndNil(VerifiedAccounts);
  inherited Destroy;
end;

{ TGravatar4D }

constructor TGravatar4D.Create;
begin
  inherited Create(nil);
  FGravatarRating := grG;
end;

function TGravatar4D.DownloadImage(const Url: string): TPicture;
var
  RESTClient: TRESTClient;
  RESTRequest: TRESTRequest;
  RESTResponse: TRESTResponse;
  MS: TMemoryStream;
  ContentType: string;
begin
  Result := nil;
  MS := nil;
  RESTClient := TRESTClient.Create(Self);
  RESTRequest := TRESTRequest.Create(Self);
  RESTResponse := TRESTResponse.Create(Self);

  RESTRequest.Client := RESTClient;
  RESTRequest.Response := RESTResponse;

  try

    RESTClient.BaseURL := Url;
    RESTRequest.Execute;

    if (RESTResponse.StatusCode < 200) or (RESTResponse.StatusCode >= 300) then
      raise EGravatar4dException.Create(Format('Failed to download Gravatar image. HTTP status: %d.', [RESTResponse.StatusCode]), '');

    ContentType := LowerCase(Trim(RESTResponse.ContentType));
    if (ContentType <> '') and (Pos('image/', ContentType) <> 1) then
      raise EGravatar4dException.Create(Format('Unexpected content type: %s.', [RESTResponse.ContentType]), '');

    MS := TMemoryStream.Create;
    if Length(RESTResponse.RawBytes) > 0 then
      MS.WriteData(RESTResponse.RawBytes, Length(RESTResponse.RawBytes));
    MS.Position := 0;

    if MS.Size > 0 then
    begin
      MS.Position := 0;
      Result := TPicture.Create;
      try
        Result.LoadFromStream(MS);
      except
        FreeAndNil(Result);
        raise;
      end;
    end
    else
      raise EGravatar4dException.Create('Empty response from Gravatar.', '');

  finally
    FreeAndNil(RESTClient);
    FreeAndNil(RESTRequest);
    FreeAndNil(RESTResponse);

    FreeAndNil(MS);
  end;
end;

function TGravatar4D.EmailIsValid(const AEmail: string): Boolean;
var
  RegEx: TRegEx;
begin
  try
    RegEx := TRegEx.Create('^\S+@\S+\.\S+$', [roIgnoreCase]);
    Result := RegEx.IsMatch(AEmail);
  finally

  end;
end;

function TGravatar4D.EmailToMD5(const Value: string): string;
var
  md5: TIdHashMessageDigest5;
  Normalized: string;
begin
  md5 := TIdHashMessageDigest5.Create;
  try
    Normalized := LowerCase(Trim(Value));
    Result := LowerCase(md5.HashStringAsHex(Normalized));
  finally
    md5.Free;
  end;
end;

function TGravatar4D.GenerateUrl(const Email: string; const Size: Smallint; const GravatarRating: TGravatarRating; const GravatarDeafult: TGravatarDeafult; const URLDefaultImage: string): string;
var
  sb: TStringBuilder;
  d: string;
begin
  sb := TStringBuilder.Create;

  try
    sb.Append(URL_BASE);
    sb.Append(EmailToMD5(Email));

    sb.Append('?r=' + LowerCase(Trim(Copy(GetEnumName(TypeInfo(TGravatarRating), Integer(GravatarRating)), 3, 5))));

    if Size > 0 then
      sb.Append('&s=' + Size.ToString);

    case GravatarDeafult of
      gdNone:
        d := '';
      gdUrlImage:
        begin
          if URLDefaultImage <> '' then
            d := TIdURI.URLEncode(URLDefaultImage)
          else
            d := '';
        end
    else
      begin
        d := LowerCase(Trim(Copy(GetEnumName(TypeInfo(TGravatarDeafult), Integer(GravatarDeafult)), 3, 20)));
      end;

    end;

    if d <> '' then
      sb.Append('&d=' + d);

    Result := sb.ToString;
  finally
    FreeAndNil(sb);
  end;

end;

function TGravatar4D.GravatarImage(const Email: string; const Size: Smallint): TPicture;
begin
  Result := GravatarImage(Email, Size, grG);
end;

function TGravatar4D.GravatarImage(const Email: string): TPicture;
begin
  Result := GravatarImage(Email, 80, grG);
end;

function TGravatar4D.GravatarImage(const Email: string; const Size: Smallint; const GravatarRating: TGravatarRating; const GravatarDeafult: TGravatarDeafult; const URLDefaultImage: string): TPicture;
begin
  Result := nil;

  if Trim(Email) = '' then
    raise EGravatar4dException.Create('The email was not provided.', Email);

  if not EmailIsValid(Trim(Email)) then
    raise EGravatar4dException.Create('The email entered has an invalid format.', Email);

  Result := DownloadImage(GenerateUrl(Email, Size, GravatarRating, GravatarDeafult, URLDefaultImage));

end;

{ TGravatar4DV3 }

constructor TGravatar4DV3.Create;
begin
  inherited Create(nil);
end;

function TGravatar4DV3.DownloadImage(const Url: string): TPicture;
var
  RESTClient: TRESTClient;
  RESTRequest: TRESTRequest;
  RESTResponse: TRESTResponse;
  MS: TMemoryStream;
  ContentType: string;
begin
  Result := nil;
  MS := nil;
  RESTClient := TRESTClient.Create(Self);
  RESTRequest := TRESTRequest.Create(Self);
  RESTResponse := TRESTResponse.Create(Self);

  RESTRequest.Client := RESTClient;
  RESTRequest.Response := RESTResponse;

  try

    RESTClient.BaseURL := Url;
    RESTRequest.Execute;

    if (RESTResponse.StatusCode < 200) or (RESTResponse.StatusCode >= 300) then
      raise EGravatar4dException.Create(Format('Failed to download Gravatar image. HTTP status: %d.', [RESTResponse.StatusCode]), '');

    ContentType := LowerCase(Trim(RESTResponse.ContentType));
    if (ContentType <> '') and (Pos('image/', ContentType) <> 1) then
      raise EGravatar4dException.Create(Format('Unexpected content type: %s.', [RESTResponse.ContentType]), '');

    MS := TMemoryStream.Create;
    if Length(RESTResponse.RawBytes) > 0 then
      MS.WriteData(RESTResponse.RawBytes, Length(RESTResponse.RawBytes));
    MS.Position := 0;

    if MS.Size > 0 then
    begin
      MS.Position := 0;
      Result := TPicture.Create;
      try
        Result.LoadFromStream(MS);
      except
        FreeAndNil(Result);
        raise;
      end;
    end
    else
      raise EGravatar4dException.Create('Empty response from Gravatar.', '');

  finally
    FreeAndNil(RESTClient);
    FreeAndNil(RESTRequest);
    FreeAndNil(RESTResponse);

    FreeAndNil(MS);
  end;
end;

function TGravatar4DV3.EmailIsValid(const AEmail: string): Boolean;
var
  RegEx: TRegEx;
begin
  try
    RegEx := TRegEx.Create('^\S+@\S+\.\S+$', [roIgnoreCase]);
    Result := RegEx.IsMatch(AEmail);
  finally

  end;
end;

function TGravatar4DV3.DownloadImageByRequest(const BaseUrl: string; const Resource: string): TPicture;
var
  RESTClient: TRESTClient;
  RESTRequest: TRESTRequest;
  RESTResponse: TRESTResponse;
  MS: TMemoryStream;
  ContentType: string;
  RequestUrl: string;
  ResourcePath: string;
begin
  Result:= nil;
  MS:= nil;
  RequestUrl:= Trim(BaseUrl);
  if RequestUrl = ''
  then
    raise EGravatar4dException.Create('Request URL was not provided.', '');

  ResourcePath:= Trim(Resource);
  if ResourcePath = ''
  then
    raise EGravatar4dException.Create('Request resource was not provided.', '');

  while (Length(ResourcePath) > 0) and (ResourcePath[1] = '/') do
    Delete(ResourcePath, 1, 1);

  if Pos('://', RequestUrl) = 0
  then
    RequestUrl:= 'https://' + RequestUrl;

  RESTClient:= TRESTClient.Create(Self);
  RESTRequest:= TRESTRequest.Create(Self);
  RESTResponse:= TRESTResponse.Create(Self);

  RESTRequest.Client:= RESTClient;
  RESTRequest.Response:= RESTResponse;

  try
    RESTClient.BaseURL:= RequestUrl;
    RESTRequest.Resource:= ResourcePath;
    RESTRequest.Execute;

    if (RESTResponse.StatusCode < 200) or (RESTResponse.StatusCode >= 300)
    then
      raise EGravatar4dException.Create(
        Format('Failed to download Gravatar image. HTTP status: %d.', [RESTResponse.StatusCode]), '');

    ContentType:= LowerCase(Trim(RESTResponse.ContentType));
    if (ContentType <> '') and (Pos('image/', ContentType) <> 1)
    then
      raise EGravatar4dException.Create(Format('Unexpected content type: %s.', [RESTResponse.ContentType]), '');

    MS:= TMemoryStream.Create;
    if Length(RESTResponse.RawBytes) > 0
    then
      MS.WriteData(RESTResponse.RawBytes, Length(RESTResponse.RawBytes));
    MS.Position:= 0;

    if MS.Size > 0
    then
    begin
      MS.Position:= 0;
      Result:= TPicture.Create;
      try
        Result.LoadFromStream(MS);
      except
        FreeAndNil(Result);
        raise;
      end;
    end
    else
      raise EGravatar4dException.Create('Empty response from Gravatar.', '');

  finally
    FreeAndNil(RESTClient);
    FreeAndNil(RESTRequest);
    FreeAndNil(RESTResponse);

    FreeAndNil(MS);
  end;
end;

function TGravatar4DV3.EmailToSHA256(const Value: string): string;
var
  Normalized: string;
begin
  Normalized := LowerCase(Trim(Value));
  Result := LowerCase(THashSHA2.GetHashString(Normalized, THashSHA2.TSHA2Version.SHA256));
end;

function TGravatar4DV3.GenerateAvatarUrl(const Email: string): string;
var
  sb: TStringBuilder;
begin
  sb := TStringBuilder.Create;
  try
    sb.Append(URL_BASE_V3_AVATAR);
    sb.Append(EmailToSHA256(Email));
    Result := sb.ToString;
  finally
    FreeAndNil(sb);
  end;
end;

function TGravatar4DV3.GetAvatarImageByEmail(const Email: string): TPicture;
begin
  if Trim(Email) = '' then
    raise EGravatar4dException.Create('The email was not provided.', Email);

  if not EmailIsValid(Trim(Email)) then
    raise EGravatar4dException.Create('The email entered has an invalid format.', Email);

  Result := GetAvatarImageByHash(EmailToSHA256(Email));
end;

function TGravatar4DV3.GetAvatarImageByHash(const Sha256Hash: string): TPicture;
var
  NormalizedHash: string;
begin
  NormalizedHash := Trim(Sha256Hash);
  if NormalizedHash = '' then
    raise EGravatar4dException.Create('SHA256 hash was not provided.', '');

  Result := DownloadImage(URL_BASE_V3_AVATAR + NormalizedHash);
end;

function TGravatar4DV3.BuildProfileResourceByIdentifier(const Identifier: string): string;
var
  Normalized: string;
begin
  Normalized := Trim(Identifier);
  if Normalized = '' then
    raise EGravatar4dException.Create('Profile identifier was not provided.', '');

  Result:= URL_API_V3_PATH + '/profiles/' + Normalized;
end;

function TGravatar4DV3.BuildQrCodeResource(const Sha256Hash: string; const Size: Smallint; const Version: Smallint; const IconType: string): string;
var
  sb: TStringBuilder;
  Prefix: string;
  NormalizedHash: string;
  IconValue: string;
begin
  NormalizedHash:= Trim(Sha256Hash);
  if NormalizedHash = ''
  then
    raise EGravatar4dException.Create('SHA256 hash was not provided.', '');

  sb:= TStringBuilder.Create;
  try
    sb.Append(URL_API_V3_PATH);
    sb.Append('/qr-code/');
    sb.Append(NormalizedHash);

    Prefix:= '?';
    if Size > 0
    then
    begin
      sb.Append(Prefix + 'size=' + Size.ToString);
      Prefix:= '&';
    end;

    if Version > 0
    then
    begin
      sb.Append(Prefix + 'version=' + Version.ToString);
      Prefix:= '&';
    end;

    IconValue:= Trim(IconType);
    if IconValue <> ''
    then
      sb.Append(Prefix + 'type=' + IconValue);

    Result:= sb.ToString;
  finally
    FreeAndNil(sb);
  end;
end;

function TGravatar4DV3.ExecuteJsonGet(const BaseUrl: string; const Resource: string; const ApiKey: string): string;
var
  RESTClient: TRESTClient;
  RESTRequest: TRESTRequest;
  RESTResponse: TRESTResponse;
  AuthToken: string;
  RequestUrl: string;
  ResourcePath: string;
begin
  Result := '';
  RequestUrl := Trim(BaseUrl);
  if RequestUrl = '' then
    raise EGravatar4dException.Create('Request URL was not provided.', '');

  ResourcePath := Trim(Resource);
  if ResourcePath = '' then
    raise EGravatar4dException.Create('Request resource was not provided.', '');

  while (Length(ResourcePath) > 0) and (ResourcePath[1] = '/') do
    Delete(ResourcePath, 1, 1);

  if Pos('://', RequestUrl) = 0 then
    RequestUrl := 'https://' + RequestUrl;

  RESTClient := TRESTClient.Create(Self);
  RESTRequest := TRESTRequest.Create(Self);
  RESTResponse := TRESTResponse.Create(Self);

  RESTRequest.Client := RESTClient;
  RESTRequest.Response := RESTResponse;

  try
    RESTClient.BaseURL := RequestUrl;
    RESTRequest.Resource := ResourcePath;
    RESTRequest.Method := rmGET;
    RESTRequest.Accept := 'application/json';

    AuthToken := Trim(ApiKey);
    if AuthToken <> '' then
      RESTRequest.AddParameter('Authorization', 'Bearer ' + AuthToken, pkHTTPHEADER, [poDoNotEncode]);

    RESTRequest.Execute;

    if (RESTResponse.StatusCode < 200) or (RESTResponse.StatusCode >= 300) then
      raise EGravatar4dException.Create(Format('Gravatar v3 request failed. HTTP status: %d. %s', [RESTResponse.StatusCode, RESTResponse.Content]), '');

    Result := RESTResponse.Content;
  finally
    FreeAndNil(RESTClient);
    FreeAndNil(RESTRequest);
    FreeAndNil(RESTResponse);
  end;
end;

function TGravatar4DV3.ParseProfileJson(const Json: string): TGravatarProfile;
var
  Root: TJSONValue;
  Obj: TJSONObject;
  Accounts: TJSONArray;
  AccountValue: TJSONValue;
  AccountObj: TJSONObject;
  Account: TGravatarVerifiedAccount;
  SectionObj: TJSONObject;
  function JsonGetString(const AObj: TJSONObject; const Name: string): string;
  var
    V: TJSONValue;
  begin
    Result:= '';
    if AObj = nil
    then EXIT('');
    V:= AObj.Values[Name];
    if Assigned(V)
    then
      Result:= V.Value;
  end;
  function JsonGetBool(const AObj: TJSONObject; const Name: string): Boolean;
  var
    V: TJSONValue;
  begin
    Result:= false;
    if AObj = nil
    then EXIT(false);
    V:= AObj.Values[Name];
    if not Assigned(V)
    then EXIT(false);
    if V is TJSONBool
    then
      Result:= TJSONBool(V).AsBoolean
    else
      Result:= SameText(V.Value, 'true');
  end;
begin
  Root:= TJSONObject.ParseJSONValue(Json);
  if Root = nil
  then
    raise EGravatar4dException.Create('Invalid JSON response from Gravatar.', '');
  try
    if not (Root is TJSONObject)
    then
      raise EGravatar4dException.Create('Unexpected JSON response from Gravatar.', '');

    Obj:= TJSONObject(Root);
    Result:= TGravatarProfile.Create;
    try
      Result.Hash:= JsonGetString(Obj, 'hash');
      Result.DisplayName:= JsonGetString(Obj, 'display_name');
      Result.ProfileUrl:= JsonGetString(Obj, 'profile_url');
      Result.AvatarUrl:= JsonGetString(Obj, 'avatar_url');
      Result.AvatarAltText:= JsonGetString(Obj, 'avatar_alt_text');
      Result.Location:= JsonGetString(Obj, 'location');
      Result.Description:= JsonGetString(Obj, 'description');
      Result.JobTitle:= JsonGetString(Obj, 'job_title');
      Result.Company:= JsonGetString(Obj, 'company');
      Result.Pronunciation:= JsonGetString(Obj, 'pronunciation');
      Result.Pronouns:= JsonGetString(Obj, 'pronouns');
      Result.HideDefaultHeaderImage:= JsonGetBool(Obj, 'hide_default_header_image');
      Result.BackgroundColor:= JsonGetString(Obj, 'background_color');

      SectionObj:= Obj.Values['section_visibility'] as TJSONObject;
      if Assigned(SectionObj)
      then
      begin
        Result.SectionVisibility.HiddenContactInfo:= JsonGetBool(SectionObj, 'hidden_contact_info');
        Result.SectionVisibility.HiddenFeeds:= JsonGetBool(SectionObj, 'hidden_feeds');
        Result.SectionVisibility.HiddenLinks:= JsonGetBool(SectionObj, 'hidden_links');
        Result.SectionVisibility.HiddenInterests:= JsonGetBool(SectionObj, 'hidden_interests');
        Result.SectionVisibility.HiddenWallet:= JsonGetBool(SectionObj, 'hidden_wallet');
        Result.SectionVisibility.HiddenPhotos:= JsonGetBool(SectionObj, 'hidden_photos');
        Result.SectionVisibility.HiddenVerifiedAccounts:= JsonGetBool(SectionObj, 'hidden_verified_accounts');
      end;

      Accounts:= Obj.Values['verified_accounts'] as TJSONArray;
      if Assigned(Accounts)
      then
        for AccountValue in Accounts do
        begin
          if AccountValue is TJSONObject
          then
          begin
            AccountObj:= TJSONObject(AccountValue);
            Account:= TGravatarVerifiedAccount.Create;
            Account.ServiceType:= JsonGetString(AccountObj, 'service_type');
            Account.ServiceLabel:= JsonGetString(AccountObj, 'service_label');
            Account.ServiceIcon:= JsonGetString(AccountObj, 'service_icon');
            Account.Url:= JsonGetString(AccountObj, 'url');
            Account.IsHidden:= JsonGetBool(AccountObj, 'is_hidden');
            Result.VerifiedAccounts.Add(Account);
          end;
        end;
    except
      FreeAndNil(Result);
      raise;
    end;
  finally
    FreeAndNil(Root);
  end;
end;

function TGravatar4DV3.GetProfileJsonByEmail(const Email: string; const ApiKey: string): string;
begin
  if Trim(Email) = ''
  then
    raise EGravatar4dException.Create('The email was not provided.', Email);

  if not EmailIsValid(Trim(Email))
  then
    raise EGravatar4dException.Create('The email entered has an invalid format.', Email);

  Result:= GetProfileJsonByIdentifier(EmailToSHA256(Email), ApiKey);
end;

function TGravatar4DV3.GetProfileJsonByIdentifier(const Identifier: string; const ApiKey: string): string;
begin
  Result:= ExecuteJsonGet(URL_API_V3_BASE, BuildProfileResourceByIdentifier(Identifier), ApiKey);
end;

function TGravatar4DV3.GetProfileByEmail(const Email: string; const ApiKey: string): TGravatarProfile;
var
  Json: string;
begin
  Json:= GetProfileJsonByEmail(Email, ApiKey);
  Result:= ParseProfileJson(Json);
end;

function TGravatar4DV3.GetProfileByIdentifier(const Identifier: string; const ApiKey: string): TGravatarProfile;
var
  Json: string;
begin
  Json:= GetProfileJsonByIdentifier(Identifier, ApiKey);
  Result:= ParseProfileJson(Json);
end;

function TGravatar4DV3.GetQrCodeImageByEmail(const Email: string; const Size: Smallint; const Version: Smallint; const IconType: string): TPicture;
begin
  if Trim(Email) = ''
  then
    raise EGravatar4dException.Create('The email was not provided.', Email);

  if not EmailIsValid(Trim(Email))
  then
    raise EGravatar4dException.Create('The email entered has an invalid format.', Email);

  Result:= GetQrCodeImageByHash(EmailToSHA256(Email), Size, Version, IconType);
end;

function TGravatar4DV3.GetQrCodeImageByHash(const Sha256Hash: string; const Size: Smallint; const Version: Smallint; const IconType: string): TPicture;
begin
  Result:= DownloadImageByRequest(URL_API_V3_BASE, BuildQrCodeResource(Sha256Hash, Size, Version, IconType));
end;

{ EGravatar4dException }

constructor EGravatar4dException.Create(const Msg: string; const AEmail: string);
begin
  inherited Create(Msg);
  FEmail := AEmail;
end;

end.
