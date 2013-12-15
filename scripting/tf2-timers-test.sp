#include <sourcemod>
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
	RegConsoleCmd("sm_timers_main", GetMainTimer, "a command that gets the main timer of the map");
	RegConsoleCmd("sm_timers_koth", GetKOTHTimer, "a command that gets the KOTH timer for a team");
	RegConsoleCmd("sm_timers_sw_set", GetStopwatchTimeSet, "a command that gets the time set on the stopwatch");
	RegConsoleCmd("sm_timers_sw_remaining", GetStopwatchTimeRemaining, "a command that gets the time remaining on the stopwatch");
	RegConsoleCmd("sm_timers_sw_points", GetStopwatchPoints, "a command that gets the number of points on the stopwatch");
	RegConsoleCmd("sm_timers_sw_state", GetStopwatchState, "a command that gets the state of the stopwatch");
}

public Action:GetMainTimer(client, args)
{
	new Float:time = TF2Timers_GetMainTimer();
	
	ReplyToCommand(client, "Main time: %f", time);
	return Plugin_Handled;
}

public Action:GetKOTHTimer(client, args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "Need to specify team!");
		return Plugin_Handled;
	}
	
	decl String:teamName[50];
	GetCmdArg(1, teamName, sizeof(teamName));
	
	new TFTeam:team = TFTeam_Unassigned;
	
	if (StrEqual(teamName, "blu", false) || StrEqual(teamName, "blu", false) || TFTeam:StringToInt(teamName) == TFTeam_Blue)
	{
		team = TFTeam_Blue;
	}
	else if (StrEqual(teamName, "red", false) || TFTeam:StringToInt(teamName) == TFTeam_Red)
	{
		team = TFTeam_Red;
	}
	else
	{
		ReplyToCommand(client, "Invalid team!");
		return Plugin_Handled;
	}
	
	new Float:time = TF2Timers_GetKOTHTimer(team);
	
	ReplyToCommand(client, "Timer for team %i: %f", team, time);
	return Plugin_Handled;
}

public Action:GetStopwatchTimeSet(client, args)
{
	new Float:time = TF2Timers_GetStopwatchTimeSet();
	
	ReplyToCommand(client, "Time set: %f", time);
	return Plugin_Handled;
}

public Action:GetStopwatchTimeRemaining(client, args)
{
	new Float:time = TF2Timers_GetStopwatchTimeRemaining();
	
	ReplyToCommand(client, "Time remaining: %f", time);
	return Plugin_Handled;
}

public Action:GetStopwatchPoints(client, args)
{
	new points = TF2Timers_GetStopwatchPoints();
	
	ReplyToCommand(client, "Points: %i", points);
	return Plugin_Handled;
}

public Action:GetStopwatchState(client, args)
{
	new swstate = TF2Timers_GetStopwatchState();
	
	ReplyToCommand(client, "State: %i", swstate);
}