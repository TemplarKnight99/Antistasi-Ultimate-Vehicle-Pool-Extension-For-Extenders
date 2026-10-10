# Implementing your own Antistasi Ultimate vehicle purchase pools

This starter adds configurable groups to the existing **Buy Vehicle > Rebel** dropdown. Antistasi continues to render the vehicle cards and handle prices, purchase payment, placement and garage systems.

Use the built addon as a separate mod, or include its PBO in your own extender. The source runs under its own **AVPE** namespace and does not require the Kraken Hunter template addon.

The native integration is adapted from the supplied working Kraken Hunter vehicle module, whose earlier documentation targeted Antistasi Ultimate 12.0.3. That is the compatibility baseline; this standalone adaptation has not been run in Arma 3 here.

## 1. Install and check the sample groups

Extract this ZIP somewhere you can keep the editable source. The loadable mod is the **@Antistasi_Vehicle_Pool_Extension** folder. Its **addons** directory already contains **avpe_vehicles.pbo**.

Add the **@ folder** as a local mod in Arma 3 Launcher. Load it with Antistasi Ultimate, CBA_A3, your faction extender if applicable, and the vehicle addons whose classes you use.

For multiplayer, load the same PBO on the dedicated server **and every client** using the normal mod list. A server-only load cannot supply the client purchase-menu scripts. Headless clients that run the mission should use the same mod set.

At HQ, within 35 metres of Petros, open **Buy Vehicle > Rebel**. Scroll below the original Rebel categories. The starter appends sixteen groups; empty groups remain available for future additions.

Five demonstration vehicles are active:

| Group | Demo classname | Example base price | Tier | Airport |
| --- | --- | ---: | ---: | --- |
| Rebel IFVs | B_APC_Wheeled_01_cannon_F | 25,000 | 5 | No |
| Rebel Tanks | B_MBT_01_cannon_F | 75,000 | 6 | No |
| Rebel Transport Helicopters | B_Heli_Transport_01_F | 45,000 | 6 | No |
| Rebel Heavy VTOL Transports | B_T_VTOL_01_vehicle_F | 90,000 | 6 | Yes |
| Rebel VTOL CAS | B_T_VTOL_01_armed_F | 110,000 | 6 | Yes |

These prices demonstrate the format; choose your own campaign balance. The Blackfish vehicles are Apex content, and native DLC restrictions still apply. Tier/airport requirements can leave a card visible but locked.

The two VTOL variants deliberately occupy **separate categories and arrays**.

## 2. Know which files to edit

| File under addons/vehicles/data/ | Purpose |
| --- | --- |
| vehicleCategories.sqf | Category key, dropdown label, unlock rules and fallback costs. |
| vehiclePools.sqf | Classnames supplied directly by this addon. |
| vehiclePrices.sqf | Optional explicit base prices, one per class. |
| templateFilter.sqf | Restricts addon-managed pools/prices to selected rebel templates. |
| previewRoots.sqf | Optional fallback image folders inside loaded vehicle addons. |

**examples/faction_template_vehicle_pools.sqf** shows the alternative of defining pools in your own faction template. **tools/build.py** validates configuration and builds the PBO.

Data files return literal SQF arrays. Use double quotes around strings, true/false for flags, and commas between rows. The last row has no trailing comma. Comments are allowed. Put conditional/script logic in functions rather than these declarative files.

**The addon reads the packed data inside the PBO. Editing loose source files alone does not change the installed mod. Rebuild and replace the PBO after each change.**

## 3. Replace sample vehicles with your own

Open **vehiclePools.sqf**. Each row contains a category key and its classnames:

~~~sqf
[
    ["vehiclesIFV", ["YourMod_IFV_01", "YourMod_IFV_02"]],
    ["vehiclesTank", ["YourMod_Tank_01"]],
    ["vehiclesMilitaryHeliTransport", ["YourMod_TransportHeli_01"]],
    ["vehiclesMilitaryVTOLHeavyTransport", ["YourMod_TransportVTOL_01"]],
    ["vehiclesMilitaryVTOLCAS", ["YourMod_CASVTOL_01"]]
]
~~~

The **YourMod_...** names are placeholders. Replace them with **real CfgVehicles classnames**, not display names. Find a class in Eden's Config Viewer, or inspect **typeOf** for an actual selected vehicle in the debug console. Load the relevant vehicle addon on server and clients.

A key must exactly match a row in **vehicleCategories.sqf**. For example, vehiclesIFV differs from vehiclesIFVs. Unknown keys are rejected by the build tool.

To clear an addon-managed pool, use an empty array:

~~~sqf
["vehiclesMilitaryVTOLCAS", []]
~~~

To remove all demo pools while using faction-template pools, make the entire **vehiclePools.sqf** result **[]**. Also clear the demo price rows so they no longer override native/template prices.

A class can belong to several categories. It appears once within each category, and the extension avoids adding duplicate class cards to All Rebel. One class has one shared base price/resource cost/threat; separate categories do not give the same class independent prices.

Missing classes are skipped with an **[AVPE Vehicles]** RPT message. Vehicle assets are supplied by their original addons.

## 4. Set prices and unlock rules

Open **vehiclePrices.sqf** for explicit class prices:

~~~sqf
[
    ["YourMod_IFV_01", 42000],
    ["YourMod_TransportVTOL_01", 95000],
    ["YourMod_CASVTOL_01", 125000]
]
~~~

Use one positive price row per class. Delete a row to use faction/native pricing instead.

Base-price priority is:

1. An explicit vehiclePrices.sqf row, when the template filter allows it.
2. A merged faction rebCost attribute.
3. An existing server class price.
4. The category fallback price.

Faction attributes merge in the inherited native order: rebels, occupants, invaders. Resource costs and threats prefer faction attributes, then existing native maps, then category defaults.

The quote still uses **A3A_fnc_vehiclePrice**. Native discounts and price comparisons can make it differ from your base value.

Every category row has eight fields:

~~~sqf
["vehiclesIFV", "Rebel IFVs", 5, false, 1000, 150, 200, ["vehiclesIFVs", "vehiclesArmor"]]
~~~

| Position | Meaning |
| ---: | --- |
| 1 | Unique category/template key. |
| 2 | Exact dropdown label; also unique. |
| 3 | Minimum war tier, as an integer. |
| 4 | true requires an owned airport. |
| 5 | Positive fallback base price. |
| 6 | Nonnegative fallback resource cost. |
| 7 | Nonnegative fallback ground-threat value. |
| 8 | Additional native aggregate asset-list keys, or []. |

The inherited rule also requires an airport for **any actual Plane subclass**, including VTOL planes, even if field 4 is false. Helicopters do not automatically get this plane requirement.

Each valid class enters its category and vehiclesReb. Actual helicopters also enter vehiclesHelis; actual planes enter vehiclesFixedWing. Field 8 adds further classification lists such as armour/UAV lists. These lists influence native asset classification, so choose keys appropriate to your vehicles.

## 5. Add an entirely new category

This example creates a logistics group.

Insert a row into the array in **vehicleCategories.sqf**:

~~~sqf
["vehiclesMyLogistics", "Rebel Logistics", 3, false, 12000, 50, 0, []]
~~~

Add its matching row in **vehiclePools.sqf**:

~~~sqf
["vehiclesMyLogistics", ["B_Truck_01_transport_F", "B_Truck_01_repair_F"]]
~~~

Optionally insert price rows in **vehiclePrices.sqf**:

~~~sqf
["B_Truck_01_transport_F", 12000],
["B_Truck_01_repair_F", 18000]
~~~

These are rows to insert, not complete replacement files. Add/remove surrounding commas accordingly.

Choose unique keys and labels. A label already used by the loaded native dropdown is logged and skipped. **A new group needs no separate label file, GUI registration, stringtable modification or edit to native Antistasi files.**

Rebuild, install the new PBO and restart game/server. The new group uses the same Rebel dropdown.

## 6. Integrate with your faction template

This route is useful when your extender already owns the faction's vehicle arrays.

Inside your own **rebel template SQF**, save arrays using Antistasi's **_fnc_saveToTemplate**. For separate VTOL roles:

~~~sqf
private _myTransportVTOLs = ["YourMod_TransportVTOL_01"];
private _myCASVTOLs = ["YourMod_CASVTOL_01"];

["vehiclesMilitaryVTOLHeavyTransport", _myTransportVTOLs] call _fnc_saveToTemplate;
["vehiclesMilitaryVTOLCAS", _myCASVTOLs] call _fnc_saveToTemplate;
~~~

**_fnc_saveToTemplate** is supplied while Antistasi loads the faction template. Put these lines in that template, rather than ordinary mission init.sqf or an unrelated postInit.

The example file also demonstrates IFV, tank and transport-helicopter keys. If a key is already saved, update its existing array/registration instead of saving it twice.

The extension combines the selected faction's same-named saved arrays with its **vehiclePools.sqf** rows. To use only template lists, clear the demo addon pools and price overrides.

You can retain your existing faction vehicle attributes for pricing:

~~~sqf
["attributesVehicles", [
    ["YourMod_IFV_01", ["rebCost", 42000], ["cost", 150], ["threat", 200]]
]] call _fnc_saveToTemplate;
~~~

Merge this row into the template's **existing** attributes array/include. Replacing the entire attributesVehicles registration would remove other entries.

For a new template-owned group, register its key and add its category row. It does not also need a vehiclePools.sqf row.

### Restrict addon-managed pools to your faction

**templateFilter.sqf** defaults to **[]**, enabling addon-managed pools and price overrides for every rebel template.

To apply those files only to selected factions, return their **registered template IDs**:

~~~sqf
["MyFaction_Desert", "MyFaction_Woodland"]
~~~

Use the ID, not the display name. Diagnostics report the selected **A3A_Reb_template** value.

The filter controls addon-managed pools/prices only. A faction's own saved category arrays are still read. If no faction/addon pool provides any valid vehicle, extra categories are not attached.

## 7. Build and include it in your extender

The ZIP already includes a PBO. To rebuild after edits, install Python **3.9 or newer**. No Python packages or Arma build tools are needed for this text-config build.

On Windows, double-click **BUILD.cmd**, or run from the extracted project folder:

~~~bat
py -3 tools\build.py --check
py -3 tools\build.py
~~~

On Linux/macOS:

~~~bash
python3 tools/build.py --check
python3 tools/build.py
~~~

**--check** validates without changing the PBO. A normal build checks data formats, keys, duplicate prices, brackets and function paths, then writes:

**@Antistasi_Vehicle_Pool_Extension/addons/avpe_vehicles.pbo**

**VALIDATION.json** describes source/package checks. These are not full SQF compilation or gameplay tests.

### Include the PBO in an existing extender

Copy **avpe_vehicles.pbo** into your extender's loadable **@YourExtender/addons/** directory alongside its faction/other PBOs. Keep this starter's source/tools as an editable build project, and copy over the rebuilt PBO after changes.

The addon has its own **CfgPatches/AVPE_Vehicles** and **AVPE_fnc_*** registrations.

Load one copy of this module. An extender with the original Kraken Hunter vehicle menu should replace its old **vehicles.pbo** when adopting this one. Loading both causes duplicate integration and content-control ID collisions.

### Use another PBO builder

Pack **addons/vehicles** as the addon root. Include config.cpp, the functions and data files. Set the prefix to:

~~~text
x\AVPE\addons\vehicles
~~~

**$PBOPREFIX$** stores this prefix for compatible builders. The bundled builder embeds it directly. This is the virtual path used by CfgFunctions, not a physical folder path on your computer.

The included build is **uncompressed and unsigned**, with a text config.cpp, prefix metadata and SHA-1 trailer. If your server requires signed mods, sign the final PBO with your own key using Arma 3 Tools, distribute its **.bisign**, and install the corresponding public **.bikey** on the server. Re-sign after rebuilding.

Restart Arma on clients and restart the dedicated server after replacing PBOs. The catalogue is created during mission initialization; edits to loose source or a running mission's arrays do not automatically rebuild it.

## 8. Verify your release in game

Use a test campaign to check:

1. Categories appear once, including after changing tabs and reopening the menu.
2. IFV/tank cards show their own native previews.
3. Heavy VTOL Transports and VTOL CAS display their independently configured vehicles.
4. Tier/airport requirements lock and unlock the relevant custom cards.
5. An eligible vehicle is not added twice to All Rebel.
6. Purchases use normal payment and placement; cancellation, insufficient funds and garage storage behave as expected.
7. Server and joining client see matching groups/classes.
8. Save/reload and respawn preserve normal Antistasi behavior.

The HQ guard requires a living actual rebel player within 35 metres of Petros. Purchases call native **A3A_fnc_addFIAveh**, using Antistasi's currency and vehicle initialization.

## 9. Diagnose common problems

Run locally in the in-game debug console:

~~~sqf
call AVPE_fnc_diagnostics;
~~~

This returns a read-only summary and logs it to the local RPT. It can also report catalogue state when run on a dedicated server. It shows addon version, rebel template, readiness, counts, class/price availability, menu status and preview repairs.

| Symptom | Check |
| --- | --- |
| Dependency error | Antistasi Ultimate and CBA are loaded. |
| Menu unchanged | Correct PBO loaded on server/client; catalogueReady, menuAdaptersInstalled and RPT messages. |
| No valid catalogue | Correct classes, loaded vehicle mods, matching filter or saved template keys. |
| Empty group | Category/pool/template keys match exactly, and classes exist. |
| Grey card | Tier, airport ownership, HQ position and synchronized positive price. |
| Old vehicles/prices | Rebuild, replace the PBO on every machine, then restart. |
| Missing category label | Label collision or native dialog layout changed. |
| Missing preview | Packed editorPreview image exists; optionally configure preview roots. |
| Control-ID collision | Another module/copy created controls 7191/7192. |
| Failure after Ultimate update | Native callback names/layout changed; inspect the adapters below. |

### Optional preview roots

If your vehicle addon moved its pictures, return virtual addon folders from **previewRoots.sqf**:

~~~sqf
["\MyFaction\Preview\", "\MyLegacyFaction\Preview\"]
~~~

These are addon paths, not Windows C:\ paths. Each starts/ends with a backslash. The configured editorPreview is tried first; fallbacks try its filename and then the exact classname with JPG/PAA extensions. The actual images must be included in a loaded vehicle addon.

## 10. Where the integration lives

- **fn_installCatalogue.sqf** builds the server catalogue, class prices/costs and native asset lists.
- **fn_postInit.sqf** waits for Antistasi initialization and synchronizes clients/JIP.
- **fn_installMenuHooks.sqf** wraps loaded SCRT_fnc_ui_populateVehicleBox and A3A_fnc_buyVehicleDialog, retaining original delegates.
- **fn_attachBuyMenu.sqf / fn_extendRebelDropdown.sqf** attach content groups and labels.
- **fn_selectRebelCategory.sqf** calls native A3A_fnc_buyVehicleTabs for cards.
- **fn_populateVehicleBox.sqf** supplies native [classname, price, undercover] rows.
- **fn_guardMilitaryCards.sqf / fn_buyMilitaryCard.sqf** use the selected category's requirements and native purchase/placement.
- Preview functions use configured/optional roots with no faction-specific paths.

The adapters expect native **A3A_BuyVehicleDialog** controls named TabButtons, VehicleTabCombo, rebelVehicleTab and VehiclesControlsGroup, plus the native card/control styles. Missing callbacks/layout or occupied content IDs are logged. A different GUI or Antistasi edition may require adapter changes.

Normal category/pool additions do not require changing these functions.

## Reference links

- [Antistasi Ultimate source](https://github.com/Antistasi-Ultimate-Community/A3-Antistasi-Ultimate)
- [Extender project linked by Antistasi Ultimate](https://github.com/Westalgie/A3UExtender)
- [Arma 3 addon creation](https://community.bistudio.com/wiki/Arma_3:_Creating_an_Addon)
- [CfgPatches and requiredAddons](https://community.bistudio.com/wiki/CfgPatches)
- [Addon prefixes](https://community.bistudio.com/wiki/PBOPREFIX)
- [Arma 3 WEST class list](https://community.bistudio.com/wiki/Arma_3_CfgVehicles_WEST)

