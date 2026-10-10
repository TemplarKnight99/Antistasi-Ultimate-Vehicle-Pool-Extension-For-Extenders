/* Client-only CBA handler. Installs our categories once per purchase display.
   IDD/IDCs come from the loaded dialog config rather than copied ids.inc.
   No separate purchase action is added. */
disableSerialization;
if (!hasInterface || {!(missionNamespace getVariable ["AVPE_menuHooksInstalled", false])} || {count (missionNamespace getVariable ["AVPE_catalogue", []]) == 0}) exitWith {};

private _cfg = missionConfigFile >> "A3A_BuyVehicleDialog";
if (!isClass _cfg) then {_cfg = configFile >> "A3A_BuyVehicleDialog";};
if (!isClass _cfg) exitWith {};
private _idd = getNumber (_cfg >> "idd");
if (_idd <= 0) exitWith {};
private _display = findDisplay _idd;
if (isNull _display || {_display getVariable ["AVPE_tabAttempted", false]}) exitWith {};

// The native scheduled onLoad sets this reference at the end of initialisation.
private _comboCfg = _cfg >> "Controls" >> "TabButtons" >> "Controls" >> "VehicleTabCombo";
if (!isClass _comboCfg) exitWith
{
    _display setVariable ["AVPE_tabAttempted", true];
    diag_log "[AVPE Vehicles] Native purchase category control changed; categories could not be attached.";
};
private _combo = _display displayCtrl getNumber (_comboCfg >> "idc");
private _readyControl = uiNamespace getVariable ["cv_vehicleTypeBox", controlNull];
if (isNull _combo || {isNull _readyControl} || {!(_readyControl isEqualTo _combo)} || {lbSize _combo == 0}) exitWith {};

_display setVariable ["AVPE_tabAttempted", true];
[_display, _cfg] call AVPE_fnc_attachBuyMenu;
