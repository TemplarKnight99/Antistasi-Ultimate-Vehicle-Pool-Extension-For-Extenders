// Client-local adapters: standard requests call the original loaded functions.
// No official PBO, config, controller source or stringtable is copied/replaced.
if (!hasInterface) exitWith {false};
if (missionNamespace getVariable ["AVPE_menuHooksInstalled", false]) exitWith {true};
if (count (missionNamespace getVariable ["AVPE_catalogue", []]) == 0) exitWith
{
    diag_log "[AVPE Vehicles] No valid catalogue vehicles. Check pools, template filter and loaded vehicle mods.";
    false
};
if (isNil "SCRT_fnc_ui_populateVehicleBox" || {isNil "A3A_fnc_buyVehicleDialog"} || {isNil "A3A_fnc_buyVehicleTabs"}) exitWith
{
    diag_log "[AVPE Vehicles] Native purchase functions are unavailable; menu adapters could not be installed.";
    false
};
AVPE_originalPopulateVehicleBox = SCRT_fnc_ui_populateVehicleBox;
AVPE_originalBuyVehicleDialog = A3A_fnc_buyVehicleDialog;
SCRT_fnc_ui_populateVehicleBox = AVPE_fnc_populateVehicleBox;
A3A_fnc_buyVehicleDialog = AVPE_fnc_buyVehicleDialog;
AVPE_menuHooksInstalled = true;
true
