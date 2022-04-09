scriptName "LND\functions\TaskFramework\fn_taskAttack.sqf";
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

// TODO: Generate urban variant of task, with opfor garrisoned in building

params ["_position"];


private _taskIcon = "";
if(intel > 1) then { _taskIcon = "attack" };
_task = [true, format ["tsk%1", task_counter], ["", "Attack Hostiles", _position],  objNull, true, -1, true, _taskIcon] call BIS_fnc_taskCreate;

if (random 101 < smokeChance) then {	
	smoke = smokeHostile createVehicle _position;
};

// TODO: Vary number of units (based on difficulty?)
private _units = [];
for "_i" from 0 to 3 do {
	_units pushBack selectRandom opfor_infantry;
};

[
	_units,
	[selectRandom opfor_vehicles_light],
	[[_position, 100]],
	[],
	["PAT", _position, 100]
] call LND_fnc_spawnOpfor;

if(intel > 0) then {
	[format ["tsk%1", task_counter], [opfor_priorityTargets select 0, true]] call BIS_fnc_taskSetDestination;
};

// TODO: Use get SAFE position to avoid stacking vehicles
