
LND_smokeChance = ["LND_smoke", 60] call BIS_fnc_getParamValue;
intel = ["Intel", 2] call BIS_fnc_getParamValue;
manpadThreat = ["MANPAD", 10] call BIS_fnc_getParamValue;
aaaThreat = ["AAA", 0] call BIS_fnc_getParamValue;
completionPercent = ["Completion", 80] call BIS_fnc_getParamValue;

safeZone = [getMarkerPos "respawn_start", 1500];
LND_playerCallsign = selectRandom ["Hornet", "Banshee", "Shriek", "Thunderfoot", "Hammer", "Big-Bird", "Alchemist"];


LND_attackDifficulty = ["MissionAttack", 2] call BIS_fnc_getParamValue;
LND_defendDifficulty = ["MissionDefend", 2] call BIS_fnc_getParamValue;
LND_convoyDifficulty = ["MissionConvoy", 1] call BIS_fnc_getParamValue;

LND_taskTypes = [];
// if(LND_attackDifficulty >= 1) then { LND_taskTypes pushBack LND_fnc_taskAttack };
// if(LND_defendDifficulty >= 1) then { LND_taskTypes pushBack LND_fnc_taskDefend };
if(LND_convoyDifficulty >= 1) then { LND_taskTypes pushBack LND_fnc_taskConvoy };

setTimeMultiplier 0.1;

LND_bluforInfantry = [];
LND_ffIncidents = 0;

LND_opforInfantry = [];
LND_opforAAA = [];
LND_opforManpads = [];
LND_opforVehiclesUnarmed = [];
LND_opforVehiclesLight = [];
LND_opforVehiclesMedium = [];
LND_opforVehiclesHeavy = [];

LND_taskCounter = 0;
LND_smoke = objNull;
LND_smokeFriendly = "";
LND_smokeHostile = "";
LND_bluforUnits = [];
LND_opforTargets = [];
LND_opforPriorityTargets = [];
LND_totalTargets = 0;


if(intel == 4) then {
	[] spawn {
		while{true} do{
			sleep 0.5;
			{
				private "_a";
				_a = toArray _x;
				_a resize 11;
				if (toString _a == "marker_unit") then {
					deleteMarker _x;
				};
			} forEach allMapMarkers;
			_c = 0;
			{
				_c = _c+1;
			    _marker = createMarkerLocal [format ["marker_unit_%1", _c], getPos _x];

			    if(isPlayer _x) then {
			    	_marker setMarkerColorLocal "ColorYellow";	
			    }
				else{
					_marker setMarkerColorLocal (
						switch (side _x) do {
							case west: { "ColorWEST" };
							case east: { "ColorEAST" };
							case resistance: { "ColorGUER" };
							default { "ColorWhite" };
						}
					);
				};
				_marker setMarkerType "hd_dot";
			} forEach allUnits;
		};
	};
};



call LND_fnc_loadFactions;

call LND_fnc_loadVehicles;

if(count LND_taskTypes == 0) then {
	systemChat "No task types enabled!";
	systemChat "Enable a task in the lobby parameters";
	systemChat "(Or just enjoy flying around!)";
}
else {
	call LND_fnc_newTask;
};