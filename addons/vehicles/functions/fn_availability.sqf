// Rechecked when buying; the list does not alone authorise a purchase.
params ["_entry"];
_entry params ["_class", "_key", "_tier", "_airport"];
if (!isClass (configFile >> "CfgVehicles" >> _class)) exitWith {[false, "Required vehicle mod is missing"]};
if ((missionNamespace getVariable ["tierWar", 0]) < _tier) exitWith {[false, format ["Requires war tier %1", _tier]]};
if (_airport) then
{
    private _sides = missionNamespace getVariable ["sidesX", objNull];
    private _side = missionNamespace getVariable ["teamPlayer", sideUnknown];
    private _owned = !isNull _sides && {
        ((missionNamespace getVariable ["airportsX", []]) findIf {
            _sides getVariable [_x, sideUnknown] isEqualTo _side
        }) >= 0
    };
    if (!_owned) exitWith {[false, "Requires a controlled airport"]};
    if (isNil "server" || {server getVariable [_class, -1] <= 0}) exitWith {[false, "Vehicle price is synchronising"]};
    [true, "Available"]
}
else
{
    if (isNil "server" || {server getVariable [_class, -1] <= 0}) exitWith {[false, "Vehicle price is synchronising"]};
    [true, "Available"]
}
