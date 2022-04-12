
params ["_player", "_didJIP"];

_player createDiaryRecord ["Diary", ["CAS Training", "Welcome to Close Air Support Training!<br/><br/>Complete an infinite amount of missions in order to hone your skills in a variety of aircraft"]];

"Group" setDynamicSimulationDistance 1500;
"Vehicle" setDynamicSimulationDistance 2500;
"EmptyVehicle" setDynamicSimulationDistance 1000;

if(isClass(configFile >> "CfgPatches" >> "ace_interaction")) then {
	_player addItem "ACE_Flashlight_XL50";
	_player addItem "ACE_MapTools";
};

if( ["_playerDamage", 1] call BIS_fnc_getParamValue == 0) then {
	_player allowDamage false;
};

if( ["_playerDamage", 1] call BIS_fnc_getParamValue == 1) then {
	_player addeventhandler ["handledamage",{ (_this select 2) / 6}];
};


if( ["RespawnOnDemand", 1] call BIS_fnc_getParamValue == 1) then {

	startPos = getPos _player;
	startDir = getDir _player;

	_player addAction [  
		"Respawn",  
		{
			params ["_target", "_caller", "_actionId", "_arguments"];
			if(vehicle _caller != _caller) then {
				if(count crew vehicle _caller <= 1) then {
					[vehicle _caller] spawn {
					params ["_vehicle"];
						sleep 2;
						_vehicle setDamage 1;
					};
				};
			};
			_caller setDamage 0; 
			_caller setPos startPos;
			_caller setDir startDir;
			_caller setVelocity [0, 0, 0];
		},  
		nil,  
		10,  
		false,  
		true,
		"",
		"_originalTarget isEqualTo _this",
		50,
		true
	];
};


// Can't rely on the code in the "expression" of the vehicle respawn module due to a bug in the underlying engine
_player addEventHandler ["GetOutMan", {
	params ["_unit", "_role", "_vehicle", "_turret"];
	
	if(!alive _vehicle) then {
		_unit setDamage 0;
		_unit setPos startPos;
		_unit setDir startDir;
		_unit setVelocity [0, 0, 0];
	};
}];


_player addEventHandler ["HandleRating", {
	params ["_unit", "_rating"];

	// Prevent players being turned "renegade" after crashing
	// (or killing friendlies)
	// This is a practice scenario after all
	0
}];