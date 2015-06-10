-module(conds).

-export([all/1, all/2,
         any/1, any/2,
         unwrap/1]).

%%
%% API
%%

all(Conditions) ->
    all(Conditions, []).

all(Conditions, Opts) ->
    do(fun product/2, {true, []}, Conditions, Opts).

any(Conditions) ->
    any(Conditions, []).

any(Conditions, Opts) ->
    do(fun sum/2, {false, []}, Conditions, Opts).

unwrap({Boolean, _}) -> Boolean.

%%
%% Helpers
%%

do(Step, Acc, Conditions, Opts) ->
    {Result, Premises} = lists:foldl(Step, Acc, Conditions),
    case proplists:lookup(unwrap, Opts) of
        none -> {Result, lists:reverse(Premises)};
        {unwrap, Unwrap} when is_function(Unwrap, 1) ->
            Unwrap({Result, lists:reverse(Premises)});
        {unwrap, true} -> Result
    end.

product({M, F, Args} = Condition, {Result, Premises}) ->
    This = erlang:apply(M, F, Args),
    {This andalso Result, if
                              This -> Premises;
                              not This -> [{This, Condition} | Premises]
                          end}.

sum(_, {true, Premises}) ->
    {true, Premises};
sum({M, F, Args} = Condition, {false, Premises}) ->
    This = erlang:apply(M, F, Args),
    {This, if
               This -> [{This, Condition} | Premises];
               not This -> Premises
           end}.
