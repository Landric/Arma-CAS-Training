scriptName "LND\functions\TaskFramework\fn_newTask.sqf";
/*
	Author:
		Landric

	Description:
		Creates a task suitable for CAS

	Parameter(s):
		_this: parameters

			- required:
				-

			- optional:
				-

	Example:
		

	Returns:
		
*/

if(!isServer) exitWith { }; // TODO: Probably not needed ?Does it hinder?

task_counter = task_counter + 1;

if(intel >= 4) then { systemChat format["Generating task #%1...", task_counter]; };

// The first time newTask is called, the dayTime hasn't been set which means sunOrMoon won't work; so we need to check
// the parameter directly and compare it to local sunrise/sunset
private "_isLight";
if (task_counter == 1) then {
	_daytime = ["Daytime", 12] call BIS_fnc_getParamValue;
	_sunriseSunset = date call BIS_fnc_sunriseSunsetTime;
	_isLight = (_daytime > (_sunriseSunset select 0) and _daytime < (_sunriseSunset select 1));
}
else {
	_isLight = sunOrMoon > 0;
};

if (_isLight) then {
	smokeFriendly = "SmokeShellBlue_Infinite";
	smokeHostile = "SmokeShellRed_Infinite";
}
else {
	smokeFriendly = "B_IRStrobe";
	smokeHostile = "B_IRStrobe";
};


_whitelist = ([6000] call LND_fnc_getPlayerPositions);
_blacklist = ["water", safeZone];
_blacklist append ([700] call LND_fnc_getPlayerPositions);
_position = [_whitelist, _blacklist] call BIS_fnc_randomPos;

[_position] call selectRandom LND_taskTypes;

totalTargets = count opfor_targets;

// Spawn AA around the AO, and between the player and the zone
private _aaCorridors = [];
{
	_aaCorridors pushBack [_x, _position, 1000] call LND_fnc_createRect;
} forEach [] call LND_fnc_getPlayerPositions;



_whitelist = [];
_whitelist append _aaCorridors;
_whitelist pushBack [_position, 1000];
_blacklist = ["water", safeZone, [_position, 500]];
_blacklist append ([700] call LND_fnc_getPlayerPositions);

// TODO: Base number/chance of AA on player vehicle?

for "_i" from 0 to random 3 do {
	if(random 101 < manpadThreat) then {
		_p = [_whitelist, _blacklist] call BIS_fnc_randomPos;
		_p = [
			_p,						// centre
			0,						// minDist
			100,					// maxDist
			10,						// objDist
			0,						// waterMode (land)
			0.2,					// maxGrad
			0,						// shoreMode (land)
			_blacklist - ["water"]  // blacklist
		] call BIS_fnc_findSafePos;

		if (not (_p isEqualTo [0, 0])) then {
			_aa_group = [_p, east, selectRandom opfor_manpads] call BIS_fnc_spawnGroup;
			_aa_group setFormation "DIAMOND";

			if(intel >= 2) then {
				private _radius = switch (intel) do {
					case 2: { 200 };
					case 3: { 100 };
					default {   0 };
				};
				private _markerPos = [[[_p, _radius]]] call BIS_fnc_randomPos;
				_m = createMarkerLocal [format ["marker_aa_%1", groupId _aa_group], _markerPos];
				_m setMarkerType "o_antiair";
				if(_radius > 0) then {
					_m = createMarkerLocal [format ["marker_aa_area_%1", groupId _aa_group], _markerPos];
					_m setMarkerShapeLocal "ELLIPSE";
					_m setMarkerSizeLocal [_radius, _radius];
					_m setMarkerColorLocal "ColorEAST";
					_m setMarkerBrushLocal "DiagGrid";
					_m setMarkerAlpha 0.5;
				};
			};			
		};
	}
	else {
		break;
	};
};


_whitelist = [];
_whitelist append _aaCorridors;
_whitelist pushBack [_position, 3000];
_blacklist = ["water", safeZone, [_position, 1000]];
_blacklist append ([2000] call LND_fnc_getPlayerPositions);
if(random 101 < aaaThreat) then {
	_p = [_whitelist, _blacklist] call BIS_fnc_randomPos;
	_p = [
		_p,						// centre
		0,						// minDist
		100,					// maxDist
		10,						// objDist
		0,						// waterMode (land)
		0.2,					// maxGrad
		0,						// shoreMode (land)
		_blacklist - ["water"]  // blacklist
	] call BIS_fnc_findSafePos;
	if (not (_p isEqualTo [0, 0])) then {
		_aaa_vic = [_p, random 360, selectRandom opfor_aaa, east] call BIS_fnc_spawnVehicle;

		if(intel >= 2) then {
			private _radius = switch (intel) do {
				case 2: { 200 };
				case 3: { 100 };
				default {   0 };
			};
			private _markerPos = [[[_p, _radius]]] call BIS_fnc_randomPos;
			_m = createMarkerLocal [format ["marker_aa_%1", groupId _aa_group], _markerPos];
			_m setMarkerType "o_antiair";
			if(_radius > 0) then {
				_m = createMarkerLocal [format ["marker_aa_area_%1", groupId _aa_group], _markerPos];
				_m setMarkerShapeLocal "ELLIPSE";
				_m setMarkerSizeLocal [_radius, _radius];
				_m setMarkerColorLocal "ColorEAST";
				_m setMarkerBrushLocal "DiagGrid";
				_m setMarkerAlpha 0.5;
			};
		};
	};
};

if(count blufor_units > 0) then {
	[_position, group (blufor_units select 0)] call LND_fnc_taskIntel;
}
else {
	[_position, selectRandom ["HQ", "BLU"]] call LND_fnc_taskIntel;
};


format ["tsk%1", task_counter] call BIS_fnc_taskSetCurrent;