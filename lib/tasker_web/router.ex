defmodule TaskerWeb.Router do
  use TaskerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", TaskerWeb do
    pipe_through :api
  end
end
