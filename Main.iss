; Virtual Environment Tools Pack
;
; this install virtual environment tools (virtualbox, vagrant, chefdk, cygwin) all at once,
; for development in Windows.
;
; Install
;   - VirtualBox
;   - Vagrant
;   - ChefDK
;   - Cygwin
; Set Registory
;   - Proxy Setting
;   - Envrionment Path
;

; define constants
#define MyPublisher  "ClickMaker"
#define MyAppName    "Virtual Environment Tools Pack"
#define MyAppAlias   "VETs Pack"
#define MyAppVersion "0.1.15"
#define MyOutputFile StringChange(MyAppAlias, " ", "") + "-" + MyAppVersion

#define SetupIni     "Setup.ini"

; include InnoSetup download plugin
#include <idp.iss>

; inclue sources
#include "Src\Common.iss"
#include "Src\Registry.iss"
#include "Src\ProxyPage.iss"
#include "Src\Virtualbox.iss"
#include "Src\Vagrant.iss"
#include "Src\ChefDK.iss"
#include "Src\Cygwin.iss"

[Setup]
; setup basic info
AppName            = {#MyAppName}
AppVerName         = {#MyAppName} {#MyAppVersion}
AppPublisher       = {#MyPublisher}
VersionInfoVersion = {#MyAppVersion}
OutputBaseFilename = {#MyOutputFile}

; enable logging
SetupLogging       = yes

; require admin execution
PrivilegesRequired = admin

; default pages setting
ShowLanguageDialog   = yes
DisableWelcomePage   = yes
LicenseFile          = ""
Password             = ""
InfoBeforeFile       = ""
UserInfoPage         = no
DisableDirPage       = yes
DefaultDirName       = {pf}\{#MyPublisher}\{#emit StringChange(MyAppAlias, " ", "")}
UsePreviousAppDir    = yes
AppendDefaultDirName = no
DisableReadyPage     = no


[Languages]
Name: japanese; \
    MessagesFile: "compiler:\Languages\Japanese.isl,{__FILE__}\..\Messages\Japanese.isl"; \
    InfoBeforeFile: "Files\Readme_JP.md"

Name: english; \
    MessagesFile: "compiler:Default.isl,{__FILE__}\..\Messages\English.isl"; \
    InfoBeforeFile: "Readme.md"

[Files]
Source: "Files\Setup.ini"; DestDir: "{app}";
Source: "Readme.md"; DestDir: "{app}";
Source: "Files\Readme_JP.md"; DestDir: "{app}";

[Types]
Name: "custom"; Description: {cm:NormalInstallation}; Flags: iscustom

[Components]
Name: "VirtualBox"; Description: "VirtualBox";           Flags: disablenouninstallwarning;
Name: "Vagrant";    Description: "Vagrant";              Flags: disablenouninstallwarning;
Name: "ChefDK";     Description: "Chef Development Kit"; Flags: disablenouninstallwarning;
Name: "Cygwin";     Description: "cygwin";               Flags: disablenouninstallwarning;

[Code]
var
    DownloadDir: String;

procedure ListUpSoftware;  forward;
procedure InstallSoftware; forward;
function  GetDownloadUrl  (SoftName: String): String; forward;
function  GetInstallerPath(SoftName: String): String; forward;

procedure InitializeWizard;
begin
    { extract setup.ini }
    ExtractTemporaryFile(ExpandConstant('{#SetupIni}'));
    DownloadDir := '{tmp}';

    { create the custom pages }
    CreateProxyPage(wpInfoBefore);
end;

procedure CurPageChanged(CurPageID: Integer);
begin
    if CurPageID = wpReady then
    begin
        { list up software to download }
        ListUpSoftware;
    end;

    if CurPageID = wpPreparing then
    begin
        { set proxy to registry }
        SetProxyToRegistry;

        { download starts set }
        idpDownloadAfter(wpPreparing);
    end;

    if CurPageID = wpInstalling then
    begin
        { install software }
        InstallSoftware;
    end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
    case CurStep of
        ssPostInstall:
        begin
            //DelTree(ExpandConstant('{tmp}') + '\*', False, True, True);
        end;
    end;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
    case CurPageID of
        ProxyPage.ID:
        begin
        end;
    end;
    Result := True;
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
    Result := False;
end;

procedure ListUpSoftware;
var
    SoftNames:     array of String;
    SoftName:      String;
    DownloadUrl:   String;
    InstallerPath: String;
    i: Integer;
begin
    { reset file list }
    idpClearFiles;

    SetArrayLength(SoftNames, 4);
    SoftNames[0] := 'VirtualBox';
    SoftNames[1] := 'Vagrant';
    SoftNames[2] := 'ChefDK';
    SoftNames[3] := 'Cygwin';
    { add download file list }
    for i := 0 to 3 do
    begin
        SoftName := SoftNames[i];
        if IsComponentSelected(SoftName) then
        begin
            DownloadUrl   := GetDownloadUrl(SoftName);
            InstallerPath := GetInstallerPath(SoftName);
            idpAddFile(DownloadUrl, InstallerPath);
        end;
    end;

end;


(**
 * InstallSoftware
 *   execute installers.
 *)
procedure InstallSoftware;
var
    SoftName:     String;
begin
    // install VirtualBox
    SoftName := 'VirtualBox';
    if IsComponentSelected(SoftName) then
    begin
        Virtualbox_Install(GetInstallerPath(SoftName));
    end;

    // install Vagrant
    SoftName := 'Vagrant';
    if IsComponentSelected(SoftName) then
    begin
        Vagrant_Install(GetInstallerPath(SoftName));
    end;

    // install ChefDK
    SoftName := 'ChefDK';
    if IsComponentSelected(SoftName) then
    begin
        ChefDK_Install(GetInstallerPath(SoftName));
    end;

    // install Cygwin
    SoftName := 'Cygwin';
    if IsComponentSelected(SoftName) then
    begin
        Cygwin_Install(GetInstallerPath(SoftName));
        if Cygwin_Exists then
        begin
            Cygwin_PathSet;
        end;
    end;
end;

(**
 * GetDownloadUrl
 *   get download url from setup.ini
 *)
function GetDownloadUrl (SoftName: String): String;
var
    Bit: String;
begin
    Bit := '';
    if SoftName = 'Cygwin' then
    begin
        if IsWin64 then
        begin
            Bit := '64';
        end else begin
            Bit := '32';
        end;
    end;
    Result := GetIniString(SoftName, SoftName + Bit + 'DownloadUrl',  '', ExpandConstant('{tmp}\{#SetupIni}'));
end;

(**
 * GetInstallerPath
 *   get the path of downloaded installer.
 *)
function GetInstallerPath(SoftName: String): String;
var
    SaveFileName: String;
begin
    SaveFileName := GetIniString(SoftName, SoftName + 'SaveFileName', '', ExpandConstant('{tmp}\{#SetupIni}'));
    Result := ExpandConstant(DownloadDir + '\' + SaveFileName);
end;
