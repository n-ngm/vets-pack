[Files]
Source: "Files\chef-zero.bat"; DestDir: "{tmp}";

[Code]
(**---------------------------
 * ChefDK functions
 * --------------------------- *)

(**
 * ChefDK_Exists
 *   check if ChefDK has already been installed
 *)
function ChefDK_Exists(): Boolean;
begin
    Result := False;
    if Pos('chefdk', Lowercase(GetWhichDir('chef.bat'))) > 0 then
    begin
        Result := True;
    end else begin
        Result := RegStringContained(GetHKLM, '{#HKLM_EnvKey}', 'Path', 'chefdk', '');
    end;
end;

(**
 * ChefDK_GegInstalledDir
 *   get chedk path
 *)
function ChefDK_GegInstalledDir: String;
var
    InstalledDir: String;
    RegPath:      String;
begin
    Result := '';

    InstalledDir := GetWhichDir('chef.bat');
    if (InstalledDir <> '') and (Pos('chefdk', Lowercase(InstalledDir)) > 0) then
    begin
        Result := InstalledDir;
    end else begin
        if ChefDK_Exists then
        begin
            RegQueryStringValue(GetHKLM, '{#HKLM_EnvKey}', 'Path', RegPath);
            InstalledDir := RegexReplace(RegPath, '$2', '(^|.*;)([^;]*\\chefdk\\bin).*$', True);
            if Pos(InstalledDir, ';') = 0 then
            begin
                Result := InstalledDir;
            end;
        end;
    end;
end;

(**
 * ChefDK_Install
 *   execute ChefDK installer
 *)
procedure ChefDK_Install(InstallerPath: String);
var
    SoftName:    String;
    ExecCommand: String;
    Params:      String;

    InstalledDir: String;
begin
    SoftName    := 'ChefDK';
    ExecCommand := 'msiexec';
    Params      := '/i ' + AddQuotes(InstallerPath) + ' /norestart ALLUSERS=1';
    if CustomizeForms.AutoInstallCheckBox.Checked then
    begin
        Params  := Params + ' /passive'
    end;
    ExecOtherInstaller(SoftName, ExecCommand, Params);

    InstalledDir := ChefDK_GegInstalledDir;
    if InstalledDir <> '' then
    begin
        ExtractTemporaryFile(ExpandConstant('chef-zero.bat'));
        FileCopy(ExpandConstant('{tmp}\chef-zero.bat'), InstalledDir + '\chef-zero.bat', False);
    end;
end;
