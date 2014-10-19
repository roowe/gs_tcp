-module(tcp_listener_sup).

-behaviour(supervisor).

%% API
-export([
         start_link/4
        ]).
%% Supervisor callbacks
-export([init/1]).


-define(SERVER, ?MODULE).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================
start_link(Reader, Port, AcceptorCount, Opts) ->
    supervisor:start_link(?MODULE, [Reader, Port, AcceptorCount, Opts]).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([Reader, Port, AcceptorCount, Opts]) ->
    TCPAcceptorSup = 
        {tcp_acceptor_sup,
         {tcp_acceptor_sup, start_link, [Port, Reader]},
         transient,
         infinity,
         supervisor,
         [tcp_acceptor_sup]
        },
    TCPListener =
        {listener_sup,
         {tcp_listener, start_link, [Port, AcceptorCount, Opts]},
         transient,
         16#ffffffff,
         worker,
         [tcp_listener]
        },    
    {ok,
     {{one_for_one, 10, 10},
      [TCPAcceptorSup, TCPListener]
     }
    }.
