defmodule TimeSync.Supervisor do
  use Supervisor

  def start_link(opts \\ []), do: Supervisor.start_link(__MODULE__, opts)

  @impl Supervisor
  def init(_init_arg) do
    children = [
      TimeSync.Http.Supervisor,
      TimeSync.Sync.Server
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
