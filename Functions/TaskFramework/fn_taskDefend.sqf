scriptName "LND\functions\TaskFramework\fn_taskDefend.sqf";
/*
	Author:
		Landric

	Description:
		Creates a Close Air Support task to support friendly units under attack from enemy infantry/vehicles (dependant on difficultly defined in LND_defendDifficulty)

	Parameter(s):
		None
	
	Returns:
		None

	Example Usage:
		call LND_fnc_taskDefend;
*/

LND_fnc_generateIntel = {

	params ["_distance", "_direction"];

	// Show direction only
	private "_location";
	private _composition = "#hostile forces#";
	private _danger = "";
	if(LND_intel < 2) then {
		_location = format ["#approaching# from the %1, say again our %2", _direction, toUpper _direction];
	}
	// Show direction, distance, and composition
	else {
		if(LND_intel >= 1) then {
			switch(LND_defendDifficulty) do {
				// Disabled
				case 0: { throw "Defend tasks are disabled - why are we generating one?!"; };
				// Easy - infantry and medium location
				case 1: { _composition = "#hostile# infantry" };
				// Medium - infantry and potentially danger close
				case 2: { _composition = "large volume of #hostile# infantry" };
				// Hard - more infantry and light vehicle
				case 3: { _composition = "large volume of #hostile# infantry supported by vehicle"; };
				// Extreme - large volume of infantry and up to medium vehicle
				case 4: { _composition = "extreme volume of #hostile# infantry with vehicle support"; };
				// Unknown
				default { throw format ["Unexpected Defend task difficulty: %1", LND_defendDifficulty]; };
			};
		};

		_location= format ["are approximately %1m to our %2", _distance, _direction];
	};

	if(_distance <= 500) then {
		_danger = ", danger close";
	};


	private _intelGrammar = createHashMapFromArray [
		["origin", "#request#! #composition.capitalise# #location##danger#"],
		
		["request", [
			"we need immediate air support",
			"in need of urgent CAS",
			"we are under attack from #hostile forces#",
			"we're close to being overwhelmed"
		]],
		["location", _location],
		["composition", _composition],
		["hostile forces", [
			"#hostile# forces",
			"#hostile.s#"
		]],
		["hostile", [
			"hostile",
			"enemy"
		]],
		["approaching", [
			"approaching",
			"closing in"
		]],
		["danger", _danger]
	];

	private _desc = format ["tsk%1", LND_taskCounter] call BIS_fnc_taskDescription;
	[
		format ["tsk%1", LND_taskCounter],
		[
			[_intelGrammar] call LND_fnc_parseGrammar,
			_desc select 1,
			_desc select 2
		]
	] call BIS_fnc_taskSetDescription;	
};


LND_fnc_spawnBlufor = {
	params ["_position"];

	private _blufor_group = [_position, west, (selectRandom LND_bluforInfantry)] call BIS_fnc_spawnGroup;
	private _blu_waypoint = _blufor_group addWaypoint [_position, 20];
	_blu_waypoint setWaypointType "HOLD";
	// _blufor_group enableDynamicSimulation true;
	// { _x triggerDynamicSimulation false; } forEach units _blufor_group;
	{

		if(LND_defendDifficulty <= 1) then {
			private _unit = _x;
			_contents = vestItems _unit;
			removeVest _unit;
			_unit addVest "V_Safety_yellow_F";
			{
				if(_unit canAddItemToUniform _x) then { _unit addItemToUniform _x; } else { break; };
			} forEach _contents;
		};

		// TODO: Balance the damage grace
		_x addeventhandler ["handledamage", {
			
			_dmg = switch (LND_defendDifficulty) do {
				// Disabled
				case 0: { throw "Defend tasks are disabled - why are we generating one?!"; };
				// Easy
				case 1: { (_this select 2) / 8 };
				// Medium
				case 2: { (_this select 2) / 4 };
				// Hard
				case 3: { (_this select 2) / 2 };
				// Extreme
				case 4: { (_this select 2) };
				// Unknown
				default { throw format ["Unexpected Defend task difficulty: %1", LND_defendDifficulty]; };
			};
			_dmg
		}];
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

				LND_ffIncidents = LND_ffIncidents + 1;
				
				// Scale friendly fire forgiveness based on difficulty
				if(LND_ffIncidents > (4 - LND_defendDifficulty)) then {
					["FAILED"] call LND_fnc_taskCleanup;
				};
			};
			LND_bluforUnits = LND_bluforUnits - [_unit];
			if({alive _x} count LND_bluforUnits < 1) then {
				["FAILED"] call LND_fnc_taskCleanup;
			};
		}];
	} forEach units _blufor_group;
	LND_bluforUnits append units _blufor_group;
};


// TODO: Generate urban variant of task, with blufor garrisoned in building

params ["_position"];

if(LND_intel >= 4) then { systemChat "Task type: Defend" ; };

[_position] call LND_fnc_spawnBlufor;

if (([1, 100] call BIS_fnc_randomInt) <= LND_smokeChance) then {	
	LND_smoke = LND_smokeFriendly createVehicle _position;
	LND_smoke attachTo [LND_bluforUnits select 0];
};


private _taskIcon = if(LND_intel > 0) then {"defend"} else{""};
private _taskTitle = if(LND_intel > 0) then { "Support Friendly Forces" } else { "Close Air Support" };
private _taskDest = if(LND_intel >= 2) then {[leader (LND_bluforUnits select 0), true]} else{objNull};

private _task = [true, format ["tsk%1", LND_taskCounter], ["", _taskTitle, _position], _taskDest, true, -1, true, _taskIcon] call BIS_fnc_taskCreate;

private "_direction";
private "_distance";
private _units = [];
private _vehicles = [];
switch(LND_defendDifficulty) do {

	case 0: { throw "Defend tasks are disabled - why are we generating one?!"; };
	// Easy - infantry and medium location
	case 1: {
		_distance =	selectRandom [600, 800];
		for "_i" from 0 to (_distance/100)-3 do { _units pushBack selectRandom LND_opforInfantry; };
	};
	// Medium - infantry and potentially danger close
	case 2: {
		_distance =	selectRandom [400, 600, 800, 1000];
		for "_i" from 0 to (_distance/100)-2 do { _units pushBack selectRandom LND_opforInfantry; };
	};
	// Hard - more infantry and light vehicle
	case 3: {
		_distance =	selectRandom [400, 600, 800, 1000];
		for "_i" from 0 to (_distance/100)-1 do { _units pushBack selectRandom LND_opforInfantry; };
		_vehicles pushBack selectRandom LND_opforVehiclesLight;
	};
	// Extreme - large volume of infantry and up to medium vehicle
	case 4: {
		_distance =	selectRandom [400, 600, 800, 1000, 1200];
		for "_i" from 0 to (_distance/100)+3 do { _units pushBack selectRandom LND_opforInfantry; };
		
		if([0, 1] call BIS_fnc_randomInt == 0) then {
			_vehicles pushBack selectRandom LND_opforVehiclesLight;
			_vehicles pushBack selectRandom LND_opforVehiclesLight;
		}
		else{
			_vehicles pushBack selectRandom LND_opforVehiclesMedium;
		};
		[_position] call LND_fnc_spawnBlufor;
	};
	default { throw format ["Unexpected Defend task difficulty: %1", LND_defendDifficulty]; };
};

private _loop = true;
while { _loop } do {
	private _viableDirections = ["north","east","south","west"];
	while {count _viableDirections > 0 and _loop} do {
		try {
				_direction = selectRandom _viableDirections;
				_viableDirections = _viableDirections - [_direction];
				private _opforPos = switch(_direction) do {
					case "north": { [(_position select 0),             (_position select 1) + _distance] };
					case  "east": { [(_position select 0) + _distance, (_position select 1)            ] };
					case "south": { [(_position select 0),             (_position select 1) - _distance] };
					case  "west": { [(_position select 0) - _distance, (_position select 1)            ] };
				};

				private _rotate = 0;
				if( _direction isEqualTo "east" || _direction isEqualTo "west") then {
					_rotate = 90;
				};

				[
					_units,
					_vehicles,
					[[_opforPos, [_distance, 100, _rotate, true]]], // position whitelist
					[[_position, 100]], 							// position blacklist
					["SAD", _position, 10] 							// waypoint
				] call LND_fnc_spawnOpfor;
				_loop = false;
		}
		catch {
			if(LND_intel >= 4) then { systemChat str _exception; };

			{ if(side _x == east) then {deleteVehicle _x }; } forEach allUnits;
			{ deleteVehicle _x } forEach allDead;
			{ if(not (_x in synchronizedObjects v_respawn)) then { deleteVehicle _x; }; } forEach vehicles;

			LND_opforTargets = [];
			LND_opforPriorityTargets = [];
		};
	}; //while
	if(_loop) then {
		if(LND_intel >= 4) then { systemChat "No direction from current position is viable; generating new position!"; };
		_position = [[[_position, 3000]], ["water", LND_safeZone]] call BIS_fnc_randomPos;
		{ if(!isPlayer _x) then {deleteVehicle _x }; } forEach allUnits;
		LND_bluforUnits = [];
		[_position] call LND_fnc_spawnBlufor;
		if(not isNull LND_smoke) then {
			deleteVehicle LND_smoke;
			LND_smoke = LND_smokeFriendly createVehicle _position;
			LND_smoke attachTo [LND_bluforUnits select 0];
		};
	};
	// TODO: Add a counter to the loop that causes a loud failure after a certain number of iterations
}; //while

if(LND_intel >= 1) then { [_distance, _direction] call LND_fnc_generateIntel; };