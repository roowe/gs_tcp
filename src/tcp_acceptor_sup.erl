-module(tcp_acceptor_sup).
-behaviour(supervisor).

-export([
         start_link/2
        ]).

-export([
         init/1
        ]).

-export([
         start_child/3
        ]).

start_link(Port, Reader) ->
    supervisor:start_link({local, acceptor_sup(Port)}, ?MODULE, [Reader]).

acceptor_sup(Port) ->
    list_to_atom("acceptor_sup_" ++ integer_to_list(Port)).

start_child(Port, LSock, Count) ->
    start_child2(acceptor_sup(Port), LSock, Count).

start_child2(_AcceptorSup, _LSock, Count) 
  when Count =< 0 ->
    ok;
start_child2(AcceptorSup, LSock, Count) ->
    {ok, _APid} = supervisor:start_child(AcceptorSup, [LSock]),
    start_child2(AcceptorSup, LSock, Count-1).


init([Reader]) ->
    {ok, {{simple_one_for_one, 10, 10},
          [{tcp_acceptor, {tcp_acceptor, start_link, [Reader]},
            transient, brutal_kill, worker, [tcp_acceptor]}]}}.
