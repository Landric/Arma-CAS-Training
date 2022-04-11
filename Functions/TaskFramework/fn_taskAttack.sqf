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

LND_fnc_generateIntel = {
	
	private _intel = "Concentration of enemy troops spotted. Engage and destroy.";


	private _desc = format ["tsk%1", LND_taskCounter] call BIS_fnc_taskDescription;
	[
		format ["tsk%1", LND_taskCounter],
		[
			_intel,
			_desc select 1,
			_desc select 2
		]
	] call BIS_fnc_taskSetDescription;	
};


// TODO: Generate urban variant of task, with opfor garrisoned in building / military camp

params ["_position"];

if(intel >= 4) then { systemChat "Task type: Attack" ; };

private _taskIcon = if(intel > 0) then { "attack" } else { "" };
private _taskTitle = if(intel > 0) then { "Strike Hostile Forces" } else { "Close Air Support" };
_task = [true, format ["tsk%1", LND_taskCounter], ["", _taskTitle, _position],  objNull, true, -1, true, _taskIcon] call BIS_fnc_taskCreate;

if (([0, 100] call BIS_fnc_randomInt) < LND_smokeChance) then {	
	LND_smoke = LND_smokeHostile createVehicle _position;
};

// TODO: Vary number of units (based on difficulty?)
private _units = [];
for "_i" from 0 to 3 do {
	_units pushBack selectRandom LND_opforInfantry;
};

_vehicles = [selectRandom LND_opforVehiclesLight, selectRandom LND_opforVehiclesLight];

[
	_units,
	_vehicles,
	[[_position, 80]],
	[],
	["PAT", _position, 250]
] call LND_fnc_spawnOpfor;

if(intel >= 1) then {
	[format ["tsk%1", LND_taskCounter], _position] call BIS_fnc_taskSetDestination;
	call LND_fnc_generateIntel;
};