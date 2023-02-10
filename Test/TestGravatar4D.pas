unit TestGravatar4D;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit
  being tested.

}

interface

uses
  TestFramework, IdUri, Gravatar4D, System.SysUtils, Winapi.Windows, System.TypInfo,
  System.Classes, IdHashMessageDigest;

type
  // Test methods for class TGravatar4D

  TestTGravatar4D = class(TTestCase)
  strict private
    FGravatar4D: TGravatar4D;
  public
    procedure SetUp; override;
    procedure TearDown; override;
    procedure _InternalTestEmailNotInformed;
    procedure _InternalTestEmailInvalid;
  published
    procedure TestEmailToMD5;
    procedure TestEmailNotInformed;
    procedure TestEmailInvalid;
    procedure TestGenerateUrl;
    procedure TestGenerateUrl_DefaultImage;
    procedure TestGenerateUrl_FullParams;

  end;

implementation

procedure TestTGravatar4D.SetUp;
begin
  FGravatar4D := TGravatar4D.Create;
end;

procedure TestTGravatar4D.TearDown;
begin
  FGravatar4D.Free;
  FGravatar4D := nil;
end;

procedure TestTGravatar4D.TestEmailInvalid;
begin
  CheckException(Self._InternalTestEmailInvalid, EGravatar4dException, 'The email entered has an invalid format.');
end;

procedure TestTGravatar4D.TestEmailNotInformed;
begin
  CheckException(Self._InternalTestEmailNotInformed, EGravatar4dException, 'The email was not provided.');
end;

procedure TestTGravatar4D.TestEmailToMD5;
var
  ReturnValue: string;
  Value: string;
begin
  Value := 'user@github.com';
  ReturnValue := FGravatar4D.EmailToMD5(Value);
  // Note
  // this test hash was generated on the website: https://www.md5hashgenerator.com
  CheckEquals('1496f7f4fd086e2d0a0460220331e9ec', ReturnValue, 'Email to MD5');
end;

procedure TestTGravatar4D.TestGenerateUrl;
var
  ReturnValue: string;
  Email: string;
begin
  Email := 'user@github.com';
  ReturnValue := FGravatar4D.GenerateUrl(Email);
  CheckEquals('https://www.gravatar.com/avatar/1496f7f4fd086e2d0a0460220331e9ec?r=g', ReturnValue,
    'Generate Url from basic parameters');
end;

procedure TestTGravatar4D.TestGenerateUrl_DefaultImage;
var
  ReturnValue: string;
  Email: string;
  URLDefaultImage: string;
  GravatarDeafult: TGravatarDeafult;
  Size: Smallint;
begin
  Email := 'user@github.com';
  Size := 400;
  GravatarDeafult := gdUrlImage;
  URLDefaultImage := 'https://learndelphi.org/wp-content/uploads/2020/06/delphi2.png';

  ReturnValue := FGravatar4D.GenerateUrl(Email, Size, grG, GravatarDeafult, URLDefaultImage);
  CheckEquals
    ('https://www.gravatar.com/avatar/1496f7f4fd086e2d0a0460220331e9ec?r=g&s=400&d=https://learndelphi.org/wp-content/uploads/2020/06/delphi2.png',
    ReturnValue, 'Generate Url from default image parameter');

end;

procedure TestTGravatar4D.TestGenerateUrl_FullParams;
var
  ReturnValue: string;
  GravatarDeafult: TGravatarDeafult;
  GravatarRating: TGravatarRating;
  Size: Smallint;
  Email: string;
begin
  Email := 'user@github.com';
  Size := 200;
  GravatarRating := grPG;
  GravatarDeafult := gdwavatar;

  ReturnValue := FGravatar4D.GenerateUrl(Email, Size, GravatarRating, GravatarDeafult);

  CheckEquals('https://www.gravatar.com/avatar/1496f7f4fd086e2d0a0460220331e9ec?r=pg&s=200&d=wavatar', ReturnValue,
    'Generate Url from full parameters')

end;

procedure TestTGravatar4D._InternalTestEmailInvalid;
begin
  FGravatar4D.GravatarImage('email@gmail.');
end;

procedure TestTGravatar4D._InternalTestEmailNotInformed;
begin
  FGravatar4D.GravatarImage('')
end;

initialization

// Register any test cases with the test runner
RegisterTest(TestTGravatar4D.Suite);

end.
