-module(example_SUITE).
-compile([export_all]).

-type stanza_type() :: binary().
-type namespace() :: binary().

-include_lib("exml/include/exml_stream.hrl").

-define(NS_PRIVACY, <<"jabber:iq:privacy">>).

-define(VERBOSE_UNWRAP, true).

all() ->
    [classic_test_invalid_element,
     classic_test_valid_element,
     test_w_conds_invalid_element,
     test_w_conds_valid_element].

%%
%% Tests
%%

classic_test_invalid_element(_) ->
    put(debug, {?MODULE, ?LINE}),
    false = is_privacy_list_nonexistent_error(invalid_iq_error()).

classic_test_valid_element(_) ->
    put(debug, {?MODULE, ?LINE}),
    true = is_privacy_list_nonexistent_error(valid_iq_error()).

test_w_conds_invalid_element(_) ->
    put(debug, {?MODULE, ?LINE}),
    false = is_privacy_list_nonexistent_error_w_conds(invalid_iq_error()).

test_w_conds_valid_element(_) ->
    put(debug, {?MODULE, ?LINE}),
    true = is_privacy_list_nonexistent_error_w_conds(valid_iq_error()).

%%
%% Helpers
%%

invalid_iq_error() ->
    {ok, El} = exml:parse(<<"<iq id='123' type='error' "
                            "    from='xmpp.com' to='user@xmpp.com'>"
                            "  <query>"
                            "    <list name='a-list'/>"
                            "  </query>"
                            "  <error>"
                            "    <item-not-found/>"
                            "  </error>"
                            "</iq>">>),
    El.

valid_iq_error() ->
    {ok, El} = exml:parse(<<"<iq id='123' type='error' "
                            "    from='xmpp.com' to='user@xmpp.com'>"
                            "  <query xmlns='jabber:iq:privacy'>"
                            "    <list name='a-list'/>"
                            "  </query>"
                            "  <error>"
                            "    <item-not-found/>"
                            "  </error>"
                            "</iq>">>),
    El.

-spec is_privacy_list_nonexistent_error(xmlterm()) -> boolean().
is_privacy_list_nonexistent_error(Stanza) ->
    is_iq(<<"error">>, ?NS_PRIVACY, Stanza)
    andalso
    has_path(Stanza, [{element, <<"query">>},
                      {element, <<"list">>},
                      {attr, <<"name">>}])
    andalso
    has_path(Stanza, [{element, <<"error">>},
                      {element, <<"item-not-found">>}]).

-spec is_privacy_list_nonexistent_error_w_conds(xmlterm()) -> boolean().
is_privacy_list_nonexistent_error_w_conds(Stanza) ->
    Cs = [{?MODULE, is_iq_w_conds, [<<"error">>, ?NS_PRIVACY, Stanza]},
          {?MODULE, has_path, [Stanza, [{element, <<"query">>},
                                        {element, <<"list">>},
                                        {attr, <<"name">>}]]},
          {?MODULE, has_path, [Stanza, [{element, <<"error">>},
                                        {element, <<"item-not-found">>}]]}],
    Unwrap = mk_verbose_unwrap(is_privacy_list_nonexistent_error_w_conds),
    conds:all(Cs, [{unwrap, Unwrap}]).

-ifdef(VERBOSE_UNWRAP).
mk_verbose_unwrap(Predicate) ->
    fun ({true = Boolean, _Conds}) -> Boolean;
        ({false = Boolean, Conds}) ->
            {Mod, Line} = get(debug),
            ct:pal("~p:~p ~p is ~p~nbecause of ~p",
                   [Mod, Line, Predicate, Boolean, Conds]),
            Boolean
    end.
-else.
mk_verbose_unwrap(_) ->
    fun ({Boolean, _Conds}) -> Boolean end.
-endif.

-spec is_iq(stanza_type(), namespace(), xmlterm()) -> boolean().
is_iq(Type, NS, Stanza) ->
    is_iq_with_ns(NS, Stanza)
    andalso
    has_type(Type, Stanza).

-spec is_iq_w_conds(stanza_type(), namespace(), xmlterm()) -> boolean().
is_iq_w_conds(Type, NS, Stanza) ->
    Cs = [{?MODULE, is_iq_with_ns_w_conds, [NS, Stanza]},
          {?MODULE, has_type, [Type, Stanza]}],
    conds:all(Cs, [{unwrap, mk_verbose_unwrap(is_iq_w_conds)}]).

-spec is_iq_with_ns(namespace(), xmlterm()) -> boolean().
is_iq_with_ns(NS, Stanza) ->
    is_iq(Stanza)
    andalso
    NS == exml_query:path(Stanza, [{element, <<"query">>},
                                   {attr, <<"xmlns">>}]).

-spec is_iq_with_ns_w_conds(namespace(), xmlterm()) -> boolean().
is_iq_with_ns_w_conds(NS, Stanza) ->
    Cs = [{?MODULE, is_iq, [Stanza]},
          {erlang, '==', [NS, exml_query:path(Stanza, [{element, <<"query">>},
                                                       {attr, <<"xmlns">>}])]}],
    conds:all(Cs, [{unwrap, mk_verbose_unwrap(is_iq_with_ns_w_conds)}]).

-spec is_iq(xmlterm()) -> boolean().
is_iq(#xmlel{name = <<"iq">>}) ->
    true;
is_iq(_) ->
    false.

-spec has_path(xmlterm(), exml_query:path()) -> boolean().
has_path(Stanza, Path) ->
    exml_query:path(Stanza, Path) /= undefined.

-spec has_type(stanza_type() | undefined, xmlterm()) -> boolean().
has_type(undefined, Stanza) ->
    undefined == exml_query:attr(Stanza, <<"type">>);
has_type(Type, Stanza) ->
    Type == exml_query:attr(Stanza, <<"type">>).
