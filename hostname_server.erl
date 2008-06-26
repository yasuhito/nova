%% ホスト名を返すサーバ
%% plain_server と合わせて使うつもりの物。
%%
%% 使用例:
%% 
%% 1> Pid = plain_server:start().
%% <0.33.0>
%% 2> Pid ! {become, fun hostname_server:loop/0}.
%% {become,#Fun<hostname_server.loop.0>}
%% 3> plain_server:rpc(Pid,hostname).
%% "yasuhito-takamiya-no-macbook.local"
%%

-module(hostname_server).
-export([loop/0, hostname/0]).


loop() ->
    receive{From, hostname} ->
	    From ! {self(), hostname()},
	    loop();
	   {become, Something} ->
	    Something()
    end.


hostname() ->
    string:strip(os:cmd("hostname"), right, $\n).
