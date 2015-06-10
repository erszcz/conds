-module(conds_SUITE).
-compile([export_all]).

-include_lib("eunit/include/eunit.hrl").

-define(ae(Expected, Actual), ?assertEqual(Expected, Actual)).

all() ->
    [test_all,
     test_unwrap_all,
     test_all_with_unwrap,
     test_all_with_my_unwrap,
     test_any,
     test_unwrap_any,
     test_any_with_unwrap,
     test_any_with_my_unwrap].

%%
%% Tests
%%

test_all(_) ->
    ?ae({false, [{false, {?MODULE, is_asd, [qwe]}},
                 {false, {?MODULE, is_asd, [zxc]}}]},
        conds:all(conditions())).

test_unwrap_all(_) ->
    ?ae(false, conds:unwrap(conds:all(conditions()))).

test_all_with_unwrap(_) ->
    ?ae(false, conds:all(conditions(), [unwrap])).

test_all_with_my_unwrap(_) ->
    ?ae(false, conds:all(conditions(), [{unwrap, fun ?MODULE:my_unwrap/1}])),
    receive
        my_unwrap_got_called -> ok
    after 0 -> ct:fail(my_unwrap_never_got_called)
    end.

test_any(_) ->
    ?ae({true, [{true, {?MODULE, is_asd, [asd]}}]},
        conds:any(conditions())).

test_unwrap_any(_) ->
    ?ae(true, conds:unwrap(conds:any(conditions()))).

test_any_with_unwrap(_) ->
    ?ae(true, conds:any(conditions(), [unwrap])).

test_any_with_my_unwrap(_) ->
    ?ae(true, conds:any(conditions(), [{unwrap, fun ?MODULE:my_unwrap/1}])),
    receive
        my_unwrap_got_called -> ok
    after 0 -> ct:fail(my_unwrap_never_got_called)
    end.

%%
%% Helpers
%%

is_asd(asd) -> true;
is_asd(_) -> false.

my_unwrap({Result, _} = Wrapped) ->
    ct:pal("unwrapping ~p -> ~p", [Wrapped, Result]),
    self() ! my_unwrap_got_called,
    Result.

conditions() ->
    [{?MODULE, is_asd, [qwe]},
     {?MODULE, is_asd, [asd]},
     {?MODULE, is_asd, [zxc]},
     {?MODULE, is_asd, [asd]}].
