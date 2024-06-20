defmodule TimeSync.Http.Endpoint do
  use AbHttp.Plug.Builder
  require Logger

  plug TimeSync.Http.Router
  plug :log

  def log(%AbHttp.Connection{method: method, path: path, resp_status: status} = conn, _opts) do
    Logger.info("#{method} #{path} #{status}")
    conn
  end
end
