unit ufrmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Mask, Vcl.Samples.Spin, Gravatar4D,
  System.Types, System.TypInfo;

type
  TForm1 = class(TForm)
    pnlMain: TPanel;
    GroupBox1: TGroupBox;
    Image1: TImage;
    lbEmail: TLabeledEdit;
    btnGererate: TButton;
    chkCenter: TCheckBox;
    chkStretch: TCheckBox;
    SpinEdit1: TSpinEdit;
    Label1: TLabel;
    cbDefault: TComboBox;
    cbRating: TComboBox;
    Label2: TLabel;
    Label3: TLabel;
    leDefault: TLabeledEdit;
    leApiKey: TLabeledEdit;
    chkUseV3: TCheckBox;
    btnProfileV3: TButton;
    btnQrCodeV3: TButton;
    procedure chkCenterClick(Sender: TObject);
    procedure chkStretchClick(Sender: TObject);
    procedure btnGererateClick(Sender: TObject);
    procedure btnProfileV3Click(Sender: TObject);
    procedure btnQrCodeV3Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cbDefaultChange(Sender: TObject);
  private
    procedure ShowProfileJson(const Json: string);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.btnGererateClick(Sender: TObject);
var
  G: TGravatar4D;
  Gv3: TGravatar4DV3;
  image: TPicture;
begin
  G := nil;
  Gv3 := nil;
  image := nil;
  try
    try
      if chkUseV3.Checked then
      begin
        Gv3 := TGravatar4DV3.Create;
        image := Gv3.GetAvatarImageByEmail(lbEmail.Text);
      end
      else
      begin
        G := TGravatar4D.Create;
        image := G.GravatarImage(lbEmail.Text, SpinEdit1.Value, TGravatarRating(cbRating.ItemIndex), TGravatarDeafult(cbDefault.ItemIndex), leDefault.Text);
      end;

      if Assigned(image) then
        Image1.Picture.Assign(image);
    except
      on E: EGravatar4dException do
      begin
        ShowMessage('Unable to locate the Gravatar for the email.' + sLineBreak + 'Original message: ' + E.Message);
      end;
      on E: Exception do
      begin
        ShowMessage(E.Message);
      end;
    end;

  finally
    FreeAndNil(image);
    FreeAndNil(G);
    FreeAndNil(Gv3);
  end;
end;

procedure TForm1.btnProfileV3Click(Sender: TObject);
var
  Gv3: TGravatar4DV3;
  Json: string;
begin
  Gv3 := TGravatar4DV3.Create;
  try
    try
      Json := Gv3.GetProfileJsonByEmail(lbEmail.Text, leApiKey.Text);
      ShowProfileJson(Json);
    except
      on E: EGravatar4dException do
      begin
        ShowMessage('Unable to locate the Gravatar profile.' + sLineBreak + 'Original message: ' + E.Message);
      end;
      on E: Exception do
      begin
        ShowMessage(E.Message);
      end;
    end;
  finally
    FreeAndNil(Gv3);
  end;
end;

procedure TForm1.btnQrCodeV3Click(Sender: TObject);
var
  Gv3: TGravatar4DV3;
  image: TPicture;
begin
  Gv3 := TGravatar4DV3.Create;
  image := nil;
  try
    try
      image := Gv3.GetQrCodeImageByEmail(lbEmail.Text, SpinEdit1.Value, 3, 'user');
      if Assigned(image) then
        Image1.Picture.Assign(image);
    except
      on E: EGravatar4dException do
      begin
        ShowMessage('Unable to generate the Gravatar QR code.' + sLineBreak + 'Original message: ' + E.Message);
      end;
      on E: Exception do
      begin
        ShowMessage(E.Message);
      end;
    end;
  finally
    FreeAndNil(image);
    FreeAndNil(Gv3);
  end;
end;

procedure TForm1.cbDefaultChange(Sender: TObject);
begin
  leDefault.Enabled := (TGravatarDeafult(cbDefault.ItemIndex) = gdUrlImage);
end;

procedure TForm1.chkCenterClick(Sender: TObject);
begin
  Image1.Center := chkCenter.Checked;
  Image1.Repaint;
end;

procedure TForm1.chkStretchClick(Sender: TObject);
begin
  Image1.Stretch := chkStretch.Checked;
  Image1.Repaint;
end;

procedure TForm1.FormShow(Sender: TObject);
var
  d: TGravatarDeafult;
  r: TGravatarRating;
begin
  for d := Low(TGravatarDeafult) to High(TGravatarDeafult) do
    cbDefault.Items.Add(GetEnumName(TypeInfo(TGravatarDeafult), Integer(d)));
  cbDefault.ItemIndex := 0;

  for r := Low(TGravatarRating) to High(TGravatarRating) do
    cbRating.Items.Add(GetEnumName(TypeInfo(TGravatarRating), Integer(r)));
  cbRating.ItemIndex := 0;

  chkStretch.Checked := True;

  chkCenter.Checked := True;

end;

procedure TForm1.ShowProfileJson(const Json: string);
var
  ProfileForm: TForm;
  Memo: TMemo;
begin
  ProfileForm := TForm.Create(Self);
  Memo := TMemo.Create(ProfileForm);
  try
    ProfileForm.Caption := 'Gravatar v3 Profile JSON';
    ProfileForm.Position := poOwnerFormCenter;
    ProfileForm.Width := 520;
    ProfileForm.Height := 400;

    Memo.Parent := ProfileForm;
    Memo.Align := alClient;
    Memo.ScrollBars := ssVertical;
    Memo.WordWrap := false;
    Memo.Lines.Text := Json;

    ProfileForm.ShowModal;
  finally
    FreeAndNil(ProfileForm);
  end;
end;

end.
