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
	
	private _intelString = "Concentration of enemy troops spotted. Engage and destroy.";


	private _desc = format ["tsk%1", LND_taskCounter] call BIS_fnc_taskDescription;
	[
		format ["tsk%1", LND_taskCounter],
		[
			_intelString,
			_desc select 1,
			_desc select 2
		]
	] call BIS_fnc_taskSetDescription;	
};


// TODO: Generate urban variant of task, with opfor garrisoned in building / military camp

params ["_position"];

if(LND_intel >= 4) then { systemChat "Task type: Attack" ; };

private _taskIcon = if(LND_intel > 0) then { "attack" } else { "" };
private _taskTitle = if(LND_intel > 0) then { "Strike Hostile Forces" } else { "Close Air Support" };
private _task = [true, format ["tsk%1", LND_taskCounter], ["", _taskTitle, _position],  objNull, true, -1, true, _taskIcon] call BIS_fnc_taskCreate;

if (([1, 100] call BIS_fnc_randomInt) <= LND_smokeChance) then {	
	LND_smoke = LND_smokeHostile createVehicle _position;
};


private _units = [selectRandom LND_opforInfantry, selectRandom LND_opforInfantry, selectRandom LND_opforInfantry];
private _vehicles = [];
private _radius = 80;
switch(LND_attackDifficulty) do {
	// Disabled
	case 0: { throw "Attack tasks are disabled - why are we generating one?!"; };
	// Easy - infantry only
	case 1: { };
	// Medium - infantry and (up to) a pair of light vehicles
	case 2: {
		_vehicles pushback selectRandom LND_opforVehiclesLight;
		if([0, 1] call BIS_fnc_randomInt == 1) then {
			_units pushBack selectRandom LND_opforInfantry;
		}
		else {
			_vehicles pushback selectRandom LND_opforVehiclesLight;
		};
	};
	// Hard - more infantry, supported by a medium or (rarely) heavy vehicle 
	case 3: {
		_radius = 120;
		_units pushBack selectRandom LND_opforInfantry;
		if([0, 4] call BIS_fnc_randomInt < 4) then {
			_vehicles pushback selectRandom LND_opforVehiclesMedium;
		}
		else{
			_vehicles pushback selectRandom LND_opforVehiclesHeavy;
		};
	};
	// Extreme - even more infantry, supported by a pair of medium vehicles or a heavy vehicle or (if not disabled) triple-A
	case 4: {
		_radius = 200;
		for "_i" from 0 to 2 do { _units pushBack selectRandom LND_opforInfantry; };
		switch([0, 4] call BIS_fnc_randomInt) do {
			case 0;
			case 1: { for "_i" from 0 to 1 do { _vehicles pushback selectRandom LND_opforVehiclesMedium; }; };
			case 2;
			case 3: { _vehicles pushback selectRandom LND_opforVehiclesHeavy; };
			case 4: {
				if(LND_aaaThread > 0) then {
					_vehicles pushback selectRandom LND_opforAAA;
				}
				else {
					for "_i" from 0 to 1 do { _vehicles pushback selectRandom LND_opforVehiclesHeavy; };
				};
			};
		};
		
	};
	default { throw format ["Unexpected Attack task difficulty: %1", LND_attackDifficulty]; };
};

[
	_units,
	_vehicles,
	[[_position, _radius]],
	[],
	["PAT", _position, 250]
] call LND_fnc_spawnOpfor;

if(LND_intel >= 1) then {
	[format ["tsk%1", LND_taskCounter], _position] call BIS_fnc_taskSetDestination;
	call LND_fnc_generateIntel;
};