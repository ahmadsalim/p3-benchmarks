#define readCommand (readMsg == commandMsg)
#define readAlarm (readMsg == alarmMsg)
#define readLevel (readMsg == levelMsg)
#define userStart (uwants == start)
#define userStop (uwants == stop)
#define highWater (waterLevel == high)
#define mediumWater (waterLevel == medium)
#define lowWater (waterLevel == low)
#define stateReady (pstate == ready)
#define stateRunning (pstate == running)
#define stateStopped (pstate == stopped)
#define stateMethanestop (pstate == methanestop)
#define stateLowstop (pstate == lowstop)

typedef features {
	bool Start;
	bool Stop;
 	bool MethaneAlarm;
 	bool MethaneQuery;
	bool Low;
	bool Normal;
	bool High
}

features f;

mtype = {stop, start, alarm, low, medium, high, ready, running, stopped, methanestop, lowstop, commandMsg, alarmMsg, levelMsg}

chan cCmd = [0] of {mtype}; 	/* stop, start			*/
chan cAlarm = [0] of {mtype}; 	/* alarm                */
chan cMethane = [0] of {mtype}; /* methanestop, ready   */
chan cLevel = [0] of {mtype}; 	/* low, medium, high    */

mtype pstate = stopped; 		/* ready, running, stopped, methanestop, lowstop */
mtype readMsg = commandMsg; 		/* commandMsg, alarmMsg, levelMsg */

bool pumpOn = false;
bool methane = false;
mtype waterLevel = medium;

mtype uwants = stop; 			/* what the user wants */

active proctype controller() {
	mtype pcommand = start;
	mtype level = medium;
	
	do	::	atomic {
				cCmd?pcommand;
				readMsg = commandMsg; 
			};
			if	::	pcommand == stop;
					if	::	true;
							if	::	atomic {
										pstate == running;
										pumpOn = false;
									}
								::	else -> skip;
								fi;
							pstate = stopped;
						::	else -> skip;
						fi;
				::	pcommand == start;
					if	::	true;
							if	::	atomic {
										pstate != running;
										pstate = ready;
									};
								::	else -> skip;
								fi;
						::	else -> skip;
						fi;
				::	else -> assert(false);
				fi;
			cCmd!pstate;
			
		::	atomic { 
				cAlarm?_;
				readMsg = alarmMsg;
			};
			if	::	false;
					if	::	atomic {
								pstate == running;
								pumpOn = false;
							};
						::	else -> skip;
						fi;
					pstate = methanestop;	
				::	else -> skip;
				fi;
			
		::	atomic { 
				cLevel?level;
				readMsg = levelMsg;
			};
			if	::	level == high;
					if	::	false;
							/* The same block with and without race condition.
							   First, without race condition: */
							if	::	pstate == ready  ||  pstate == lowstop;
									if	::	true;
											skip;
											atomic {
												cMethane!pstate;
												cMethane?pstate;
												if	::	pstate == ready;
														pstate = running;
														pumpOn = true;
													::	else -> skip;
												fi;
											};
										::	else;
											skip;
											atomic {
												pstate = running;
												pumpOn = true;
											};
										fi;
								::	else -> skip;
								fi;
							/* Here, with race condition: (only for testing)
							if	::	pstate == ready  ||  pstate == lowstop;
									if	::	true;
											cMethane!pstate;
											cMethane?pstate;
										::	else;
											pstate = ready;
										fi;
									if	::	atomic {
												pstate == ready;
												pstate = running;
												pumpOn = true;
											};
										::	else -> skip;
									fi;
								::	else -> skip;
								fi;
								*/
						::	else -> skip;
						fi;
				::	level == low;
					if	::	true;
							if	::	atomic {
										pstate == running;
										pumpOn = false;
										pstate = lowstop;
									};
								::	else -> skip;
								fi;
						::	else -> skip;
						fi;
				::	level == medium;
					skip;
				fi;
		od;
}

active proctype user() {
	do	::	if	::	uwants = start;
				::	uwants = stop;
				fi;
			cCmd!uwants;
			cCmd?_;			/* Sends back the state; ignore it */
		od;
}

active proctype methanealarm() {
	do	:: 	methane = true;
			cAlarm!alarm;
		::	methane = false;
		od;
}

active proctype methanesensor() {
	do	:: 	atomic {
				cMethane?_;
				if	::	methane;
						cMethane!methanestop;
					::	!methane;
						cMethane!ready;
					fi;
			};
		od;
}

active proctype watersensor() {
	do	:: 	atomic {
				if	::	waterLevel == low ->
						if	:: waterLevel = low;
							:: waterLevel = medium;
							fi;
					::	waterLevel == medium ->
						if	:: waterLevel = low;
							:: waterLevel = medium;
							:: waterLevel = high;
							fi;
					::	waterLevel == high ->
						if	:: waterLevel = medium;
							:: waterLevel = high;
							fi;
					fi;
				cLevel!waterLevel;
			};
		od;
};

never  {    /* !((([]<> readCommand) && ([]<> readAlarm) && ([]<> readLevel)) -> !(<>[](pumpOn && methane))) */
T0_init:
	do
	:: ((pumpOn && methane) && (readAlarm) && (readCommand) && (readLevel)) -> goto accept_S6655
	:: ((pumpOn && methane) && (readAlarm) && (readCommand)) -> goto T3_S6655
	:: ((pumpOn && methane) && (readAlarm)) -> goto T2_S6655
	:: ((pumpOn && methane)) -> goto T0_S6655
	:: (1) -> goto T0_init
	od;
accept_S6655:
	do
	:: ((pumpOn && methane)) -> goto T0_S6655
	od;
T3_S6655:
	do
	:: ((pumpOn && methane) && (readLevel)) -> goto accept_S6655
	:: ((pumpOn && methane)) -> goto T3_S6655
	od;
T2_S6655:
	do
	:: ((pumpOn && methane) && (readCommand) && (readLevel)) -> goto accept_S6655
	:: ((pumpOn && methane) && (readCommand)) -> goto T3_S6655
	:: ((pumpOn && methane)) -> goto T2_S6655
	od;
T0_S6655:
	do
	:: ((pumpOn && methane) && (readAlarm) && (readCommand) && (readLevel)) -> goto accept_S6655
	:: ((pumpOn && methane) && (readAlarm) && (readCommand)) -> goto T3_S6655
	:: ((pumpOn && methane) && (readAlarm)) -> goto T2_S6655
	:: ((pumpOn && methane)) -> goto T0_S6655
	od;
}
