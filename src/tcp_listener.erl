-module(tcp_listener).
-behaviour(gen_server).

-export([start_link/3]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
         code_change/3]).

-include("internal.hrl").

-record(state,{
          sock
         }).
 
start_link(Port, AcceptorCount, Opts) ->
    gen_server:start_link(?MODULE, [Port, AcceptorCount, Opts], []).
 
init([Port, AcceptorCount, ListenOpts]) ->
    ?INFO_MSG("Listen on port: ~p, AcceptorCount ~p~n", [Port, AcceptorCount]),
    process_flag(trap_exit, true),
    Opts = ListenOpts ++ [binary, 
                          {active, false},
                          {reuseaddr, true}],
    case gen_tcp:listen(Port, Opts) of
        {ok, LSock} ->             
            %% ?PRINT("~p~n", [prim_inet:getopts(LSock, [sndbuf, recbuf, packet, header, active, nodelay, keepalive, priority, tos,buffer,delay_send,packet_size,high_watermark, low_watermark,sndbuf])]),            
            ok = tcp_acceptor_sup:start_child(Port, LSock, AcceptorCount),
	        {ok, #state{sock = LSock}};
	    {error, Reason} ->
	        {stop, {cannot_listen, Port, Reason}}
    end.

handle_call(_Request, _From, State) ->
    {reply, State, State}.

handle_cast(_Msg, State) ->
    ?ERROR_MSG("Unknow cast ~p~n", [_Msg]),
    {noreply, State}.
 
handle_info(_Info, State) ->
    ?ERROR_MSG("Unknow info ~p~n", [_Info]),
    {noreply, State}.
 
terminate(_Reason, State) ->
    gen_tcp:close(State#state.sock),
    ?INFO_MSG("Sock ~p terminate~n", [State#state.sock]),
    ok.
 
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

