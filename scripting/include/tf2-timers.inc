#if defined _tf2_timers_included_
  #endinput
#endif
#define _tf2_timers_included_
 
/**
 * Gets the main map timer.
 *
 * @return		The time remaining.
 * @error		Game mode does not have timer.	
 */
native Float:TF2Timers_GetMainTimer();

/**
 * Gets the KOTH timer for a team.
 *
 * @param team	The team to return the KOTH timer for.
 * @return		The time remaining.
 * @error		Invalid team, or KOTH not current game mode.	
 */
native Float:TF2Timers_GetKOTHTimer(TFTeam:team);

/**
 * Gets the time set for the stopwatch.
 *
 * @return		The time set.
 * @error		Stopwatch not enabled.
 */
native Float:TF2Timers_GetStopwatchTimeSet();

/**
 * Gets the time remaining.
 *
 * @return		The time remaining.
 * @error		Stopwatch not enabled.
 */
native Float:TF2Timers_GetStopwatchTimeRemaining();

/**
 * Gets the number of points captured/remaining for the stopwatch.
 *
 * @return		The number of points captured/remaining.
 * @error		Stopwatch not enabled.
 */
native TF2Timers_GetStopwatchPoints();

/**
 * Gets the current state of the stopwatch.
 *
 * @return		The state of the stopwatch.
 */
native TF2Timers_GetStopwatchState();