/* Thin controller adapter. Native modes/category labels delegate to the
   original loaded controller. Only our dropdown labels select our own group. */
disableSerialization;
params [["_mode", "onLoad", [""]], ["_args", []]];
private _cfg = missionConfigFile >> "A3A_BuyVehicleDialog";
if (!isClass _cfg) then {_cfg = configFile >> "A3A_BuyVehicleDialog";};
private _display = if (isClass _cfg) then {findDisplay getNumber (_cfg >> "idd")} else {displayNull};

private _customKey = "";
if (_mode isEqualTo "selectCategory" && {!isNull _display}) then
{
    private _label = _args param [0, ""];
    _customKey = (_display getVariable ["AVPE_rebelLabels", createHashMap]) getOrDefault [_label, ""];
};
if (_customKey != "") exitWith
{
    [_display, _customKey] call AVPE_fnc_selectRebelCategory;
};
if (_mode in ["switchTab", "selectCategory"] && {!isNull _display}) then
{
    private _panel = _display displayCtrl 7191;
    if (!isNull _panel) then {_panel ctrlShow false;};
    _display setVariable ["AVPE_selectedRebelCategory", ""];
};

_this call AVPE_originalBuyVehicleDialog;

// Cover the original categories too: missing pictures are not limited to extras.
if (_mode in ["onLoad", "switchTab", "selectCategory"] && {!isNull _display}) then
{
    [_display] call AVPE_fnc_repairVehiclePreviews;
};

if (_mode isEqualTo "onLoad") then
{
    _display = if (isClass _cfg) then {findDisplay getNumber (_cfg >> "idd")} else {displayNull};
    if (!isNull _display && {!(_display getVariable ["AVPE_tabAttempted", false])}) then
    {
        _display setVariable ["AVPE_tabAttempted", true];
        [_display, _cfg] call AVPE_fnc_attachBuyMenu;
    };
};
// Append after native tab rebuilding finishes, never from its nested selection EH.
if (_mode in ["onLoad", "switchTab"] && {!isNull _display}) then
{
    [_display] call AVPE_fnc_extendRebelDropdown;
};
