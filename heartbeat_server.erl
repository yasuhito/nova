-module( heartbeat_server ).
-export( [ start/0 ] ).


start() ->
    spawn( fun() -> main() end ).


main() ->
    process_flag( trap_exit, true ),
    lib_nova:spawn_all( "nova@hongo", 0, 10 ),
    loop( [] ).


loop( X ) ->
    receive
        { 'EXIT', SomePid, Reason } ->
            io:format( "EXIT ~p ~p~n", [ SomePid, Reason ] ),
            loop( X );
        Any ->
            io:format( "Received:~p~n", [ Any ] ),
            loop( X )
    end.
