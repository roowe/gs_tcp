-ifndef(INTERNAL_HRL).
-define(INTERNAL_HRL,true).

-define(INFO_MSG, error_logger:info_msg).
-define(ERROR_MSG, error_logger:error_msg).


%% -define(PRINT(Format, Args),
%%     io:format("(~p:~p:~p) : " ++ Format,
%%               [self(), ?MODULE, ?LINE] ++ Args)).
-define(PRINT(Format, Args), ok).

-endif.
