-module (fmk_config).
-include ("fmk.hrl").
-export ([
    get/2,
    get_env/2,
    set/2
]).

get(Key, Default) ->
    mochiglobal:get(Key, Default).

get_env(Key, Default) ->
    application:get_env(?APP, Key, Default).

set(Key, Value) ->
    application:set_env(?APP, Key, Value),
    mochiglobal:put(Key, Value).