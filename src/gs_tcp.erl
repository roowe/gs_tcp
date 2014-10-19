-module(gs_tcp).

-export([listen/4]).

-include("internal.hrl").
%% {packet, 2}, 
%% {header, 11},
%% {backlog, 1024},            
%% {send_timeout, 5000}
listen(Reader, Port, AcceptorCount, Opts) ->
    gs_tcp_sup:start_supervisor_child(tcp_listener_sup, [Reader, Port, AcceptorCount, Opts]).
%% gs_tcp:listen(echo_example_sup, 8001, 2, [{packet, 2}, {backlog, 1024}, {send_timeout, 5000}]).

