
smokeChance = ["Smoke", 60] call BIS_fnc_getParamValue;
intel = ["Intel", 2] call BIS_fnc_getParamValue;
manpadThreat = ["MANPAD", 10] call BIS_fnc_getParamValue;
aaaThreat = ["AAA", 0] call BIS_fnc_getParamValue;
completionPercent = ["Completion", 80] call BIS_fnc_getParamValue;

safeZone = [getMarkerPos "respawn_start", 1500];
LND_playerCallsign = selectRandom ["Hornet", "Banshee", "Shriek", "Thunderfoot", "Hammer", "Big-Bird", "Alchemist"];

blufor_infantry = [];

opfor_infantry = [];
opfor_aaa = [];
opfor_manpads = [];
opfor_vehicles_unarmed = [];
opfor_vehicles_light = [];
opfor_vehicles_medium = [];
opfor_vehicles_heavy = [];

task_counter = -1;
smoke = objNull;
smokeFriendly = "";
smokeHostile = "";
blufor_units = [];
opfor_targets = [];
opfor_priorityTargets = [];
totalTargets = 0;


// TODO: Remove this debug code before release
//if(intel == 4) then {
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
			    _marker = createMarker [format ["marker_unit_%1", _c], getPos _x];

			    if(isPlayer _x) then {
			    	_marker setMarkerColor "ColorYellow";	
			    }
				else{
					_marker setMarkerColor (
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
//};



call LND_fnc_loadFactions;

call LND_fnc_loadVehicles;

call LND_fnc_newTask;
