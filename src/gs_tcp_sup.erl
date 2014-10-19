-module(gs_tcp_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

-export([start_child/1, start_child/2, start_child/3,
         start_supervisor_child/1, start_supervisor_child/2,
         start_supervisor_child/3,
         start_restartable_child/1, start_restartable_child/2]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).
-define(SERVER, ?MODULE).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
    {ok, { {one_for_one, 5, 10}, []} }.



start_child(Mod) ->
    start_child(Mod, []).

start_child(Mod, Args) ->
    start_child(Mod, Mod, Args).

start_child(ChildId, Mod, Args) ->
    child_reply(supervisor:start_child(
                  ?SERVER,
                  {ChildId, {Mod, start_link, Args},
                   transient, 16#ffffffff, worker, [Mod]})).

start_supervisor_child(Mod) -> 
    start_supervisor_child(Mod, []).

start_supervisor_child(Mod, Args) -> 
    start_supervisor_child(Mod, Mod, Args).

start_supervisor_child(ChildId, Mod, Args) ->
    child_reply(supervisor:start_child(
                  ?SERVER,
                  {ChildId, {Mod, start_link, Args},
                   transient, infinity, supervisor, [Mod]})).

start_restartable_child(Mod) -> 
    start_restartable_child(Mod, []).

start_restartable_child(Mod, Args) ->
    Name = list_to_atom(atom_to_list(Mod) ++ "_sup"),
    child_reply(supervisor:start_child(
                  ?SERVER,
                  {Name, {restartable_sup, start_link,
                          [Name, {Mod, start_link, Args}]},
                   transient, infinity, supervisor, [restartable_sup]})).



child_reply({ok, _}) -> 
    ok;
child_reply(X) ->
    X.
