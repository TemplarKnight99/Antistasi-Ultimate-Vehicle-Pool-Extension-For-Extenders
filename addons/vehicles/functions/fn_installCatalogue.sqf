/*
Server only. Extend the existing asset/cost maps after native initialisation.
Do not rerun compileMissionAssets: that also converts template data in place.
Catalogue entries: [classname, category key, minimum tier, airport required, base price].
*/
if (!isServer) exitWith {};
if (missionNamespace getVariable ["AVPE_ready", false]) exitWith {};

private _required = ["A3A_faction_reb", "A3A_faction_occ", "A3A_faction_inv", "A3A_faction_all", "A3A_rebelVehicleCosts",
    "A3A_vehicleResourceCosts", "A3A_groundVehicleThreat", "server"];
if ((_required findIf {isNil _x}) >= 0) exitWith
{
    diag_log "[AVPE Vehicles] Required Antistasi data missing; catalogue was not installed.";
};

private _categories = call AVPE_fnc_categories;
private _attributes = createHashMap;
// Match the native reb -> occ -> inv attribute override order.
{
    {
        if !(_x isEqualType [] && {count _x > 0}) then { continue };
        private _class = _x select 0;
        if !(_class isEqualType "") then { continue };
        private _values = _attributes getOrDefault [toLower _class, createHashMap];
        {
            if (_x isEqualType [] && {count _x == 2} && {(_x select 0) isEqualType ""}) then
            {
                _values set [toLower (_x select 0), _x select 1];
            };
        } forEach (_x select [1]);
        _attributes set [toLower _class, _values];
    } forEach (_x getOrDefault ["attributesVehicles", []]);
} forEach [A3A_faction_reb, A3A_faction_occ, A3A_faction_inv];

// Restrict addon-managed pools/prices optionally; faction-saved pools remain readable.
private _filter = call AVPE_fnc_templateFilter;
private _useAddonPools = count _filter == 0 || {
    (missionNamespace getVariable ["A3A_Reb_template", ""]) in _filter
};
private _pools = createHashMap;
private _prices = createHashMap;
if (_useAddonPools) then
{
    {
        if !(_x isEqualType [] && {count _x == 2}) then {continue};
        _x params ["_key", "_classes"];
        if !(_key isEqualType "" && {_classes isEqualType []}) then {continue};
        if ((_categories findIf {(_x select 0) isEqualTo _key}) < 0) then
        {
            diag_log format ["[AVPE Vehicles] Unknown pool category: %1", _key];
            continue;
        };
        private _list = _pools getOrDefault [_key, []];
        _list append _classes;
        _pools set [_key, _list];
    } forEach (call AVPE_fnc_vehiclePools);
    {
        if !(_x isEqualType [] && {count _x == 2}) then {continue};
        _x params ["_class", "_price"];
        if !(_class isEqualType "" && {_class != ""} && {_price isEqualType 0} && {_price > 0}) then {continue};
        private _key = toLower _class;
        if (_key in _prices) then
        {
            diag_log format ["[AVPE Vehicles] Duplicate price row skipped: %1", _class];
            continue;
        };
        _prices set [_key, _price];
    } forEach (call AVPE_fnc_vehiclePrices);
};

private _merge =
{
    params ["_key", "_class"];
    private _list = A3A_faction_all getOrDefault [_key, []];
    if ((_list findIf {_x isEqualType "" && {toLower _x isEqualTo toLower _class}}) < 0) then
    {
        _list pushBack _class;
        A3A_faction_all set [_key, _list];
    };
};

AVPE_catalogue = [];
private _seen = createHashMap;
{
    _x params ["_key", "_label", "_tier", "_airport", "_default", "_resource", "_threat", "_assetKeys"];
    private _classes = +(A3A_faction_reb getOrDefault [_key, []]);
    _classes append (_pools getOrDefault [_key, []]);

    {
        // Drop empty placeholders, weights and missing addon classes.
        if !(_x isEqualType "" && {_x != ""}) then { continue };
        private _cfg = configFile >> "CfgVehicles" >> _x;
        if (!isClass _cfg) then
        {
            diag_log format ["[AVPE Vehicles] Vehicle addon/class missing, skipped: %1", _x];
            continue;
        };
        private _class = configName _cfg;
        if (_class isKindOf "CAManBase" || {!(_class isKindOf "AllVehicles")}) then { continue };
        // One membership per class/category; a vehicle can belong to several groups.
        private _membership = str [toLower _class, _key];
        if (_seen getOrDefault [_membership, false]) then { continue };
        _seen set [_membership, true];

        private _attrs = _attributes getOrDefault [toLower _class, createHashMap];
        private _price = _attrs getOrDefault ["rebcost", server getVariable [_class, _default]];
        _price = _prices getOrDefault [toLower _class, _price];
        if !(_price isEqualType 0 && {_price > 0}) then { _price = _default; };

        private _resourceCost = _attrs getOrDefault ["cost", A3A_vehicleResourceCosts getOrDefault [_class, _resource]];
        private _groundThreat = _attrs getOrDefault ["threat", A3A_groundVehicleThreat getOrDefault [_class, _threat]];
        if !(_resourceCost isEqualType 0 && {_resourceCost >= 0}) then { _resourceCost = _resource; };
        if !(_groundThreat isEqualType 0 && {_groundThreat >= 0}) then { _groundThreat = _threat; };

        A3A_rebelVehicleCosts set [_class, _price];
        A3A_vehicleResourceCosts set [_class, _resourceCost];
        A3A_groundVehicleThreat set [_class, _groundThreat];
        server setVariable [_class, _price, true];

        private _needsAirport = _airport || {_class isKindOf "Plane"};
        AVPE_catalogue pushBack [_class, _key, _tier, _needsAirport, _price];
        { [_x, _class] call _merge; } forEach ([_key, "vehiclesReb"] + _assetKeys);
        if (_class isKindOf "Helicopter") then { ["vehiclesHelis", _class] call _merge; };
        if (_class isKindOf "Plane") then { ["vehiclesFixedWing", _class] call _merge; };
    } forEach _classes;
} forEach _categories;

// Publish maps first, then the readiness flag. Extend native JIP synchronisation.
{
    publicVariable _x;
    if (!isNil "serverInitialisedVariables") then { serverInitialisedVariables pushBackUnique _x; };
} forEach ["AVPE_catalogue", "A3A_faction_all", "A3A_rebelVehicleCosts",
    "A3A_vehicleResourceCosts", "A3A_groundVehicleThreat"];
AVPE_ready = true;
publicVariable "AVPE_ready";
if (!isNil "serverInitialisedVariables") then
{
    serverInitialisedVariables pushBackUnique "AVPE_ready";
    publicVariable "serverInitialisedVariables";
};
diag_log format ["[AVPE Vehicles] Installed %1 military catalogue entries without overriding Antistasi functions.", count AVPE_catalogue];
