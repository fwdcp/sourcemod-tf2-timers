#include <sourcemod>
#include <sdktools>
#include <tf2>

new Handle:timelimit = INVALID_HANDLE;

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
	timelimit = FindConVar("mp_timelimt");
	
	if (timelimit == INVALID_HANDLE)
	{
		LogMessage("Could not find timelimit!");
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
	CreateNative("TF2Timers_GetStopwatchPoints", Native_GetStopwatchPoints);
	CreateNative("TF2Timers_GetStopwatchState", Native_GetStopwatchState);
	return APLRes_Success;
}

public Native_GetRoundTimer(Handle:plugin, numParams)
{
	new entity = -1;
	new Float:timeRemaining;
	
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
	new Float:timeRemaining;
	
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
	if (FindEntityByClassname(entity, "tf_logic_koth") == -1)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "map not KOTH");
	}
	
	new entity;
	new Float:timeRemaining;
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
	new Float:timeRemaining;
	
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

public Native_GetStopwatchTimeSet(Handle:plugin, numParams)
{
	if (!GameRules_GetProp("m_bStopWatch"))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "not in stopwatch mode");
	}
	
	new entity = FindTimer("zz_stopwatch_timer");
	new Float:timeSet;
	
	if (entity == -1)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "stopwatch timer not found");
	}
	else
	{
		timeSet = GetEntPropFloat(entity, Prop_Send, "m_flTotalTime");
	}
	
	return _:timeSet;
}

public Native_GetStopwatchPoints(Handle:plugin, numParams)
{
	if (!GameRules_GetProp("m_bStopWatch"))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "not in stopwatch mode");
	}
	
	new entity = -1;
	
	while ((entity = FindEntityByClassname(entity, "tf_objective_resource")) != -1)
	{
		new points = GetEntProp(entity, Prop_Send, "m_iNumControlPoints");
		
		return points;
	}
	
	if (entity == -1)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "stopwatch info not found");
	}
	
	return 0;
}

public Native_GetStopwatchState(Handle:plugin, numParams)
{
	new stopwatchState = GameRules_GetProp("m_nStopWatchState");
	return stopwatchState;
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

Float:GetTimeRemaining(entity)
{
	new Float:secondsRemaining;
	
	if (GetEntProp(entity, Prop_Send, "m_bTimerPaused"))
	{
		secondsRemaining = GetEntPropFloat(entity, Prop_Send, "m_flTimeRemaining");
	}
	else
	{
		secondsRemaining = GetEntPropFloat(entity, Prop_Send, "m_flTimerEndTime") - GetGameTime();
	}

	if (secondsRemaining < 0)
	{
		secondsRemaining = 0.0;
	}

	return secondsRemaining;
}