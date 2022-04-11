scriptName "LND\functions\LoadMods\fn_loadFactions.sqf";
/*
	Author:
		Landric

	Description:
		Initialises types of unit (e.g. Infantry, AA, Vehicles) as a faction provided in description.ext

	Parameter(s):
		_this: parameters (array of array [key (string), value (any)])

			- required:
				-

			- optional:
				-

	Example:
		call LND_fnc_loadFactions;

	Returns:

*/

// TODO: Standardise on using groups vs individual units; accounting for vehicles etc.


try {
	switch((["BLUFORFaction", 0] call BIS_fnc_getParamValue)) do {
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
	    case 2: {
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
	    case 3: {
			LND_opforInfantry = [
				(configfile >> "CfgGroups" >> "East" >> "rhs_faction_msv" >> "rhs_group_rus_msv_infantry_emr" >> "rhs_group_rus_msv_infantry_emr_squad"),
				(configfile >> "CfgGroups" >> "East" >> "rhs_faction_msv" >> "rhs_group_rus_msv_infantry_emr" >> "rhs_group_rus_msv_infantry_emr_squad_2mg"),
				(configfile >> "CfgGroups" >> "East" >> "rhs_faction_msv" >> "rhs_group_rus_msv_infantry_emr" >> "rhs_group_rus_msv_infantry_emr_squad_sniper"),
				(configfile >> "CfgGroups" >> "East" >> "rhs_faction_msv" >> "rhs_group_rus_msv_infantry_emr" >> "rhs_group_rus_msv_infantry_emr_squad_mg_sniper")
			];

			LND_opforAAA = ["RHS_ZU23_MSV","RHS_Ural_Zu23_MSV_01","rhs_zsu234_aa"];
			LND_opforManpads = [
				(configfile >> "CfgGroups" >> "East" >> "rhs_faction_msv" >> "rhs_group_rus_msv_infantry_emr" >> "rhs_group_rus_msv_infantry_emr_section_AA")];
			
			LND_opforVehiclesUnarmed = ["rhs_tigr_msv","rhs_uaz_open_MSV_01","rhs_gaz66_msv","rhs_gaz66o_flat_msv","RHS_Ural_Fuel_MSV_01","RHS_Ural_Flat_MSV_01"];
			LND_opforVehiclesLight = ["rhs_tigr_sts_msv", "rhs_tigr_m_msv", "rhsgref_BRDM2_HQ_msv", "rhsgref_BRDM2_msv"];
			LND_opforVehiclesMedium = ["rhs_btr70_msv","rhs_btr80_msv","rhs_bmp1_msv"];
			LND_opforVehiclesHeavy = ["rhs_btr80a_msv", "rhs_bmp3_late_msv", "rhs_t72bd_tv"];
	    };
		default {
			LND_opforInfantry = [
				(configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> "OIA_InfAssault"),
				(configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> "OIA_InfSquad"),
				(configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> "OIA_InfWeapons")
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
	LND_opforInfantry = [
		(configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> "OIA_InfAssault"),
		(configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> "OIA_InfSquad"),
		(configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> "OIA_InfWeapons")
	];

	LND_opforAAA = ["O_APC_Tracked_02_AA_F"];
	LND_opforManpads = [(configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> "OIA_InfTeam_AA")];
	
	LND_opforVehiclesUnarmed = ["O_MRAP_02_F", "O_Truck_03_transport_F", "O_Truck_03_repair_F", "O_Truck_03_fuel_F", "O_Truck_02_Ammo_F", "O_Truck_02_fuel_F", "O_Truck_02_transport_F", "O_Truck_02_covered_F"];
	LND_opforVehiclesLight = ["O_MRAP_02_hmg_F", "O_LSV_02_armed_F"];
	LND_opforVehiclesMedium = ["O_APC_Tracked_02_cannon_F", "O_APC_Wheeled_02_rcws_v2_F"];
	LND_opforVehiclesHeavy = ["O_MBT_02_cannon_F", "O_MBT_04_cannon_F"];
};