## Gravatar4Delphi

Grava4Delphi is a library for implementing gravatar for delphi.



[**Gravatar web site**](https://gravatar.com)



## ⚙️ Installation

Installation is done using the [`boss install`](https://github.com/HashLoad/boss) command:

```sh
boss install github.com/gamboajorge49/Gravatar4Delphi.git
```

## ⚡️ Quickstart Delphi

```delphi
uses Gravatar4d;

var
  Gravatar: TGravatar4D;
  image: TPicture;

begin
  Gravatar := TGravatar4D.Create;
  try
    image := Gravatar.GravatarImage('user@email.com');

  finally    
    FreeAndNil(Gravatar);
  end;

end.
```

## ⚡️ Quickstart Delphi (v3)

```delphi
uses
  System.SysUtils,
  Gravatar4d;

var
  GravatarV3: TGravatar4DV3;
  AvatarUrl: string;

begin
  GravatarV3:= TGravatar4DV3.Create;
  try
    AvatarUrl:= GravatarV3.GenerateAvatarUrl('user@email.com');
  finally
    FreeAndNil(GravatarV3);
  end;

end.
```

### Profile JSON / model (v3)

```delphi
uses
  System.SysUtils,
  Gravatar4d;

var
  GravatarV3: TGravatar4DV3;
  Profile: TGravatarProfile;

begin
  GravatarV3:= TGravatar4DV3.Create;
  Profile:= nil;
  try
    Profile:= GravatarV3.GetProfileByEmail('user@email.com');
    // Example: Profile.DisplayName / Profile.AvatarUrl
  finally
    FreeAndNil(Profile);
    FreeAndNil(GravatarV3);
  end;

end.
```

### QR Code image (v3)

```delphi
uses
  System.SysUtils,
  Gravatar4d;

var
  GravatarV3: TGravatar4DV3;
  QrCode: TPicture;

begin
  GravatarV3:= TGravatar4DV3.Create;
  QrCode:= nil;
  try
    QrCode:= GravatarV3.GetQrCodeImageByEmail('user@email.com', 256, 13, 'qr');
  finally
    FreeAndNil(QrCode);
    FreeAndNil(GravatarV3);
  end;

end.
```

## Delphi Versions

`Gravatar4Delphi` works with Delphi 11 Alexandria, Delphi 10.4 Sydney, Delphi 10.3 Rio, Delphi 10.2 Tokyo, Delphi 10.1 Berlin, Delphi 10 Seattle, Delphi XE8 and Delphi XE7.

## ⚠️ License

`Gravatar4Delphi` is free and open-source software licensed under the [MIT License](https://github.com/gamboajorge49/Gravatar4Delphi/blob/main/LICENCE).

## 📐 Tests

![tests](https://github.com/GlerystonMatos/horse/workflows/tests/badge.svg)
