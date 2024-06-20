defmodule TimeSync.Http.Router do
  use AbHttp.Router
  alias TimeSync.Http.Controller

  get "/", Controller, :index
  post "/", Controller, :update
end
