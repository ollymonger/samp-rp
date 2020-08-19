#include <a_samp>

#define dcmd(%1,%2,%3) if (!strcmp((%3)[1], #%1, true, (%2)) && ((((%3)[(%2) + 1] == '\0') && (dcmd_%1(playerid, ""))) || (((%3)[(%2) + 1] == ' ') && (dcmd_%1(playerid, (%3)[(%2) + 2]))))) return 1

#define COLOR_RED            0xff000000
#define COLOR_GREEN          0x00660000

new bool:IsCreatingMenu[MAX_PLAYERS];
new bool:IsTypingItems[MAX_PLAYERS];
new bool:IsTypingItemName[MAX_PLAYERS];
new bool:IsSettingMenuPos[MAX_PLAYERS];
new bool:IsSettingMenuWidth[MAX_PLAYERS];
new MenuItems[12][20] = {
    "none",
	"none",
	"none",
	"none",
	"none",
	"none",
	"none",
	"none",
	"none",
	"none",
	"none",
	"none"
};
new MenuItemAdded[12];

new MenuItems2[12][20] = {
    "none",
	"none",
	"none",
	"none",
	"none",
	"none",
	"none",
	"none",
	"none",
	"none",
	"none",
	"none"
};
new MenuItem2Added[12];
new MenuColumns;
new MenuHeader[30];
new HeaderSet = 0;
new MenuColumnHeader[50];
new MenuName[20];
new FileName[30];
new Float:MenuPos[2] = {
    200.0,
	200.0
};
new Float:MenuWidth = 100.0;
new Float:size = 10.0;
new Float:size2 = 10.0;
new Menu:createmenu, Menu:modifymenu;
new Item[12];
new ItemsAdded;

public OnFilterScriptInit()
{
	print("\n--------------------------------------");
	print(" In-Game Menu Filterscript");
	print("--------------------------------------\n");
	
	modifymenu = CreateMenu("Modify", 1, 200.0, 100.0, 100, 100);
	AddMenuItem(modifymenu, 0, "Rename");
	return 1;
}

public OnFilterScriptExit()
{
	return 1;
}


public OnPlayerConnect(playerid)
{
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	return 1;
}

public OnPlayerSpawn(playerid)
{
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	return 1;
}


public OnPlayerText(playerid, text[])
{
	if(IsTypingItems[playerid] == true)
	{
		ItemsAdded = strval(text);
		if(ItemsAdded > 12 || ItemsAdded < 1)
		{
			SendClientMessage(playerid, COLOR_RED, "Min items 1, Max items 12");
			return 0;
		}
		else
		{
	        for(new i; i<ItemsAdded; i++)
	        {
				if(MenuColumns == 1)
				{
					AddMenuItem(createmenu, 0, MenuItems[i]);
					MenuItemAdded[i] = 1;
				}
				else if(MenuColumns == 2)
				{
					AddMenuItem(createmenu, 0, MenuItems[i]);
					MenuItemAdded[i] = 1;
					AddMenuItem(createmenu, 1, MenuItems2[i]);
					MenuItem2Added[i] = 1;
				}
			}
		}
		IsTypingItems[playerid] = false;
		ShowMenuForPlayer(createmenu, playerid);
	}
	if(IsTypingItemName[playerid] == true)
	{
		if(MenuColumns == 1)
		{
	    	if(Item[0] == 1)
    		{
    		    if(MenuItemAdded[0] == 1)
    		    {
					if(sscanf(text, "s", MenuItems[0])) SendClientMessage(playerid, COLOR_RED, "Write Something");
					else
					{
   		    	        UpdateMenu(playerid);
		     		}
		        }
		        Item[0] = 0;
		        IsTypingItemName[playerid] = false;
	    	}
	    	else if(Item[1] == 1)
    		{
    		    if(MenuItemAdded[1] == 1)
    		    {
					if(sscanf(text, "s", MenuItems[1])) SendClientMessage(playerid, COLOR_RED, "Write Something");
					else
					{
   		    	        UpdateMenu(playerid);
		     		}
		        }
		        Item[1] = 0;
		        IsTypingItemName[playerid] = false;
	    	}
	    	else if(Item[2] == 1)
    		{
    		    if(MenuItemAdded[2] == 1)
    		    {
					if(sscanf(text, "s", MenuItems[2])) SendClientMessage(playerid, COLOR_RED, "Write Something");
					else
					{
   		    	        UpdateMenu(playerid);
		     		}
		        }
		        Item[2] = 0;
		        IsTypingItemName[playerid] = false;
	    	}
	    	else if(Item[3] == 1)
    		{
    		    if(MenuItemAdded[3] == 1)
    		    {
					if(sscanf(text, "s", MenuItems[3])) SendClientMessage(playerid, COLOR_RED, "Write Something");
					else
					{
   		    	        UpdateMenu(playerid);
		     		}
		        }
		        Item[3] = 0;
		        IsTypingItemName[playerid] = false;
	    	}
	    	else if(Item[4] == 1)
    		{
    		    if(MenuItemAdded[4] == 1)
    		    {
					if(sscanf(text, "s", MenuItems[4])) SendClientMessage(playerid, COLOR_RED, "Write Something");
					else
					{
   		    	        UpdateMenu(playerid);
		     		}
		        }
		        Item[4] = 0;
		        IsTypingItemName[playerid] = false;
	    	}
	    	else if(Item[5] == 1)
    		{
    		    if(MenuItemAdded[5] == 1)
    		    {
					if(sscanf(text, "s", MenuItems[5])) SendClientMessage(playerid, COLOR_RED, "Write Something");
					else
					{
   		    	        UpdateMenu(playerid);
		     		}
		        }
		        Item[5] = 0;
		        IsTypingItemName[playerid] = false;
	    	}
	    	else if(Item[6] == 1)
    		{
    		    if(MenuItemAdded[6] == 1)
    		    {
					if(sscanf(text, "s", MenuItems[6])) SendClientMessage(playerid, COLOR_RED, "Write Something");
					else
					{
   		    	        UpdateMenu(playerid);
		     		}
		        }
		        Item[6] = 0;
		        IsTypingItemName[playerid] = false;
	    	}
	    	else if(Item[7] == 1)
    		{
    		    if(MenuItemAdded[7] == 1)
    		    {
					if(sscanf(text, "s", MenuItems[7])) SendClientMessage(playerid, COLOR_RED, "Write Something");
					else
					{
   		    	        UpdateMenu(playerid);
		     		}
		        }
		        Item[7] = 0;
		        IsTypingItemName[playerid] = false;
	    	}
	    	else if(Item[8] == 1)
    		{
    		    if(MenuItemAdded[8] == 1)
    		    {
					if(sscanf(text, "s", MenuItems[8])) SendClientMessage(playerid, COLOR_RED, "Write Something");
					else
					{
   		    	        UpdateMenu(playerid);
		     		}
		        }
		        Item[8] = 0;
		        IsTypingItemName[playerid] = false;
	    	}
	    	else if(Item[9] == 1)
    		{
    		    if(MenuItemAdded[9] == 1)
    		    {
					if(sscanf(text, "s", MenuItems[9])) SendClientMessage(playerid, COLOR_RED, "Write Something");
					else
					{
   		    	        UpdateMenu(playerid);
		     		}
		        }
		        Item[9] = 0;
		        IsTypingItemName[playerid] = false;
	    	}
	    	else if(Item[10] == 1)
    		{
    		    if(MenuItemAdded[10] == 1)
    		    {
					if(sscanf(text, "s", MenuItems[10])) SendClientMessage(playerid, COLOR_RED, "Write Something");
					else
					{
   		    	        UpdateMenu(playerid);
		     		}
		        }
		        Item[10] = 0;
		        IsTypingItemName[playerid] = false;
	    	}
	    	else if(Item[11] == 1)
    		{
    		    if(MenuItemAdded[11] == 1)
    		    {
					if(sscanf(text, "s", MenuItems[11])) SendClientMessage(playerid, COLOR_RED, "Write Something");
					else
					{
   		    	        UpdateMenu(playerid);
		     		}
		        }
		        Item[11] = 0;
		        IsTypingItemName[playerid] = false;
	    	}
    	}
		else if(MenuColumns == 2)
		{
	    	if(Item[0] == 1)
    		{
                if(MenuItemAdded[0] == 1 && MenuItem2Added[0] == 1)
    		    {
					if(sscanf(text, "ss", MenuItems[0], MenuItems2[0]))
					{
                        SendClientMessage(playerid, COLOR_RED, "[1st item] [2nd item]");
                        ShowMenuForPlayer(createmenu, playerid);
                        Item[0] = 0;
				    }
					else
					{
   		    	        UpdateMenu2(playerid);
		     		}
		        }
		        Item[0] = 0;
		        IsTypingItemName[playerid] = false;
	    	}
	    	else if(Item[1] == 1)
    		{
    		    if(MenuItemAdded[1] == 1 && MenuItem2Added[1] == 1)
    		    {
					if(sscanf(text, "ss", MenuItems[1], MenuItems2[1]))
					{
                        SendClientMessage(playerid, COLOR_RED, "[1st item] [2nd item]");
                        ShowMenuForPlayer(createmenu, playerid);
                        Item[1] = 0;
				    }
					else
					{
   		    	        UpdateMenu2(playerid);
		     		}
		        }
		        Item[1] = 0;
		        IsTypingItemName[playerid] = false;
	    	}
	    	else if(Item[2] == 1)
    		{
    		    if(MenuItemAdded[2] == 1 && MenuItem2Added[2] == 1)
    		    {
					if(sscanf(text, "ss", MenuItems[2], MenuItems2[2]))
					{
                        SendClientMessage(playerid, COLOR_RED, "[1st item] [2nd item]");
                        ShowMenuForPlayer(createmenu, playerid);
                        Item[2] = 0;
				    }
					else
					{
   		    	        UpdateMenu2(playerid);
		     		}
		        }
		        Item[2] = 0;
		        IsTypingItemName[playerid] = false;
	    	}
	    	else if(Item[3] == 1)
    		{
    		    if(MenuItemAdded[3] == 1 && MenuItem2Added[3] == 1)
    		    {
					if(sscanf(text, "ss", MenuItems[3], MenuItems2[3]))
					{
                        SendClientMessage(playerid, COLOR_RED, "[1st item] [2nd item]");
                        ShowMenuForPlayer(createmenu, playerid);
                        Item[3] = 0;
				    }
					else
					{
   		    	        UpdateMenu2(playerid);
		     		}
		        }
		        Item[3] = 0;
		        IsTypingItemName[playerid] = false;
	    	}
	    	else if(Item[4] == 1)
    		{
    		    if(MenuItemAdded[4] == 1 && MenuItem2Added[4] == 1)
    		    {
					if(sscanf(text, "ss", MenuItems[4], MenuItems2[4]))
					{
                        SendClientMessage(playerid, COLOR_RED, "[1st item] [2nd item]");
                        ShowMenuForPlayer(createmenu, playerid);
                        Item[4] = 0;
				    }
					else
					{
   		    	        UpdateMenu2(playerid);
		     		}
		        }
		        Item[4] = 0;
		        IsTypingItemName[playerid] = false;
	    	}
	    	else if(Item[5] == 1)
    		{
    		    if(MenuItemAdded[5] == 1 && MenuItem2Added[5] == 1)
    		    {
					if(sscanf(text, "ss", MenuItems[5], MenuItems2[5]))
					{
                        SendClientMessage(playerid, COLOR_RED, "[1st item] [2nd item]");
                        ShowMenuForPlayer(createmenu, playerid);
                        Item[5] = 0;
				    }
					else
					{
   		    	        UpdateMenu2(playerid);
		     		}
		        }
		        Item[5] = 0;
		        IsTypingItemName[playerid] = false;
	    	}
	    	else if(Item[6] == 1)
    		{
    		    if(MenuItemAdded[6] == 1 && MenuItem2Added[6] == 1)
    		    {
					if(sscanf(text, "ss", MenuItems[6], MenuItems2[6]))
					{
                        SendClientMessage(playerid, COLOR_RED, "[1st item] [2nd item]");
                        ShowMenuForPlayer(createmenu, playerid);
                        Item[6] = 0;
				    }
					else
					{
   		    	        UpdateMenu2(playerid);
		     		}
		        }
		        Item[6] = 0;
		        IsTypingItemName[playerid] = false;
	    	}
	    	else if(Item[7] == 1)
    		{
    		    if(MenuItemAdded[7] == 1 && MenuItem2Added[7] == 1)
    		    {
					if(sscanf(text, "ss", MenuItems[7], MenuItems2[7]))
					{
                        SendClientMessage(playerid, COLOR_RED, "[1st item] [2nd item]");
                        ShowMenuForPlayer(createmenu, playerid);
                        Item[7] = 0;
				    }
					else
					{
   		    	        UpdateMenu2(playerid);
		     		}
		        }
		        Item[7] = 0;
		        IsTypingItemName[playerid] = false;
	    	}
	    	else if(Item[8] == 1)
    		{
    		    if(MenuItemAdded[8] == 1 && MenuItem2Added[8] == 1)
    		    {
					if(sscanf(text, "ss", MenuItems[8], MenuItems2[8]))
					{
                        SendClientMessage(playerid, COLOR_RED, "[1st item] [2nd item]");
                        ShowMenuForPlayer(createmenu, playerid);
                        Item[8] = 0;
				    }
					else
					{
   		    	        UpdateMenu2(playerid);
		     		}
		        }
		        Item[8] = 0;
		        IsTypingItemName[playerid] = false;
	    	}
	    	else if(Item[9] == 1)
    		{
    		    if(MenuItemAdded[9] == 1 && MenuItem2Added[9] == 1)
    		    {
					if(sscanf(text, "ss", MenuItems[9], MenuItems2[9]))
					{
                        SendClientMessage(playerid, COLOR_RED, "[1st item] [2nd item]");
                        ShowMenuForPlayer(createmenu, playerid);
                        Item[9] = 0;
				    }
					else
					{
   		    	        UpdateMenu2(playerid);
		     		}
		        }
		        Item[9] = 0;
		        IsTypingItemName[playerid] = false;
	    	}
	    	else if(Item[10] == 1)
    		{
    		    if(MenuItemAdded[10] == 1 && MenuItem2Added[10] == 1)
    		    {
					if(sscanf(text, "ss", MenuItems[10], MenuItems2[10]))
					{
                        SendClientMessage(playerid, COLOR_RED, "[1st item] [2nd item]");
                        ShowMenuForPlayer(createmenu, playerid);
                        Item[10] = 0;
				    }
					else
					{
   		    	        UpdateMenu2(playerid);
		     		}
		        }
		        Item[10] = 0;
		        IsTypingItemName[playerid] = false;
	    	}
	    	else if(Item[11] == 1)
    		{
    		    if(MenuItemAdded[11] == 1 && MenuItem2Added[11] == 1)
    		    {
					if(sscanf(text, "ss", MenuItems[11], MenuItems2[11]))
					{
                        SendClientMessage(playerid, COLOR_RED, "[1st item] [2nd item]");
                        ShowMenuForPlayer(createmenu, playerid);
                        Item[11] = 0;
				    }
					else
					{
   		    	        UpdateMenu2(playerid);
		     		}
		        }
		        Item[11] = 0;
		        IsTypingItemName[playerid] = false;
	    	}
    	}
    }
	return 1;
}


public OnPlayerCommandText(playerid, cmdtext[])
{
	dcmd(createmenu,10,cmdtext);
	dcmd(menu,4,cmdtext);
	dcmd(menupos,7,cmdtext);
	dcmd(menuwidth,9,cmdtext);
	dcmd(possize,7,cmdtext);
	dcmd(widthsize,9,cmdtext);
	dcmd(done,4,cmdtext);
	dcmd(header,6,cmdtext);
	dcmd(savemenu,8,cmdtext);
	return 0;
}

dcmd_createmenu(playerid, params[])
{
	if(sscanf(params, "ssd", MenuHeader, MenuName, MenuColumns)) SendClientMessage(playerid, COLOR_RED, "Usage: /createmenu [Header] [Menu Name] [Columns]");
	else if(MenuColumns < 1 || MenuColumns > 2) return SendClientMessage(playerid, COLOR_RED, "Min columns 1, Max columns 2");
	else if(IsCreatingMenu[playerid] == true) return SendClientMessage(playerid, COLOR_RED, "You aleardy creating menu");
	else
	{
	    IsCreatingMenu[playerid] = true;
	    SendClientMessage(playerid, COLOR_GREEN, "Menu created. Now type number of items [1-12]");
	    IsTypingItems[playerid] = true;
	    TogglePlayerControllable(playerid, false);
	    createmenu = CreateMenu(MenuHeader, MenuColumns, MenuPos[0], MenuPos[1], MenuWidth, MenuWidth);
	    return 1;
	}
	return 1;
}

dcmd_menu(playerid, params[])
{
	#pragma unused params
	ShowMenuForPlayer(createmenu, playerid);
	return 1;
}

dcmd_menupos(playerid, params[])
{
	#pragma unused params
    if(IsTypingItems[playerid] == true) return SendClientMessage(playerid, COLOR_RED, "Type items first");
    else if(IsTypingItemName[playerid] == true) return SendClientMessage(playerid, COLOR_RED, "Type item name first");
	else if(IsSettingMenuWidth[playerid] == true) return SendClientMessage(playerid, COLOR_RED, "Type /done");
	else if(IsCreatingMenu[playerid] == false) return SendClientMessage(playerid, COLOR_RED, "Create menu first");
	IsSettingMenuPos[playerid] = true;
    SendClientMessage(playerid, COLOR_GREEN, "Set menu pos ( shift - up, ctrl - down, mouse wheel - left, tab - right )");
    SendClientMessage(playerid, COLOR_GREEN, "Jump key - up, Fire key - down, Look Behind key - left, Action Key - right");
    SendClientMessage(playerid, COLOR_GREEN, "You can change stepping size by typing /possize [ammount]");
    SendClientMessage(playerid, COLOR_GREEN, "Type /done when you finish to set up menu pos");
    return 1;
}

dcmd_menuwidth(playerid, params[])
{
	#pragma unused params
    if(IsTypingItems[playerid] == true) return SendClientMessage(playerid, COLOR_RED, "Type items first");
    else if(IsTypingItemName[playerid] == true) return SendClientMessage(playerid, COLOR_RED, "Type item name first");
	else if(IsSettingMenuPos[playerid] == true) return SendClientMessage(playerid, COLOR_RED, "Type /done");
	else if(IsCreatingMenu[playerid] == false) return SendClientMessage(playerid, COLOR_RED, "Create menu first");
	IsSettingMenuWidth[playerid] = true;
    SendClientMessage(playerid, COLOR_GREEN, "Set menu width ( mouse wheel - increase, tab - decrease )");
    SendClientMessage(playerid, COLOR_GREEN, "Look Behind - increase, Action Key - decrease");
    SendClientMessage(playerid, COLOR_GREEN, "You can change increase/deacrease size by typing /widthsize [ammount]");
    SendClientMessage(playerid, COLOR_GREEN, "Type /done when you finish to set up menu width");
    return 1;
}

dcmd_done(playerid, params[])
{
    #pragma unused params
    if(IsTypingItems[playerid] == true) return SendClientMessage(playerid, COLOR_RED, "Type items first");
    else if(IsTypingItemName[playerid] == true) return SendClientMessage(playerid, COLOR_RED, "Type item name first");
	else if(IsCreatingMenu[playerid] == false) return SendClientMessage(playerid, COLOR_RED, "Create menu first");
    IsSettingMenuPos[playerid] = false;
	IsSettingMenuWidth[playerid] = false;
    SendClientMessage(playerid, COLOR_GREEN, "Menu pos/width setting done");
    return 1;
}


dcmd_possize(playerid, params[])
{
	if(sscanf(params, "f", size)) SendClientMessage(playerid, COLOR_RED, "Enter size");
	else if(IsTypingItems[playerid] == true) return SendClientMessage(playerid, COLOR_RED, "Type items first");
    else if(IsTypingItemName[playerid] == true) return SendClientMessage(playerid, COLOR_RED, "Type item name first");
	else if(IsCreatingMenu[playerid] == false) return SendClientMessage(playerid, COLOR_RED, "Create menu first");
	else if(floatstr(params) > 50.0 || floatstr(params) < 1.0) return SendClientMessage(playerid, COLOR_RED, "Min 1, Max 50");
	else
	{
		new string[20];
		format(string, 20, "Size set to %f", size);
        SendClientMessage(playerid, COLOR_GREEN, string);
    }
    return 1;
}

dcmd_widthsize(playerid, params[])
{
	if(sscanf(params, "f", size2)) SendClientMessage(playerid, COLOR_RED, "Enter size");
	else if(IsTypingItems[playerid] == true) return SendClientMessage(playerid, COLOR_RED, "Type items first");
    else if(IsTypingItemName[playerid] == true) return SendClientMessage(playerid, COLOR_RED, "Type item name first");
	else if(IsCreatingMenu[playerid] == false) return SendClientMessage(playerid, COLOR_RED, "Create menu first");
	else if(floatstr(params) > 50.0 || floatstr(params) < 1.0) return SendClientMessage(playerid, COLOR_RED, "Min 1, Max 50");
	else
	{
		new string[20];
		format(string, 20, "Size set to %f", size2);
        SendClientMessage(playerid, COLOR_GREEN, string);
    }
    return 1;
}

dcmd_header(playerid, params[])
{
    if(sscanf(params, "s", MenuColumnHeader)) SendClientMessage(playerid, COLOR_RED, "/header [Column header]");
   	else if(IsTypingItems[playerid] == true) return SendClientMessage(playerid, COLOR_RED, "Type items first");
    else if(IsTypingItemName[playerid] == true) return SendClientMessage(playerid, COLOR_RED, "Type item name first");
    else if(IsCreatingMenu[playerid] == false) return SendClientMessage(playerid, COLOR_RED, "Create menu first");
    else
    {
		HeaderSet = 1;
		SetMenuColumnHeader(createmenu, 0, MenuColumnHeader);
		if(MenuColumns == 1)
		{
			UpdateMenu(playerid);
		}
		else UpdateMenu2(playerid);
	}
	return 1;
}
		
dcmd_savemenu(playerid, params[])
{
	if(sscanf(params, "s", FileName)) SendClientMessage(playerid, COLOR_RED, "/savemenu [file name]");
	else if(IsCreatingMenu[playerid] == false) return SendClientMessage(playerid, COLOR_RED, "Create menu first");
	else if(fexist(FileName)) return SendClientMessage(playerid, COLOR_RED, "File aleardy exists");
	else
	{
		SaveToFile(FileName);
		TogglePlayerControllable(playerid, true);
		IsCreatingMenu[playerid] = false;
		HideMenuForPlayer(createmenu, playerid);
		DestroyMenu(createmenu);
		new string[50];
		format(string, 50, "Menu Saved To File %s", FileName);
		SendClientMessage(playerid, COLOR_GREEN, string);
	}
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	new Menu:current = GetPlayerMenu(playerid);
	if(current == createmenu)
    {
		switch(row)
        {
			case 0:
			{
				ShowMenuForPlayer(modifymenu, playerid);
	            Item[0] = 1;
	        }
            case 1:
			{
				ShowMenuForPlayer(modifymenu, playerid);
	            Item[1] = 1;
	        }
	        case 2:
			{
				ShowMenuForPlayer(modifymenu, playerid);
	            Item[2] = 1;
	        }
	        case 3:
			{
				ShowMenuForPlayer(modifymenu, playerid);
	            Item[3] = 1;
	        }
	        case 4:
			{
				ShowMenuForPlayer(modifymenu, playerid);
	            Item[4] = 1;
	        }
	        case 5:
			{
				ShowMenuForPlayer(modifymenu, playerid);
	            Item[5] = 1;
	        }
	        case 6:
			{
				ShowMenuForPlayer(modifymenu, playerid);
	            Item[6] = 1;
	        }
	        case 7:
			{
				ShowMenuForPlayer(modifymenu, playerid);
	            Item[7] = 1;
	        }
	        case 8:
			{
				ShowMenuForPlayer(modifymenu, playerid);
	            Item[8] = 1;
	        }
	        case 9:
			{
				ShowMenuForPlayer(modifymenu, playerid);
	            Item[9] = 1;
	        }
	        case 10:
			{
				ShowMenuForPlayer(modifymenu, playerid);
	            Item[10] = 1;
	        }
	        case 11:
			{
				ShowMenuForPlayer(modifymenu, playerid);
	            Item[11] = 1;
	        }
	    }
	    return 1;
	}
	if(current == modifymenu)
	{
		switch(row)
		{
			case 0:
			{
				if(Item[0] == 1)
				{
					SendClientMessage(playerid, COLOR_GREEN, "Type item name");
					IsTypingItemName[playerid] = true;
				}
				else if(Item[1] == 1)
				{
					SendClientMessage(playerid, COLOR_GREEN, "Type item name");
					IsTypingItemName[playerid] = true;
				}
				else if(Item[2] == 1)
				{
					SendClientMessage(playerid, COLOR_GREEN, "Type item name");
					IsTypingItemName[playerid] = true;
				}
				else if(Item[3] == 1)
				{
					SendClientMessage(playerid, COLOR_GREEN, "Type item name");
					IsTypingItemName[playerid] = true;
				}
				else if(Item[4] == 1)
				{
					SendClientMessage(playerid, COLOR_GREEN, "Type item name");
					IsTypingItemName[playerid] = true;
				}
				else if(Item[5] == 1)
				{
					SendClientMessage(playerid, COLOR_GREEN, "Type item name");
					IsTypingItemName[playerid] = true;
				}
				else if(Item[6] == 1)
				{
					SendClientMessage(playerid, COLOR_GREEN, "Type item name");
					IsTypingItemName[playerid] = true;
				}
				else if(Item[7] == 1)
				{
					SendClientMessage(playerid, COLOR_GREEN, "Type item name");
					IsTypingItemName[playerid] = true;
				}
				else if(Item[8] == 1)
				{
					SendClientMessage(playerid, COLOR_GREEN, "Type item name");
					IsTypingItemName[playerid] = true;
				}
				else if(Item[9] == 1)
				{
					SendClientMessage(playerid, COLOR_GREEN, "Type item name");
					IsTypingItemName[playerid] = true;
				}
				else if(Item[10] == 1)
				{
					SendClientMessage(playerid, COLOR_GREEN, "Type item name");
					IsTypingItemName[playerid] = true;
				}
				else if(Item[11] == 1)
				{
					SendClientMessage(playerid, COLOR_GREEN, "Type item name");
					IsTypingItemName[playerid] = true;
				}
			}
		}
		return 1;
	}
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(IsSettingMenuPos[playerid] == true)
	{
		if(newkeys & KEY_JUMP)
		{
			if(MenuColumns == 1)
			{
	    		MenuPos[1] = MenuPos[1]-size;
	    		UpdateMenu(playerid);
	    	}
	    	else
	    	{
                MenuPos[1] = MenuPos[1]-size;
	    		UpdateMenu2(playerid);
	    	}
	    }
	    else if(newkeys & KEY_FIRE)
		{
			if(MenuColumns == 1)
			{
	    		MenuPos[1] = MenuPos[1]+size;
	    		UpdateMenu(playerid);
	    	}
	    	else
	    	{
                MenuPos[1] = MenuPos[1]+size;
	    		UpdateMenu2(playerid);
	    	}
	    }
	    else if(newkeys & KEY_ACTION)
		{
			if(MenuColumns == 1)
			{
	    		MenuPos[0] = MenuPos[0]+size;
	    		UpdateMenu(playerid);
	    	}
	    	else
	    	{
                MenuPos[0] = MenuPos[0]+size;
	    		UpdateMenu2(playerid);
	    	}
	    }
	    else if(newkeys & KEY_LOOK_BEHIND)
		{
			if(MenuColumns == 1)
			{
	    		MenuPos[0] = MenuPos[0]-size;
	    		UpdateMenu(playerid);
	    	}
	    	else
	    	{
                MenuPos[0] = MenuPos[0]-size;
	    		UpdateMenu2(playerid);
	    	}
	    }
	}
	if(IsSettingMenuWidth[playerid] == true)
	{
		if(newkeys & KEY_ACTION)
		{
			if(MenuColumns == 1)
			{
	    		MenuWidth = MenuWidth-size2;
	    		UpdateMenu(playerid);
	    	}
	    	else
	    	{
                MenuWidth = MenuWidth-size2;
	    		UpdateMenu2(playerid);
	    	}
	    }
	    if(newkeys & KEY_LOOK_BEHIND)
		{
			if(MenuColumns == 1)
			{
	    		MenuWidth = MenuWidth+size2;
	    		UpdateMenu(playerid);
	    	}
	    	else
	    	{
                MenuWidth = MenuWidth+size2;
	    		UpdateMenu2(playerid);
	    	}
	    }
	}
	return 1;
}

fcreate(filename[])
{
    if (fexist(filename)){return false;}
    new File:fhandle = fopen(filename,io_write);
    fclose(fhandle);
    return true;
}

sset(filename[], string[])
{
	if(!fexist(filename)) return 0;
	new stringz[256];
	new File:newfile = fopen(filename, io_append);
	format(stringz, 256, "%s\r\n", string);
	fwrite(newfile, stringz);
	fclose(newfile);
	return 1;
}



stock sscanf(string[], format[], {Float,_}:...)
{
	#if defined isnull
		if (isnull(string))
	#else
		if (string[0] == 0 || (string[0] == 1 && string[1] == 0))
	#endif
		{
			return format[0];
		}
	#pragma tabsize 4
	new
		formatPos = 0,
		stringPos = 0,
		paramPos = 2,
		paramCount = numargs(),
		delim = ' ';
	while (string[stringPos] && string[stringPos] <= ' ')
	{
		stringPos++;
	}
	while (paramPos < paramCount && string[stringPos])
	{
		switch (format[formatPos++])
		{
			case '\0':
			{
				return 0;
			}
			case 'i', 'd':
			{
				new
					neg = 1,
					num = 0,
					ch = string[stringPos];
				if (ch == '-')
				{
					neg = -1;
					ch = string[++stringPos];
				}
				do
				{
					stringPos++;
					if ('0' <= ch <= '9')
					{
						num = (num * 10) + (ch - '0');
					}
					else
					{
						return -1;
					}
				}
				while ((ch = string[stringPos]) > ' ' && ch != delim);
				setarg(paramPos, 0, num * neg);
			}
			case 'h', 'x':
			{
				new
					num = 0,
					ch = string[stringPos];
				do
				{
					stringPos++;
					switch (ch)
					{
						case 'x', 'X':
						{
							num = 0;
							continue;
						}
						case '0' .. '9':
						{
							num = (num << 4) | (ch - '0');
						}
						case 'a' .. 'f':
						{
							num = (num << 4) | (ch - ('a' - 10));
						}
						case 'A' .. 'F':
						{
							num = (num << 4) | (ch - ('A' - 10));
						}
						default:
						{
							return -1;
						}
					}
				}
				while ((ch = string[stringPos]) > ' ' && ch != delim);
				setarg(paramPos, 0, num);
			}
			case 'c':
			{
				setarg(paramPos, 0, string[stringPos++]);
			}
			case 'f':
			{
				setarg(paramPos, 0, _:floatstr(string[stringPos]));
			}
			case 'p':
			{
				delim = format[formatPos++];
				continue;
			}
			case '\'':
			{
				new
					end = formatPos - 1,
					ch;
				while ((ch = format[++end]) && ch != '\'') {}
				if (!ch)
				{
					return -1;
				}
				format[end] = '\0';
				if ((ch = strfind(string, format[formatPos], false, stringPos)) == -1)
				{
					if (format[end + 1])
					{
						return -1;
					}
					return 0;
				}
				format[end] = '\'';
				stringPos = ch + (end - formatPos);
				formatPos = end + 1;
			}
			case 'u':
			{
				new
					end = stringPos - 1,
					id = 0,
					bool:num = true,
					ch;
				while ((ch = string[++end]) && ch != delim)
				{
					if (num)
					{
						if ('0' <= ch <= '9')
						{
							id = (id * 10) + (ch - '0');
						}
						else
						{
							num = false;
						}
					}
				}
				if (num && IsPlayerConnected(id))
				{
					setarg(paramPos, 0, id);
				}
				else
				{
					#if !defined foreach
						#define foreach(%1,%2) for (new %2 = 0; %2 < MAX_PLAYERS; %2++) if (IsPlayerConnected(%2))
						#define __SSCANF_FOREACH__
					#endif
					string[end] = '\0';
					num = false;
					new
						name[MAX_PLAYER_NAME];
					id = end - stringPos;
					foreach (Player, playerid)
					{
						GetPlayerName(playerid, name, sizeof (name));
						if (!strcmp(name, string[stringPos], true, id))
						{
							setarg(paramPos, 0, playerid);
							num = true;
							break;
						}
					}
					if (!num)
					{
						setarg(paramPos, 0, INVALID_PLAYER_ID);
					}
					string[end] = ch;
					#if defined __SSCANF_FOREACH__
						#undef foreach
						#undef __SSCANF_FOREACH__
					#endif
				}
				stringPos = end;
			}
			case 's', 'z':
			{
				new
					i = 0,
					ch;
				if (format[formatPos])
				{
					while ((ch = string[stringPos++]) && ch != delim)
					{
						setarg(paramPos, i++, ch);
					}
					if (!i)
					{
						return -1;
					}
				}
				else
				{
					while ((ch = string[stringPos++]))
					{
						setarg(paramPos, i++, ch);
					}
				}
				stringPos--;
				setarg(paramPos, i, '\0');
			}
			default:
			{
				continue;
			}
		}
		while (string[stringPos] && string[stringPos] != delim && string[stringPos] > ' ')
		{
			stringPos++;
		}
		while (string[stringPos] && (string[stringPos] == delim || string[stringPos] <= ' '))
		{
			stringPos++;
		}
		paramPos++;
	}
	do
	{
		if ((delim = format[formatPos++]) > ' ')
		{
			if (delim == '\'')
			{
				while ((delim = format[formatPos++]) && delim != '\'') {}
			}
			else if (delim != 'z')
			{
				return delim;
			}
		}
	}
	while (delim > ' ');
	return 0;
}

UpdateMenu(playerid)
{
	HideMenuForPlayer(createmenu, playerid);
	DestroyMenu(createmenu);
	createmenu = CreateMenu(MenuHeader, MenuColumns, MenuPos[0], MenuPos[1], MenuWidth, MenuWidth);
	if(HeaderSet == 1) SetMenuColumnHeader(createmenu, 0, MenuColumnHeader);
	for(new i; i<ItemsAdded; i++)
	{
	    AddMenuItem(createmenu, 0, MenuItems[i]);
	}
	ShowMenuForPlayer(createmenu, playerid);
	return 1;
}

UpdateMenu2(playerid)
{
	HideMenuForPlayer(createmenu, playerid);
	DestroyMenu(createmenu);
	createmenu = CreateMenu(MenuHeader, MenuColumns, MenuPos[0], MenuPos[1], MenuWidth, MenuWidth);
	if(HeaderSet == 1) SetMenuColumnHeader(createmenu, 0, MenuColumnHeader);
	for(new i; i<ItemsAdded; i++)
	{
	   	AddMenuItem(createmenu, 0, MenuItems[i]);
	   	AddMenuItem(createmenu, 1, MenuItems2[i]);
	}
	ShowMenuForPlayer(createmenu, playerid);
	return 1;
}

SaveToFile(filename[])
{
	new filenamestring[50];
	format(filenamestring, 50, "%s.txt", filename);
	if(fexist(filenamestring))
	{
		return 0;
	}
	fcreate(filenamestring);
	new string[128];
	sset(filenamestring, "//After your includes/defines add");
	format(string, 128, "new Menu:%s;", MenuName);
	sset(filenamestring, string);
	sset(filenamestring, "    ");
	sset(filenamestring, "//OnGameModeInt()");
	format(string, 128, "%s = CreateMenu(\"%s\", %d, %f, %f, %f, %f);", MenuName, MenuHeader, MenuColumns, MenuPos[0], MenuPos[1], MenuWidth, MenuWidth);
	sset(filenamestring, string);
	for(new i; i<ItemsAdded; i++)
	{
		if(MenuColumns == 1)
		{
			format(string, 128, "AddMenuItem(%s, 0, \"%s\");", MenuName, MenuItems[i]);
			sset(filenamestring, string);
		}
		else
		{
            format(string, 128, "AddMenuItem(%s, 0, \"%s\");", MenuName, MenuItems[i]);
			sset(filenamestring, string);
			format(string, 128, "AddMenuItem(%s, 1, \"%s\");", MenuName, MenuItems2[i]);
			sset(filenamestring, string);
		}
	}
	sset(filenamestring, "    ");
	sset(filenamestring, "//Add This after OnPlayerSelectedMenuRow(playerid, row)");
	sset(filenamestring, "    new Menu:CurrentMenu = GetPlayerMenu(playerid);");
	format(string, 128, "    if(CurrentMenu == %s)", MenuName);
	sset(filenamestring, string);
	sset(filenamestring, "    {");
	sset(filenamestring, "        switch(row)");
	sset(filenamestring, "        {");
	for(new i; i<ItemsAdded; i++)
	{
		format(string, 128, "            case %d:", i);
		sset(filenamestring, string);
		sset(filenamestring, "            {");
		sset(filenamestring, "                //Your Code Here");
		sset(filenamestring, "            }");
	}
	sset(filenamestring, "        }");
	sset(filenamestring, "    }");
	sset(filenamestring, "    ");
	sset(filenamestring, "Menu was created with Scott's In-Game Menu filterscript.");
	sset(filenamestring, "Thanks for using it, www.sa-mp.lt.");
	return 1;
}