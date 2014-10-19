-module(gs_tcp_tests).

-include_lib("eunit/include/eunit.hrl").
-define(MFA, {io, fwrite, [" It's running~n"]}).

%%%===================================================================
%%% Types
%%%===================================================================
cron_test_() ->
    {setup,
     fun() ->
             application:start(gs_tcp),
             echo_example_sup:start_link(),
             gs_tcp:listen(echo_example_sup, 8001, 2, [{packet, 2}, {backlog, 1024}, {send_timeout, 5000}]),
             gs_tcp:listen(echo_example_sup, 8002, 2, [{packet, 2}, {backlog, 1024}, {send_timeout, 5000}])
     end,
     fun(_) ->
             application:stop(gs_tcp)
     end,
     {with, [
             fun test_8001/1
            ]}}.

test_tcp(Port) ->
    {ok, Socket} = gen_tcp:connect("127.0.0.1", Port, [binary, {packet, 2}, {active, false}]),
    Msg = <<"hello world">>,
    gen_tcp:send(Socket, Msg),
    ?assertEqual({ok, Msg},  gen_tcp:recv(Socket, 0, 5000)),
    gen_tcp:close(Socket).

test_8001(_) ->
    test_tcp(8001).

test_8002(_) ->
    test_tcp(8002).
