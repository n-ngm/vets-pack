[Code]
function Virtualbox_Exists(): Boolean;
begin
    Result := RegKeyExists(HKEY_LOCAL_MACHINE, 'SOFTWARE\Oracle\VirtualBox');
end;

function Virtualbox_Install(InstallerPath: String): Boolean;
var
  Params: String;
  StatusText: String;
  ResultCode: Integer;
begin
  StatusText := WizardForm.StatusLabel.Caption;
  WizardForm.StatusLabel.Caption := 'Executing VirtualBox Installer. Please complete.';
  WizardForm.ProgressGauge.Style := npbstMarquee;
  try
    Result := True;
    Params := '-msiparams ALLUSERS=1';
    if not Exec(InstallerPath, Params, '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
    begin
      MsgBox('VirtualBox installation failed with code: ' + IntToStr(ResultCode), mbError, MB_OK);
      Result := False;
    end;
  finally
    WizardForm.StatusLabel.Caption := StatusText;
    WizardForm.ProgressGauge.Style := npbstNormal;
  end;
end;
