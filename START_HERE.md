# Antistasi Ultimate Vehicle Pool Extension

A standalone starter for expanding **Buy Vehicle > Rebel** with your own purchase groups and vehicle pools.

Open the [tutorial in your browser](TUTORIAL.html), or read [TUTORIAL.md](TUTORIAL.md). It covers installation, replacing demo vehicles, adding a category, faction-template integration, rebuilding, multiplayer and troubleshooting.

## Included

- A built **@Antistasi_Vehicle_Pool_Extension/addons/avpe_vehicles.pbo**.
- Editable addon source under **addons/vehicles/**.
- Sixteen starter groups, including IFVs, tanks, transport helicopters, **separate Heavy VTOL Transports and VTOL CAS**.
- Five active Arma sample vehicles, including different transport/armed Blackfish variants.
- Separate category, pool, price, template-filter and preview-root data files.
- **BUILD.cmd** for Windows and **tools/build.py** for Python 3.9+.
- Optional faction-template and new-category examples.
- Read-only in-game diagnostics and a source/package validation report.

## Quick start

1. Load the supplied **@Antistasi_Vehicle_Pool_Extension** folder alongside Antistasi Ultimate, CBA_A3 and your chosen vehicle mods, on the server and clients.
2. At HQ, open **Buy Vehicle > Rebel** and scroll down the dropdown.
3. Replace sample classes in **addons/vehicles/data/vehiclePools.sqf**, and edit prices/categories as needed.
4. Run **BUILD.cmd** or **python tools/build.py**, distribute the rebuilt PBO and restart Arma/server.

The five demo vehicles and example prices are active by default. Remove/replace their pool and price rows for your own release. This starter does not require Kraken Hunter or Knight Security vehicle/faction addons.

Use one copy of this vehicle-menu module. An extender containing the original Kraken Hunter vehicle-menu module should replace its original module when adopting this standalone one; both use the same native content-control IDs.

The included PBO is unsigned. Source/data/path checks passed; this standalone adaptation has not been run in Arma 3 here. See **VALIDATION.json** for the precise checks.

