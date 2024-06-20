defmodule TimeSync.Application do
  use Application

  @impl Application
  def start(_start_type, _start_args) do
    TimeSync.Supervisor.start_link()
  end
end
