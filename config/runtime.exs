import Config

{my_port, ""} = System.get_env("MY_PORT") |> Integer.parse()
config :time_sync, :my_port, my_port

{http_port, ""} = System.get_env("HTTP_PORT") |> Integer.parse()
config :time_sync, :http_port, http_port

others = System.get_env("OTHERS")
|> String.split(",")
|> Enum.map(fn host ->
  [host, port] = String.split(host, ":")
  {:ok, {:hostent, _, _, _, _, [address | _]}} = :inet.gethostbyname(to_charlist(host))
  {port, ""} = Integer.parse(port)
  {address, port}
end)

config :time_sync, :others, others
