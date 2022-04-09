scriptName "LND\functions\LoadMods\fn_loadVehicles.sqf";
/*
	Author:
		Landric

	Description:
		Loads a predefined list of vehicles from compatible mods if they are loaded, and spawns them at predefined markers

	Parameter(s):
		_this: parameters (array of array [key (string), value (any)])

			- required:
				-

			- optional:
				-

	Example:
		call LND_fnc_loadVehicles;

	Returns:

*/

_helo_locations = [];
_plane_locations = [];
{
	private "_a";
	_a = toArray _x;
	_a resize 12;
	if (toString _a isEqualTo "marker_helo_") then {
		_helo_locations pushBack _x;
	};
	if (toString _a isEqualTo "marker_plane") then {
		_plane_locations pushBack _x;
	};
} forEach allMapMarkers;


_mod_helos = ["UK3CB_BAF_Wildcat_AH1_CAS_6A_Arctic", "UK3CB_BAF_Apache_AH1_DDPM", "RHS_UH60M_d", "RHS_MELB_AH6M", "RHS_Mi24V_vdv", "vn_b_air_ah1g_04"];
{
	if(count _helo_locations < 1) then {
		break;
	};
	_helo = _x createVehicle (getMarkerPos (_helo_locations select 0));
	if(isNull _helo) then { continue; }
	else {
		_helo setDir 68; // TODO: better to deliberately orient the spawn location in editor so that it is always north, for cross-map compatibility
		v_respawn synchronizeObjectsAdd [_helo];
		_helo_locations deleteAt 0;
	};
} forEach _mod_helos;


_mod_planes = ["RHS_Su25SM_vvs", "FIR_AV8B", "RHS_A10", "vn_b_air_f4b_navy_cas"];
{
	if(count _plane_locations < 1) then {
		break;
	};
	_plane = _x createVehicle (getMarkerPos (_plane_locations select 0));
	if(isNull _plane) then { continue; }
	else {
		_plane setDir 221; // TODO: better to deliberately orient the spawn location in editor so that it is always north, for cross-map compatibility
		v_respawn synchronizeObjectsAdd [_plane];
		_plane_locations deleteAt 0;
	};
} forEach _mod_planes;



if (["RepairOnDemand", 1] call BIS_fnc_getParamValue == 1) then {
	//_vehicles = nearestObjects [getPos player, ["helicopter", "plane"], 1000];
	{
		_x addAction [ 
			"Repair and Resupply", 
			{ 
			 _target = _this select 0;
			 _target setDamage 0;
			 _target setFuel 1;
			 _target setVehicleAmmo 1;
			 { _x setDamage 0; } forEach crew _target;
			}, 
			nil, 
			10, 
			false, 
			true 
		];
	} forEach vehicles;
};