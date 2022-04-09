scriptName "LND\functions\TaskFramework\fn_taskDefend.sqf";
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

// TODO: Generate urban variant of task, with blufor garrisoned in building

params ["_position"];

if(intel >= 4) then { systemChat "Task type: Defend" ; };

// TODO: Parameterise BLUFOR faction
_blufor_group = [_position, west, (selectRandom blufor_infantry)] call BIS_fnc_spawnGroup;
_blu_waypoint = _blufor_group addWaypoint [_position, 10];
_blu_waypoint setWaypointType "HOLD";
// _blufor_group enableDynamicSimulation true;
// { _x triggerDynamicSimulation false; } forEach units _blufor_group;
{
	// TODO: Balance the damage grace
	_x addeventhandler ["handledamage",{ (_this select 2) / 2}];
	_x addEventHandler ["Killed", {
		params ["_unit", "_killer"];
		if(isPlayer _killer) then {
			private _ffString = format ["%1, BLUE ON BLUE, SAY AGAIN, BLUE ON BLUE, THOSE ARE FRIENDLIES!", toUpper LND_playerCallsign];
			if (isNull leader _unit || not alive leader _unit) then {
				[west, "HQ"] sideChat _ffString;
			}
			else{
				leader _unit sideChat _ffString;
			};
			
			// TODO: Keep track of number of friendly kills (per task); only fail on repeat
			["FAILED"] call LND_fnc_taskCleanup;
		};
		blufor_units = blufor_units - [_unit];
		if({alive _x} count blufor_units < 1) then {
			["FAILED"] call LND_fnc_taskCleanup;
		};
	}];
} forEach units _blufor_group;
blufor_units append units _blufor_group;

if (random 101 < smokeChance) then {	
	smoke = smokeFriendly createVehicle _position;
	smoke attachTo [leader _blufor_group];
	// TODO: Update on leader death?
};


private _taskIcon = if(intel < 2) then {""} else{"defend"};
_task = [true, format ["tsk%1", task_counter], ["", "Defend Friendlies", _position], [leader _blufor_group, true], true, -1, true, _taskIcon] call BIS_fnc_taskCreate;


while { true } do {

	try {
			_distance =	selectRandom [400, 600, 800, 1000];
			_direction = selectRandom ["north","east","south","west"];
			_opforPos = switch(_direction) do {
				case "north": { [(_position select 0),             (_position select 1) + _distance] };
				case  "east": { [(_position select 0) + _distance, (_position select 1)            ] };
				case "south": { [(_position select 0),             (_position select 1) - _distance] };
				case  "west": { [(_position select 0) - _distance, (_position select 1)            ] };
			};

			_rotate = 0;
			if( _direction isEqualTo "east" || _direction isEqualTo "west") then {
				_rotate = 90;
			};

			private _units = [];
			for "_i" from 0 to (_distance/100)-1 do {
				_units pushBack selectRandom opfor_infantry;
			};
			[
				_units,
				[], 											// no vehicles
				[[_opforPos, [_distance, 100, _rotate, true]]], // position whitelist
				[[_position, 100]], 							// position blacklist
				["SAD", _position, 10] 							// waypoint
			] call LND_fnc_spawnOpfor;
	}
	catch {
		// TODO: Suppress this before release
		systemChat str _exception;

		{ if(side _x == east) then {deleteVehicle _x }; } forEach allUnits;
		{ deleteVehicle _x } forEach allDead;
		{ if(not (_x in synchronizedObjects v_respawn)) then { deleteVehicle _x; }; } forEach vehicles;

		opfor_targets = [];
		opfor_priorityTargets = [];
	};
	break;
}; //while