/* Adapter for the native [classname, price, undercover] row contract.
   Extension categories include locked cards. Native All Rebel gains additional
   unlocked vehicles; existing rows are preserved and duplicates are skipped. */
disableSerialization;
params [["_category", "", [""]]];
private _prefix = "AVPE:";
private _custom = (_category find _prefix) isEqualTo 0;
if (!_custom && {_category != "military"}) exitWith {_this call AVPE_originalPopulateVehicleBox};

private _rows = if (_custom) then {[]} else {_this call AVPE_originalPopulateVehicleBox};
private _key = if (_custom) then {_category select [count _prefix]} else {""};
private _seen = _rows apply {toLower (_x select 0)};
private _added = [];
{
    _x params ["_class", "_entryKey"];
    if (_custom && {_entryKey != _key}) then {continue};
    if (!isClass (configFile >> "CfgVehicles" >> _class)) then {continue};
    private _normalised = toLower _class;
    if (_normalised in _seen) then {continue};
    if (!_custom && {!(([_x] call AVPE_fnc_availability) select 0)}) then {continue};
    private _price = if (!isNil "server" && {server getVariable [_class, -1] > 0}) then {[_class] call A3A_fnc_vehiclePrice} else {-1};
    _rows pushBack [_class, _price, false];
    _seen pushBack _normalised;
    _added pushBack _normalised;
} forEach (missionNamespace getVariable ["AVPE_catalogue", []]);
if (!_custom && {hasInterface}) then
{
    private _cfg = missionConfigFile >> "A3A_BuyVehicleDialog";
    if (!isClass _cfg) then {_cfg = configFile >> "A3A_BuyVehicleDialog";};
    private _display = if (isClass _cfg) then {findDisplay getNumber (_cfg >> "idd")} else {displayNull};
    if (!isNull _display) then {_display setVariable ["AVPE_nativeAllAdded", _added];};
};
_rows
