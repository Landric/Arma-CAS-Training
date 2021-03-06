scriptName "LND\functions\LoadMods\fn_loadFactions.sqf";
/*
	Author:
		Landric

	Description:
		Initialises types of unit (e.g. Infantry, AA, Vehicles) as a faction provided in description.ext

	Parameter(s):
		None
	
	Returns:
		None

	Example Usage:
		call LND_fnc_loadFactions;
*/

try {
	switch((["BLUFORFaction", 0] call BIS_fnc_getParamValue)) do {
		// Cadian
		case 1: {
			if(!isClass(configfile >> "CfgGroups" >> "West" >> "Cad836")) then {
	    		throw "TIOW not loaded!"
	    	};
			LND_bluforInfantry = [
				(configfile >> "CfgGroups" >> "West" >> "Cad836" >> "TIOW_Cad_836th_Squads" >> "TIOW_Group_Cad_836th_Guardsmen_1")
			];
 		};
 		// Clone Troopers
 		case 2: {
 			if(!isClass(configfile >> "CfgGroups" >> "West" >> "SWLB_group_GAR")) then {
	    		throw "SWLB not loaded!"
	    	};
			LND_bluforInfantry = [
				(configfile >> "CfgGroups" >> "West" >> "SWLB_group_GAR" >> "Infantry_p1" >> "clone_squad")
			];
 		};
 		// NATO
		default {
			LND_bluforInfantry = [
				(configfile >> "CfgGroups" >> "West" >> "BLU_F" >> "Infantry" >> "BUS_InfSquad")
			];
 		};
	};
}
catch {
	LND_bluforInfantry = [
		(configfile >> "CfgGroups" >> "West" >> "BLU_F" >> "Infantry" >> "BUS_InfSquad")
	];
};

try {
	switch((["OPFORFaction", 0] call BIS_fnc_getParamValue)) do {

		// AAF
		case 1: {
			LND_opforInfantry = [
				(configfile >> "CfgGroups" >> "Indep" >> "IND_F" >> "Infantry" >> "HAF_InfSquad"),
				(configfile >> "CfgGroups" >> "Indep" >> "IND_F" >> "Infantry" >> "HAF_InfSquad_Weapons")
			];

			LND_opforAAA = ["I_LT_01_AA_F"];
			LND_opforManpads = [(configfile >> "CfgGroups" >> "Indep" >> "IND_F" >> "Infantry" >> "HAF_InfTeam_AA")];
			
			LND_opforVehiclesUnarmed = ["I_MRAP_03_F", "I_Truck_02_ammo_F", "I_Truck_02_fuel_F", "I_Truck_02_transport_F", "I_Truck_02_covered_F"];
			LND_opforVehiclesLight = ["I_MRAP_03_hmg_F"];
			LND_opforVehiclesMedium = ["I_APC_Wheeled_03_cannon_F", "I_APC_tracked_03_cannon_F", "I_LT_01_cannon_F"];
			LND_opforVehiclesHeavy = ["I_MBT_03_cannon_F"];

	    };
	    // MDF
	    case 2: {
	    	if(!isClass(configfile >> "CfgGroups" >> "East" >> "UK3CB_MDF_O")) then {
	    		throw "UK3CB not loaded!"
	    	};

			LND_opforInfantry = [
				(configfile >> "CfgGroups" >> "East" >> "UK3CB_MDF_O" >> "Infantry" >> "UK3CB_MDF_O_RIF_Squad"),
				(configfile >> "CfgGroups" >> "East" >> "UK3CB_MDF_O" >> "Infantry" >> "UK3CB_MDF_O_MK_Squad"),
				(configfile >> "CfgGroups" >> "East" >> "UK3CB_MDF_O" >> "Infantry" >> "UK3CB_MDF_O_AT_Squad"),
				(configfile >> "CfgGroups" >> "East" >> "UK3CB_MDF_O" >> "Infantry" >> "UK3CB_MDF_O_MG_Squad")
			];

			LND_opforAAA = ["UK3CB_MDF_O_Stinger_AA_pod", "UK3CB_MDF_O_MTVR_Zu23"];
			LND_opforManpads = [
				(configfile >> "CfgGroups" >> "East" >> "UK3CB_MDF_O" >> "Infantry" >> "UK3CB_MDF_O_AA_FireTeam"),
				(configfile >> "CfgGroups" >> "East" >> "UK3CB_MDF_O" >> "Infantry" >> "UK3CB_MDF_O_AA_Squad")
			];
			
			LND_opforVehiclesUnarmed = ["UK3CB_MDF_O_M1025_Unarmed", "UK3CB_MDF_O_MTVR_Closed", "UK3CB_MDF_O_MTVR_Repair", "UK3CB_MDF_O_MTVR_Refuel"];
			LND_opforVehiclesLight = ["UK3CB_MDF_O_M1151_OGPK_MK19", "UK3CB_MDF_O_M1025_M2"];
			LND_opforVehiclesMedium = ["UK3CB_MDF_O_M113_M2", "UK3CB_MDF_O_M113_M240"];
			LND_opforVehiclesHeavy = ["UK3CB_MDF_O_Warrior_Camo", "UK3CB_MDF_O_Warrior_Cage_Camo", "UK3CB_MDF_O_M60A3"];

	    };
	    // AFRF
	    case 3: {
	    	if(!isClass(configfile >> "CfgGroups" >> "East" >> "rhs_faction_msv")) then {
	    		throw "RHS not loaded!"
	    	};

			LND_opforInfantry = [
				(configfile >> "CfgGroups" >> "East" >> "rhs_faction_msv" >> "rhs_group_rus_msv_infantry_emr" >> "rhs_group_rus_msv_infantry_emr_squad"),
				(configfile >> "CfgGroups" >> "East" >> "rhs_faction_msv" >> "rhs_group_rus_msv_infantry_emr" >> "rhs_group_rus_msv_infantry_emr_squad_2mg"),
				(configfile >> "CfgGroups" >> "East" >> "rhs_faction_msv" >> "rhs_group_rus_msv_infantry_emr" >> "rhs_group_rus_msv_infantry_emr_squad_sniper"),
				(configfile >> "CfgGroups" >> "East" >> "rhs_faction_msv" >> "rhs_group_rus_msv_infantry_emr" >> "rhs_group_rus_msv_infantry_emr_squad_mg_sniper")
			];

			LND_opforAAA = ["RHS_ZU23_MSV","RHS_Ural_Zu23_MSV_01","rhs_zsu234_aa"];
			LND_opforManpads = [(configfile >> "CfgGroups" >> "East" >> "rhs_faction_msv" >> "rhs_group_rus_msv_infantry_emr" >> "rhs_group_rus_msv_infantry_emr_section_AA")];
			
			LND_opforVehiclesUnarmed = ["rhs_tigr_msv","rhs_uaz_open_MSV_01","rhs_gaz66_msv","rhs_gaz66o_flat_msv","RHS_Ural_Fuel_MSV_01","RHS_Ural_Flat_MSV_01"];
			LND_opforVehiclesLight = ["rhs_tigr_sts_msv", "rhs_tigr_m_msv", "rhsgref_BRDM2_HQ_msv", "rhsgref_BRDM2_msv"];
			LND_opforVehiclesMedium = ["rhs_btr70_msv","rhs_btr80_msv","rhs_bmp1_msv"];
			LND_opforVehiclesHeavy = ["rhs_btr80a_msv", "rhs_bmp3_late_msv", "rhs_t72bd_tv"];
	    };
	    // Chaos
	    case 4: {
	    	if(!isClass(configfile >> "CfgGroups" >> "East" >> "TIOW_ChaosSpaceMarines" )) then {
	    		throw "TIOW not loaded!"
	    	};

			LND_opforInfantry = [
				(configfile >> "CfgGroups" >> "East" >> "TIOW_ChaosSpaceMarines" >> "TIOW_CSM_WB_Squads" >> "TIOW_Group_SM_WB_Tact_1")
			];

			LND_opforAAA = ["TIOW_SM_Razorback_AC_WB"];
			LND_opforManpads = [(configfile >> "CfgGroups" >> "East" >> "TIOW_ChaosSpaceMarines" >> "TIOW_CSM_WB_Squads" >> "TIOW_Group_SM_WB_Tact_1")];
			
			// TODO: "Unarmed" and "Light" is EXTREMELY relative in 40K
			LND_opforVehiclesUnarmed = ["TIOW_SM_Whirlwind_Arty_WB", "TIOW_SM_Vindicator_WB", "TIOW_SM_Rhino_WB"]; 
			LND_opforVehiclesLight = ["TIOW_SM_Whirlwind_Arty_WB", "TIOW_SM_Vindicator_WB", "TIOW_SM_Rhino_WB"];
			LND_opforVehiclesMedium = ["TIOW_SM_Predator_WB", "TIOW_SM_Razorback_LC_WB", "TIOW_SM_Razorback_AC_WB", "TIOW_SM_Razorback_WB"];
			LND_opforVehiclesHeavy = ["TIOW_SM_Predator_WB", "TIOW_SM_Razorback_LC_WB", "TIOW_SM_Razorback_AC_WB", "TIOW_SM_Razorback_WB"];
		};
	    // CIS
	    case 5: {
	    	if(!isClass(configfile >> "CfgGroups" >> "East" >> "ls_groups_cis")) then {
	    		throw "LSB not loaded!"
	    	};

			LND_opforInfantry = [
				(configfile >> "CfgGroups" >> "East" >> "ls_groups_cis" >> "cis_baseInfantry" >> "base_b1_squad"),
				(configfile >> "CfgGroups" >> "East" >> "ls_groups_cis" >> "cis_baseInfantry" >> "base_b1_mgTeam"),
				(configfile >> "CfgGroups" >> "East" >> "ls_groups_cis" >> "cis_baseInfantry" >> "base_b1_at")
			];

			LND_opforAAA = ["ls_ground_aat"];
			LND_opforManpads = [(configfile >> "CfgGroups" >> "East" >> "ls_groups_cis" >> "cis_baseInfantry" >> "base_b1_aa")];

			LND_opforVehiclesUnarmed = ["lsd_car_ast"]; // TODO: There are no unarmed vehicles in this mod!
			LND_opforVehiclesLight = ["lsd_car_ast"];
			LND_opforVehiclesMedium = ["ls_ground_mtt_federation", "ls_ground_bawhag", "ls_ground_aat"];
			LND_opforVehiclesHeavy = ["ls_ground_aat"];
	    };
	    // CSAT
		default {
			LND_opforInfantry = [
				(configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> "OIA_InfAssault"),
				(configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> "OIA_InfSquad"),
				(configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> "OIA_InfSquad_Weapons")
			];

			LND_opforAAA = ["O_APC_Tracked_02_AA_F"];
			LND_opforManpads = [(configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> "OIA_InfTeam_AA")];
			
			LND_opforVehiclesUnarmed = ["O_MRAP_02_F", "O_Truck_03_transport_F", "O_Truck_03_repair_F", "O_Truck_03_fuel_F", "O_Truck_02_Ammo_F", "O_Truck_02_fuel_F", "O_Truck_02_transport_F", "O_Truck_02_covered_F"];
			LND_opforVehiclesLight = ["O_MRAP_02_hmg_F", "O_LSV_02_armed_F"];
			LND_opforVehiclesMedium = ["O_APC_Tracked_02_cannon_F", "O_APC_Wheeled_02_rcws_v2_F"];
			LND_opforVehiclesHeavy = ["O_MBT_02_cannon_F", "O_MBT_04_cannon_F"];
 		};
	};
}
// If something goes wrong (e.g. if the correct mod isn't loaded), default to vanilla CSAT
catch {
	diag_log format ["LND: %1", _exception];
	diag_log "LND: Defaulting to OPFOR: CSAT";
	LND_opforInfantry = [
		(configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> "OIA_InfAssault"),
		(configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> "OIA_InfSquad"),
		(configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> "OIA_InfSquad_Weapons")
	];

	LND_opforAAA = ["O_APC_Tracked_02_AA_F"];
	LND_opforManpads = [(configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> "OIA_InfTeam_AA")];
	
	LND_opforVehiclesUnarmed = ["O_MRAP_02_F", "O_Truck_03_transport_F", "O_Truck_03_repair_F", "O_Truck_03_fuel_F", "O_Truck_02_Ammo_F", "O_Truck_02_fuel_F", "O_Truck_02_transport_F", "O_Truck_02_covered_F"];
	LND_opforVehiclesLight = ["O_MRAP_02_hmg_F", "O_LSV_02_armed_F"];
	LND_opforVehiclesMedium = ["O_APC_Tracked_02_cannon_F", "O_APC_Wheeled_02_rcws_v2_F"];
	LND_opforVehiclesHeavy = ["O_MBT_02_cannon_F", "O_MBT_04_cannon_F"];
};