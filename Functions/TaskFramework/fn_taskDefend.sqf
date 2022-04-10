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

LND_fnc_generateIntel = {

	params ["_distance", "_direction"];

	private _intel = "";
	_intel = _intel +  selectRandom [
		"We need immediate air support!",
		"In need of urgent CAS!"
	];
	_intel = _intel +  " ";
	_intel = _intel +  selectRandom [
		format ["Hostiles closing in from the %1, say again our %2.", _direction, toUpper _direction],
		format ["Enemy forces are approximately %1m to our %2.", _distance, _direction]
	];
	if(_distance <= 500) then {
		_intel = _intel +  " Danger close!";
	};




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


private _taskIcon = if(intel > 0) then {"defend"} else{""};
private _taskTitle = if(intel > 0) then { "Support Friendly Forces" } else { "Close Air Support" };
private _taskDest = if(intel >= 2) then {[leader _blufor_group, true]} else{objNull};

_task = [true, format ["tsk%1", task_counter], ["", _taskTitle, _position], _taskDest, true, -1, true, _taskIcon] call BIS_fnc_taskCreate;

private "_distance";
private "_direction";

private _loop = true;
while { _loop } do {

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
			_loop = false;
	}
	catch {
		if(intel >= 4) then { systemChat str _exception; };

		{ if(side _x == east) then {deleteVehicle _x }; } forEach allUnits;
		{ deleteVehicle _x } forEach allDead;
		{ if(not (_x in synchronizedObjects v_respawn)) then { deleteVehicle _x; }; } forEach vehicles;

		opfor_targets = [];
		opfor_priorityTargets = [];
	};
}; //while

if(intel >= 2) then { [_distance, _direction] call LND_fnc_generateIntel; };