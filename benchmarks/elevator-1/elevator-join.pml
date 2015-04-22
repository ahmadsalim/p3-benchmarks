typedef features
{
    bool Determined;
    bool Empty;
    bool Exec;
    bool OpenIfIdle;
    bool Overload;
    bool Park;
    bool QuickClose;
    bool Shuttle;
    bool TTFull
};
 
features f;
 
typedef tPerson
{
    byte at_floor = 0;
    byte to_floor = 0;
    bool in_elevator = 0
};
 
typedef tButton
{
    bool pushed = false
};
 
tPerson person [2];
                   
tButton cabin_button [4];
                         
tButton floor_button [4];
                         
byte floor = 0;
               
mtype = { open, closed, up, down, stay };
 
mtype door = closed;
                    
mtype direction = stay;
 
active [2] proctype ptPersonDetermined ()
{
    if
        :: true -> if
                       :: person[_pid].at_floor = 0
                       :: person[_pid].at_floor = 1
                       :: person[_pid].at_floor = 2
                       :: person[_pid].at_floor = 3
                   fi;
                   do
                       :: atomic {
                                     floor_button[person[_pid].at_floor].pushed = true
                                 } -> if
                                          :: skip
                                          :: atomic {
                                                        ((floor) == (person[_pid].at_floor)) && ((door) == (open));
                                                        person[_pid].at_floor = 0;
                                                        person[_pid].in_elevator = true;
                                                        if
                                                            :: (floor) != (0) -> person[_pid].to_floor = 0
                                                            :: (floor) != (1) -> person[_pid].to_floor = 1
                                                            :: (floor) != (2) -> person[_pid].to_floor = 2
                                                            :: (floor) != (3) -> person[_pid].to_floor = 3
                                                        fi;
                                                        cabin_button[person[_pid].to_floor].pushed = true;
                                                        if
                                                            :: (door) == (closed) -> ((floor) == (person[_pid].to_floor)) && ((door) == (open));
                                                                                     person[_pid].at_floor = floor;
                                                                                     person[_pid].to_floor = 0;
                                                                                     person[_pid].in_elevator = false
                                                            :: timeout -> person[_pid].at_floor = floor;
                                                                          person[_pid].to_floor = 0;
                                                                          person[_pid].in_elevator = false
                                                        fi
                                                    }
                                      fi
                   od
        :: true -> if
                       :: person[_pid].at_floor = 0
                       :: person[_pid].at_floor = 1
                       :: person[_pid].at_floor = 2
                       :: person[_pid].at_floor = 3
                   fi;
                   do
                       :: skip
                       :: atomic {
                                     floor_button[person[_pid].at_floor].pushed = true
                                 } -> if
                                          :: skip
                                          :: atomic {
                                                        ((floor) == (person[_pid].at_floor)) && ((door) == (open));
                                                        person[_pid].in_elevator = true;
                                                        if
                                                            :: (floor) != (0) -> person[_pid].to_floor = 0
                                                            :: (floor) != (1) -> person[_pid].to_floor = 1
                                                            :: (floor) != (2) -> person[_pid].to_floor = 2
                                                            :: (floor) != (3) -> person[_pid].to_floor = 3
                                                        fi;
                                                        cabin_button[person[_pid].to_floor].pushed = true
                                                    } -> if
                                                             :: (door) == (closed)
                                                             :: atomic {
                                                                           timeout;
                                                                           assert ((door) == (open));
                                                                           person[_pid].at_floor = floor;
                                                                           person[_pid].to_floor = 0;
                                                                           person[_pid].in_elevator = false
                                                                       }
                                                         fi;
                                                         if
                                                             :: skip
                                                             :: atomic {
                                                                           if
                                                                               :: (person[_pid].at_floor) != (0) -> person[_pid].to_floor = 0
                                                                               :: (person[_pid].at_floor) != (1) -> person[_pid].to_floor = 1
                                                                               :: (person[_pid].at_floor) != (2) -> person[_pid].to_floor = 2
                                                                               :: (person[_pid].at_floor) != (3) -> person[_pid].to_floor = 3
                                                                           fi;
                                                                           cabin_button[person[_pid].to_floor].pushed = true
                                                                       }
                                                         fi;
                                                         do
                                                             :: skip
                                                             :: cabin_button[person[_pid].to_floor].pushed = true
                                                             :: atomic {
                                                                           ((floor) != (person[_pid].at_floor)) && ((door) == (open));
                                                                           person[_pid].at_floor = floor;
                                                                           person[_pid].to_floor = 0;
                                                                           person[_pid].in_elevator = false
                                                                       } -> break
                                                         od
                                      fi
                   od
    fi
};
 
bool progress = false;
                      
bool waiting = false;
 
active proctype controller ()
{
    bool stop = false;
    do
        :: progress = true -> progress = false;
                              if
                                  :: true -> stop = ((((person[0].in_elevator -> 1 : 0)) + ((person[1].in_elevator -> 1 : 0))) < (2) -> ((cabin_button[floor].pushed) || (floor_button[floor].pushed)) && (((floor) == (3)) || (! ((cabin_button[3].pushed) || (floor_button[3].pushed)))) : ((cabin_button[3].pushed) || (floor_button[3].pushed) -> (floor) == (3) : (cabin_button[floor].pushed) || ((floor_button[floor].pushed) && ((((person[0].in_elevator -> 1 : 0)) + ((person[1].in_elevator -> 1 : 0))) < (2)))))
                                  :: true -> stop = (cabin_button[floor].pushed) || ((floor_button[floor].pushed) && ((((person[0].in_elevator -> 1 : 0)) + ((person[1].in_elevator -> 1 : 0))) < (2)))
                                  :: true -> stop = ((cabin_button[floor].pushed) || (floor_button[floor].pushed)) && (((floor) == (3)) || (! ((cabin_button[3].pushed) || (floor_button[3].pushed))))
                                  :: true -> stop = (cabin_button[floor].pushed) || (floor_button[floor].pushed)
                              fi;
                              if
                                  :: atomic {
                                                stop;
                                                stop = false;
                                                door = open;
                                                cabin_button[floor].pushed = false;
                                                floor_button[floor].pushed = false;
                                                (((person[0].to_floor) != (floor)) || (! (person[0].in_elevator))) && (((person[1].to_floor) != (floor)) || (! (person[1].in_elevator)))
                                            } -> if
                                                     :: true -> do
                                                                    :: atomic {
                                                                                  (floor_button[floor].pushed) || (cabin_button[floor].pushed);
                                                                                  floor_button[floor].pushed = false;
                                                                                  cabin_button[floor].pushed = false;
                                                                                  waiting = true
                                                                              } -> waiting = false
                                                                    :: else -> break
                                                                od
                                                     :: true
                                                 fi;
                                                 if
                                                     :: true -> if
                                                                    :: atomic {
                                                                                  (floor) == (0);
                                                                                  waiting = true
                                                                              } -> atomic {
                                                                                              (((((((floor_button[0].pushed) || (cabin_button[0].pushed)) || (floor_button[1].pushed)) || (cabin_button[1].pushed)) || (floor_button[2].pushed)) || (cabin_button[2].pushed)) || (floor_button[3].pushed)) || (cabin_button[3].pushed);
                                                                                              waiting = false
                                                                                          }
                                                                    :: else -> if
                                                                                   :: true -> waiting = true;
                                                                                              atomic {
                                                                                                         (((((((floor_button[0].pushed) || (cabin_button[0].pushed)) || (floor_button[1].pushed)) || (cabin_button[1].pushed)) || (floor_button[2].pushed)) || (cabin_button[2].pushed)) || (floor_button[3].pushed)) || (cabin_button[3].pushed);
                                                                                                         waiting = false
                                                                                                     }
                                                                                   :: true
                                                                               fi
                                                                fi
                                                     :: true
                                                 fi;
                                                 atomic {
                                                            if
                                                                :: true -> (((person[0].in_elevator -> 1 : 0)) + ((person[1].in_elevator -> 1 : 0))) < (2)
                                                                :: true
                                                            fi;
                                                            cabin_button[floor].pushed = false;
                                                            floor_button[floor].pushed = false;
                                                            if
                                                                :: true -> if
                                                                               :: ((person[0].in_elevator) == (false)) && ((person[1].in_elevator) == (false)) -> cabin_button[0].pushed = false;
                                                                                                                                                                  cabin_button[1].pushed = false;
                                                                                                                                                                  cabin_button[2].pushed = false;
                                                                                                                                                                  cabin_button[3].pushed = false
                                                                               :: else
                                                                           fi
                                                                :: true
                                                            fi;
                                                            door = closed
                                                        }
                                  :: else -> skip
                              fi;
                              atomic {
                                         bool set = false;
                                         if
                                             :: true -> direction = ((floor) == (0) -> up : ((floor) == ((4) - (1)) -> down : direction));
                                                        set = true
                                             :: true
                                         fi;
                                         if
                                             :: true -> if
                                                            :: (! (set)) && ((cabin_button[3].pushed) || (floor_button[3].pushed)) -> direction = ((3) < (floor) -> down : ((3) > (floor) -> up : stay));
                                                                                                                                      set = true
                                                            :: else
                                                        fi
                                             :: true
                                         fi;
                                         if
                                             :: true -> if
                                                            :: (! (set)) && (! ((((((((floor_button[0].pushed) || (cabin_button[0].pushed)) || (floor_button[1].pushed)) || (cabin_button[1].pushed)) || (floor_button[2].pushed)) || (cabin_button[2].pushed)) || (floor_button[3].pushed)) || (cabin_button[3].pushed))) -> direction = ((0) < (floor) -> down : ((0) > (floor) -> up : stay));
                                                                                                                                                                                                                                                                                                                              set = true
                                                            :: else
                                                        fi
                                             :: true
                                         fi;
                                         if
                                             :: set -> set = false
                                             :: else -> direction = ((floor) == (0) -> up : ((floor) == ((4) - (1)) -> down : direction));
                                                        direction = (((((((floor) > (0)) && ((floor_button[0].pushed) || (cabin_button[0].pushed))) || (((floor) > (1)) && ((floor_button[1].pushed) || (cabin_button[1].pushed)))) || (((floor) > (2)) && ((floor_button[2].pushed) || (cabin_button[2].pushed)))) || (((floor) > (3)) && ((floor_button[3].pushed) || (cabin_button[3].pushed)))) && ((direction) == (down)) -> down : (((((((floor) < (0)) && ((floor_button[0].pushed) || (cabin_button[0].pushed))) || (((floor) < (1)) && ((floor_button[1].pushed) || (cabin_button[1].pushed)))) || (((floor) < (2)) && ((floor_button[2].pushed) || (cabin_button[2].pushed)))) || (((floor) < (3)) && ((floor_button[3].pushed) || (cabin_button[3].pushed)))) && ((direction) == (up)) -> up : ((((((floor) > (0)) && ((floor_button[0].pushed) || (cabin_button[0].pushed))) || (((floor) > (1)) && ((floor_button[1].pushed) || (cabin_button[1].pushed)))) || (((floor) > (2)) && ((floor_button[2].pushed) || (cabin_button[2].pushed)))) || (((floor) > (3)) && ((floor_button[3].pushed) || (cabin_button[3].pushed))) -> down : ((((((floor) < (0)) && ((floor_button[0].pushed) || (cabin_button[0].pushed))) || (((floor) < (1)) && ((floor_button[1].pushed) || (cabin_button[1].pushed)))) || (((floor) < (2)) && ((floor_button[2].pushed) || (cabin_button[2].pushed)))) || (((floor) < (3)) && ((floor_button[3].pushed) || (cabin_button[3].pushed))) -> up : stay))))
                                         fi;
                                         floor = ((direction) == (up) -> (floor) + (1) : ((direction) == (down) -> (floor) - (1) : floor))
                                     }
    od
};
 
