%%%-------------------------------------------------------------------
%% @doc I²C based sensors public API
%% @end
%%%-------------------------------------------------------------------

-module(c3card_sensor).

-include_lib("kernel/include/logger.hrl").

-behaviour(gen_server).

-export([read_sensors/0,
         start_link/1]).

-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2]).

-define(SERVER, ?MODULE).

-type reading_type() :: humidity | relative_humidity | pressure | temperature.
-type reading() ::
	#{type => reading_type(),
	  data => float()}
      | #{error => Error :: term()}.

-type readings() :: [reading()].

-type sensors_option() ::
        {i2c_bus, I2CBus :: i2c_bus:i2c_bus()}
      | {sensors, [{Mod :: atom(), StartFun :: atom(), Args :: list()}]}.

-type sensors_config() :: [sensors_option()].

-export_type([sensors_config/0, readings/0]).

%% API

-spec read_sensors() -> {ok, readings()} | {error, Reason :: term()}.
read_sensors() ->
    gen_server:call(?SERVER, read_sensors).

-spec start_link(Config :: sensors_config()) -> gen_server:start_ret().
start_link(Config) ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, Config, []).

%% gen_server callbacks

%% @private
init(Config) ->
    I2CBus = proplists:get_value(i2c_bus, Config),
    Sensors = lists:map(fun({Mod, Fun, Args}) ->
                                case Mod:Fun(I2CBus, Args) of
                                    {ok, Pid} -> {Mod, Pid};
                                    Error -> throw({stop, {c3card_sensors, Mod, Error}})
                                end
                        end, proplists:get_value(sensors, Config)),
    ?LOG_NOTICE("starting sensors: ~p", [Sensors]),
    {ok, #{i2c_bus => I2CBus, sensors => Sensors}}.

%% @private
handle_call(read_sensors, _From, #{sensors := Sensors} = State) ->
    Readings0 = lists:map(fun({Mod, Pid}) ->
                                 case Mod:take_reading(Pid) of
                                     {ok, Reading} -> {Mod, Reading};
                                     {error, Reason} -> {Mod, Reason}
                                 end
                         end, Sensors),
    Readings = maps:map(fun deaggregate_reading/2, maps:from_list(Readings0)),
    {reply, {ok, Readings}, State};
handle_call(_Message, _From, State) ->
    {reply, ok, State}.

%% @private
handle_cast(_Message, State) ->
    {noreply, State}.

%% @private
handle_info(_Message, State) ->
    {noreply, State}.

%% internal functions

deaggregate_reading(bme280, {Temp, Pressure, Hum}) ->
    [
     #{type => humidity, data => Hum},
     #{type => pressure, data => Pressure},
     #{type => temperature, data => Temp}
    ];
deaggregate_reading(aht20, {Hum, Temp, RH}) ->
    [
     #{type => humidity, data => Hum},
     #{type => relative_humidity, data => RH},
     #{type => temperature, data => Temp}
    ];
deaggregate_reading(_Sensor, Error) ->
    [#{error => Error}].
