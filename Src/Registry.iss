[Code]
(**---------------------------
 * Registry utility functions
 * --------------------------- *)

#define HKLM_EnvKey "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
#define HKCU_NetKey "Software\Microsoft\Windows\CurrentVersion\Internet Settings"

(**
 * GetHKLM
 *   Get HKEY_LOCAL_MACHINE RootKey by bit
 *)
function GetHKLM: Integer;
begin
    if IsWin64 then
    begin
        Result := HKLM64;
    end else begin
        Result := HKLM32;
    end;
end;

(**
 * RegStringContained
 *   check if string is contained in string type registry
 *)
function RegStringContained(
    RootKey:     Integer;
    SubKeyName:  String;
    TargetKey:   String;
    TargetValue: String;
    Delimiter:   String): Boolean;
var
    OrigValue: String;
begin
    // not found key
    if not RegQueryStringValue(RootKey, SubKeyName, TargetKey, OrigValue) then
    begin
        Result := False;
        exit;
    end;

    // if contain in registry
    if Pos(Delimiter + TargetValue + Delimiter, Delimiter + OrigValue + Delimiter) > 0 then
    begin
        Result := True;
    end else begin
        Result := False;
    end;
end;

(**
 * RegAddStringValue
 *   add string to last of string type registry
 *)
function RegAddStringValue(
    RootKey:     Integer;
    SubKeyName:  String;
    TargetKey:   String;
    TargetValue: String;
    Delimiter:   String): Boolean;
var
    OrigValue:  String;
    WriteValue: String;
begin
     // already contained
    if RegStringContained(RootKey, SubKeyName, TargetKey, TargetValue, Delimiter) then
    begin
        Result := True;
        exit;
    end;

    // not found key, then create
    if not RegQueryStringValue(RootKey, SubKeyName, TargetKey, OrigValue) then
    begin
        Result := RegWriteStringValue(RootKey, SubKeyName, TargetKey, TargetValue);
        exit;
    end;

    // add string value
    WriteValue := OrigValue + Delimiter + TargetValue;
    Result := RegWriteStringValue(RootKey, SubKeyName, TargetKey, ExpandConstant(WriteValue));
end;

(**
 * RegRemoveStringValue
 *    remove string from string type registry
 *)
function RegRemoveStringValue(
    RootKey:     Integer;
    SubKeyName:  String;
    TargetKey:   String;
    TargetValue: String;
    Delimiter:   String): Boolean;
var
    OrigValue: String;
begin
    // not found key, return true
    if not RegQueryStringValue(RootKey, SubKeyName, TargetKey, OrigValue) then
    begin
        Result := True;
        exit;
    end;

    // not contained, return true
    if not RegStringContained(RootKey, SubKeyName, TargetKey, TargetValue, Delimiter) then
    begin
        Result := True;
        exit;
    end;

    // remove string
    StringChange(OrigValue, TargetValue, '' );
    StringChange(OrigValue, Delimiter + Delimiter, Delimiter);
    Result := RegWriteStringValue(RootKey, SubKeyName, TargetKey, OrigValue);
end;

(**
 * RegWriteInternetSetting
 * RegDeleteInternetSetting
 * RegAddInternetSetting
 * RegRemoveInternetSetting
 *   wrapper functions
 *)
function RegWriteInternetSetting(
    TargetKey:   String;
    TargetValue: String): Boolean;
begin
    Result := RegWriteStringValue(HKEY_CURRENT_USER,  '{#HKCU_NetKey}', TargetKey,  TargetValue);
end;
function RegDeleteInternetSetting(
    TargetKey:   String): Boolean;
begin
    Result := RegDeleteValue(HKEY_CURRENT_USER,  '{#HKCU_NetKey}', TargetKey);
end;
function RegAddInternetSetting(
    TargetKey:   String;
    TargetValue: String;
    Delimiter:   String): Boolean;
begin
    Result := RegAddStringValue(HKEY_CURRENT_USER,  '{#HKCU_NetKey}', TargetKey,  TargetValue, Delimiter);
end;
function RegRemoveInternetSetting(
    TargetKey:   String;
    TargetValue: String;
    Delimiter:   String): Boolean;
begin
    Result := RegRemoveStringValue(HKEY_CURRENT_USER,  '{#HKCU_NetKey}', TargetKey,  TargetValue, Delimiter);
end;

(**
 * RegWriteEnvironment
 * RegDeleteEnvironment
 * RegAddEnvironment
 * RegRemoveEnvironment
 *   wrapper functions
 *)
function RegWriteEnvironment(
    TargetKey:   String;
    TargetValue: String): Boolean;
begin
    Result := RegWriteStringValue(GetHKLM, '{#HKLM_EnvKey}', TargetKey,  TargetValue);
end;
function RegDeleteEnvironment(
    TargetKey:   String): Boolean;
begin
    Result := RegDeleteValue(GetHKLM, '{#HKLM_EnvKey}', TargetKey);
end;
function RegAddEnvironment(
    TargetKey:   String;
    TargetValue: String;
    Delimiter:   String): Boolean;
begin
    Result := RegAddStringValue(GetHKLM, '{#HKLM_EnvKey}', TargetKey,  TargetValue, Delimiter);
end;
function RegRemoveEnvironment(
    TargetKey:   String;
    TargetValue: String;
    Delimiter:   String): Boolean;
begin
    Result := RegRemoveStringValue(GetHKLM, '{#HKLM_EnvKey}', TargetKey,  TargetValue, Delimiter);
end;


