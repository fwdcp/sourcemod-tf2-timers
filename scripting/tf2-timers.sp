#include <sourcemod>
#include <sdktools>
#include <tf2>

public Plugin:myinfo =
{
	name = "TF2 Timers",
	author = "Forward Command Post",
	description = "A plugin exposing the various timers of TF2.",
	version = "0.1",
	url = "http://fwdcp.net/"
};

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	CreateNative("TF2Timers_GetRoundTimeRemaining", Native_GetRoundTimeRemaining);
	CreateNative("TF2Timers_GetMapTimeRemaining", Native_GetMapTimeRemaining);
	CreateNative("TF2Timers_GetKOTHTimeRemaining", Native_GetKOTHTimeRemaining);
	CreateNative("TF2Timers_GetStopwatchTimeSet", Native_GetStopwatchTimeSet);
	CreateNative("TF2Timers_GetStopwatchTimeRemaining", Native_GetStopwatchTimeRemaining);
	CreateNative("TF2Timers_GetStopwatchPoints", Native_GetStopwatchPoints);
	CreateNative("TF2Timers_GetStopwatchState", Native_GetStopwatchState);
	return APLRes_Success;
}

public Native_GetRoundTimeRemaining(Handle:plugin, numParams)
{
	new entity = -1;
	new Float:timeRemaining;
	
	while ((entity = FindEntityByClassname(entity, "team_round_timer")) != -1)
	{
		decl String:name[50];
		GetEntPropString(entity, Prop_Data, "m_iName", name, sizeof(name));
		
		if (GetEntProp(entity, Prop_Send, "m_bShowInHUD") && !GetEntProp(entity, Prop_Send, "m_bStopWatchTimer") && !StrEqual(name, "zz_red_koth_timer") && !StrEqual(name, "zz_blue_koth_timer"))
		{
			timeRemaining = GetTimeRemaining(entity);
				
			return _:timeRemaining;
		}
	}
	
	if (entity == -1)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "timer for map not found");
	}
	
	return _:timeRemaining;
}

public Native_GetMapTimeRemaining(Handle:plugin, numParams)
{
	new Float:timeRemaining;
	
	new entity = -1;
	
	while ((entity = FindEntityByClassname(entity, "team_round_timer")) != -1)
	{
		decl String:name[50];
		GetEntPropString(entity, Prop_Data, "m_iName", name, sizeof(name));
		
		if (StrEqual(name, "zz_teamplay_timelimit_timer"))
		{
			timeRemaining = GetTimeRemaining(entity);
				
			return _:timeRemaining;
		}
	}
	
	if (entity == -1)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "map timer not found");
	}
	
	return _:timeRemaining;
}

public Native_GetKOTHTimer(Handle:plugin, numParams)
{
	new Float:timeRemaining;
	
	new entity = -1;
	new TFTeam:team = TFTeam:GetNativeCell(1);
	
	if (team == TFTeam_Unassigned || team == TFTeam_Spectator)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "valid team not specified");
	}
	
	while ((entity = FindEntityByClassname(entity, "team_round_timer")) != -1)
	{
		decl String:name[50];
		GetEntPropString(entity, Prop_Data, "m_iName", name, sizeof(name));
		
		if (team == TFTeam_Red && StrEqual(name, "zz_red_koth_timer"))
		{
			timeRemaining = GetTimeRemaining(entity);
				
			return _:timeRemaining;
		}
		else if (team == TFTeam_Blue && StrEqual(name, "zz_blue_koth_timer"))
		{
			timeRemaining = GetTimeRemaining(entity);
				
			return _:timeRemaining;
		}
	}
	
	if (entity == -1)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "KOTH timer for team not found");
	}
	
	return _:timeRemaining;
}

public Native_GetStopwatchTimeSet(Handle:plugin, numParams)
{
	new Float:timeSet;
	
	if (!GameRules_GetProp("m_bStopWatch"))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "not in stopwatch mode");
	}
	
	new entity = -1;
	
	while ((entity = FindEntityByClassname(entity, "tf_objective_resource")) != -1)
	{
		new timer = GetEntPropEnt(entity, Prop_Send, "m_iStopWatchTimer");
		
		if (!IsValidEntity(timer))
		{
			ThrowNativeError(SP_ERROR_NATIVE, "stopwatch timer not found");
		}
		
		decl String:name[50];
		GetEntityClassname(entity, name, sizeof(name));
		
		if (!StrEqual(name, "team_round_timer") || !GetEntProp(timer, Prop_Send, "m_bStopWatchTimer"))
		{
			ThrowNativeError(SP_ERROR_NATIVE, "invalid stopwatch timer");
		}
		
		
		timeSet = GetEntPropFloat(entity, Prop_Send, "m_flTotalTime");
		
		return _:timeSet;
	}
	
	if (entity == -1)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "stopwatch info not found");
	}
	
	return _:timeSet;
}

public Native_GetStopwatchTimeRemaining(Handle:plugin, numParams)
{
	new Float:timeRemaining;
	
	if (!GameRules_GetProp("m_bStopWatch"))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "not in stopwatch mode");
	}
	
	new entity = -1;
	
	while ((entity = FindEntityByClassname(entity, "tf_objective_resource")) != -1)
	{
		new timer = GetEntPropEnt(entity, Prop_Send, "m_iStopWatchTimer");
		
		if (!IsValidEntity(timer))
		{
			ThrowNativeError(SP_ERROR_NATIVE, "stopwatch timer not found");
		}
		
		decl String:name[50];
		GetEntityClassname(entity, name, sizeof(name));
		
		if (!StrEqual(name, "team_round_timer") || !GetEntProp(timer, Prop_Send, "m_bStopWatchTimer"))
		{
			ThrowNativeError(SP_ERROR_NATIVE, "invalid stopwatch timer");
		}
		
		
		timeRemaining = GetTimeRemaining(entity);
		
		return _:timeRemaining;
	}
	
	if (entity == -1)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "stopwatch info not found");
	}
	
	return _:timeRemaining;
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