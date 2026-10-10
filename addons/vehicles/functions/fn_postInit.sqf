// Run only in an Antistasi mod mission. No main-mod files are overwritten.
if (!isClass (missionConfigFile >> "A3A")) exitWith {};

if (isServer) then
{
    // Read-only resynchronisation for clients joining after initial broadcasts.
    ["AVPE_requestSync", {
        params [["_owner", -1, [0]]];
        if (_owner < 2 || {!(missionNamespace getVariable ["AVPE_ready", false])}) exitWith {};
        {
            _owner publicVariableClient _x;
        } forEach ["AVPE_catalogue", "AVPE_ready", "A3A_faction_all",
            "A3A_rebelVehicleCosts", "A3A_vehicleResourceCosts", "A3A_groundVehicleThreat"];
    }] call CBA_fnc_addEventHandler;
};

[] spawn
{
    waitUntil { uiSleep 0.5; missionNamespace getVariable ["serverInitDone", false] };

    if (isServer) then { call AVPE_fnc_installCatalogue; };
    if (!hasInterface) exitWith {};

    waitUntil { uiSleep 0.5; !isNull player && {!isNil "A3A_faction_reb"} };
    // Explicit request also covers JIP. Only read-only catalogue data is requested.
    private _attempts = 0;
    while {!(missionNamespace getVariable ["AVPE_ready", false]) && {_attempts < 15}} do
    {
        ["AVPE_requestSync", [clientOwner]] call CBA_fnc_serverEvent;
        uiSleep 2;
        _attempts = _attempts + 1;
    };
    if (!(missionNamespace getVariable ["AVPE_ready", false])) exitWith
    {
        diag_log "[AVPE Vehicles] Server catalogue did not synchronise. Confirm the extension is loaded on the server and inspect its RPT.";
    };

    // Native callbacks delegate standard requests to the originally loaded code.
    if (!(call AVPE_fnc_installMenuHooks)) exitWith {};
    // Also covers a purchase display already open when the catalogue synchronises.
    if (isNil "AVPE_buyMenuPFH") then
    {
        AVPE_buyMenuPFH = [{call AVPE_fnc_watchBuyMenu}, 0.2] call CBA_fnc_addPerFrameHandler;
    };
};
