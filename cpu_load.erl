%% Usage:
%%
%% 1> c(cpu_load).
%% 2> cpu_load:add_event_handler().
%% 3> event_handler:event(cpu, too_high).
%% 4> event_handler:event(cpu, unknown).
%%


-module(cpu_load).
-export([add_event_handler/0]).


add_event_handler() ->
    event_handler:add_handler(cpu, fun cpu_load/1).


cpu_load(too_high) ->
    io:format("Kill some processes~n");
cpu_load(X) ->
    io:format("~w ignored event: ~p~n", [?MODULE, X]).
