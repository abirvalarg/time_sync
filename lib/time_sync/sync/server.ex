defmodule TimeSync.Sync.Server do
  use GenServer
  require Logger

  defstruct [:seconds, :socket, :sync_token, :sync_time, :random_id, time_svn: 0]

  def start_link(arg), do: GenServer.start_link(__MODULE__, arg, name: __MODULE__)

  def get_time, do: GenServer.call(__MODULE__, :get)
  def set_time(time), do: GenServer.cast(__MODULE__, {:set, time})

  @impl GenServer
  def init(_init_arg) do
    start_time = DateTime.to_unix(DateTime.utc_now())

    {:ok, socket} = :gen_udp.open(Application.get_env(:time_sync, :my_port), ip: :any, reuseaddr: true, mode: :binary, active: true)

    Process.send_after(self(), :count, 1_000)
    Process.send_after(self(), :sync, 10_000)
    {:ok, %__MODULE__{seconds: start_time, socket: socket, random_id: generate_random_id()}}
  end

  @impl GenServer
  def handle_call(:get, _from, state) do
    {:reply, state.seconds, state}
  end

  @impl GenServer
  def handle_cast({:set, new_time}, %__MODULE__{time_svn: svn, random_id: id} = state) do
    {:noreply, %__MODULE__{state | seconds: new_time, time_svn: svn + id}}
  end

  @impl GenServer
  def handle_info(:count, %__MODULE__{seconds: seconds} = state) do
    Process.send_after(self(), :count, 1_000)
    {:noreply, %__MODULE__{state | seconds: seconds + 1}}
  end

  def handle_info(:sync, state) do
    Process.send_after(self(), :sync, 10_000)
    token = :rand.bytes(8)
    payload = token <> "SYNC" <> <<state.time_svn::integer-little-size(32), state.seconds::integer-little-size(64)>>
    dest = Enum.random(Application.get_env(:time_sync, :others))
    Logger.info("Trying to sync with #{inspect(dest)}")
    :gen_udp.send(state.socket, dest, payload)
    {:noreply, %__MODULE__{state | sync_token: token, sync_time: state.seconds}}
  end

  def handle_info({:udp, socket, _ip, _port, <<token::binary-size(8)>> <> "RESP" <> <<time_svn::integer-little-size(32), time::little-integer-size(64)>>}, %__MODULE__{socket: socket, sync_token: token} = state) do
    delta = state.seconds - state.sync_time
    time = trunc(time + delta / 2)
    Logger.info("Synchronized to #{time} seconds")
    {:noreply, %__MODULE__{state | seconds: time, time_svn: time_svn}}
  end

  def handle_info({:udp, socket, _ip, _port, <<token::binary-size(8)>> <> "YOUR"}, %__MODULE__{socket: socket, sync_token: token} = state) do
    Logger.info("Other server has less relevant time")
    {:noreply, state}
  end

  def handle_info({:udp, socket, ip, port, <<token::binary-size(8)>> <> "SYNC" <> <<other_svn::integer-little-size(32), other_time::integer-little-size(64)>>}, state) do
    if state.time_svn >= other_svn do
      :gen_udp.send(socket, ip, port, token <> "RESP" <> <<state.time_svn::integer-little-size(32), state.seconds::little-integer-size(64)>>)
      {:noreply, state}
    else
      :gen_udp.send(socket, ip, port, token <> "YOUR")
      {:noreply, %__MODULE__{state| seconds: other_time, time_svn: other_svn}}
    end
  end

  def handle_info({:udp, _, _, _, data}, state) do
    Logger.debug("Weird payload: #{inspect(data)}")
    {:noreply, state}
  end

  defp generate_random_id do
    <<id::integer-size(8)>> = :rand.bytes(1)
    if id != 0 do
      id
    else
      generate_random_id()
    end
  end
end
