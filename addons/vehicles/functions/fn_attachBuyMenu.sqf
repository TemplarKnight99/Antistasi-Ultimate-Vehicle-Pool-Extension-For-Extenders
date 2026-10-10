// Add category content to the existing Rebel dropdown; no extra tab or combo.
disableSerialization;
params ["_display", "_cfg"];
if (isNull _display) exitWith {false};
private _tabsCfg = _cfg >> "Controls" >> "TabButtons";
private _mainCfg = _cfg >> "Controls" >> "rebelVehicleTab";
private _rowsCfg = _mainCfg >> "Controls" >> "VehiclesControlsGroup";
private _comboCfg = _tabsCfg >> "Controls" >> "VehicleTabCombo";
if (!(isClass _tabsCfg && {isClass _mainCfg} && {isClass _rowsCfg} && {isClass _comboCfg})) exitWith
{
    diag_log "[AVPE Vehicles] Native Rebel dropdown layout changed; categories could not be attached.";
    false
};
private _tabs = _display displayCtrl getNumber (_tabsCfg >> "idc");
private _main = _display displayCtrl getNumber (_mainCfg >> "idc");
private _nativeRows = _display displayCtrl getNumber (_rowsCfg >> "idc");
private _combo = _display displayCtrl getNumber (_comboCfg >> "idc");
if (isNull _tabs || {isNull _main} || {isNull _nativeRows} || {isNull _combo}) exitWith {false};
if ([7191,7192] findIf {!isNull (_display displayCtrl _x)} >= 0) exitWith
{
    diag_log "[AVPE Vehicles] Rebel category control ID collision; categories could not be attached.";
    false
};
private _styles = ["A3A_ControlsGroupNoScrollbars", "A3A_ControlsGroupNoHScrollbars"];
if (_styles findIf {!isClass (configFile >> _x)} >= 0) exitWith {false};
private _nativePanels = (allControls _display) select {ctrlType _x == 15 && {isNull (ctrlParentControlsGroup _x)} && {!(_x isEqualTo _tabs)}};
private _previewCfg = _cfg >> "Objects" >> "VehiclePreview";
private _preview = if (isClass _previewCfg) then {_display displayCtrl getNumber (_previewCfg >> "idc")} else {controlNull};

private _panel = _display ctrlCreate ["A3A_ControlsGroupNoScrollbars", 7191];
private _rows = _display ctrlCreate ["A3A_ControlsGroupNoHScrollbars", 7192, _panel];
if (isNull _panel || {isNull _rows}) exitWith
{
    ctrlDelete _rows; ctrlDelete _panel;
    diag_log "[AVPE Vehicles] Could not create Rebel category content.";
    false
};
private _mainPos = ctrlPosition _main;
private _rowsPos = ctrlPosition _nativeRows;
_panel ctrlSetPosition _mainPos;
_rows ctrlSetPosition _rowsPos;
{_x ctrlCommit 0;} forEach [_panel, _rows];
_panel ctrlShow false;

_display setVariable ["AVPE_nativePanels", _nativePanels];
_display setVariable ["AVPE_nativePreview", _preview];
_display setVariable ["AVPE_nativeCombo", _combo];
_display setVariable ["AVPE_integrated", true];
[_display] call AVPE_fnc_repairVehiclePreviews;
[_display, _nativeRows, _display getVariable ["AVPE_nativeAllAdded", []]] call AVPE_fnc_guardMilitaryCards;
[_display] call AVPE_fnc_extendRebelDropdown;
diag_log "[AVPE Vehicles] Installed individual military categories in the native Rebel dropdown.";
true
