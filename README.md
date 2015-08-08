# Check whether _and why_ compound conditional expressions (do not) hold

Here's why this library is useful - instead of getting this in test results:

```
- - - - - - - - - - - - - - - - - - - - - - - - - -
example_SUITE:classic_test_invalid_element failed on line 25
Reason: {badmatch,false}
- - - - - - - - - - - - - - - - - - - - - - - - - -

Testing lavrin.conds.example_SUITE: *** FAILED test case 1 of 4 ***
```

You'll get this:

```
----------------------------------------------------
2015-08-08 15:52:02.140
example_SUITE:32 is_iq_with_ns_w_conds is false
because of [{false,{erlang,'==',[<<"jabber:iq:privacy">>,undefined]}}]


----------------------------------------------------
2015-08-08 15:52:02.140
example_SUITE:32 is_iq_w_conds is false
because of [{false,
                {example_SUITE,is_iq_with_ns_w_conds,
                    [<<"jabber:iq:privacy">>,
                     {xmlel,<<"iq">>,
                         [{<<"id">>,<<"123">>},
                          {<<"type">>,<<"error">>},
                          {<<"from">>,<<"xmpp.com">>},
                          {<<"to">>,<<"user@xmpp.com">>}],
                         [{xmlcdata,<<"  ">>},
                          {xmlel,<<"query">>,[],
                              [{xmlcdata,<<"    ">>},
                               {xmlel,<<"list">>,
                                   [{<<"name">>,<<"a-list">>}],
                                   []},
                               {xmlcdata,<<"  ">>}]},
                          {xmlcdata,<<"  ">>},
                          {xmlel,<<"error">>,[],
                              [{xmlcdata,<<"    ">>},
                               {xmlel,<<"item-not-found">>,[],[]},
                               {xmlcdata,<<"  ">>}]}]}]}}]


----------------------------------------------------
2015-08-08 15:52:02.141
example_SUITE:32 is_privacy_list_nonexistent_error_w_conds is false
because of [{false,
                {example_SUITE,is_iq_w_conds,
                    [<<"error">>,<<"jabber:iq:privacy">>,
                     {xmlel,<<"iq">>,
                         [{<<"id">>,<<"123">>},
                          {<<"type">>,<<"error">>},
                          {<<"from">>,<<"xmpp.com">>},
                          {<<"to">>,<<"user@xmpp.com">>}],
                         [{xmlcdata,<<"  ">>},
                          {xmlel,<<"query">>,[],
                              [{xmlcdata,<<"    ">>},
                               {xmlel,<<"list">>,
                                   [{<<"name">>,<<"a-list">>}],
                                   []},
                               {xmlcdata,<<"  ">>}]},
                          {xmlcdata,<<"  ">>},
                          {xmlel,<<"error">>,[],
                              [{xmlcdata,<<"    ">>},
                               {xmlel,<<"item-not-found">>,[],[]},
                               {xmlcdata,<<"  ">>}]}]}]}}]


- - - - - - - - - - - - - - - - - - - - - - - - - -
example_SUITE:test_w_conds_invalid_element failed on line 33
Reason: {badmatch,false}
- - - - - - - - - - - - - - - - - - - - - - - - - -

Testing lavrin.conds.example_SUITE: *** FAILED test case 3 of 4 ***
```

Have a look inside `test/example_SUITE.erl` to see how to use it.
