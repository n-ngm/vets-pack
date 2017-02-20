{ ProxyPage }
{ define enum }
type TProxyForms = record
    UseProxyCheckBox:    TNewCheckBox;
    ProxyAddressLabel:   TNewStaticText;
    ProxyAddressTextBox: TNewEdit;
    ProxyPortLabel:      TNewStaticText;
    ProxyPortTextBox:    TNewEdit;
    AddLocalCheckBox:    TNewCheckBox;
    AddVmCheckBox:       TNewCheckBox;
    ProxyNotice:         TNewStaticText;
end;

{ define global variables }
var
    ProxyPage  : TInputQueryWizardPage;
    ProxyForms : TProxyForms;

{ define hook method }
procedure UseProxyCheckBoxClick (Sender: TObject); forward;

{ create proxy page }
procedure CreateProxyPage(AfterID: Integer);
var
    Page  : TInputQueryWizardPage;
    Forms : TProxyForms;
    RegProxyEnable:   Cardinal;
    RegProxyServer:   String;
    RegProxyAddress:  String;
    RegProxyPort:     String;
    RegProxyOverride: String;
    LineCount:        Integer;
    LineHeight:       Integer;
begin
    { create page }
    Page  := CreateInputQueryPage(AfterID, CustomMessage('ProxyPageTitle'), CustomMessage('ProxyPageDesc'), '');

    { get current proxy registry }
    RegQueryDWordValue (HKEY_CURRENT_USER, '{#HKCU_NetKey}', 'ProxyEnable', RegProxyEnable);
    RegQueryStringValue(HKEY_CURRENT_USER, '{#HKCU_NetKey}', 'ProxyServer', RegProxyServer);
    if (Length(RegProxyServer) > 0) then
    begin
        RegProxyAddress := Copy(RegProxyServer, 1, Pos(':', RegProxyServer) -1);
        RegProxyPort    := Copy(RegProxyServer, Pos(':', RegProxyServer) + 1, Length(RegProxyServer) - Pos(':', RegProxyServer));
    end;

    { create forms }
    LineCount := 0;
    LineHeight := 24;

    Forms.UseProxyCheckBox := TNewCheckBox.Create(Page);
    with Forms.UseProxyCheckBox do
    begin
        Parent   := Page.Surface;
        Checked  := False;
        Top      := ScaleY(16) + LineCount * LineHeight;
        Width    := Page.SurfaceWidth;
        Caption  := CustomMessage('ProxyPageUseProxy');
    end;

    LineCount := LineCount + 1;

    Forms.ProxyAddressLabel := TNewStaticText.Create(Page);
    with Forms.ProxyAddressLabel do
    begin
        Parent   := Page.Surface;
        Top      := ScaleY(16) + LineCount * LineHeight;
        Left     := ScaleX(16);
        AutoSize := True;
        Caption  := CustomMessage('ProxyPageAddress');
    end;

    Forms.ProxyAddressTextBox := TNewEdit.Create(Page);
    with Forms.ProxyAddressTextBox do
    begin
        Parent   := Page.Surface;
        Top      := ScaleY(16) + LineCount * LineHeight;
        Left     := ScaleX(16) + Forms.ProxyAddressLabel.Width + ScaleX(8);
        Width    := Page.SurfaceWidth div 2 - ScaleX(8);
        Text     := RegProxyAddress
    end;

    LineCount := LineCount + 1;

    Forms.ProxyPortLabel := TNewStaticText.Create(Page);
    with Forms.ProxyPortLabel do
    begin
        Parent   := Page.Surface;
        Top      := ScaleY(16) + LineCount * LineHeight;
        Left     := ScaleX(16);
        AutoSize := True;
        Caption  := CustomMessage('ProxyPagePort');
    end;

    Forms.ProxyPortTextBox := TNewEdit.Create(Page);
    with Forms.ProxyPortTextBox do
    begin
        Parent   := Page.Surface;
        Top      := ScaleY(16) + LineCount * LineHeight - ScaleY(2);
        Left     := Forms.ProxyAddressTextBox.Left;
        Width    := Page.SurfaceWidth div 2 - ScaleX(8);
        Text     := RegProxyPort
    end;

    LineCount := LineCount + 1;

    Forms.AddLocalCheckBox := TNewCheckBox.Create(Page);
    with Forms.AddLocalCheckBox do
    begin
        Parent   := Page.Surface;
        Checked  := True;
        Top      := ScaleY(16) + LineCount * LineHeight;
        Left     := ScaleX(16);
        Width    := Page.SurfaceWidth;
        Caption  := CustomMessage('ProxyPageAddLocalToNoProxy');
    end;

    LineCount := LineCount + 1;

    Forms.AddVmCheckBox := TNewCheckBox.Create(Page);
    with Forms.AddVmCheckBox do
    begin
        Parent   := Page.Surface;
        Checked  := True;
        Top      := ScaleY(16) + LineCount * LineHeight;
        Left     := ScaleX(16);
        Width    := Page.SurfaceWidth;
        Caption  := CustomMessage('ProxyPageAddVmToNoProxy');
    end;

    LineCount := LineCount + 1;

    Forms.ProxyNotice := TNewStaticText.Create(Page);
    with Forms.ProxyNotice do
    begin
        Parent   := Page.Surface;
        Top      := ScaleY(16) + LineCount * LineHeight;
        Left     := ScaleX(0);
        AutoSize := True;
        Caption  := CustomMessage('ProxyPageNotice');
    end;

    { check by current setting }
    if (RegProxyEnable = 1) then
    begin
        Forms.UseProxyCheckBox.Checked  := True;
    end else begin
        Forms.UseProxyCheckBox.Checked  := False;
    end;

    { return to global }
    ProxyPage  := Page;
    ProxyForms := Forms;

    { set onclick hook }
    ProxyForms.UseProxyCheckBox.OnClick := @UseProxyCheckBoxClick;
    UseProxyCheckBoxClick(Page);
end;

{ enable/disable forms if proxy is enabled or not }
procedure UseProxyCheckBoxClick (Sender: TObject);
begin
    if ProxyForms.UseProxyCheckBox.Checked then
    begin
        with ProxyForms do
        begin
            ProxyAddressLabel.Enabled   := True;
            ProxyAddressTextBox.Enabled := True;
            ProxyPortLabel.Enabled      := True;
            ProxyPortTextBox.Enabled    := True;
            AddLocalCheckBox.Enabled    := True;
            AddVmCheckBox.Enabled       := True;
            ProxyNotice.Enabled         := True;
        end;
    end else begin
        with ProxyForms do
        begin
            ProxyAddressLabel.Enabled   := False;
            ProxyAddressTextBox.Enabled := False;
            ProxyPortLabel.Enabled      := False;
            ProxyPortTextBox.Enabled    := False;
            AddLocalCheckBox.Enabled    := False;
            AddVmCheckBox.Enabled       := False;
            ProxyNotice.Enabled         := False;
        end;
    end;
end;

