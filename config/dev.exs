import Config

config :disbursements_api, port: 8080

config :disbursements_api, DisbursementsApi.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("PGUSER"),
  password: System.get_env("PGPASSWORD"),
  database: System.get_env("PGDATABASE"),
  hostname: System.get_env("PGHOST"),
  port: System.get_env("PGPORT"),
  pool_size: 10
