defmodule TimeSync.Http.Controller do
  import AbHttp.Connection

  def index(conn, _opts) do
    append_response(conn, document())
    |> add_header("Content-Type", "text/html")
  end

  def update(conn, %{"time" => time}) do
    {time, ""} = Integer.parse(time)
    TimeSync.Sync.Server.set_time(time)
    append_response(conn, document())
    |> add_header("Content-Type", "text/html")
  end

  defp document do
    time = TimeSync.Sync.Server.get_time()
    |> DateTime.from_unix!()
    |> DateTime.to_iso8601()
    """
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="utf-8">
        </head>
        <body>
          <p>Server time: #{time}</p>
          <div>
            <h2>Update</h2>
            <form method="post">
              <input name="time">
              <input type="submit">
            </form>
          </div>
        </body>
      </html>
    """
  end
end
