-module(heartbeat_server).
-export([start/0, rpc/2]).


start() ->
    process_flag(trap_exit, true),
    spawn( fun() -> loop( [] ) end ).


rpc( Pid, Request ) ->
    Pid ! { self(), Request },
    receive
        { Pid, Response } ->
            Response
    end.


loop( X ) ->
    receive
        { From, spawn } ->
            From ! { self(), lib_nova:spawn_all( "nova@hongo", 0, 10 ) },
            loop( X );
        { 'EXIT', SomePid, Reason } ->
            io:format( "EXIT ~p ~p~n", [SomePid, Reason] ),
            loop( X );
        Any ->
            io:format( "Received:~p~n", [Any] ),
            loop( X )
    end.
