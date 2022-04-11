scriptName "LND\functions\TaskFramework\fn_taskConvoy.sqf";
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

LND_fnc_generateIntel = {

	private _convoyWaypoints = waypoints (group (opfor_priorityTargets select 0));
	
	private _intel = format ["Enemy convoy moving through the area. Final destination believed to be in the vicinity of grid %1. Engage and destroy.",
		mapGridPosition (getWPPos (_convoyWaypoints select ((count _convoyWaypoints)-1)))
	];

	private _desc = format ["tsk%1", task_counter] call BIS_fnc_taskDescription;
	[
		format ["tsk%1", task_counter],
		[
			_intel,
			_desc select 1,
			_desc select 2
		]
	] call BIS_fnc_taskSetDescription;	
};

params ["_position"];

if(intel >= 4) then { systemChat "Task type: Convoy" ; };

private _taskIcon = if(intel > 0) then { "destroy" } else { "" };
private _taskTitle = if(intel > 0) then { "Destroy Hostile Convoy" } else { "Close Air Support" };
_task = [true, format ["tsk%1", task_counter], ["", _taskTitle, _position],  objNull, true, -1, true, _taskIcon] call BIS_fnc_taskCreate;

private _vehicles = [selectRandom opfor_vehicles_heavy];
for "_i" from 0 to 4 do {
	// TODO: Base vics on difficulty
	_vehicles pushback (selectRandom opfor_vehicles_unarmed);
};

// Extreme difficulty: add AAA to the convoy
if(LND_convoyDifficulty >=4) then {
	_mobileAAA = opfor_aaa select { not (_x isKindOf "Turret") };
	if(count _mobileAAA > 0) then {
		_vehicles pushback (selectRandom _mobileAAA);
	};
};


_convoyStartPos = getPos ([_position, 20000] call BIS_fnc_nearestRoad);
[
	[],							// no units
	_vehicles,	 				// vehicles
	[[_convoyStartPos, 20]],	// position whitelist 
	[],							// position blacklist
	["CON", objNull, 0],		// waypoint
	true						// spawnOnRoad
] call LND_fnc_spawnOpfor;


if(intel >= 1) then {
	[format ["tsk%1", task_counter], [opfor_priorityTargets select 0], true] call BIS_fnc_taskSetDestination;
	call LND_fnc_generateIntel;
};