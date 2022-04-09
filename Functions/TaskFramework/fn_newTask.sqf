scriptName "LND\functions\Utilities\fn_newTask.sqf";
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

LND_fnc_taskDefend = {

	// TODO: Generate urban variant of task, with blufor garrisoned in building

	params ["_position"];

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
		smoke attachTo leader _blufor_group;
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

}; //LND_fnc_taskDefend

LND_fnc_taskAttack = {

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
	

}; //LND_fnc_taskAttack

LND_fnc_taskConvoy = {

	// Get road closest to position
	// Spawn vehicles - softskin trucks for easy, mraps for medium, apcs for hard
	// Pick another point several kilometers away - road (or town?)
	// Assign waypoint
	// Task fails if convoy ever gets to that waypoint - although I doubt it will
};


LND_fnc_taskCleanup = {
	params ["_state"];

	if(!isServer) exitWith { }; // TODO: is this needed? Does it hinder?

	if (not (format ["tsk%1", task_counter] call BIS_fnc_taskCompleted)) then {
	
		[format ["tsk%1", task_counter], _state] call BIS_fnc_taskSetState;	

		{ if(!isPlayer _x) then {deleteVehicle _x }; } forEach allUnits;
		{ deleteVehicle _x } forEach allDead;
		{ if(not (_x in synchronizedObjects v_respawn)) then { deleteVehicle _x; }; } forEach vehicles;
		if(not isNull smoke) then {	deleteVehicle smoke; };

		{
			private "_a";
			_a = toArray _x;
			_a resize 9;
			if (toString _a isEqualTo "marker_aa") then {
				deleteMarker _x;
			};
		} forEach allMapMarkers;

		opfor_targets = [];
		opfor_priorityTargets = [];
		blufor_units = [];

		[] spawn {
			sleep 3;
			call LND_fnc_newTask;
		};
	};

}; //LND_fnc_taskCleanup

LND_fnc_taskSuccessCheck = {
	if({canFire _x || canMove _x} count opfor_priorityTargets <= 0 and (({alive _x} count opfor_targets) / totalTargets < (100-completionPercent)/100)) then {
		["SUCCEEDED"] call LND_fnc_taskCleanup;
	};
};

LND_fnc_spawnOpfor = {

	params ["_groups", "_vehicles", "_whitelist", "_blacklist"];
	private _waypoint = param [4, []]; // Expected [Type, location, radius]

	_blacklist append ["water", safeZone];

	{ //forEach _groups
		// TODO: Replace with get SAFE pos
		_p = [_whitelist, _blacklist] call BIS_fnc_randomPos; 

		if (_p isEqualTo [0, 0]) then {
			throw "Invalid OPFOR position generated";
		};

		_opfor_group = [_p, east, _x] call BIS_fnc_spawnGroup;
		// TODO: Balance "Defend" missions so that player has enough time to respond before Blufor are wiped out,
		// or enable the line below
		// _opfor_group enableDynamicSimulation true;

		if(count _waypoint > 0) then {
			if(count _waypoint != 3) then { throw format ["Unexpected waypoint passed to spawnOpfor: %1", _waypoint]};

			if(_waypoint select 0 isEqualTo "PAT") then {
				//[_x, _waypoint select 1, _waypoint select 2] call BIS_fnc_taskPatrol; // Didn't seem to work?
				[_opfor_group] call LND_fnc_doPatrol;
			}
			else {
				_op_waypoint = _opfor_group addWaypoint [_waypoint select 1, _waypoint select 2];
				_op_waypoint setWaypointType _waypoint select 0;
				if((_waypoint select 0) isEqualTo "SAD") then {
					_opfor_group setCombatMode "RED";
				};
			};
		};

		{ //forEach units _opfor_group
			_x addEventHandler ["Killed", {
				params ["_unit", "_killer"];
				
				opfor_targets = opfor_targets - [_unit]; // Unneeded if we only count alive units; then again, this might make that count faster?
				
				if(({alive _x} count units _unit) <= 0) then {
					// TODO: Add a check if this task exists?
					[format ["tsk%1_%2", task_counter, groupId (group _unit)], "SUCCEEDED"] call BIS_fnc_taskSetState;
				}
				else{
					if(leader group _unit == _unit) then {
						//The leader is dead (long live the leader)
						[group _unit, _unit] spawn {
							params ["_group", "_prevLeader"];
							waitUntil {
								sleep 1;
								//Checking leader...
								(leader _group != _prevLeader) or isNull _group
							};
							//A new leader has arisen!
							if(not isNull _group) then {
								[format ["tsk%1_%2", task_counter, groupId _group], leader _group] call BIS_fnc_taskSetDestination;
							};
							
						};
					};
				};
				call LND_fnc_taskSuccessCheck;
			}];
		} forEach units _opfor_group;
		opfor_targets append units _opfor_group;
		
		if(intel >= 3) then {
			_task = [true, [format ["tsk%1_%2", task_counter, groupId _opfor_group], format ["tsk%1", task_counter]], ["", "Destroy Hostiles", _p], [leader _opfor_group, true], "CREATED", -1, false, "destroy"] call BIS_fnc_taskCreate;
		};
	} forEach _groups;

	{
		// TODO: Use SAFE position
		// TODO: Add "Killed" event handlers
		_v = [_position, random 360, _x, east] call BIS_fnc_spawnVehicle;
		_v = _v select 0;
		//_v setUnloadInCombat [false, false];
		_v addEventHandler ["Hit", {
			params ["_unit", "_source", "_damage", "_instigator"];
			call LND_fnc_taskSuccessCheck;
		}];
		_v addEventHandler ["Killed", {
			params ["_unit", "_killer", "_instigator", "_useEffects"];
			call LND_fnc_taskSuccessCheck;
		}];

		opfor_priorityTargets pushBack _v;

		if(intel >= 3) then {
			_task = [true, [format ["tsk%1_%2", task_counter, groupId group _v], format ["tsk%1", task_counter]], ["", "Destroy Hostiles", _position], [_v, true], "CREATED", -1, false, "destroy"] call BIS_fnc_taskCreate;
		};
	} forEach _vehicles;

}; //LND_fnc_spawnOpfor


///////////////////
// Generate Task //
///////////////////

if(!isServer) exitWith { }; // TODO: Probably not needed ?Does it hinder?

task_counter = task_counter + 1;

// The first time newTask is called, the dayTime hasn't been set which means sunOrMoon won't work; so we need to check
// the parameter directly and compare it to local sunrise/sunset
private "_isLight";
if (task_counter == 0) then {
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
	_p = [[_corridor, [_position, 1000]], _blacklist-["water"]] call BIS_fnc_randomPos;
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