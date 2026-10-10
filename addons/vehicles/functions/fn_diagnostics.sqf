/* Run locally from the in-game debug console:
call AVPE_fnc_diagnostics;
Returns a summary and writes it to the local RPT. No money or save data changes.
*/
disableSerialization;
private _catalogue = missionNamespace getVariable ["AVPE_catalogue", []];
private _uniqueClasses = [];
{_uniqueClasses pushBackUnique (toLower (_x select 0));} forEach _catalogue;
private _cfg = missionConfigFile >> "A3A_BuyVehicleDialog";
if (!isClass _cfg) then {_cfg = configFile >> "A3A_BuyVehicleDialog";};
private _display = if (hasInterface && {isClass _cfg}) then {findDisplay getNumber (_cfg >> "idd")} else {displayNull};
private _summary = [
    ["addonLoaded", isClass (configFile >> "CfgPatches" >> "AVPE_Vehicles")],
    ["isServer", isServer],
    ["serverInitialised", missionNamespace getVariable ["serverInitDone", false]],
    ["catalogueReady", missionNamespace getVariable ["AVPE_ready", false]],
    ["rebelTemplate", missionNamespace getVariable ["A3A_Reb_template", ""]],
    ["catalogueEntries", count _catalogue],
    ["vehicleCount", count _uniqueClasses],
    ["categoryCounts", (call AVPE_fnc_categories) apply {
        private _key = _x select 0;
        [_key, {(_x select 1) isEqualTo _key} count _catalogue]
    }],
    ["warTier", missionNamespace getVariable ["tierWar", -1]],
    ["atHQ", if (hasInterface) then {call AVPE_fnc_atHQ} else {false}],
    ["addonVersion", getText (configFile >> "CfgPatches" >> "AVPE_Vehicles" >> "version")],
    ["menuWatcherRunning", !isNil "AVPE_buyMenuPFH"],
    ["nativeMenuOpen", !isNull _display],
    ["menuAdaptersInstalled", missionNamespace getVariable ["AVPE_menuHooksInstalled", false]],
    ["rebelCategoriesAttached", if (isNull _display) then {false} else {_display getVariable ["AVPE_integrated", false]}],
    ["categoryAttachAttempted", if (isNull _display) then {false} else {_display getVariable ["AVPE_tabAttempted", false]}],
    ["selectedMilitaryCategory", if (isNull _display) then {""} else {_display getVariable ["AVPE_selectedRebelCategory", ""]}],
    ["previewRepairs", if (isNull _display) then {[]} else {_display getVariable ["AVPE_previewRepairs", []]}],
    ["vehicles", _catalogue apply {
        [(_x select 0), isClass (configFile >> "CfgVehicles" >> (_x select 0)),
         if (isNil "server") then {-1} else {server getVariable [(_x select 0), -1]}]
    }]
];
diag_log format ["[AVPE Vehicles] Diagnostics: %1", _summary];
_summary
