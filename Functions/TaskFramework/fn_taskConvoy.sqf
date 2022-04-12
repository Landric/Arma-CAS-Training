scriptName "LND\functions\TaskFramework\fn_taskConvoy.sqf";
/*
	Author:
		Landric

	Description:
		Creates a Close Air Support task to destroy a concentration of vehicles (dependant on difficultly defined in LND_convoyDifficulty)

	Parameter(s):
		None
	
	Returns:
		None

	Example Usage:
		call LND_fnc_taskConvoy;
*/

LND_fnc_generateIntel = {

	private _composition = "composition unknown";
	if(LND_intel >= 1) then {
		switch(LND_convoyDifficulty) do {
			// Disabled
			case 0: { throw "Convoy tasks are disabled - why are we generating one?!"; };
			// Easy - unarmed only
			case 1: { _composition = "#unarmed#" };
			// Medium - unarmed supported by light escort
			case 2: { _composition = "#light#" };
			// Hard - armoured convoy
			case 3: { _composition = "#armoured#"; };
			// Extreme - armoured convoy, led by heavy armour, with AAA support
			case 4: { _composition = "#armoured#"; };
			// Unknown
			default { throw format ["Unexpected Convoy task difficulty: %1", LND_convoyDifficulty]; };
		};
	};
	private _convoyWaypoints = waypoints (group (LND_opforPriorityTargets select 0));
	private _destinationGrid = mapGridPosition (getWPPos (_convoyWaypoints select ((count _convoyWaypoints)-1)));
	

	private _intelGrammar = createHashMapFromArray [
		["origin", "#enemy# #convoy# #spotted# #on the move# - #composition#."+endl+"#destination.capitalise#. #engage.capitalise#"],
		
		["enemy", ["enemy", "hostile"]],
		["convoy", ["convoy", "#vehicle.s#"]],
		["vehicle", ["vehicle", "vic"]],
		["spotted", ["spotted", "reported", "seen", "observed"]],
		["on the move", ["on the move", "#traversing# the #area#"]],
		["traversing", ["traversing", "moving through", "in the vicinity of"]],
		["area", ["area", "AO", "area of operations"]],

		["composition", _composition],
		["unarmed", [
			"#supply# #vehicle.s# only"
		]],
		["supply", ["supply", "unarmed", "transport"]],
		["light", [
			"primarily #supply# #vehicle.s# with light escort",
			"armed escort of #supply# #vehicle.s#"
		]],
		["armoured", [
			"armoured column"
		]],

		["destination", [
			format ["Final destination #believed# to be in the vicinity of grid %1", _destinationGrid],
			format ["#convoy.capitalise# #believed# to be moving towards grid %1", _destinationGrid]
		]],
		["believed", ["believed", "suspected", "reported"]],

		["engage", ["engage and destroy", "ensure they don't reach their destination"]]
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

params ["_position"];

if(LND_intel >= 4) then { systemChat "Task type: Convoy" ; };

private _taskIcon = if(LND_intel > 0) then { "destroy" } else { "" };
private _taskTitle = if(LND_intel > 0) then { "Destroy Hostile Convoy" } else { "Close Air Support" };
_task = [true, format ["tsk%1", LND_taskCounter], ["", _taskTitle, _position],  objNull, true, -1, true, _taskIcon] call BIS_fnc_taskCreate;


private _vehicles = [];
switch(LND_convoyDifficulty) do {
	// Disabled
	case 0: { throw "Convoy tasks are disabled - why are we generating one?!"; };
	// Easy - unarmed only
	case 1: { for "_i" from 0 to 2 do {	_vehicles pushback (selectRandom LND_opforVehiclesUnarmed); }; };
	// Medium - unarmed supported by light escort
	case 2: {
		_vehicles pushback selectRandom LND_opforVehiclesLight;
		for "_i" from 0 to 2 do {	_vehicles pushback (selectRandom LND_opforVehiclesUnarmed); };
		_vehicles pushback selectRandom LND_opforVehiclesLight;
	};
	// Hard - armoured convoy
	case 3: { for "_i" from 0 to 3 do {	_vehicles pushback (selectRandom LND_opforVehiclesMedium); }; };
	// Extreme - armoured convoy, led by heavy armour, with AAA support
	case 4: {
		_vehicles pushback selectRandom LND_opforVehiclesHeavy;
		for "_i" from 0 to 2 do {	_vehicles pushback (selectRandom LND_opforVehiclesMedium); };
		_mobileAAA = LND_opforAAA select { not (_x isKindOf "Turret") };
		if((count _mobileAAA > 0) and (LND_aaaThreat > 0)) then {
			_vehicles pushback (selectRandom _mobileAAA);
		}
		else{
			_vehicles pushback selectRandom LND_opforVehiclesHeavy;
		};
	};
	default { throw format ["Unexpected Convoy task difficulty: %1", LND_convoyDifficulty]; };
};

private _loop = true;
while { _loop } do {
	try{
		_convoyStartPos = getPos ([_position, 20000] call BIS_fnc_nearestRoad);
		[
			[],							// no units
			_vehicles,	 				// vehicles
			[[_convoyStartPos, 20]],	// position whitelist 
			[],							// position blacklist
			["CON", objNull, 0],		// waypoint
			true						// spawnOnRoad
		] call LND_fnc_spawnOpfor;
		_loop = false;
	}
	catch{
		if(LND_intel >= 4) then { systemChat str _exception; };

		{ if(side _x == east) then {deleteVehicle _x }; } forEach allUnits;
		{ deleteVehicle _x } forEach allDead;
		{ if(not (_x in synchronizedObjects v_respawn)) then { deleteVehicle _x; }; } forEach vehicles;

		LND_opforTargets = [];
		LND_opforPriorityTargets = [];

		_position = [[[_position, 3000]], ["water", LND_safeZone]] call BIS_fnc_randomPos;
	};
	// TODO: Add a counter to the loop that causes a loud failure after a certain number of iterations
};

if(LND_intel >= 1) then {
	[format ["tsk%1", LND_taskCounter], [LND_opforPriorityTargets select 0], true] call BIS_fnc_taskSetDestination;
	call LND_fnc_generateIntel;
};