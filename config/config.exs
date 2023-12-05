import Config

config :disbursements_api, ecto_repos: [DisbursementsApi.Repo]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
