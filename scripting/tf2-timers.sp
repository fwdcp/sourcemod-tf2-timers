#include <sourcemod>
#include <sdktools>
#include <tf2>
#include <tf2-timers>

new Handle:timelimit = INVALID_HANDLE;
new pointsSet;
new pointsRemaining;

public Plugin:myinfo =
{
	name = "TF2 Timers",
	author = "Forward Command Post",
	description = "A plugin exposing the various timers of TF2.",
	version = "0.1",
	url = "http://fwdcp.net/"
};

public OnPluginStart()
{
	timelimit = FindConVar("mp_timelimit");
	
	if (timelimit == INVALID_HANDLE)
	{
		LogMessage("Could not find timelimit!");
	}
	
	HookEvent("teamplay_round_start", Event_RoundStart);
	HookEvent("teamplay_point_captured", Event_PointCaptured);
	HookEvent("teamplay_round_win", Event_RoundWin);
}

public Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	new StopwatchState:swState = TF2Timers_GetStopwatchState();
	
	if (swState == StopwatchState_NotRunning)
	{
		pointsSet = 0;
		pointsRemaining = 0;
	}
	else if (swState == StopwatchState_Setting)
	{
		pointsSet = 0;
		pointsRemaining = 0;
	}
	else if (swState == StopwatchState_Beating)
	{
		pointsRemaining = pointsSet;
	}
}

public Event_PointCaptured(Handle:event, const String:name[], bool:dontBroadcast)
{
	new StopwatchState:swState = TF2Timers_GetStopwatchState();
	
	if (swState == StopwatchState_Setting)
	{
		pointsSet++;
	}
	else if (swState == StopwatchState_Beating)
	{
		pointsRemaining--;
	}
}

public Event_RoundWin(Handle:event, const String:name[], bool:dontBroadcast)
{
	new StopwatchState:swState = TF2Timers_GetStopwatchState();
	
	if (swState == StopwatchState_Setting)
	{
		if (TFTeam:GetEventInt(event, "team") == TFTeam_Blue && GetEventBool(event, "full_round"))
		{
			new entity = FindEntityByClassname(entity, "tf_objective_resource");
			
			pointsSet = GetEntProp(entity, Prop_Send, "m_iNumControlPoints");
		}
	}
	else if (swState == StopwatchState_Beating)
	{
		if (TFTeam:GetEventInt(event, "team") == TFTeam_Blue && GetEventBool(event, "full_round"))
		{
			new entity = FindEntityByClassname(entity, "tf_objective_resource");
			
			pointsRemaining = pointsSet - GetEntProp(entity, Prop_Send, "m_iNumControlPoints");
		}
	}
}

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	CreateNative("TF2Timers_GetRoundTimer", Native_GetRoundTimer);
	CreateNative("TF2Timers_GetMapTimer", Native_GetMapTimer);
	CreateNative("TF2Timers_GetKOTHTimer", Native_GetKOTHTimer);
	CreateNative("TF2Timers_GetStopwatchTimer", Native_GetStopwatchTimer);
	CreateNative("TF2Timers_AddTime", Native_AddTime);
	CreateNative("TF2Timers_SetTime", Native_AddTime);
	CreateNative("TF2Timers_GetTime", Native_GetTime);
	CreateNative("TF2Timers_GetStopwatchTimeSet", Native_GetStopwatchTimeSet);
	CreateNative("TF2Timers_GetStopwatchPointsSet", Native_GetStopwatchPointsSet);
	CreateNative("TF2Timers_GetStopwatchPointsRemaining", Native_GetStopwatchPointsRemaining);
	CreateNative("TF2Timers_GetStopwatchState", Native_GetStopwatchState);
	return APLRes_Success;
}

public Native_GetRoundTimer(Handle:plugin, numParams)
{
	new entity = -1;
	
	while ((entity = FindEntityByClassname(entity, "team_round_timer")) != -1)
	{
		decl String:name[50];
		GetEntPropString(entity, Prop_Data, "m_iName", name, sizeof(name));
		
		if (GetEntProp(entity, Prop_Send, "m_bShowInHUD") && !GetEntProp(entity, Prop_Send, "m_bStopWatchTimer") && !StrEqual(name, "zz_red_koth_timer") && !StrEqual(name, "zz_blue_koth_timer"))
		{
			return entity;
		}
	}
	
	if (entity == -1)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "timer for round not found");
	}
	
	return -1;
}

public Native_GetMapTimer(Handle:plugin, numParams)
{
	if (timelimit == INVALID_HANDLE)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "timelimit not found");
	}
	else if (GetConVarInt(timelimit) == 0)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "no timelimit");
	}
	
	new entity = FindTimer("zz_teamplay_timelimit_timer");
	
	if (entity == -1)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "map timer not found");
	}
	else
	{
		return entity;
	}
	
	return -1;
}

public Native_GetKOTHTimer(Handle:plugin, numParams)
{
	if (FindEntityByClassname(-1, "tf_logic_koth") == -1)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "map not KOTH");
	}
	
	new entity;
	new TFTeam:team = TFTeam:GetNativeCell(1);
	
	if (team == TFTeam_Unassigned || team == TFTeam_Spectator)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "valid team not specified");
	}
	else if (team == TFTeam_Red)
	{
		entity = FindTimer("zz_red_koth_timer");
	}
	else if (team == TFTeam_Blue)
	{
		entity = FindTimer("zz_blue_koth_timer");
	}
	
	if (entity == -1)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "KOTH timer for team not found");
	}
	else
	{
		return entity;
	}
	
	return -1;
}

public Native_GetStopwatchTimer(Handle:plugin, numParams)
{
	if (!GameRules_GetProp("m_bStopWatch"))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "not in stopwatch mode");
	}
	
	new entity = FindTimer("zz_stopwatch_timer");
	
	if (entity == -1)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "stopwatch timer not found");
	}
	else
	{
		return entity;
	}
	
	return -1;
}

public Native_AddTime(Handle:plugin, numParams)
{
	new timer = GetNativeCell(1);
	new time = GetNativeCell(2);
	new TFTeam:team = TFTeam:GetNativeCell(3);
	
	if (!IsValidEntity(timer))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "invalid entity");
	}
	
	decl String:entityClass[255];
	GetEntityClassname(timer, entityClass, sizeof(entityClass));
	
	if (!StrEqual(entityClass, "team_round_timer"))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "entity not a timer");
	}
	
	if (team == TFTeam_Red)
	{
		decl String:input[255];
		Format(input, sizeof(input), "%i %i", 2, time);
		SetVariantString(input);
		AcceptEntityInput(timer, "AddTeamTime");
	}
	else if (team == TFTeam_Blue)
	{
		decl String:input[255];
		Format(input, sizeof(input), "%i %i", 3, time);
		SetVariantString(input);
		AcceptEntityInput(timer, "AddTeamTime");
	}
	else
	{
		SetVariantInt(time);
		AcceptEntityInput(timer, "AddTime");
	}
	
	return;
}

public Native_GetTime(Handle:plugin, numParams)
{
	new timer = GetNativeCell(1);
	
	if (!IsValidEntity(timer))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "invalid entity");
	}
	
	decl String:entityClass[255];
	GetEntityClassname(timer, entityClass, sizeof(entityClass));
	
	if (!StrEqual(entityClass, "team_round_timer"))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "entity not a timer");
	}
	
	new Float:secondsRemaining;
	
	if (GetEntProp(timer, Prop_Send, "m_bTimerPaused"))
	{
		secondsRemaining = GetEntPropFloat(timer, Prop_Send, "m_flTimeRemaining");
	}
	else
	{
		secondsRemaining = GetEntPropFloat(timer, Prop_Send, "m_flTimerEndTime") - GetGameTime();
	}

	if (secondsRemaining < 0)
	{
		secondsRemaining = 0.0;
	}

	return _:secondsRemaining;
}

public Native_SetTime(Handle:plugin, numParams)
{
	new timer = GetNativeCell(1);
	new time = GetNativeCell(2);
	
	if (!IsValidEntity(timer))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "invalid entity");
	}
	
	decl String:entityClass[255];
	GetEntityClassname(timer, entityClass, sizeof(entityClass));
	
	if (!StrEqual(entityClass, "team_round_timer"))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "entity not a timer");
	}
	
	SetVariantInt(time);
	AcceptEntityInput(timer, "SetTime");
	
	return;
}

public Native_GetStopwatchTimeSet(Handle:plugin, numParams)
{
	if (!GameRules_GetProp("m_bStopWatch"))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "not in stopwatch mode");
	}
	
	new timer = GetNativeCell(1);
	
	if (!IsValidEntity(timer))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "invalid entity");
	}
	
	decl String:entityClass[255];
	GetEntityClassname(timer, entityClass, sizeof(entityClass));
	
	if (!StrEqual(entityClass, "team_round_timer"))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "entity not a timer");
	}
	
	new Float:timeSet = GetEntPropFloat(timer, Prop_Send, "m_flTotalTime");
	
	return _:timeSet;
}

public Native_GetStopwatchPointsSet(Handle:plugin, numParams)
{
	new StopwatchState:swState = TF2Timers_GetStopwatchState();
	
	if (swState == StopwatchState_NotRunning)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "not in stopwatch mode");
	}
	
	return pointsSet;
}

public Native_GetStopwatchPointsRemaining(Handle:plugin, numParams)
{
	new StopwatchState:swState = TF2Timers_GetStopwatchState();
	
	if (swState != StopwatchState_Beating)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "not in stopwatch beating mode");
	}
	
	return pointsRemaining;
}

public Native_GetStopwatchState(Handle:plugin, numParams)
{
	if (!GameRules_GetProp("m_bStopWatch"))
	{
		return _:StopwatchState_NotRunning;
	}
	
	new timer = TF2Timers_GetStopwatchTimer();
	
	if (GetEntProp(timer, Prop_Send, "m_bInCaptureWatchState"))
	{
		return _:StopwatchState_Setting;
	}
	else
	{
		return _:StopwatchState_Beating;
	}
}

FindTimer(const String:desiredName[255])
{
	new entity = -1;
	
	while ((entity = FindEntityByClassname(entity, "team_round_timer")) != -1)
	{
		decl String:timerName[255];
		GetEntPropString(entity, Prop_Data, "m_iName", timerName, sizeof(timerName));
		
		if (StrEqual(timerName, desiredName))
		{
			return entity;
		}
	}
	
	return -1;
}