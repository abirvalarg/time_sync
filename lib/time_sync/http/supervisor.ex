defmodule TimeSync.Http.Supervisor do
  use Supervisor

  def start_link(opts \\ []), do: Supervisor.start_link(__MODULE__, opts)

  @impl Supervisor
  def init(_init_arg) do
    children = [
      AbHttp.HandlerSupervisor,
      {AbHttp.Server.Tcp, endpoint: TimeSync.Http.Endpoint, ip: :loopback, port: Application.get_env(:time_sync, :http_port)}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
