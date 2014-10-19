-module(echo_example_sup).

-behaviour(supervisor).

%% API
-export([
         start_link/0      
        ]).

-export([start_reader/1]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%% ===================================================================
%% API functions
%% ===================================================================
start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

start_reader(Sock) ->
    supervisor:start_child(?MODULE, [Sock]).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
    %% for child
    {ok,
     {{simple_one_for_one, 10, 10},
      [
       %% TCP Client
       {undefined,
        {echo_example, start_link, []},
        temporary,
        16#ffffffff,
        worker,
        [tcp_client_handler]
       }
      ]
     }
    }.

