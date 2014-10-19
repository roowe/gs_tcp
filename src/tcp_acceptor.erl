-module(tcp_acceptor).
-behaviour(gen_server).

-export([start_link/2]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-include("internal.hrl").

-record(state, {
          reader,
          sock,
          ref
         }).

start_link(Reader, LSock) ->
    gen_server:start_link(?MODULE, [Reader, LSock], []).

init([Reader, LSock]) ->
    gen_server:cast(self(), accept),
    {ok, #state{
            reader = Reader,
            sock = LSock
           }}.

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(accept, State) ->
    accept(State);

handle_cast(_Msg, State) ->
    ?ERROR_MSG("Unknow cast ~p~n", [_Msg]),
    {noreply, State}.

handle_info({inet_async, LSock, Ref, {ok, Sock}}, 
            #state{
               reader = Reader,
               sock = LSock, 
               ref = Ref
              } = State) ->
    %% patch up the socket so it looks like one we got from
    %% gen_tcp:accept/1
    %% comment from rmq
    {ok, Mod} = inet_db:lookup_socket(LSock),
    inet_db:register_socket(Sock, Mod),
    case start_client(Reader, Sock) of
        ok ->
            ok;
        failed ->
            gen_tcp:close(Sock)
    end,       
    accept(State);

handle_info({inet_async, LSock, Ref, {error, Reason}}, State=#state{sock=LSock, ref=Ref}) ->
    case Reason of
        closed -> 
            {stop, normal, State}; %% listening socket closed
        econnaborted -> 
            accept(State); %% client sent RST before we accepted
        _  -> 
            {stop, {accept_failed, Reason}, State}
    end;

handle_info(_Info, State) ->
    ?ERROR_MSG("Unknow info ~p~n", [_Info]),
    {noreply, State}.

terminate(_Reason, _State) ->    
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


accept(#state{
          sock = LSock
         } = State) ->
    case prim_inet:async_accept(LSock, -1) of
        {ok, Ref} -> 
            {noreply, State#state{
                        ref=Ref
                       }};
        Error -> 
            {stop, {cannot_accept, Error}, State}
    end.

%% 开启客户端服务
start_client(Reader, Sock) ->
    %% ?PRINT("~p~n", [prim_inet:getopts(Sock, [sndbuf, recbuf,packet, header, active, nodelay, keepalive, priority, tos,buffer,delay_send,packet_size,high_watermark, low_watermark,sndbuf,exit_on_close,send_timeout])]),
    case catch Reader:start_reader(Sock) of
        {ok, Pid} ->
            ?PRINT("reader ~p~n", [Pid]),
            case gen_tcp:controlling_process(Sock, Pid) of
                ok ->
                    ok;
                {error, Error} ->
                    ?ERROR_MSG("controlling_process ~p~n", [Error]),
                    failed
            end;
        Other ->
            ?ERROR_MSG("start_client ~p~n", [Other]),
            failed
    end.

