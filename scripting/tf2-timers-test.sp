#include <sourcemod>
#include <sdktools>
#include <tf2-timers>
#include <tf2>

public Plugin:myinfo =
{
	name = "TF2 Timers Test",
	author = "Forward Command Post",
	description = "A plugin testing the TF2 Timers plugin.",
	version = "0.1",
	url = "http://fwdcp.net/"
};

public OnPluginStart()
{
	RegConsoleCmd("sm_timers_find", GetAllTimers, "a command to find all timers in a map");
	RegConsoleCmd("sm_timers_round", RoundTime, "a command that works with the round time remaining");
	RegConsoleCmd("sm_timers_map", MapTime, "a command that works the map time remaining");
	RegConsoleCmd("sm_timers_koth", KOTHTime, "a command that works the KOTH time remaining for a team");
	RegConsoleCmd("sm_timers_sw_timerem", GetStopwatchTimeRemaining, "a command that gets the stopwatch time remaining");
	RegConsoleCmd("sm_timers_sw_timeset", GetStopwatchTimeSet, "a command that gets the stopwatch time set");
	RegConsoleCmd("sm_timers_sw_pointsrem", GetStopwatchPointsRemaining, "a command that gets the stopwatch points remaining");
	RegConsoleCmd("sm_timers_sw_pointsset", GetStopwatchPointsSet, "a command that gets the stopwatch points set");
	RegConsoleCmd("sm_timers_sw_state", GetStopwatchState, "a command that gets the state of the stopwatch");
}

public Action:GetAllTimers(client, args)
{
	new entity = -1;
	
	while ((entity = FindEntityByClassname(entity, "team_round_timer")) != -1)
	{
		decl String:name[50];
		GetEntPropString(entity, Prop_Data, "m_iName", name, sizeof(name));
		
		ReplyToCommand(client, "Timer: %s", name);
	}
	
	return Plugin_Handled;
}

public Action:RoundTime(client, args)
{
	decl String:action[50];
	
	if (args < 1)
	{
		action = "get";
	}
	else
	{
		GetCmdArg(1, action, sizeof(action));
	}
	
	if (StrEqual(action, "get", false))
	{
		new Float:time = TF2Timers_GetTime(TF2Timers_GetRoundTimer());
		
		ReplyToCommand(client, "Round time: %f", time);
	}
	else if (StrEqual(action, "add", false))
	{
		decl String:time[50];
		GetCmdArg(2, time, sizeof(time));
		
		decl String:teamName[50];
		GetCmdArg(3, teamName, sizeof(teamName));
		
		new TFTeam:team = TFTeam_Unassigned;
		
		if (StrEqual(teamName, "blu", false) || StrEqual(teamName, "blue", false) || TFTeam:StringToInt(teamName) == TFTeam_Blue)
		{
			team = TFTeam_Blue;
		}
		else if (StrEqual(teamName, "red", false) || TFTeam:StringToInt(teamName) == TFTeam_Red)
		{
			team = TFTeam_Red;
		}
		
		TF2Timers_AddTime(TF2Timers_GetRoundTimer(), StringToInt(time), team);
		
		ReplyToCommand(client, "Round time added: %i", StringToInt(time));
	}
	else if (StrEqual(action, "set", false))
	{
		decl String:time[50];
		GetCmdArg(2, time, sizeof(time));
		
		TF2Timers_SetTime(TF2Timers_GetRoundTimer(), StringToInt(time));
		
		ReplyToCommand(client, "Round time set: %i", StringToInt(time));
	}
	
	return Plugin_Handled;
}

public Action:MapTime(client, args)
{
	decl String:action[50];
	
	if (args < 1)
	{
		action = "get";
	}
	else
	{
		GetCmdArg(1, action, sizeof(action));
	}
	
	if (StrEqual(action, "get", false))
	{
		new Float:time = TF2Timers_GetTime(TF2Timers_GetMapTimer());
		
		ReplyToCommand(client, "Map time: %f", time);
	}
	else if (StrEqual(action, "add", false))
	{
		decl String:time[50];
		GetCmdArg(2, time, sizeof(time));
		
		decl String:teamName[50];
		GetCmdArg(3, teamName, sizeof(teamName));
		
		new TFTeam:team = TFTeam_Unassigned;
		
		if (StrEqual(teamName, "blu", false) || StrEqual(teamName, "blue", false) || TFTeam:StringToInt(teamName) == TFTeam_Blue)
		{
			team = TFTeam_Blue;
		}
		else if (StrEqual(teamName, "red", false) || TFTeam:StringToInt(teamName) == TFTeam_Red)
		{
			team = TFTeam_Red;
		}
		
		TF2Timers_AddTime(TF2Timers_GetMapTimer(), StringToInt(time), team);
		
		ReplyToCommand(client, "Map time added: %i", StringToInt(time));
	}
	else if (StrEqual(action, "set", false))
	{
		decl String:time[50];
		GetCmdArg(2, time, sizeof(time));
		
		TF2Timers_SetTime(TF2Timers_GetMapTimer(), StringToInt(time));
		
		ReplyToCommand(client, "Map time set: %i", StringToInt(time));
	}
	
	return Plugin_Handled;
}

public Action:KOTHTime(client, args)
{
	decl String:teamName[50];
	GetCmdArg(1, teamName, sizeof(teamName));
	
	new TFTeam:team = TFTeam_Unassigned;
	
	if (StrEqual(teamName, "blu", false) || StrEqual(teamName, "blue", false) || TFTeam:StringToInt(teamName) == TFTeam_Blue)
	{
		team = TFTeam_Blue;
	}
	else if (StrEqual(teamName, "red", false) || TFTeam:StringToInt(teamName) == TFTeam_Red)
	{
		team = TFTeam_Red;
	}
		
	decl String:action[50];
	
	if (args < 2)
	{
		action = "get";
	}
	else
	{
		GetCmdArg(2, action, sizeof(action));
	}
	
	if (StrEqual(action, "get", false))
	{
		new Float:time = TF2Timers_GetTime(TF2Timers_GetKOTHTimer(team));
		
		ReplyToCommand(client, "Map time: %f", time);
	}
	else if (StrEqual(action, "add", false))
	{
		decl String:time[50];
		GetCmdArg(3, time, sizeof(time));
		
		decl String:blameTeamName[50];
		GetCmdArg(4, blameTeamName, sizeof(blameTeamName));
		
		new TFTeam:blameTeam = TFTeam_Unassigned;
		
		if (StrEqual(blameTeamName, "blu", false) || StrEqual(blameTeamName, "blue", false) || TFTeam:StringToInt(blameTeamName) == TFTeam_Blue)
		{
			blameTeam = TFTeam_Blue;
		}
		else if (StrEqual(blameTeamName, "red", false) || TFTeam:StringToInt(blameTeamName) == TFTeam_Red)
		{
			blameTeam = TFTeam_Red;
		}
		
		TF2Timers_AddTime(TF2Timers_GetKOTHTimer(team), StringToInt(time), blameTeam);
		
		ReplyToCommand(client, "Map time added: %i", StringToInt(time));
	}
	else if (StrEqual(action, "set", false))
	{
		decl String:time[50];
		GetCmdArg(3, time, sizeof(time));
		
		TF2Timers_SetTime(TF2Timers_GetKOTHTimer(team), StringToInt(time));
		
		ReplyToCommand(client, "KOTH time set: %i", StringToInt(time));
	}
	
	return Plugin_Handled;
}

public Action:GetStopwatchTimeRemaining(client, args)
{
	new Float:time = TF2Timers_GetTime(TF2Timers_GetStopwatchTimer());
	
	ReplyToCommand(client, "Stopwatch time remaining: %f", time);
	
	return Plugin_Handled;
}

public Action:GetStopwatchTimeSet(client, args)
{
	new Float:time = TF2Timers_GetStopwatchTimeSet(TF2Timers_GetStopwatchTimer());
	
	ReplyToCommand(client, "Stopwatch time set: %f", time);
	
	return Plugin_Handled;
}

public Action:GetStopwatchPointsRemaining(client, args)
{
	new points = TF2Timers_GetStopwatchPointsRemaining();
	
	ReplyToCommand(client, "Stopwatch points remaining: %f", points);
	
	return Plugin_Handled;
}

public Action:GetStopwatchPointsSet(client, args)
{
	new points = TF2Timers_GetStopwatchPointsSet();
	
	ReplyToCommand(client, "Stopwatch points set: %f", points);
	
	return Plugin_Handled;
}

public Action:GetStopwatchState(client, args)
{
	new StopwatchState:swState = TF2Timers_GetStopwatchState();
	
	if (swState == StopwatchState_NotRunning)
	{
		ReplyToCommand(client, "Stopwatch status: not running");
	}
	else if (swState == StopwatchState_Setting)
	{
		ReplyToCommand(client, "Stopwatch status: setting");
	}
	else if (swState == StopwatchState_Beating)
	{
		ReplyToCommand(client, "Stopwatch status: beating");
	}
	
	return Plugin_Handled;
}