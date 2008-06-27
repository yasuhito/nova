%% commonly used routines.


-module( lib_nova ).
-export( [ spawn_all/3, ping_all/3, node_list/3 ] ).


node_list( Name, From, To ) ->
    [ list_to_atom( string:concat( Name, X ) ) || X <- seq_str( From, To ) ].


seq_str( From, To ) ->
    L = lists:seq( From, To ),
    [ string:concat( "00", integer_to_list( X ) ) || X <- L, X < 10 ]
        ++ [ string:concat( "0", integer_to_list( X ) ) || X <- L, X >= 10, X < 100 ]
        ++ [ integer_to_list( X ) || X <- L, X >= 100, X < 1000 ].


spawn_all( Name, From, To ) ->
    lists:foreach( fun( X ) ->
                           spawn( X, fun plain_server:start/0 )
                   end,
                   node_list( Name, From, To ) ).


ping_all( Name, From, To ) ->
    lists:foreach( fun( X ) ->
                           spawn( fun() -> ping( X ) end )
                   end,
                   node_list( Name, From, To ) ).


ping( Node ) ->
    io:format( "~p~n", [ Node ] ),
    net_adm:ping( Node ).
