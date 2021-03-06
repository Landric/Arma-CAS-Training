scriptName "LND\functions\LoadMods\fn_loadVehicles.sqf";
/*
	Author:
		Landric

	Description:
		Loads a predefined list of vehicles from compatible mods if they are loaded, and spawns them at predefined markers

	Parameter(s):
		None
	
	Returns:
		None

	Example Usage:
		call LND_fnc_loadVehicles;
*/


LND_fnc_addVehicleScripts = {
	params ["_vehicle"];

	LND_playerVehicles pushBack _vehicle;

	_vehicle setVariable ["_respawnPos", getPos _vehicle];
	_vehicle setVariable ["_respawnDir", getDir _vehicle];
	
	_vehicle addEventHandler ["Killed", {
		params ["_unit", "_killer", "_instigator", "_useEffects"];
		{ _x setDamage 0; _x setPos getMarkerPos "respawn_start"; } forEach crew _unit;
		_unit setPos [0,0,0];
		_type = typeOf _unit;
		_pos = _unit getVariable "_respawnPos";
		_dir = _unit getVariable "_respawnDir";
		deleteVehicle _unit;
		LND_playerVehicles = LND_playerVehicles - [objNull];

		[_type, _pos, _dir] spawn {
			params ["_type", "_pos", "_dir"];
			sleep 0.5;
			_v = _type createVehicle _pos;
			_v setDir _dir;
			[_v] call LND_fnc_addVehicleScripts;
		};
	}];

	if (["RepairOnDemand", 1] call BIS_fnc_getParamValue == 1) then {
		_vehicle addAction [ 
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
	};
	
};



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


_mod_helos = ["UK3CB_BAF_Wildcat_AH1_CAS_6A_Arctic", "UK3CB_BAF_Apache_AH1_DDPM", "RHS_UH60M_d", "RHS_MELB_AH6M", "RHS_Mi24V_vdv", "RHS_Ka52_vvsc", "vn_b_air_ah1g_04", "ls_cis_hmp", "lsd_heli_laati", "Deffkopta_02_1"];
{
	if(count _helo_locations < 1) then {
		break;
	};
	_helo = _x createVehicle (getMarkerPos (_helo_locations select 0));
	if(isNull _helo) then { continue; }
	else {
		_helo setDir 68; // TODO: better to deliberately choose the spawn location in editor so that it is always (say) north, for cross-map compatibility
		_helo_locations deleteAt 0;
	};
} forEach _mod_helos;


_mod_planes = ["RHS_Su25SM_vvs", "FIR_AV8B", "RHS_A10", "vn_b_air_f4b_navy_cas", "ML700_Avenger_BLU", "TIOW_Valkyrie_Rocket_M_B"];
{
	if(count _plane_locations < 1) then {
		break;
	};
	_plane = _x createVehicle (getMarkerPos (_plane_locations select 0));
	if(isNull _plane) then { continue; }
	else {
		_plane setDir 221; // TODO: better to deliberately choose the spawn location in editor so that it is always (say) south, for cross-map compatibility
		_plane_locations deleteAt 0;
	};
} forEach _mod_planes;


// AC130 gets its own special spot, 'cos its a big boi
// TODO: Make generic for "large vehicles"
_ac130 = "USAF_AC130U" createVehicle (getMarkerPos "marker_ac130");
if(not isNull _ac130) then {
	_ac130 setDir 221; // TODO: better to deliberately choose the spawn location in editor so that it is always (say) west, for cross-map compatibility
};


{
	[_x] call LND_fnc_addVehicleScripts;
} forEach vehicles;
