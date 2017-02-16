; Installer of Virtual Environment Softwares 
;
; Install 
;   - VirtualBox
;   - Vagrant
;   - ChefDK
;   - Cygwin
; Set
;   - Registery Proxy
;   - Path
;

; Registry Position
#define HKLM_EnvKey "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
#define HKCU_NetKey "Software\Microsoft\Windows\CurrentVersion\Internet Settings"

; Define MyApp Info
#define MyPublisher  "ClickMaker"
#define MyAppName    "Virtual Environment Installer Pack"
#define MyAppVersion "2.0.4"
#define MyOutputFile  StringChange(MyAppName, " ", "_") + "." + StringChange(MyAppVersion, ".", "_")

; Include Inno-Setup Download Plugin
#include <idp.iss>

[Setup]
AppName={#MyAppName}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyPublisher}
VersionInfoVersion={#MyAppVersion}
OutputBaseFilename={#MyOutputFile}

; Enable Logging
SetupLogging=yes

; Require Admin Execution 
PrivilegesRequired=admin

; ------------- Inno-Setup Default Pages Setup 
; Select Language Dialog 
ShowLanguageDialog=no

; Show Welcome Page
DisableWelcomePage=yes
; * no use.

; Show License Page
;LicenseFile=""
; * refer to each softwares.

; Show Password Page
;Password=
; * no use.

; Show Infomation Page
;InfoBeforeFile=""
; * set in [Languages] section.

; Show UserInfo Page
UserInfoPage=no
; * no use.

; Show Install Dir Page
DisableDirPage=yes
DefaultDirName={pf}\{#MyAppName}

;
DisableReadyPage=no

AppendDefaultDirName=no


[Languages]
Name: japanese; \
  MessagesFile: "compiler:\Languages\Japanese.isl,{__FILE__}\..\Messages\Japanese.isl"; \
  InfoBeforeFile: "Files\README_JP.txt"
                  
Name: english; \
  MessagesFile: "compiler:Default.isl,{__FILE__}\..\Messages\English.isl"; \
  InfoBeforeFile: "Files\README.txt"

[Files]
Source: "Files\*"; DestDir: "{app}"; Flags: isreadme ignoreversion touch

[Code]
var
  ProxyPage: TWizardPage;

function StrContain(SearchText: String; TargetText: String; Delimiter: String): Integer;
begin
  Result := Pos(Delimiter + SearchText + Delimiter, Delimiter + TargetText + Delimiter) ;
end;

// ProxyPage;
procedure CreateProxyPage;
var
  // Variables
  Page: TWizardPage;
  RegProxyEnable:   Cardinal;
  RegProxyServer:   String;
  RegProxyAddress:  String;
  RegProxyPort:     String;
  RegProxyOverride: String;

  // Forms  
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
  ProxyPage := CreateCustomPage(wpInfoBefore, CustomMessage('ProxyPageTitle'), CustomMessage('ProxyPageDesc'));
  Page := ProxyPage;

  // get current proxy registry
  RegQueryDWordValue (HKEY_CURRENT_USER, '{#HKCU_NetKey}', 'ProxyEnable',   RegProxyEnable);
  RegQueryStringValue(HKEY_CURRENT_USER, '{#HKCU_NetKey}', 'ProxyServer',   RegProxyServer);
  if (Length(RegProxyServer) > 0) then
  begin
     RegProxyAddress := Copy(RegProxyServer, 1, Pos(':', RegProxyServer) -1);
     RegProxyPort    := Copy(RegProxyServer, Pos(':', RegProxyServer) + 1, Length(RegProxyServer) - Pos(':', RegProxyServer));
  end;
 
  // create forms
  LineCount := 0;
  LineHeight := 24;

  UseProxyCheckBox := TNewCheckBox.Create(Page);
  UseProxyCheckBox.Parent := Page.Surface;
  if (RegProxyEnable = 1) then
  begin
    UseProxyCheckBox.Checked := True;
  end else
  begin
    UseProxyCheckBox.Checked := False;
  end;
  UseProxyCheckBox.Top := ScaleY(16);
  UseProxyCheckBox.Width := Page.SurfaceWidth;
  UseProxyCheckBox.Caption := CustomMessage('ProxyPageUseProxy');

  LineCount := LineCount + 1;

  ProxyAddressLabel := TNewStaticText.Create(Page);
  ProxyAddressLabel.Parent := Page.Surface;
  ProxyAddressLabel.Top := ScaleY(16) + LineCount * LineHeight;
  ProxyAddressLabel.Left := ScaleX(16);
  ProxyAddressLabel.AutoSize := True;
  ProxyAddressLabel.Caption := CustomMessage('ProxyPageAddress');

  ProxyAddressTextBox := TNewEdit.Create(Page);
  ProxyAddressTextBox.Parent := Page.Surface;
  ProxyAddressTextBox.Top :=  ScaleY(16) + LineCount * LineHeight;
  ProxyAddressTextBox.Left := ScaleX(16) + ProxyAddressLabel.Width + ScaleX(8);
  ProxyAddressTextBox.Width := Page.SurfaceWidth div 2 - ScaleX(8);
  ProxyAddressTextBox.Text := RegProxyAddress

  LineCount := LineCount + 1;

  ProxyPortLabel := TNewStaticText.Create(Page);
  ProxyPortLabel.Parent := Page.Surface;
  ProxyPortLabel.Top := ScaleY(16) + LineCount * LineHeight;
  ProxyPortLabel.Left := ScaleX(16);
  ProxyPortLabel.AutoSize := True;
  ProxyPortLabel.Caption := CustomMessage('ProxyPagePort');

  ProxyPortTextBox := TNewEdit.Create(Page);
  ProxyPortTextBox.Parent := Page.Surface;
  ProxyPortTextBox.Top :=  ScaleY(16) + LineCount * LineHeight - ScaleY(2);
  ProxyPortTextBox.Left := ProxyAddressTextBox.Left;
  ProxyPortTextBox.Width := Page.SurfaceWidth div 2 - ScaleX(8);
  ProxyPortTextBox.Text := RegProxyPort

  LineCount := LineCount + 1;

  AddLocalCheckBox := TNewCheckBox.Create(Page);
  AddLocalCheckBox.Parent := Page.Surface;
  AddLocalCheckBox.Checked := True;
  AddLocalCheckBox.Top := ScaleY(16) + LineCount * LineHeight;
  AddLocalCheckBox.Left := ScaleX(16);
  AddLocalCheckBox.Width := Page.SurfaceWidth;
  AddLocalCheckBox.Caption := CustomMessage('ProxyPageAddLocalToNoProxy');

  LineCount := LineCount + 1;

  AddVmCheckBox := TNewCheckBox.Create(Page);
  AddVmCheckBox.Parent := Page.Surface;
  AddVmCheckBox.Checked := True;
  AddVmCheckBox.Top := ScaleY(16) + LineCount * LineHeight;
  AddVmCheckBox.Left := ScaleX(16);
  AddVmCheckBox.Width := Page.SurfaceWidth;
  AddVmCheckBox.Caption := CustomMessage('ProxyPageAddVmToNoProxy');

  LineCount := LineCount + 1;

  ProxyNotice := TNewStaticText.Create(Page);
  ProxyNotice.Parent := Page.Surface;
  ProxyNotice.Top := ScaleY(16) + LineCount * LineHeight;
  ProxyNotice.Left := ScaleX(0);
  ProxyNotice.AutoSize := True;
  ProxyNotice.Caption := CustomMessage('ProxyPageNotice');

end;


procedure InitializeWizard;
begin
  { Create the pages }
  CreateProxyPage;

//  AboutThisPage := CreateOutputMsgPage(
//    wpWelcome,                            // Show after welcome page
//    '{#emit SetupSetting("AppVerName")}', // Page caption
//    CustomMessage('AppSimpleInfo'),       // Page description
//    CustomMessage('AboutThis')            // Main message  
//  );

end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  { Skip pages that shouldn't be shown }
  Result := False;
end;

