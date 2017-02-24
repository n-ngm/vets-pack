[Files]
Source: "Files\CygwinAliasSet.sh"; DestDir: "{tmp}";

[Code]
(**---------------------------
 * Cygwin functions
 * --------------------------- *)

(**
 * Cygwin_Exists
 *   check if Cygwin has already been installed
 *)
function Cygwin_Exists(): Boolean;
begin
    Result := RegKeyExists(HKEY_LOCAL_MACHINE, 'SOFTWARE\Cygwin');
end;

(**
 * Cygwin_Install
 *   execute Cygwin installer
 *)
procedure Cygwin_Install(InstallerPath: String);
var
    SoftName:    String;
    ExecCommand: String;
    Params:      String;
    LocalRoot:   String;
begin
    SoftName  := 'Cygwin';
    LocalRoot := ExpandConstant('{pf}\cygwin');

    CreateDir(LocalRoot);
    ExecCommand := LocalRoot + '\cygwinsetup.exe';
    FileCopy(InstallerPath, ExecCommand, False);

    // quiet mode
    // Params  := Params + ' -q';

    // proxy
    if ProxyForms.UseProxyCheckBox.Checked then
    begin
        Params := Params + ' -p ' + ProxyForms.ProxyAddressTextBox.Text + ':' + ProxyForms.ProxyPortTextBox.Text;
    end;

    // packages
    Params := Params + ' -P "rsync,openssh"';

    // repository
    Params := Params + ' -s ' + GetIniString(SoftName, SoftName + 'RepositoryUrl', '', ExpandConstant('{tmp}\{#SetupIni}'));

    // local pacakge dir
    // Params := Params + ' -l "' +  LocalRoot  + '"';

    // execute
    ExecOtherInstaller(SoftName, ExecCommand, Params);
end;

procedure Cygwin_PathSet;
var
    InstalledDir: String;
    ResultCode:   Integer;
begin
    if RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\Cygwin\setup', 'rootdir', InstalledDir) then
    begin
        // set path to use cygwin command in ms-dos prompt
        RegAddEnvironment('Path', InstalledDir, ';');
        RegAddEnvironment('Path', ExpandConstant(InstalledDir + '\bin'), ';');

        // set cdrive symbolyc link
        Exec(InstalledDir + '\bin\bash', '-c "cd /; ln -swf /cygdrive/c c;"', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);

        // set alias to use ruby commands in cygwin
        ExtractTemporaryFile(ExpandConstant('CygwinAliasSet.sh'));
        FileCopy(ExpandConstant('{tmp}\CygwinAliasSet.sh'), InstalledDir + '\tmp\CygwinAliasSet.sh', False);
        Exec(InstalledDir + '\bin\bash', '/tmp/CygwinAliasSet.sh', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
    end;
end;

