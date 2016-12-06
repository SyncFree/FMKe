%%%-------------------------------------------------------------------
%%% @author peter
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. Nov 2016 14:03
%%%-------------------------------------------------------------------
-module(antidote_pool).
-author("peter").

-behaviour(poolboy_worker).
-behaviour(supervisor).

%% API
-export([start/1, with_connection/1]).

%% Supervisor callbacks
-export([init/1]).

%% Poolboy callbacks
-export([start_link/1]).

-define(SERVER, ?MODULE).

%%%===================================================================
%%% API functions
%%%===================================================================

start(Options) ->
  supervisor:start_link({local, ?SERVER}, ?MODULE, [Options]).


with_connection(Fun) ->
  poolboy:transaction(antidote_connection_pool, Fun).


%%%===================================================================
%%% Supervisor callbacks
%%%===================================================================

init(_Options) ->
  AntidotePort = list_to_integer(fmk_config:get(antidote_port, "8087")),
  AntidoteAddress = fmk_config:get(antidote_address,'127.0.0.1'),
  PoolArgs = [
    {name, {local, antidote_connection_pool}},
    {worker_module, ?MODULE},
    {size, 15},
    {max_overflow, 0}
  ],
  WorkerArgs = [AntidoteAddress, AntidotePort],
  PoolSpec = poolboy:child_spec(antidote_connection_pool, PoolArgs, WorkerArgs),
  {ok, {{one_for_one, 10, 10}, [PoolSpec]}}.




start_link([Hostname, Port]) ->
  io:format("Connecting to ~p:~p~n", [Hostname, Port]),
  {ok, Pid} = antidotec_pb_socket:start_link(Hostname, Port),
  io:format("Connected to ~p:~p --> ~p ~n", [Hostname, Port, Pid]),
  {ok, Pid}.