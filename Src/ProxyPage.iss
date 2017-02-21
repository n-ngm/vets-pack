
[Code]
(* --- Proxy Page, Setting --- *)
(**
 * define enumeration
 *   inno setup can not use "class".
 *)
type TProxyForms = record
    UseProxyCheckBox:     TNewCheckBox;
    ProxyProtocolLabel1:  TNewStaticText;
    ProxyProtocolTextBox: TNewEdit;
    ProxyProtocolLabel2:  TNewStaticText;
    ProxyAddressLabel:    TNewStaticText;
    ProxyAddressTextBox:  TNewEdit;
    ProxyPortLabel:       TNewStaticText;
    ProxyPortTextBox:     TNewEdit;
    AddLocalCheckBox:     TNewCheckBox;
    AddVmCheckBox:        TNewCheckBox;
    ProxyNotice:          TNewStaticText;
end;

(**
 * define global variables
 *   to provide form value to other method,
 *)
var
    ProxyPage  : TInputQueryWizardPage;
    ProxyForms : TProxyForms;

(**
 * define hook method
 *)
procedure UseProxyCheckBoxClick (Sender: TObject); forward;

(**
 * CreateProxyPage
 *   create proxy page
 *)
procedure CreateProxyPage(AfterID: Integer);
var
    Page  : TInputQueryWizardPage;
    Forms : TProxyForms;
    RegProxyEnable:   Cardinal;
    RegProxyProtocol: String;
    RegProxyServer:   String;
    RegProxyAddress:  String;
    RegProxyPort:     String;
    RegProxyOverride: String;
    LineCount:        Integer;
    LineHeight:       Integer;
begin
    // create page
    Page  := CreateInputQueryPage(AfterID, CustomMessage('ProxyPageTitle'), CustomMessage('ProxyPageDesc'), '');

    // get current proxy registry
    RegQueryDWordValue (HKEY_CURRENT_USER, '{#HKCU_NetKey}', 'ProxyEnable', RegProxyEnable);
    RegQueryStringValue(HKEY_CURRENT_USER, '{#HKCU_NetKey}', 'ProxyServer', RegProxyServer);
    if (Length(RegProxyServer) > 0) then
    begin
        RegProxyAddress := Copy(RegProxyServer, 1, Pos(':', RegProxyServer) -1);
        RegProxyPort    := Copy(RegProxyServer, Pos(':', RegProxyServer) + 1, Length(RegProxyServer) - Pos(':', RegProxyServer));

        case RegProxyPort of
            '80': begin
                RegProxyProtocol := 'http';
            end;
            '443': begin
                RegProxyProtocol := 'https';
            end;
            '20', '21': begin
                RegProxyProtocol := 'ftp';
            end;
        else
            RegProxyProtocol := 'socks';
        end;
    end;

    // create forms
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

    Forms.ProxyProtocolLabel1 := TNewStaticText.Create(Page);
    with Forms.ProxyProtocolLabel1 do
    begin
        Parent   := Page.Surface;
        Top      := ScaleY(16) + LineCount * LineHeight;
        Left     := ScaleX(16);
        AutoSize := True;
        Caption  := CustomMessage('ProxyPageProtocol');
    end;

    Forms.ProxyProtocolTextBox := TNewEdit.Create(Page);
    with Forms.ProxyProtocolTextBox do
    begin
        Parent   := Page.Surface;
        Top      := ScaleY(16) + LineCount * LineHeight;
        Left     := ScaleX(16) + Forms.ProxyProtocolLabel1.Width + ScaleX(8);
        Width    := ScaleX(64);
        Text     := RegProxyProtocol;
    end;

    Forms.ProxyProtocolLabel2 := TNewStaticText.Create(Page);
    with Forms.ProxyProtocolLabel2 do
    begin
        Parent   := Page.Surface;
        Top      := ScaleY(16) + LineCount * LineHeight;
        Left     := ScaleX(16) + Forms.ProxyProtocolLabel1.Width + ScaleX(8)
                               + Forms.ProxyProtocolTextBox.Width + ScaleX(8);
        AutoSize := True;
        Caption  := '://';
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
        Left     := Forms.ProxyProtocolTextBox.Left;
        Width    := Page.SurfaceWidth div 2 - ScaleX(8);
        Text     := RegProxyAddress;
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
        Left     := Forms.ProxyProtocolTextBox.Left;
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

    // check by current setting
    if (RegProxyEnable = 1) then
    begin
        Forms.UseProxyCheckBox.Checked  := True;
    end else begin
        Forms.UseProxyCheckBox.Checked  := False;
    end;

    // return to global
    ProxyPage  := Page;
    ProxyForms := Forms;

    // set onclick hook
    ProxyForms.UseProxyCheckBox.OnClick := @UseProxyCheckBoxClick;
    UseProxyCheckBoxClick(Page);
end;

(**
 * UseProxyCheckBoxClick
 *   enable/disable forms if proxy is enabled or not.
 *)
procedure UseProxyCheckBoxClick (Sender: TObject);
begin
    if ProxyForms.UseProxyCheckBox.Checked then
    begin
        with ProxyForms do
        begin
            ProxyProtocolLabel1.Enabled  := True;
            ProxyProtocolTextBox.Enabled := True;
            ProxyProtocolLabel2.Enabled  := True;
            ProxyAddressLabel.Enabled    := True;
            ProxyAddressTextBox.Enabled  := True;
            ProxyPortLabel.Enabled       := True;
            ProxyPortTextBox.Enabled     := True;
            AddLocalCheckBox.Enabled     := True;
            AddVmCheckBox.Enabled        := True;
            ProxyNotice.Enabled          := True;
        end;
    end else begin
        with ProxyForms do
        begin
            ProxyProtocolLabel1.Enabled  := False;
            ProxyProtocolTextBox.Enabled := False;
            ProxyProtocolLabel2.Enabled  := False;
            ProxyAddressLabel.Enabled    := False;
            ProxyAddressTextBox.Enabled  := False;
            ProxyPortLabel.Enabled       := False;
            ProxyPortTextBox.Enabled     := False;
            AddLocalCheckBox.Enabled     := False;
            AddVmCheckBox.Enabled        := False;
            ProxyNotice.Enabled          := False;
        end;
    end;
end;

(**
 * SetProxyToRegistry
 *   set internet proxy setting
 *)
procedure SetProxyToRegistry;
var
    RegProxyServer:   String;
begin
    if ProxyForms.UseProxyCheckBox.Checked then
    begin
        // TODO set each protcol
        if Length(ProxyForms.ProxyAddressTextBox.Text) > 0 then
        begin
            RegProxyServer := ProxyForms.ProxyAddressTextBox.Text;
            if Length(ProxyForms.ProxyPortTextBox.Text) > 0 then
            begin
                RegProxyServer := RegProxyServer + ':' + ProxyForms.ProxyPortTextBox.Text;
            end;

            RegWriteInternetSetting ('ProxyServer', RegProxyServer);
            RegWriteEnvironment     ('http_proxy',  ProxyForms.ProxyProtocolTextBox.Text + '://' + RegProxyServer);
            RegWriteEnvironment     ('https_proxy', ProxyForms.ProxyProtocolTextBox.Text + '://' + RegProxyServer);
        end else begin
            RegDeleteInternetSetting('ProxyServer');
            RegDeleteEnvironment    ('http_proxy');
            RegDeleteEnvironment    ('https_proxy');
        end;

        if ProxyForms.AddLocalCheckBox.Checked then
        begin
            RegAddInternetSetting   ('ProxyOverride', 'localhost', ';');
            RegAddInternetSetting   ('ProxyOverride', '<local>',   ';');
            RegAddEnvironment       ('no_proxy',      'localhost', ',');
        end else begin
            RegRemoveInternetSetting('ProxyOverride', 'localhost', ';');
            RegRemoveInternetSetting('ProxyOverride', '<local>',   ';');
            RegRemoveEnvironment    ('no_proxy',      'localhost', ',');
        end;

        if ProxyForms.AddVmCheckBox.Checked then
        begin
            RegAddInternetSetting   ('ProxyOverride', '*.local',  ';');
            RegAddInternetSetting   ('ProxyOverride', '*.vmhost', ';');
            RegAddEnvironment       ('no_proxy',      '*.local',  ',');
            RegAddEnvironment       ('no_proxy',      '*.vmhost', ',');
        end else begin
            RegRemoveInternetSetting('ProxyOverride', '*.local',  ';');
            RegRemoveInternetSetting('ProxyOverride', '*.vmhost', ';');
            RegRemoveEnvironment    ('no_proxy',      '*.local',  ',');
            RegRemoveEnvironment    ('no_proxy',      '*.vmhost', ',');
        end;

        RegWriteDwordValue (HKEY_CURRENT_USER, '{#HKCU_NetKey}', 'ProxyEnable', 1);
    end else begin
        RegWriteDwordValue (HKEY_CURRENT_USER, '{#HKCU_NetKey}', 'ProxyEnable', 0);
    end;
end;
