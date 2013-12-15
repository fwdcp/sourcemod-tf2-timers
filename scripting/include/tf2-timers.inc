#if defined _tf2_timers_included_
  #endinput
#endif
#define _tf2_timers_included_

enum StopwatchState
{
	StopwatchState_NotRunning,	/** stopwatch not running */
	StopwatchState_Setting,		/** stopwatch time being set by attacking team */
	StopwatchState_Beating			/** stopwatch time being beaten by attacking team */
}

/**
 * Gets the main round timer.
 *
 * @return		The timer.
 * @error		Game mode does not have timer.	
 */
native TF2Timers_GetRoundTimer();
 
/**
 * Gets the main map timer.
 *
 * @return		The timer.
 * @error		Map does not have timer.	
 */
native TF2Timers_GetMapTimer();

/**
 * Gets the KOTH timer for a team.
 *
 * @param team	The team to return the KOTH timer for.
 * @return		The timer.
 * @error		Invalid team, or KOTH not current game mode.	
 */
native TF2Timers_GetKOTHTimer(TFTeam:team);

/**
 * Gets the stopwatch timer.
 *
 * @return		The timer.
 * @error		Stopwatch not enabled.
 */
native TF2Timers_GetStopwatchTimer();

/**
 * Adds time to the timer.
 *
 * @param timer	The timer to add the time to.
 * @param time	The amount of time to add (in seconds).
 * @param team	The team to credit the time to (usually only for Attack/Defend, set to TFTeam_Blue).
 * @noreturn
 * @error		Timer not valid.
 */
native Float:TF2Timers_AddTime(timer, time, TFTeam:team);

/**
 * Gets the time remaining on the timer.
 *
 * @param timer	The timer to get the time for.
 * @return		The time (in seconds).
 * @error		Timer not valid.
 */
native Float:TF2Timers_GetTime(timer);

/**
 * Sets the time remaining on the timer.
 *
 * @param timer	The timer to set the time for.
 * @param time	The time to set the timer to (in seconds).
 * @noreturn	
 * @error		Timer not valid.
 */
native Float:TF2Timers_SetTime(timer, time);

/**
 * Gets the time set for the stopwatch timer.
 *
 * @param timer	The stopwatch timer.
 * @return		The time set (in seconds).
 * @error		Stopwatch not enabled.
 */
native Float:TF2Timers_GetStopwatchTimeSet(timer);

/**
 * Gets the number of points set for the stopwatch.
 *
 * @return		The number of points set.
 * @error		Stopwatch not enabled.
 */
native TF2Timers_GetStopwatchPointsSet();

/**
 * Gets the number of points remaining for the stopwatch.
 *
 * @return		The number of points remaining.
 * @error		Stopwatch not enabled.
 */
native TF2Timers_GetStopwatchPointsRemaining();

/**
 * Gets the current state of the stopwatch.
 *
 * @return		The state of the stopwatch.
 */
native StopwatchState:TF2Timers_GetStopwatchState();