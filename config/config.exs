# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :tasker, TaskerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "P4AyZXu+KJxL0l1AZ/VsYbT6aI6/EHYLjgNa4uNBddomFN+o9N78P2/00xRGH3hC",
  render_errors: [view: TaskerWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Tasker.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
