/*
[key, exact dropdown label, minimum war tier, airport required,
 fallback base price, fallback resource cost, fallback ground threat,
 extra native aggregate asset-list keys]

The key also reads a same-named array from A3A_faction_reb.
Each key and dropdown label must be unique. Add your own rows here.
Prices/costs are examples; adjust them for your own balance.
*/
[
    ["vehiclesUtilities", "Rebel Utilities", 5, false, 400, 20, 0, []],
    ["vehiclesMRAP", "Rebel MRAPs", 4, false, 900, 50, 0, ["vehiclesLightArmed", "vehiclesLight"]],
    ["vehiclesDrone", "Rebel Drones", 4, false, 800, 150, 0, ["vehiclesUAVs"]],
    ["vehiclesAPC", "Rebel APCs", 5, false, 1000, 100, 120, ["vehiclesAPCs", "vehiclesArmor"]],
    ["vehiclesIFV", "Rebel IFVs", 5, false, 1000, 150, 200, ["vehiclesIFVs", "vehiclesArmor"]],
    ["vehiclesMGS", "Rebel MGS", 5, false, 1000, 100, 120, ["vehiclesAPCs", "vehiclesArmor"]],
    ["vehiclesLightTank", "Rebel Light Tanks", 5, false, 1100, 170, 180, ["vehiclesLightTanks", "vehiclesArmor"]],
    ["vehiclesTank", "Rebel Tanks", 6, false, 1200, 230, 300, ["vehiclesTanks", "vehiclesArmor"]],
    ["vehiclesMilitaryHeli", "Rebel Helicopters", 6, false, 5000, 100, 0, []],
    ["vehiclesMilitaryHeliTransport", "Rebel Transport Helicopters", 6, false, 5000, 100, 0, []],
    ["vehiclesMilitaryHeliCAS", "Rebel Attack Helicopters", 6, false, 5000, 250, 0, ["vehiclesHelisAttack"]],
    ["vehiclesMilitaryVTOLHeavyTransport", "Rebel Heavy VTOL Transports", 6, true, 5000, 100, 0, []],
    ["vehiclesMilitaryVTOLCAS", "Rebel VTOL CAS", 6, true, 5000, 250, 0, []],
    ["vehiclesPlanesCAS", "Rebel CAS Planes", 6, true, 5000, 250, 0, ["vehiclesPlanesCAS"]],
    ["vehiclesPlanesLargeCAS", "Rebel Heavy CAS Planes", 7, true, 5000, 250, 0, ["vehiclesPlanesLargeCAS"]],
    ["vehiclesPlanesGunship", "Rebel Gunships", 7, true, 5000, 275, 0, ["vehiclesPlanesGunship"]]
]

