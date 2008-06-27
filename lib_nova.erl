%% commonly used routines.


-module(lib_nova).
-export([ping/0]).


ping() ->
    net_adm:ping(nova@hongo000).
