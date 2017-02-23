[Code]
(**---------------------------
 * ChefDK functions
 * --------------------------- *)

(**
 * ChefDK_Exists
 *   check if ChefDK has already been installed
 *)
function ChefDK_Exists(): Boolean;
var
    Params:     String;
    ResultCode: Integer;
begin
    Result := True;
    Params := '--version';
    if not Exec('berks', Params, '', SW_SHOW, ewWaitUntilTerminated, ResultCode) then
    begin
        Result := False;
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
begin
    SoftName    := 'ChefDK';
    ExecCommand := 'msiexec';
    Params      := '/i ' + AddQuotes(InstallerPath) + ' /qf /norestart ALLUSERS=1';
    ExecOtherInstaller(SoftName, ExecCommand, Params);
end;
