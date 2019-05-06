defmodule TaskerWeb.Router do
  use TaskerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", TaskerWeb do
    pipe_through :api

    post "/sort", TaskController, :sort
    post "/bash", TaskController, :bash
  end
end
