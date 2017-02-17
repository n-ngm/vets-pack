[Code]
{ ProxyPage }
function CreateProxyPage(AfterID: Integer): TWizardPage;
var
    { variables }
    Page: TWizardPage;
    RegProxyEnable:   Cardinal;
    RegProxyServer:   String;
    RegProxyAddress:  String;
    RegProxyPort:     String;
    RegProxyOverride: String;

    { forms }
    UseProxyCheckBox:    TNewCheckBox;
    ProxyAddressLabel:   TNewStaticText;
    ProxyAddressTextBox: TNewEdit;
    ProxyPortLabel:      TNewStaticText;
    ProxyPortTextBox:    TNewEdit;
    AddLocalCheckBox:    TNewCheckBox;
    AddVmCheckBox:       TNewCheckBox;
    ProxyNotice:         TNewStaticText;
    LineCount:  Integer;
    LineHeight: Integer;
begin
    Page := CreateCustomPage(AfterID, CustomMessage('ProxyPageTitle'), CustomMessage('ProxyPageDesc'));

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

    UseProxyCheckBox := TNewCheckBox.Create(Page);
    with UseProxyCheckBox do
    begin
        Parent   := Page.Surface;
        if (RegProxyEnable = 1) then
        begin
        Checked  := True;
        end else
        begin
        Checked  := False;
        end;
        Top      := ScaleY(16) + LineCount * LineHeight;
        Width    := Page.SurfaceWidth;
        Caption  := CustomMessage('ProxyPageUseProxy');
    end;

    LineCount := LineCount + 1;

    ProxyAddressLabel := TNewStaticText.Create(Page);
    with ProxyAddressLabel do
    begin
        Parent   := Page.Surface;
        Top      := ScaleY(16) + LineCount * LineHeight;
        Left     := ScaleX(16);
        AutoSize := True;
        Caption  := CustomMessage('ProxyPageAddress');
    end;

    ProxyAddressTextBox := TNewEdit.Create(Page);
    with ProxyAddressTextBox do
    begin
        Parent   := Page.Surface;
        Top      := ScaleY(16) + LineCount * LineHeight;
        Left     := ScaleX(16) + ProxyAddressLabel.Width + ScaleX(8);
        Width    := Page.SurfaceWidth div 2 - ScaleX(8);
        Text     := RegProxyAddress
    end;

    LineCount := LineCount + 1;

    ProxyPortLabel := TNewStaticText.Create(Page);
    with ProxyPortLabel do
    begin
        Parent   := Page.Surface;
        Top      := ScaleY(16) + LineCount * LineHeight;
        Left     := ScaleX(16);
        AutoSize := True;
        Caption  := CustomMessage('ProxyPagePort');
    end;

    ProxyPortTextBox := TNewEdit.Create(Page);
    with ProxyPortTextBox do
    begin
        Parent   := Page.Surface;
        Top      := ScaleY(16) + LineCount * LineHeight - ScaleY(2);
        Left     := ProxyAddressTextBox.Left;
        Width    := Page.SurfaceWidth div 2 - ScaleX(8);
        Text     := RegProxyPort
    end;

    LineCount := LineCount + 1;

    AddLocalCheckBox := TNewCheckBox.Create(Page);
    with AddLocalCheckBox do
    begin
        Parent   := Page.Surface;
        Checked  := True;
        Top      := ScaleY(16) + LineCount * LineHeight;
        Left     := ScaleX(16);
        Width    := Page.SurfaceWidth;
        Caption  := CustomMessage('ProxyPageAddLocalToNoProxy');
    end;

    LineCount := LineCount + 1;

    AddVmCheckBox := TNewCheckBox.Create(Page);
    with AddVmCheckBox do
    begin
        Parent   := Page.Surface;
        Checked  := True;
        Top      := ScaleY(16) + LineCount * LineHeight;
        Left     := ScaleX(16);
        Width    := Page.SurfaceWidth;
        Caption  := CustomMessage('ProxyPageAddVmToNoProxy');
    end;

    LineCount := LineCount + 1;

    ProxyNotice := TNewStaticText.Create(Page);
    with ProxyNotice do
    begin
        Parent   := Page.Surface;
        Top      := ScaleY(16) + LineCount * LineHeight;
        Left     := ScaleX(0);
        AutoSize := True;
        Caption  := CustomMessage('ProxyPageNotice');
    end;

    Result := Page;
end;
