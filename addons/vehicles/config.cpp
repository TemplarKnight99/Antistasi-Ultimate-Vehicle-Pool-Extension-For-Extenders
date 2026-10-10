// Standalone extension for the existing Antistasi Ultimate Rebel purchase menu.
class CfgPatches
{
    class AVPE_Vehicles
    {
        name = "Antistasi Ultimate - Vehicle Pool Extension";
        author = "Knight Security / Vehicle Pool Extension contributors";
        units[] = {};
        weapons[] = {};
        requiredVersion = 2.14;
        requiredAddons[] = {"A3A_core", "A3A_gui", "A3A_ultimate", "cba_main"};
        version = "1.0.0";
    };
};

class CfgFunctions
{
    class AVPE
    {
        tag = "AVPE";
        class Vehicles
        {
            file = "\x\AVPE\addons\vehicles\functions";
            class postInit { postInit = 1; };
            class installCatalogue {};
            class atHQ {};
            class availability {};
            class watchBuyMenu {};
            class attachBuyMenu {};
            class installMenuHooks {};
            class populateVehicleBox {};
            class buyVehicleDialog {};
            class extendRebelDropdown {};
            class selectRebelCategory {};
            class guardMilitaryCards {};
            class buyMilitaryCard {};
            class resolveVehiclePreview {};
            class repairVehiclePreviews {};
            class diagnostics {};
            class categories { file = "\x\AVPE\addons\vehicles\data\vehicleCategories.sqf"; };
            class vehiclePools { file = "\x\AVPE\addons\vehicles\data\vehiclePools.sqf"; };
            class vehiclePrices { file = "\x\AVPE\addons\vehicles\data\vehiclePrices.sqf"; };
            class templateFilter { file = "\x\AVPE\addons\vehicles\data\templateFilter.sqf"; };
            class previewRoots { file = "\x\AVPE\addons\vehicles\data\previewRoots.sqf"; };
        };
    };
};

