#include <amxmodx>
#include <fakemeta>
#include <fun>

#define AUTHOR "Svend Laurids Knudsen"
#define VERSION "1.0"
#define PLUGIN "Nade Trainer"

// enum 
// {
#define SETNADES 0
#define LOADNADES 1
// }

new NADESTATE

new g_trailSpr

public plugin_precache()
{
	g_trailSpr = engfunc(EngFunc_PrecacheModel, "sprites/laserbeam.spr");
	NADESTATE = SETNADES;
}

new g_Menu;

new AmountOfSavedFlashes
new AmountOfSavedGrenades
new AmountOfSavedSmokes

new Float:vOriginFlash1[3]
new Float:vVelocityFlash1[3]
new Float:vOriginFlash2[3]
new Float:vVelocityFlash2[3]
new Float:vOriginGrenade[3]
new Float:vVelocityGrenade[3]
new Float:vOriginSmoke[3]
new Float:vVelocitySmoke[3]

new RemainingFlashes
new UNUSED 

public plugin_init()
{
	register_plugin(AUTHOR, VERSION, PLUGIN) //INITIALIZATION

	register_clcmd("nade", "Display_Menu");
	register_clcmd("say nade", "Display_Menu");

	register_forward(FM_SetModel, "Forward_SetModel"); // HOOK FOR ALL THROWN GRENADES
}


public Display_Menu(id)
{
	g_Menu = menu_create("Nade Trainer", "menu_handle");

	menu_additem(g_Menu, "Set new nadetrails", "", 0);
	menu_additem(g_Menu, "Load nadetrails", "", 0);

	menu_setprop(g_Menu, MPROP_EXIT, MEXIT_ALL);

	menu_display(1, g_Menu, 0);	
}


public menu_handle(id, menu, item)
{

	switch(item)
	{
		case 0:
		{

			NADESTATE = SETNADES;

			strip_user_weapons(id);

			give_item(1, "weapon_flashbang");
			give_item(1, "weapon_flashbang");
			give_item(1, "weapon_hegrenade");
			give_item(1, "weapon_smokegrenade");

			AmountOfSavedFlashes = 0;
			AmountOfSavedGrenades = 0;
			AmountOfSavedSmokes = 0;

		}
		case 1:
		{
			NADESTATE = LOADNADES;

			strip_user_weapons(id);

			if(AmountOfSavedFlashes == 2)
			{
				give_item(1, "weapon_flashbang");
				give_item(1, "weapon_flashbang");
			}
			else if(AmountOfSavedFlashes == 1) give_item(1, "weapon_flashbang");
			
			if(AmountOfSavedGrenades == 1) give_item(1, "weapon_hegrenade");

			if(AmountOfSavedSmokes == 1) give_item(1, "weapon_smokegrenade");
		}
	}
}

public Forward_SetModel(iIndex, const szModel[])
{
	switch(NADESTATE)
	{
		case SETNADES:
		{
			if(equal(szModel[9], "flashbang.mdl"))
			{
				get_user_ammo(1, CSW_FLASHBANG, UNUSED, RemainingFlashes)
				switch(RemainingFlashes)
				{
					case 1:
					{
						pev(iIndex, pev_velocity, vVelocityFlash1);
						pev(iIndex, pev_origin, vOriginFlash1);
						if(AmountOfSavedFlashes < 2) AmountOfSavedFlashes++;
					}
					case 2:
					{
						pev(iIndex, pev_velocity, vVelocityFlash2);
						pev(iIndex, pev_origin, vOriginFlash2);
						if(AmountOfSavedFlashes < 2) AmountOfSavedFlashes++;
					}
				}

				SetTrail(0, 255, 0, iIndex);
			}
			else if(equal(szModel[9], "hegrenade.mdl"))
			{
				pev(iIndex, pev_velocity, vVelocityGrenade);
				pev(iIndex, pev_origin, vOriginGrenade);
				AmountOfSavedGrenades = 1;
				SetTrail(255, 0, 0, iIndex);
			}
			else if(equal(szModel[9], "smokegrenade.mdl"))
			{
				pev(iIndex, pev_velocity, vVelocitySmoke);
				pev(iIndex, pev_origin, vOriginSmoke);
				AmountOfSavedSmokes = 1;
				SetTrail(0, 0, 255, iIndex);
			}
		}
		case LOADNADES:
		{
			
			if(equal(szModel[9], "flashbang.mdl"))
			{
				
				switch(AmountOfSavedFlashes)
				{
					case 1:
					{
						set_pev(iIndex, pev_velocity, vVelocityFlash2);
						set_pev(iIndex, pev_origin, vOriginFlash2);
					}
					case 2:
					{
						get_user_ammo(1, CSW_FLASHBANG, UNUSED, RemainingFlashes)
						switch(RemainingFlashes)
						{
							case 1: 
							{
								set_pev(iIndex, pev_velocity, vVelocityFlash1);
								set_pev(iIndex, pev_origin, vOriginFlash1);
							}
							case 2:
							{
								set_pev(iIndex, pev_velocity, vVelocityFlash2);
								set_pev(iIndex, pev_origin, vOriginFlash2);
							}
						}
					}
				}

			}
			else if(equal(szModel[9], "hegrenade.mdl"))
			{
				set_pev(iIndex, pev_velocity, vVelocityGrenade);
				set_pev(iIndex, pev_origin, vOriginGrenade);
			}
			else if(equal(szModel[9], "smokegrenade.mdl"))
			{
				set_pev(iIndex, pev_velocity, vVelocitySmoke);
				set_pev(iIndex, pev_origin, vOriginSmoke);
			}
		}
	}

	return FMRES_IGNORED;
}

public SetTrail(r, g, b, iIndex)
{

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMFOLLOW);
	write_short(iIndex); 
	write_short(g_trailSpr);
	write_byte(100); // Time
	write_byte(1); // Width
	write_byte(r); // Red
	write_byte(g); // Green
	write_byte(b); // Blue
	write_byte(200); // Brightness
	message_end();
}
